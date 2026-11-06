function step_out = eeg_prep03_untilica(subj_id, cfg, paths, helpers)
% EEG_PREP03_UNTILICA
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
%
% Preprocess continuous EEG until ICA preparation.
%
% Outputs:
%   (1) *_preica.set : continuous pipeline dataset for downstream steps
%   (2) *_forica.set : ICA-training-only dataset

%       Also stores a summary of rejected and remaining training epochs.
%   (3) Summary CSV under qc/03_ica_training/, if enabled in the config.
%
% Input preference:
%   A) Step 02 output: *_triggersfixed.set
%   B) fallback: raw BIDS BrainVision *.vhdr
%
% Design note:
%   This step is intended to be configurable from cfg.prep_03.
%   In the usual case, users should only need to adjust the config.
%   Only fundamentally different preprocessing logic should require edits
%   to this function.

%% ========================================================================
%  OUTPUT INIT
% ========================================================================
step_out = struct( ...
    'ok', false, ...
    'skipped', false, ...
    'message', '', ...
    'run_base_name', '', ...
    'in_triggersfixed_set', '', ...
    'out_preica_set', '', ...
    'out_forica_set', '', ...
    'qc_files', {{}} );

%% ========================================================================
%  STEP CFG DEFAULTS
% ========================================================================
step_cfg = helpers.default_prep03_cfg();

%% ========================================================================
%  MERGE OVERRIDES FROM CFG
% ========================================================================
if isfield(cfg, 'prep_03') && isstruct(cfg.prep_03)
    step_cfg = helpers.merge_structs_recursive(step_cfg, cfg.prep_03);
end

if isfield(cfg, 'steps') && isfield(cfg.steps, 'prep_03_until_ica')
    s = cfg.steps.prep_03_until_ica;
    if isfield(s, 'overwrite_mode') && strlength(string(s.overwrite_mode)) > 0
        step_cfg.overwrite_mode = string(s.overwrite_mode);
    end
end

overwrite_mode = helpers.resolve_overwrite_mode(cfg, step_cfg.overwrite_mode);

if numel(step_cfg.crop_padding_sec) ~= 2
    error('prep03_untilica: cfg.prep_03.crop_padding_sec must have exactly two elements [pre post].');
end

%% ========================================================================
%  PATHS
% ========================================================================
if isfield(paths, 'prep_02_out_dir') && strlength(string(paths.prep_02_out_dir)) > 0
    prep02_out_dir = paths.prep_02_out_dir;
else
    prep02_out_dir = fullfile(paths.derivatives_root, '01_trigger_fix', sprintf('sub-%s', subj_id));
end

if isfield(paths, 'prep_03_out_dir_until_ica') && strlength(string(paths.prep_03_out_dir_until_ica)) > 0
    prep03_out_dir_untilica = paths.prep_03_out_dir_until_ica;
else
    prep03_out_dir_untilica = fullfile(paths.derivatives_root, '02_until_ica', sprintf('sub-%s', subj_id));
end

if isfield(paths, 'prep_03_out_dir_for_ica') && strlength(string(paths.prep_03_out_dir_for_ica)) > 0
    prep03_out_dir_forica = paths.prep_03_out_dir_for_ica;
else
    prep03_out_dir_forica = fullfile(paths.derivatives_root, '03_for_ica', sprintf('sub-%s', subj_id));
end

helpers.ensure_dir(prep03_out_dir_untilica);
helpers.ensure_dir(prep03_out_dir_forica);

if isfield(paths, 'qc_bad_chans_root') && strlength(string(paths.qc_bad_chans_root)) > 0
    bad_chan_qc_dir = paths.qc_bad_chans_root;
else
    bad_chan_qc_dir = fullfile(paths.derivatives_root, 'qc', '03_bad_chans');
end
helpers.ensure_dir(bad_chan_qc_dir);

%% ========================================================================
%  FIND INPUT
% ========================================================================
input_source = "triggersfixed_set";
in_dir  = prep02_out_dir;
in_name = "";

trigger_fixed_sets = dir(fullfile(in_dir, '*_triggersfixed.set'));

if ~isempty(trigger_fixed_sets)

    if numel(trigger_fixed_sets) > 1
        [~, ix] = max([trigger_fixed_sets.datenum]);
        helpers.log_msg_default( ...
            'prep03_untilica: WARNING multiple *_triggersfixed.set found (%d). Using most recent: %s', ...
            numel(trigger_fixed_sets), trigger_fixed_sets(ix).name);
        trigger_fixed_sets = trigger_fixed_sets(ix);
    end

    in_name = trigger_fixed_sets.name;
    run_base_name = erase(in_name, '_triggersfixed.set');

else
    [vhdr_dir, vhdr_name] = helpers.find_bids_vhdr(paths, subj_id, helpers);

    if isempty(vhdr_name)
        msg = sprintf(['prep03_untilica: no input found. Neither *_triggersfixed.set in %s ' ...
            'nor any *.vhdr in BIDS eeg folder for sub-%s.'], in_dir, subj_id);
        helpers.log_msg_default('%s', msg);
        step_out.message = msg;
        return;
    end

    input_source = "bids_vhdr";
    in_dir  = vhdr_dir;
    in_name = vhdr_name;
    run_base_name = regexprep(in_name, '\.vhdr$', '', 'ignorecase');
end

step_out.run_base_name = run_base_name;

if input_source == "triggersfixed_set"
    step_out.in_triggersfixed_set = fullfile(in_dir, in_name);
else
    step_out.in_triggersfixed_set = "";
end

out_preica = fullfile(prep03_out_dir_untilica, sprintf('%s_preica.set', run_base_name));
out_forica = fullfile(prep03_out_dir_forica,   sprintf('%s_forica.set', run_base_name));

step_out.out_preica_set = out_preica;
step_out.out_forica_set = out_forica;

%% ========================================================================
%  OVERWRITE POLICY
% ========================================================================
out_files = {out_preica, out_forica};
[do_run, reason, needs_regen] = helpers.step_should_run_outputs(out_files, overwrite_mode, cfg);

if ~do_run
    helpers.log_msg_default('prep03_untilica: skip (%s)', reason);
    step_out.skipped = true;
    step_out.ok = true;
    step_out.message = reason;
    return;
end

helpers.log_msg_default( ...
    'prep03_untilica: START sub-%s | %s | input_source=%s | input=%s', ...
    subj_id, run_base_name, input_source, fullfile(in_dir, in_name));

%% ========================================================================
%  LOAD INPUT
% ========================================================================
if input_source == "triggersfixed_set"
    EEG = helpers.safe_load_set(in_dir, in_name, helpers);
elseif input_source == "bids_vhdr"
    EEG = helpers.safe_load_bv(in_dir, in_name, helpers);
else
    error('prep03_untilica: internal error: unknown input_source=%s', char(input_source));
end

EEG = eeg_checkset(EEG);

EEG = helpers.append_eeg_comment(EEG, 'prep03_untilica: start');
EEG = helpers.append_eeg_comment(EEG, sprintf('prep03_untilica: input_source=%s', input_source));
EEG = helpers.append_eeg_comment(EEG, sprintf('prep03_untilica: input=%s', fullfile(in_dir, in_name)));

%% ========================================================================
%  CHANNEL TYPES
% ========================================================================
EEG = helpers.ensure_channel_types(EEG, step_cfg);

[eeg_idx, eog_idx, aux_idx] = helpers.get_channel_indices_by_type(EEG);

EEG = helpers.append_eeg_comment(EEG, sprintf( ...
    'prep03_untilica: channel counts EEG=%d | EOG=%d | AUX=%d', ...
    numel(eeg_idx), numel(eog_idx), numel(aux_idx)));

%% ========================================================================
%  CROP TO TASK WINDOW
% ========================================================================
if step_cfg.crop_to_task_markers
    [start_marker, start_latency] = helpers.find_first_event_latency(EEG, step_cfg.crop_start_marker);
    [end_marker, end_latency]   = helpers.find_first_event_latency(EEG, step_cfg.crop_end_marker);

    if isempty(start_latency) || isempty(end_latency)
    if isfield(step_cfg, 'substitute_crop_markers') && ...
            step_cfg.substitute_crop_markers

        helpers.log_msg_default( ...
            'prep03_untilica: WARNING missing crop marker(s); using the corresponding recording boundary.');

        if isempty(start_latency)
            start_latency = 1;
            start_marker = 'first_sample';
        end

        if isempty(end_latency)
            end_latency = EEG.pnts;
            end_marker = 'last_sample';
        end

    else
        msg = sprintf( ...
            'prep03_untilica: missing task markers start(%s)=%d end(%s)=%d -> cannot continue', ...
            start_marker, isempty(start_latency), ...
            end_marker, isempty(end_latency));

        helpers.log_msg_default('%s', msg);
        step_out.message = msg;
        return;
    end
end

    % Sample 1 corresponds to time zero. Add padding before the start and after the end.
    t_start = ((double(start_latency) - 1) / EEG.srate) ...
        - step_cfg.crop_padding_sec(1);
    
    t_end = ((double(end_latency) - 1) / EEG.srate) ...
        + step_cfg.crop_padding_sec(2);

    t_start = max(t_start, 0);
    t_end   = min(t_end, (EEG.pnts - 1) / EEG.srate);

    if t_end <= t_start
        msg = sprintf( ...
            'prep03_untilica: invalid crop window t_start=%.3f t_end=%.3f -> cannot continue', ...
            t_start, t_end);
        helpers.log_msg_default('%s', msg);
        step_out.message = msg;
        return;
    end

    EEG = pop_select(EEG, 'time', [t_start t_end]);
    EEG = eeg_checkset(EEG);

    EEG = helpers.append_eeg_comment(EEG, sprintf( ...
        'prep03_untilica: cropped %s..%s padding=[%.2f %.2f] t=[%.3f %.3f]', ...
        start_marker, end_marker, ...
        step_cfg.crop_padding_sec(1), step_cfg.crop_padding_sec(2), ...
        t_start, t_end));
end

%% ========================================================================
%  CROP INTERNAL BREAKS
% ========================================================================

[EEG, break_crop_info] = ...
    helpers.crop_internal_breaks(EEG, step_cfg);

if ~isfield(EEG, 'etc') || isempty(EEG.etc)
    EEG.etc = struct();
end

EEG.etc.prep03_break_crop = break_crop_info;

helpers.log_msg_default( ...
    ['prep03_untilica: break cropping | method=%s | status=%s | ' ...
     'breaks=%d | %s'], ...
    string(break_crop_info.method), ...
    string(break_crop_info.status), ...
    break_crop_info.n_breaks_removed, ...
    string(break_crop_info.message));

EEG = helpers.append_eeg_comment( ...
    EEG, ...
    sprintf( ...
    ['prep03_untilica: break cropping method=%s status=%s ' ...
     'removed=%d trials_per_block=%s'], ...
    char(string(break_crop_info.method)), ...
    char(string(break_crop_info.status)), ...
    break_crop_info.n_breaks_removed, ...
    mat2str(break_crop_info.observed_trials_per_block)));

%% ========================================================================
%  BREAK-CROPPING QC
% ========================================================================

if step_cfg.write_break_cropping_qc && ...
        lower(strtrim(string(step_cfg.break_crop_method))) ~= "off"

    if isfield(paths, 'qc_break_crop_root') && ...
            strlength(string(paths.qc_break_crop_root)) > 0

        break_qc_dir = paths.qc_break_crop_root;
    else
        break_qc_dir = fullfile( ...
            paths.derivatives_root, ...
            'qc', ...
            '03_break_cropping');
    end

    helpers.ensure_dir(break_qc_dir);

    qc_timestamp = helpers.resolve_qc_timestamp(cfg);

    qc_delimiter = ';';
    if isfield(cfg, 'qc') && ...
            isstruct(cfg.qc) && ...
            isfield(cfg.qc, 'table_delimiter')

        qc_delimiter = cfg.qc.table_delimiter;
    end

    break_qc_table = table( ...
        string(sprintf('sub-%s', subj_id)), ...
        string(run_base_name), ...
        string(break_crop_info.method), ...
        string(break_crop_info.status), ...
        string(break_crop_info.first_marker), ...
        string(break_crop_info.last_marker), ...
        break_crop_info.n_trial_markers, ...
        break_crop_info.n_breaks_found, ...
        break_crop_info.n_breaks_removed, ...
        string(mat2str(break_crop_info.observed_trials_per_block)), ...
        break_crop_info.removed_seconds, ...
        string(break_crop_info.message), ...
        'VariableNames', { ...
            'subject_id', ...
            'run_base', ...
            'method', ...
            'status', ...
            'first_marker', ...
            'last_marker', ...
            'n_trial_markers', ...
            'n_breaks_found', ...
            'n_breaks_removed', ...
            'trials_per_block', ...
            'removed_seconds', ...
            'message'});

    break_qc_path = fullfile( ...
        break_qc_dir, ...
        sprintf( ...
            '%s_sub-%s_%s_break_cropping.csv', ...
            char(qc_timestamp), ...
            subj_id, ...
            run_base_name));

    helpers.write_qc_table( ...
        break_qc_table, ...
        break_qc_path, ...
        qc_delimiter);

    step_out.qc_files{end+1} = break_qc_path;

    helpers.log_msg_default( ...
        'prep03_untilica: break-cropping QC table written: %s', ...
        break_qc_path);
end

%% ========================================================================
%  DETECT FLAT / INVALID CHANNELS ONCE, ALWAYS AFTER CROPPING
%  - the 10% denominator is the complete retained post-crop recording
%  - flat/invalid EEG channels are kept for later interpolation
%  - non-finite/completely constant AUX channels are removed permanently
% ========================================================================
dead_idx_all    = [];
dead_labels_all = {};
flat_detection_info = struct();

dead_eeg_idx    = [];
dead_eeg_labels = {};

dead_aux_idx    = [];
dead_aux_labels = {};

if step_cfg.flat_channel_detection.enable

    [eeg_idx_now, ~, aux_idx_now] = helpers.get_channel_indices_by_type(EEG);

    % Apply the configurable cumulative/continuous flatness criterion only
    % to EEG channels. Slow, quantized AUX signals such as SCR must not be
    % rejected merely because they contain many repeated adjacent values.
    if ~isempty(eeg_idx_now)
        [dead_eeg_idx, dead_eeg_labels, flat_detection_info] = ...
            helpers.find_flat_or_invalid_channels( ...
            EEG, eeg_idx_now, step_cfg.flat_channel_detection);

        helpers.log_msg_default( ...
            ['prep03_untilica: sub-%s | post-crop flat-channel detection ' ...
            'mode=%s | duration=%.3f s | threshold=%.6g | step_tolerance=%.6g uV'], ...
            subj_id, char(flat_detection_info.mode), ...
            flat_detection_info.recording_duration_sec, ...
            flat_detection_info.criterion_threshold, ...
            flat_detection_info.step_tolerance_uV);
    end

    % AUX cleanup is deliberately narrower: only non-finite or completely
    % constant AUX channels are removed.
    if ~isempty(aux_idx_now)
        aux_data = double(reshape( ...
            EEG.data(aux_idx_now, :, :), numel(aux_idx_now), []));
        aux_invalid = any(~isfinite(aux_data), 2);
        aux_fully_constant = var(aux_data, 0, 2) == 0;
        dead_aux_idx = aux_idx_now(aux_invalid | aux_fully_constant);
        dead_aux_labels = {EEG.chanlocs(dead_aux_idx).labels};
    end

    dead_idx_all = sort(unique([dead_eeg_idx(:); dead_aux_idx(:)]));
    if ~isempty(dead_idx_all)
        dead_labels_all = {EEG.chanlocs(dead_idx_all).labels};
    end

    if ~isempty(dead_eeg_idx)
        helpers.log_msg_default( ...
            'prep03_untilica: sub-%s | post-crop flat/invalid EEG channels flagged for later interpolation: %s', ...
            subj_id, strjoin(string(dead_eeg_labels), ', '));

        EEG = helpers.append_eeg_comment(EEG, sprintf( ...
            'prep03_untilica: post-crop flat/invalid EEG flagged for interpolation: %s', ...
            strjoin(dead_eeg_labels, ', ')));
    end

    if ~isempty(dead_aux_idx)
        helpers.log_msg_default( ...
            'prep03_untilica: sub-%s | removing post-crop non-finite/constant AUX channels permanently: %s', ...
            subj_id, strjoin(string(dead_aux_labels), ', '));

        EEG = helpers.append_eeg_comment(EEG, sprintf( ...
            'prep03_untilica: removing post-crop non-finite/constant AUX channels permanently: %s', ...
            strjoin(dead_aux_labels, ', ')));

        EEG = pop_select(EEG, 'nochannel', dead_aux_idx);
        EEG = eeg_checkset(EEG);

        if ~isempty(dead_eeg_labels)
            all_labels_after_aux_delete = {EEG.chanlocs.labels};
            dead_eeg_idx = find(ismember(all_labels_after_aux_delete, dead_eeg_labels));
        else
            dead_eeg_idx = [];
        end
    end
end

if ~isfield(EEG, 'etc') || isempty(EEG.etc)
    EEG.etc = struct();
end

EEG.etc.dead_channels_detected = struct();
EEG.etc.dead_channels_detected.all_indices     = dead_idx_all;
EEG.etc.dead_channels_detected.all_labels      = dead_labels_all;
EEG.etc.dead_channels_detected.dead_eeg_idx    = dead_eeg_idx;
EEG.etc.dead_channels_detected.dead_eeg_labels = dead_eeg_labels;
EEG.etc.dead_channels_detected.dead_aux_idx    = dead_aux_idx;
EEG.etc.dead_channels_detected.dead_aux_labels = dead_aux_labels;
EEG.etc.dead_channels_detected.detection_info  = flat_detection_info;

[eeg_idx, eog_idx, aux_idx] = helpers.get_channel_indices_by_type(EEG);

EEG = helpers.append_eeg_comment(EEG, sprintf( ...
    'prep03_untilica: channel counts AFTER post-crop flat/invalid handling EEG=%d | EOG=%d | AUX=%d', ...
    numel(eeg_idx), numel(eog_idx), numel(aux_idx)));

%% ========================================================================
%  DOWNSAMPLE
% ========================================================================
if isempty(step_cfg.downsample_hz) || double(step_cfg.downsample_hz) == 0
    EEG = helpers.append_eeg_comment(EEG, 'prep03_untilica: downsampling skipped');
else
    target_hz = double(step_cfg.downsample_hz);

    if ~isscalar(target_hz) || ~isfinite(target_hz) || target_hz <= 0
        error('prep03_untilica: invalid cfg.prep_03.downsample_hz: %s', mat2str(step_cfg.downsample_hz));
    end

    if abs(double(EEG.srate) - target_hz) > eps
        EEG = pop_resample(EEG, target_hz);
        EEG = eeg_checkset(EEG);
        EEG = helpers.append_eeg_comment(EEG, sprintf( ...
            'prep03_untilica: downsampled to %.0f Hz', target_hz));
    else
        EEG = helpers.append_eeg_comment(EEG, sprintf( ...
            'prep03_untilica: downsampling skipped (already %.0f Hz)', target_hz));
    end
end


%% ========================================================================
% High-Pass Filter before bad-channel detection (EEG + EOG ONLY)
% =========================================================================
[eeg_idx, eog_idx, ~] = helpers.get_channel_indices_by_type(EEG);
filter_idx = sort(unique([eeg_idx(:); eog_idx(:)]));

EEG = helpers.apply_filter_to_subset_only(EEG, filter_idx, ...
    step_cfg.highpass_hz, [], 'prep03_untilica high-pass');

%% ========================================================================
%  OPTIONAL DEBUG SAVE: AFTER HIGH-PASS
% ========================================================================
if step_cfg.save_intermediate_steps && step_cfg.save_intermediate_after_highpass
    helpers.save_intermediate_set( ...
        EEG, ...
        prep03_out_dir_untilica, ...
        string(run_base_name) + "_stage-prep03_after-highpass", ...
        "delete", ...
        cfg, ...
        step_cfg.intermediate_savemode, ...
        helpers);
end

%% ========================================================================
%  BAD CHANNEL DETECTION (EEG ONLY)
% ========================================================================
bad_idx = [];
bad_labels = {};
clean_rawdata_bad_idx = [];
idx_prob = [];
idx_kurt = [];
idx_spec = [];
badchan_backend_status = "ok";

badchan_method = lower(strtrim(string(step_cfg.bad_channel_detection_method)));

switch char(badchan_method)

    case 'clean_rawdata'
        if exist('clean_rawdata', 'file') ~= 2
            badchan_backend_status = "clean_rawdata_unavailable_flat_only";
        end
        if ~isempty(eeg_idx)
            try
                [clean_rawdata_bad_idx, ~] = helpers.detect_bad_channels_clean_rawdata( ...
                    EEG, eeg_idx, step_cfg.clean_rawdata_channel_corr_threshold);

                bad_idx = sort(unique([ ...
                    clean_rawdata_bad_idx(:); ...
                    dead_eeg_idx(:) ...
                    ]));

                bad_idx = intersect(bad_idx, eeg_idx);
                bad_idx = setdiff(bad_idx, eog_idx);

            catch me
                badchan_backend_status = "clean_rawdata_failed_flat_only";
                helpers.log_msg_default( ...
                    'prep03_untilica: clean_rawdata bad-channel detection FAILED -> fallback flat/invalid EEG only. %s', ...
                    me.message);

                bad_idx = sort(unique(dead_eeg_idx(:)));
                bad_idx = intersect(bad_idx, eeg_idx);
            end
        end

    case 'pop_rejchan'
        if isempty(eeg_idx)
            bad_idx = sort(unique(dead_eeg_idx(:)));
        else
            try
                [~, idx_prob] = pop_rejchan(EEG, 'elec', eeg_idx, ...
                    'threshold', step_cfg.pop_rejchan_z_threshold, ...
                    'norm', 'on', 'measure', 'prob');

                [~, idx_kurt] = pop_rejchan(EEG, 'elec', eeg_idx, ...
                    'threshold', step_cfg.pop_rejchan_z_threshold, ...
                    'norm', 'on', 'measure', 'kurt');

                [~, idx_spec] = pop_rejchan(EEG, 'elec', eeg_idx, ...
                    'threshold', step_cfg.pop_rejchan_z_threshold, ...
                    'norm', 'on', 'measure', 'spec', ...
                    'freqrange', step_cfg.pop_rejchan_freqrange_hz);

                bad_idx = sort(unique([ ...
                    idx_prob(:); ...
                    idx_kurt(:); ...
                    idx_spec(:); ...
                    dead_eeg_idx(:) ...
                    ]));

                bad_idx = intersect(bad_idx, eeg_idx);
                bad_idx = setdiff(bad_idx, eog_idx);

            catch me
                badchan_backend_status = "pop_rejchan_failed_flat_only";
                helpers.log_msg_default( ...
                    'prep03_untilica: pop_rejchan bad-channel detection FAILED -> fallback flat/invalid EEG only. %s', ...
                    me.message);

                bad_idx = sort(unique(dead_eeg_idx(:)));
                bad_idx = intersect(bad_idx, eeg_idx);
            end
        end

    case 'off'
        bad_idx = sort(unique(dead_eeg_idx(:)));
        bad_idx = intersect(bad_idx, eeg_idx);

    otherwise
error('prep03_untilica: unsupported bad_channel_detection_method: %s', ...
    string(step_cfg.bad_channel_detection_method));
end

if ~isempty(bad_idx)
    bad_labels = {EEG.chanlocs(bad_idx).labels};

    helpers.log_msg_default( ...
        'prep03_untilica: sub-%s | final bad EEG channels flagged by %s (n=%d): %s', ...
        subj_id, ...
        char(badchan_method), ...
        numel(bad_labels), ...
        strjoin(string(bad_labels), ', '));

    EEG = helpers.append_eeg_comment(EEG, sprintf( ...
        'prep03_untilica: bad EEG labels (to interpolate): %s', ...
        strjoin(bad_labels, ', ')));
else
    helpers.log_msg_default( ...
        'prep03_untilica: sub-%s | final bad EEG channels flagged by %s: none', ...
        subj_id, ...
        char(badchan_method));

    EEG = helpers.append_eeg_comment(EEG, 'prep03_untilica: no bad EEG channels flagged');
end

if ~isfield(EEG, 'chaninfo') || isempty(EEG.chaninfo)
    EEG.chaninfo = struct();
end
EEG.chaninfo.bad = bad_labels;

%% ========================================================================
%  BAD-CHANNEL QC TABLE
% ========================================================================
badchan_reason_indices = struct();
badchan_reason_indices.clean_rawdata_low_correlation = clean_rawdata_bad_idx;
badchan_reason_indices.pop_rejchan_probability = idx_prob;
badchan_reason_indices.pop_rejchan_kurtosis = idx_kurt;
badchan_reason_indices.pop_rejchan_spectrum = idx_spec;

badchan_qc_table = helpers.build_bad_channel_qc_table( ...
    EEG, sprintf('sub-%s', subj_id), run_base_name, bad_idx, step_cfg, ...
    flat_detection_info, badchan_reason_indices, cfg, badchan_backend_status);

qc_timestamp = helpers.resolve_qc_timestamp(cfg);
qc_delimiter = ';';
if isfield(cfg, 'qc') && isstruct(cfg.qc) && isfield(cfg.qc, 'table_delimiter')
    qc_delimiter = cfg.qc.table_delimiter;
end
badchan_qc_path = fullfile(bad_chan_qc_dir, sprintf( ...
    '%s_sub-%s_%s_bad_chans.csv', char(qc_timestamp), subj_id, run_base_name));
helpers.write_qc_table(badchan_qc_table, badchan_qc_path, qc_delimiter);
step_out.qc_files{end+1} = badchan_qc_path;

helpers.log_msg_default( ...
    'prep03_untilica: bad-channel QC table written: %s', badchan_qc_path);

try
    [~, ~, group_badchan_qc_paths] = helpers.collect_bad_channel_qc(cfg);
    for q = 1:numel(group_badchan_qc_paths)
        step_out.qc_files{end+1} = group_badchan_qc_paths{q}; %#ok<AGROW>
    end
catch qc_me
    helpers.log_msg_default( ...
        'prep03_untilica: WARNING bad-channel group QC collection failed: %s', qc_me.message);
end

%% ========================================================================
%  INTERPOLATE BAD CHANNELS BEFORE ICA
% ========================================================================
if step_cfg.interpolate_bad_channels_before_ica && ~isempty(bad_idx)
    EEG = helpers.append_eeg_comment(EEG, sprintf( ...
        'prep03_untilica: interpolate BEFORE ICA (%s): %s', ...
        step_cfg.interp_method, strjoin(bad_labels, ', ')));

    EEG = pop_interp(EEG, bad_idx, step_cfg.interp_method);
    EEG = eeg_checkset(EEG);

    [eeg_idx, eog_idx, aux_idx] = helpers.get_channel_indices_by_type(EEG);

    helpers.log_msg_default( ...
        'prep03_untilica: AFTER interpolation channel counts EEG=%d | EOG=%d | AUX=%d', ...
        numel(eeg_idx), numel(eog_idx), numel(aux_idx));

    EEG = helpers.append_eeg_comment(EEG, sprintf( ...
        'prep03_untilica: AFTER interpolation channel counts EEG=%d | EOG=%d | AUX=%d', ...
        numel(eeg_idx), numel(eog_idx), numel(aux_idx)));

    if ~isfield(EEG, 'etc') || isempty(EEG.etc)
        EEG.etc = struct();
    end
    EEG.etc.interpolated_channel_indices = bad_idx;
    EEG.etc.interpolated_channel_labels  = bad_labels;
else
    if ~isfield(EEG, 'etc') || isempty(EEG.etc)
        EEG.etc = struct();
    end
    EEG.etc.interpolated_channel_indices = [];
    EEG.etc.interpolated_channel_labels  = {};
end

%% ========================================================================
%  OPTIONAL DEBUG SAVE: AFTER BAD CHANNEL REJECTION / INTERPOLATION
% ========================================================================
if step_cfg.save_intermediate_steps && step_cfg.save_intermediate_after_bad_channel_rejection
    helpers.save_intermediate_set( ...
        EEG, ...
        prep03_out_dir_untilica, ...
        string(run_base_name) + "_stage-prep03_after-badchan", ...
        "delete", ...
        cfg, ...
        step_cfg.intermediate_savemode, ...
        helpers);
end

%% ========================================================================
%  REREFERENCE
% ========================================================================
EEG = helpers.apply_reference_mode(EEG, step_cfg, helpers, 'prep03_untilica');

if ~isfield(EEG, 'etc') || isempty(EEG.etc)
    EEG.etc = struct();
end

EEG.etc.prep03_reference_mode = char(string(step_cfg.reference_mode));

%% ========================================================================
%  OPTIONAL DEBUG SAVE: AFTER REREFERENCE
% ========================================================================
if step_cfg.save_intermediate_steps && step_cfg.save_intermediate_after_rereference
    helpers.save_intermediate_set( ...
        EEG, ...
        prep03_out_dir_untilica, ...
        string(run_base_name) + "_stage-prep03_after-reref", ...
        "delete", ...
        cfg, ...
        step_cfg.intermediate_savemode, ...
        helpers);
end


%% ========================================================================
%  LINE NOISE (EEG + EOG ONLY)
% ========================================================================
[eeg_idx, eog_idx, ~] = helpers.get_channel_indices_by_type(EEG);
filter_idx = sort(unique([eeg_idx(:); eog_idx(:)]));

if isempty(filter_idx) % messages might need to be passed to prep03 script, not written here
    filter_idx = EEG.chanlocs;
    helpers.log_msg_default('prep03_untilica: WARNING channel indices not available, continuing with all channels.');
end

line_noise_applied = false;

if string(step_cfg.line_noise_method) ~= "none"
    plugin_path = fullfile(cfg.toolboxes.("path_eeglab_"+cfg.env.mode), 'plugins');

    [EEG, line_noise_applied, line_noise_log] = helpers.remove_line_noise_from_subset(EEG, filter_idx, step_cfg, plugin_path, helpers);
    if ~line_noise_applied
        helpers.log_msg_default('prep03_untilica: WARNING line noise removal incomplete or failed.');
    end
end

EEG = helpers.append_eeg_comment(EEG, sprintf( ...
    'prep03_untilica: line noise method=%s applied=%d freqs=%s', ...
    string(step_cfg.line_noise_method), line_noise_applied, ...
    mat2str(step_cfg.line_noise_frequencies_hz)));

EEG = helpers.apply_filter_to_subset_only(EEG, filter_idx, ...
    [], step_cfg.lowpass_hz, 'prep03_untilica low-pass');

%% ========================================================================
%  OPTIONAL DEBUG SAVE: AFTER LOW-PASS
% ========================================================================
if step_cfg.save_intermediate_steps && step_cfg.save_intermediate_after_lowpass
    helpers.save_intermediate_set( ...
        EEG, ...
        prep03_out_dir_untilica, ...
        string(run_base_name) + "_stage-prep03_after-lowpass", ...
        "delete", ...
        cfg, ...
        step_cfg.intermediate_savemode, ...
        helpers);
end

%% ========================================================================
%  NOW IT IS SAFE TO DELETE OUTPUTS
% ========================================================================
if overwrite_mode == "delete" || needs_regen
        helpers.safe_delete_set(out_preica);
        helpers.safe_delete_set(out_forica);
end

%% ========================================================================
%  SAVE PREICA
% ========================================================================
EEG = helpers.append_eeg_comment(EEG, sprintf( ...
    'prep03_untilica: saved preica: %s', out_preica));

EEG = helpers.safe_save_set( ...
    EEG, ...
    prep03_out_dir_untilica, ...
    sprintf('%s_preica.set', run_base_name), ...
    helpers, ...
    cfg);

helpers.log_msg_default( ...
    'prep03_untilica: saved preica: %s', ...
    out_preica);


%% ========================================================================
%  CREATE FORICA
% ========================================================================
ica_prep_eeg = EEG;

ica_prep_eeg = helpers.apply_filter_to_subset_only( ...
    ica_prep_eeg, filter_idx, step_cfg.ica_prep_highpass_hz, [], ...
    'prep03_untilica ICA-prep high-pass');

ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
    'prep03_untilica: ICA-prep high-pass %.2f Hz', step_cfg.ica_prep_highpass_hz));

if step_cfg.ica_prep_use_regepochs
    if step_cfg.ica_prep_regepoch_length_sec <= 0
        error('prep03_untilica: cfg.prep_03.ica_prep_regepoch_length_sec must be > 0.');
    end

    ica_prep_eeg = eeg_regepochs(ica_prep_eeg, ...
        'recurrence', step_cfg.ica_prep_regepoch_length_sec, ...
        'limits', [0 step_cfg.ica_prep_regepoch_length_sec]);

    ica_prep_eeg = eeg_checkset(ica_prep_eeg);

    ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
        'prep03_untilica: ICA-prep regepochs %.2fs', ...
        step_cfg.ica_prep_regepoch_length_sec));
end

%% ========================================================================
%  ICA-PREP EPOCH REJECTION
% ========================================================================
ica_rej_method = "erplab";
if isfield(step_cfg, 'ica_prep_epoch_rejection_method') && ...
        strlength(string(step_cfg.ica_prep_epoch_rejection_method)) > 0
    ica_rej_method = lower(strtrim(string(step_cfg.ica_prep_epoch_rejection_method)));
end

% Check whether the training data contain epochs.
summary_is_epoched = step_cfg.ica_prep_use_regepochs || ...
    ica_prep_eeg.trials > 1 || ...
    (isfield(ica_prep_eeg, 'epoch') && ~isempty(ica_prep_eeg.epoch));

% Remember how many epochs are available before rejection.
% Use NaN when the data are continuous.
summary_n_before = NaN;

if summary_is_epoched
    summary_n_before = ica_prep_eeg.trials;

    % An empty dataset contains no epochs.
    if isempty(ica_prep_eeg.data)
        summary_n_before = 0;
    end
end

% Record whether rejection is performed or skipped.
summary_rejection_status = "called";


switch ica_rej_method

    case {"none","off","disabled"}
        % Rejection is switched off.
            ica_rej_method = "none";
            summary_rejection_status = "disabled";

        ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
            'prep03_untilica: ICA-prep epoch rejection skipped by config');
        

        helpers.log_msg_default( ...
            'prep03_untilica: sub-%s | ICA-prep epoch rejection skipped backend=none', ...
            subj_id);

    case {"erplab","erplab_artifact","erplab_epoch_rejection"}
        % Use one method name in the summary.
        ica_rej_method = "erplab";

        if ~isfield(step_cfg, 'ica_prep_erplab_epoch_rejection') || ...
                ~isstruct(step_cfg.ica_prep_erplab_epoch_rejection)
            error('cfg.prep_03.ica_prep_erplab_epoch_rejection is missing, but ica_prep_epoch_rejection_backend="erplab".');
        end

        [ica_eeg_idx, ~, ~] = helpers.get_channel_indices_by_type(ica_prep_eeg);

        if isempty(ica_eeg_idx)

            % No EEG channels are available for rejection.
            summary_rejection_status = "skipped_no_eeg_channels";

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
                'prep03_untilica: ICA-prep ERPLAB rejection skipped because no EEG channels were found');

            helpers.log_msg_default( ...
                'prep03_untilica: sub-%s | ICA-prep ERPLAB rejection skipped: no EEG channels', ...
                subj_id);

        elseif ~isfield(ica_prep_eeg, 'trials') || ica_prep_eeg.trials < 1

            % No epochs are available for rejection.
            summary_rejection_status = "skipped_no_epochs";

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
                'prep03_untilica: ICA-prep ERPLAB rejection skipped because no epochs were found');

            helpers.log_msg_default( ...
                'prep03_untilica: sub-%s | ICA-prep ERPLAB rejection skipped: no epochs', ...
                subj_id);

        else
            erplab_reject_cfg = step_cfg.ica_prep_erplab_epoch_rejection;
            erplab_reject_cfg.enable = true; % method selects ERPLAB; no user-facing second switch

            [ica_prep_eeg, erplab_info] = helpers.apply_erplab_epoch_rejection( ...
                ica_prep_eeg, ...
                ica_eeg_idx, ...
                erplab_reject_cfg, ...
                helpers, ...
                sprintf('sub-%s', subj_id), ...
                char(string(run_base_name) + " | ICA-prep"));

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
                ['prep03_untilica: ICA-prep ERPLAB rejection | rejected=%d/%d | kept=%d | ' ...
                 'extreme_voltage=%d | sample_diff=%d | flatline=%d'], ...
                erplab_info.n_rejected, ...
                erplab_info.n_before, ...
                erplab_info.n_kept, ...
                erplab_info.n_rejected_extreme_voltage, ...
                erplab_info.n_rejected_sample_diff, ...
                erplab_info.n_rejected_flatline));

            helpers.log_msg_default( ...
                ['prep03_untilica: sub-%s | ICA-prep ERPLAB rejection=%d/%d | kept=%d | ' ...
                 'extreme_voltage=%d | sample_diff=%d | flatline=%d'], ...
                subj_id, ...
                erplab_info.n_rejected, ...
                erplab_info.n_before, ...
                erplab_info.n_kept, ...
                erplab_info.n_rejected_extreme_voltage, ...
                erplab_info.n_rejected_sample_diff, ...
                erplab_info.n_rejected_flatline);
        end

              case {"mad","mad_variance","mad_epoch_rejection"}

                  % Use one method name in the summary.
                    ica_rej_method = "mad_variance";
                    
                    % MAD needs at least two epochs.
                    if ica_prep_eeg.trials < 2
                        summary_rejection_status = "skipped_fewer_than_two_epochs";
                    end

        [ica_eeg_idx, ~, ~] = helpers.get_channel_indices_by_type(ica_prep_eeg);

        if isempty(ica_eeg_idx)

            % No EEG channels are available for rejection.
            summary_rejection_status = "skipped_no_eeg_channels";

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
                'prep03_untilica: ICA-prep MAD rejection skipped because no EEG channels were found');

            helpers.log_msg_default( ...
                'prep03_untilica: sub-%s | ICA-prep MAD rejection skipped: no EEG channels', ...
                subj_id);

        elseif ~isfield(ica_prep_eeg, 'trials') || ica_prep_eeg.trials < 1

            % No epochs are available for rejection.
            summary_rejection_status = "skipped_no_epochs";

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
                'prep03_untilica: ICA-prep MAD rejection skipped because no epochs were found');

            helpers.log_msg_default( ...
                'prep03_untilica: sub-%s | ICA-prep MAD rejection skipped: no epochs', ...
                subj_id);

        else
            z_thresh = 3;
            if isfield(step_cfg, 'ica_prep_mad_z_threshold') && ...
                    ~isempty(step_cfg.ica_prep_mad_z_threshold)
                z_thresh = step_cfg.ica_prep_mad_z_threshold;
            end

            use_logvar = true;
            if isfield(step_cfg, 'ica_prep_mad_use_logvar') && ...
                    ~isempty(step_cfg.ica_prep_mad_use_logvar)
                use_logvar = logical(step_cfg.ica_prep_mad_use_logvar);
            end

            [ica_prep_eeg, mad_info] = helpers.reject_ica_prep_epochs_by_mad_variance( ...
                ica_prep_eeg, ...
                ica_eeg_idx, ...
                z_thresh, ...
                use_logvar);

            n_kept = ica_prep_eeg.trials;

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
                ['prep03_untilica: ICA-prep MAD variance rejection | rejected=%d/%d | kept=%d | ' ...
                 'z=%.2f | logvar=%d'], ...
                mad_info.n_rejected, ...
                mad_info.n_before, ...
                n_kept, ...
                z_thresh, ...
                use_logvar));

            helpers.log_msg_default( ...
                ['prep03_untilica: sub-%s | ICA-prep MAD variance rejection=%d/%d | kept=%d | ' ...
                 'z=%.2f | logvar=%d'], ...
                subj_id, ...
                mad_info.n_rejected, ...
                mad_info.n_before, ...
                n_kept, ...
                z_thresh, ...
                use_logvar);

            if isfield(step_cfg, 'ica_prep_max_reject_prop') && mad_info.n_before > 0
                reject_prop = mad_info.n_rejected / mad_info.n_before;

                if reject_prop > step_cfg.ica_prep_max_reject_prop
                    msg = sprintf( ...
                        'prep03_untilica: ICA-prep MAD variance rejection removed %.1f%% of epochs (threshold %.1f%%) -> cannot continue', ...
                        100 * reject_prop, 100 * step_cfg.ica_prep_max_reject_prop);
                    helpers.log_msg_default('%s', msg);
                    step_out.message = msg;

                    % Save the rejection counts even when this dataset is excluded.
                    summary = helpers.build_ica_training_summary( ...
                        ica_prep_eeg, summary_n_before, summary_is_epoched, ...
                        subj_id, run_base_name, ica_rej_method, ...
                        summary_rejection_status, "excluded_by_max_reject_prop", ...
                        out_forica, cfg, step_cfg);
                    
                    summary_path = helpers.write_ica_training_summary( ...
                        summary, cfg, step_cfg, helpers);
                    
                    % Add the summary file to the list of QC outputs.
                    if ~isempty(summary_path)
                        step_out.qc_files{end+1} = summary_path;
                    end

                    return;
                end
            end
        end

        case {"faster","faster_ptp"}

            % Use one method name in the summary.
            ica_rej_method = "faster_ptp";

        if ~isfield(step_cfg, 'ica_prep_faster_ptp_epoch_rejection') || ...
                ~isstruct(step_cfg.ica_prep_faster_ptp_epoch_rejection)
            error('cfg.prep_03.ica_prep_faster_ptp_epoch_rejection is missing, but ica_prep_epoch_rejection_method="faster_ptp".');
        end

        [ica_eeg_idx, ~, ~] = helpers.get_channel_indices_by_type(ica_prep_eeg);

        if isempty(ica_eeg_idx)
            
            % No EEG channels are available for rejection.
            summary_rejection_status = "skipped_no_eeg_channels";
            
            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
                'prep03_untilica: ICA-prep FASTER/PTP rejection skipped because no EEG channels were found');

            helpers.log_msg_default( ...
                'prep03_untilica: sub-%s | ICA-prep FASTER/PTP rejection skipped: no EEG channels', ...
                subj_id);

        elseif ~isfield(ica_prep_eeg, 'trials') || ica_prep_eeg.trials < 1

            % No epochs are available for rejection.
            summary_rejection_status = "skipped_no_epochs";

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
                'prep03_untilica: ICA-prep FASTER/PTP rejection skipped because no epochs were found');

            helpers.log_msg_default( ...
                'prep03_untilica: sub-%s | ICA-prep FASTER/PTP rejection skipped: no epochs', ...
                subj_id);

        else
            reject_cfg = step_cfg.ica_prep_faster_ptp_epoch_rejection;
            reject_cfg.enable = true; % method selects FASTER/PTP; no user-facing second switch

            [ica_prep_eeg, faster_info] = helpers.apply_shared_epoch_rejection( ...
                ica_prep_eeg, ...
                reject_cfg);

            n_kept = ica_prep_eeg.trials;

            if isfield(faster_info, 'use_faster') && faster_info.use_faster && ...
                    isfield(faster_info, 'have_faster') && ~faster_info.have_faster
                helpers.log_msg_default( ...
                    'prep03_untilica: sub-%s | WARNING ICA-prep FASTER requested but epoch_properties() was not found. PTP may still have been applied if enabled.', ...
                    subj_id);
            end

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
                ['prep03_untilica: ICA-prep FASTER/PTP rejection | rejected=%d/%d | kept=%d | ' ...
                 'bad_faster=%d | bad_ptp=%d | z=%.2f | robust_z=%d | ptp=%.1f uV'], ...
                faster_info.n_rejected, ...
                faster_info.n_before, ...
                n_kept, ...
                helpers.getfield_safe(faster_info, 'n_bad_faster', 0), ...
                helpers.getfield_safe(faster_info, 'n_bad_ptp', 0), ...
                helpers.getfield_safe(faster_info, 'faster_z', NaN), ...
                helpers.getfield_safe(faster_info, 'use_robust_z', false), ...
                helpers.getfield_safe(faster_info, 'ptp_uV_thresh', NaN)));

            helpers.log_msg_default( ...
                ['prep03_untilica: sub-%s | ICA-prep FASTER/PTP rejection=%d/%d | kept=%d | ' ...
                 'bad_faster=%d | bad_ptp=%d | z=%.2f | robust_z=%d | ptp=%.1f uV'], ...
                subj_id, ...
                faster_info.n_rejected, ...
                faster_info.n_before, ...
                n_kept, ...
                helpers.getfield_safe(faster_info, 'n_bad_faster', 0), ...
                helpers.getfield_safe(faster_info, 'n_bad_ptp', 0), ...
                helpers.getfield_safe(faster_info, 'faster_z', NaN), ...
                helpers.getfield_safe(faster_info, 'use_robust_z', false), ...
                helpers.getfield_safe(faster_info, 'ptp_uV_thresh', NaN));

            if isfield(reject_cfg, 'max_reject_prop') && faster_info.n_before > 0
                reject_prop = faster_info.n_rejected / faster_info.n_before;

                if reject_prop > reject_cfg.max_reject_prop
                    msg = sprintf( ...
                        'prep03_untilica: ICA-prep FASTER/PTP rejection removed %.1f%% of epochs (threshold %.1f%%) -> cannot continue', ...
                        100 * reject_prop, 100 * reject_cfg.max_reject_prop);
                    helpers.log_msg_default('%s', msg);
                    step_out.message = msg;

                    % Save the rejection counts even when this dataset is excluded.
                    summary = helpers.build_ica_training_summary( ...
                        ica_prep_eeg, summary_n_before, summary_is_epoched, ...
                        subj_id, run_base_name, ica_rej_method, ...
                        summary_rejection_status, "excluded_by_max_reject_prop", ...
                        out_forica, cfg, step_cfg);
                    
                    summary_path = helpers.write_ica_training_summary( ...
                        summary, cfg, step_cfg, helpers);
                    
                    % Add the summary file to the list of QC outputs.
                    if ~isempty(summary_path)
                        step_out.qc_files{end+1} = summary_path;
                    end

                    return;
                end
            end
        end

    otherwise
        error(['Unsupported cfg.prep_03.ica_prep_epoch_rejection_method="%s". ' ...
               'Use "erplab", "faster_ptp", "mad_variance", or "none".'], ...
               char(ica_rej_method));
end

%% ========================================================================
%  SAVE FORICA
% ========================================================================

% Summarize how many training epochs were rejected and retained.
summary = helpers.build_ica_training_summary( ...
    ica_prep_eeg, summary_n_before, summary_is_epoched, ...
    subj_id, run_base_name, ica_rej_method, summary_rejection_status, ...
    "saved", out_forica, cfg, step_cfg);

% Store the summary in the training dataset.
if ~isfield(ica_prep_eeg, 'etc') || isempty(ica_prep_eeg.etc)
    ica_prep_eeg.etc = struct();
end

ica_prep_eeg.etc.prep03_ica_training_summary = summary;

ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
    'prep03_untilica: saved forica: %s', out_forica));

ica_prep_eeg = helpers.safe_save_set( ...
    ica_prep_eeg, ...
    prep03_out_dir_forica, ...
    sprintf('%s_forica.set', run_base_name), ...
    helpers, ...
    cfg);

helpers.log_msg_default( ...
    'prep03_untilica: saved forica: %s', ...
    out_forica);

% Write the summary CSV after the training dataset has been saved.
summary_path = helpers.write_ica_training_summary( ...
    summary, cfg, step_cfg, helpers);

% Add the summary file to the list of QC outputs.
if ~isempty(summary_path)
    step_out.qc_files{end+1} = summary_path;
end


helpers.log_msg_default('prep03_untilica: DONE sub-%s | %s', subj_id, run_base_name);

step_out.ok = true;
step_out.skipped = false;
step_out.message = 'ok';

end

