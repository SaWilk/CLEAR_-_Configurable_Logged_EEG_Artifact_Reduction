function step_out = eeg_prep06_epoching(subj_id, cfg, paths, helpers)
% EEG_PREP06_EPOCHING
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
%
% PURPOSE
%   Create final epoched datasets from post-ICA continuous data.
%
% SUPPORTED MODES
%   1) "event_locked"
%      - epoch around configured event markers
%
%   2) "baseline"
%      - optionally segment continuous baseline into configured conditions
%      - create regular regepochs within each chunk
%
% ARTIFACT HANDLING ORDER
%   1) optional initial hard absolute-threshold rejection
%      - usually disabled when ERPLAB rejection is used
%   2) backend-specific epoch rejection
%      - preferred for this pipeline: ERPLAB pop_artextval/pop_artdiff/pop_artflatline
%   3) optional baseline correction
%   4) optional subject exclusion by per-condition minimum trial counts
%
% INPUT
%   paths.prep_05_out_dir
%       *_until_epoching.set
%
% OUTPUT
%   paths.prep_06_out_dir
%       event_locked:
%           *_epoched_final.set
%           or split outputs
%
%       baseline:
%           *_epoched_final.set                         (no conditions)
%           *_cond-<condition-name>_epoched_final.set   (configured conditions)
%           or split outputs
%
% NOTES
%   - reference_mode defaults to "keep"
%   - output split keeps current "_NON_EEG" naming
%
% Saskia Wilken Dez 2025
% Updated Apr 2026

step_out = struct( ...
    'ok', false, ...
    'message', '', ...
    'outputs', {{}}, ...
    'summary_files', {{}});

SUBJ_LABEL        = sprintf('sub-%s', subj_id);
INPUT_FILE_GLOB   = '*_until_epoching.set';
INPUT_FILE_SUFFIX = "_until_epoching.set";

MODE_EVENT_LOCKED = "event_locked";
MODE_BASELINE     = "baseline";

%% ========================================================================
%  STEP CFG DEFAULTS
% ========================================================================
step_cfg = helpers.default_prep06_cfg();

%% ========================================================================
%  MERGE USER CONFIG
% ========================================================================
if isfield(cfg, 'prep_06') && isstruct(cfg.prep_06)
    step_cfg = helpers.merge_structs_recursive(step_cfg, cfg.prep_06);
end

if isfield(cfg, 'steps') && isfield(cfg.steps, 'prep_06_epoching') && isstruct(cfg.steps.prep_06_epoching)
    if isfield(cfg.steps.prep_06_epoching, 'overwrite_mode') && ...
            strlength(string(cfg.steps.prep_06_epoching.overwrite_mode)) > 0
        step_cfg.overwrite_mode = string(cfg.steps.prep_06_epoching.overwrite_mode);
    end
end

step_cfg.epoching_mode = string(step_cfg.epoching_mode);
step_cfg.epoching_mode = step_cfg.epoching_mode(1);
step_cfg.epoching_mode = string(helpers.normalize_epoching_mode_value(step_cfg.epoching_mode));
step_cfg.qc_timestamp = helpers.resolve_qc_timestamp(cfg);

OVERWRITE_MODE = helpers.resolve_overwrite_mode(cfg, step_cfg.overwrite_mode);

if step_cfg.epoching_mode == MODE_EVENT_LOCKED && ...
        isfield(step_cfg, 'min_trials_per_condition_enable') && ...
        step_cfg.min_trials_per_condition_enable && ...
        isempty(step_cfg.min_trials_per_condition_codes)
    error(['cfg.prep_06.min_trials_per_condition_codes is empty, but ' ...
        'cfg.prep_06.min_trials_per_condition_enable=true.']);
end

%% ========================================================================
%  PATHS
% ========================================================================
if ~isfield(paths, 'prep_05_out_dir') || strlength(string(paths.prep_05_out_dir)) == 0
    error('prep_06_epoching: paths.prep_05_out_dir is missing or empty.');
end

if ~isfield(paths, 'prep_06_out_dir') || strlength(string(paths.prep_06_out_dir)) == 0
    error('prep_06_epoching: paths.prep_06_out_dir is missing or empty.');
end

ica_method = "unknown";
if isfield(cfg, 'prep_04') && isfield(cfg.prep_04, 'ica_method') && ...
        strlength(string(cfg.prep_04.ica_method)) > 0
    ica_method = string(cfg.prep_04.ica_method);
end
ica_method_tag = lower(regexprep(char(ica_method), '[^\w\-]', '_'));

IN_DIR        = paths.prep_05_out_dir;
OUT_DIR       = paths.prep_06_out_dir;
if isfield(paths, 'qc_epoch_rej_root') && strlength(string(paths.qc_epoch_rej_root)) > 0
    QC_METHOD_DIR = fullfile(paths.qc_epoch_rej_root, ica_method_tag);
else
    QC_METHOD_DIR = fullfile(paths.derivatives_root, 'qc', '06_epoch_rej', ica_method_tag);
end

helpers.ensure_dir(OUT_DIR);
helpers.ensure_dir(QC_METHOD_DIR);

%% ========================================================================
%  FIND INPUTS
% ========================================================================
IN_SETS = dir(fullfile(IN_DIR, INPUT_FILE_GLOB));

if isempty(IN_SETS)
    step_out.ok = true;
    step_out.message = sprintf('prep_06_epoching: no %s found for %s (skip).', INPUT_FILE_GLOB, SUBJ_LABEL);
    helpers.log_msg_default('%s', step_out.message);
    return;
end

outputs_written = {};
summary_files   = {};
summary_rows    = table();
epoch_qc_rows  = table();

%% ========================================================================
%  MAIN LOOP
% ========================================================================
try
    for fi = 1:numel(IN_SETS)

        in_name_c  = IN_SETS(fi).name;
        in_name    = string(in_name_c);
        run_base   = erase(in_name, INPUT_FILE_SUFFIX);
        run_base_c = char(run_base);

        EEG_in = helpers.safe_load_set(IN_DIR, in_name_c, helpers);
        EEG_in = helpers.normalize_event_types(EEG_in);

        [idx_eeg, idx_eog, idx_non_eeg] = helpers.get_channel_indices_by_type(EEG_in);

        output_spec = helpers.build_epoching_output_paths( ...
            run_base, OUT_DIR, step_cfg, idx_eeg, idx_eog, idx_non_eeg);

        output_paths_expected = output_spec.all_paths;

        [do_run, reason] = helpers.step_should_run_outputs(output_paths_expected, OVERWRITE_MODE, cfg);
        helpers.log_msg_default('prep_06_epoching: %s | %s | %s', ...
            SUBJ_LABEL, run_base_c, char(string(reason)));

        if ~do_run
            for k = 1:numel(output_paths_expected)
                outputs_written{end+1} = output_paths_expected{k}; %#ok<AGROW>
            end
            continue;
        end

        if OVERWRITE_MODE == "delete"
            for k = 1:numel(output_paths_expected)
                if exist(output_paths_expected{k}, 'file') == 2
                    helpers.safe_delete_set(output_paths_expected{k});
                end
            end
        end

        EEG_in = helpers.append_eeg_comment(EEG_in, 'prep_06_epoching: start');
        EEG_in = helpers.append_eeg_comment(EEG_in, sprintf('prep_06_epoching: input=%s', in_name_c));
        EEG_in = helpers.append_eeg_comment(EEG_in, sprintf( ...
            'prep_06_epoching: channel counts EEG=%d | EOG=%d | NON_EEG=%d', ...
            numel(idx_eeg), numel(idx_eog), numel(idx_non_eeg)));

        EEG_ref = helpers.apply_reference_mode(EEG_in, step_cfg, helpers);

        run_summary_rows = table();
        run_epoch_qc_rows = table();

        switch step_cfg.epoching_mode

            case MODE_EVENT_LOCKED

                target_events = helpers.normalize_event_list(step_cfg.events_phase);

                if isempty(target_events)
                    error('cfg.prep_06.events_phase is missing or empty for epoching_mode="event_locked".');
                end

                present_events = helpers.get_present_events(EEG_ref, target_events);

                if isempty(present_events)
                    found_preview = helpers.preview_event_types(EEG_ref, 25);
                    error(['prep_06_epoching: none of cfg.prep_06.events_phase are present in input set. ' ...
                        'This usually means Step 02 triggerfix was skipped or cfg.prep_06.events_phase does not match the dataset. ' ...
                        'Requested=%s | Found examples=%s'], ...
                        strjoin(cellstr(target_events), ', '), ...
                        strjoin(cellstr(found_preview), ', '));
                end

                if numel(present_events) < numel(target_events)
                    missing_events = setdiff(target_events, present_events, 'stable');
                    helpers.log_msg_default( ...
                        'prep_06_epoching: %s | %s | WARNING only %d/%d requested events are present. Missing: %s', ...
                        SUBJ_LABEL, run_base_c, numel(present_events), numel(target_events), ...
                        strjoin(cellstr(missing_events), ', '));
                end

                EEG_ep = pop_epoch( ...
                    EEG_ref, ...
                    cellstr(present_events), ...
                    [step_cfg.epoch_start_s step_cfg.epoch_end_s], ...
                    'newname', sprintf('%s_epoched', run_base_c), ...
                    'epochinfo', 'yes');

                EEG_ep = eeg_checkset(EEG_ep);

                try
                    EEG_ep.times = round(linspace( ...
                        step_cfg.epoch_start_s * 1000, ...
                        step_cfg.epoch_end_s   * 1000, ...
                        size(EEG_ep.data, 2)));
                catch
                end

                EEG_ep = helpers.append_eeg_comment(EEG_ep, sprintf( ...
                    'prep_06_epoching: event_locked epoching | n_requested=%d | n_present=%d | window=[%.3f %.3f] s', ...
                    numel(target_events), numel(present_events), step_cfg.epoch_start_s, step_cfg.epoch_end_s));

                base_stem = helpers.build_epoching_output_stem(run_base, "", false);

                [EEG_final, rej_info] = helpers.finalize_epoched_dataset( ...
                    EEG_ep, base_stem, OUT_DIR, step_cfg, cfg, helpers, SUBJ_LABEL, run_base);

                saved_paths  = {};
                status_label = "empty_after_rejection";

                if ~rej_info.excluded && EEG_final.trials > 0 && step_cfg.min_trials_per_condition_enable
                    [min_ok, min_info] = helpers.evaluate_min_trials_per_condition( ...
                        EEG_final, ...
                        step_cfg.min_trials_per_condition_codes, ...
                        step_cfg.min_trials_per_condition_min_n, ...
                        step_cfg.min_trials_per_condition_zero_tol_ms);

                    rej_info.min_trials_required               = min_info.min_required;
                    rej_info.min_trials_condition_counts       = min_info.counts_joined;
                    rej_info.min_trials_insufficient_conditions = min_info.insufficient_joined;

                    if min_ok
                        helpers.log_msg_default( ...
                            'prep_06_epoching: %s | %s | min-trials PASS | required=%d | counts=%s', ...
                            SUBJ_LABEL, run_base_c, min_info.min_required, char(min_info.counts_joined));

                        EEG_final = helpers.append_eeg_comment(EEG_final, sprintf( ...
                            'prep_06_epoching: min-trials rule passed | min_n=%d | counts=%s', ...
                            min_info.min_required, char(min_info.counts_joined)));
                    else
                        rej_info.excluded                   = true;
                        rej_info.excluded_by_min_trials_rule = true;
                        rej_info.exclusion_reason           = "min_trials_per_condition";
                        status_label                        = "excluded";

                        helpers.log_msg_default( ...
                            ['prep_06_epoching: %s | %s | dataset excluded by min-trials rule | ' ...
                            'required=%d | counts=%s | insufficient=%s'], ...
                            SUBJ_LABEL, run_base_c, min_info.min_required, ...
                            char(min_info.counts_joined), char(min_info.insufficient_joined));

                        EEG_final = helpers.append_eeg_comment(EEG_final, sprintf( ...
                            ['prep_06_epoching: dataset excluded by min-trials rule | ' ...
                            'min_n=%d | counts=%s | insufficient=%s'], ...
                            min_info.min_required, ...
                            char(min_info.counts_joined), ...
                            char(min_info.insufficient_joined)));
                    end
                end

                if ~rej_info.excluded && EEG_final.trials > 0
                    saved_paths = helpers.save_final_epoched_outputs( ...
                        EEG_final, base_stem, OUT_DIR, step_cfg, cfg, helpers);

                    for k = 1:numel(saved_paths)
                        outputs_written{end+1} = saved_paths{k}; %#ok<AGROW>
                    end
                    status_label = "saved";

                elseif rej_info.excluded
                    status_label = "excluded";
                    helpers.log_msg_default( ...
                        'prep_06_epoching: %s | %s | event_locked dataset excluded.', ...
                        SUBJ_LABEL, run_base_c);

                else
                    helpers.log_msg_default( ...
                        'prep_06_epoching: %s | %s | no final event_locked dataset written.', ...
                        SUBJ_LABEL, run_base_c);
                end

                event_epoch_qc = helpers.build_epoch_rejection_qc_table( ...
                    rej_info, step_cfg, cfg, SUBJ_LABEL, run_base, ...
                    MODE_EVENT_LOCKED, "event_locked", "prep_06_epoching");
                run_epoch_qc_rows = event_epoch_qc;

                row_event_locked = helpers.build_step06_summary_rows( ...
                    SUBJ_LABEL, run_base, ica_method, step_cfg, ...
                    MODE_EVENT_LOCKED, "event_locked", ...
                    in_name, rej_info, saved_paths, status_label, ...
                    numel(idx_eeg), numel(idx_eog), numel(idx_non_eeg));

                run_summary_rows = row_event_locked;

            case MODE_BASELINE
                has_conditions = logical(step_cfg.baseline_has_conditions);
                if has_conditions
                    [condition_datasets, condition_labels] = ...
                        helpers.create_baseline_condition_datasets( ...
                        EEG_ref, step_cfg, helpers, run_base);
                else
                    EEG_baseline = eeg_regepochs(EEG_ref, ...
                        'recurrence', step_cfg.regepoch_step_sec, ...
                        'limits', [0 step_cfg.regepoch_length_sec], ...
                        'rmbase', NaN);
                    EEG_baseline.setname = sprintf('%s_resting_regepochs', char(run_base));
                    EEG_baseline = eeg_checkset(EEG_baseline);
                    EEG_baseline = helpers.append_eeg_comment(EEG_baseline, sprintf( ...
                        ['prep_06_epoching: baseline without conditions | ' ...
                        'regepoch_length=%.3f s | step=%.3f s'], ...
                        step_cfg.regepoch_length_sec, step_cfg.regepoch_step_sec));
                    condition_datasets = {EEG_baseline};
                    condition_labels = "";
                end

                for condition_ix = 1:numel(condition_labels)
                    condition_label = string(condition_labels(condition_ix));
                    condition_display = condition_label;
                    if strlength(condition_display) == 0
                        condition_display = "unconditioned";
                    end

                    EEG_condition = condition_datasets{condition_ix};
                    if isempty(EEG_condition) || EEG_condition.trials < 1
                        helpers.log_msg_default( ...
                            'prep_06_epoching: %s | %s | no dataset created for condition=%s.', ...
                            SUBJ_LABEL, run_base_c, char(condition_display));
                        continue;
                    end

                    base_stem = helpers.build_epoching_output_stem( ...
                        run_base, condition_label, has_conditions);
                    run_label = run_base;
                    if has_conditions
                        run_label = run_base + "_" + condition_label;
                    end

                    [EEG_final, rej_info] = helpers.finalize_epoched_dataset( ...
                        EEG_condition, base_stem, OUT_DIR, step_cfg, cfg, helpers, ...
                        SUBJ_LABEL, run_label);

                    if ~rej_info.excluded && EEG_final.trials > 0 && ...
                            step_cfg.min_trials_per_condition_enable
                        min_n = step_cfg.min_trials_per_condition_min_n;
                        rej_info.min_trials_required = min_n;
                        rej_info.min_trials_condition_counts = sprintf( ...
                            '%s=%d', char(condition_display), EEG_final.trials);

                        if EEG_final.trials < min_n
                            rej_info.excluded = true;
                            rej_info.excluded_by_min_trials_rule = true;
                            rej_info.exclusion_reason = "min_trials_per_condition";
                            rej_info.min_trials_insufficient_conditions = condition_label;
                            EEG_final = helpers.append_eeg_comment(EEG_final, sprintf( ...
                                ['prep_06_epoching: baseline condition=%s excluded by ' ...
                                'min-trials rule | min_n=%d | n=%d'], ...
                                char(condition_display), min_n, EEG_final.trials));
                            helpers.log_msg_default( ...
                                ['prep_06_epoching: %s | %s | baseline condition=%s ' ...
                                'excluded by min-trials rule | min_n=%d | n=%d'], ...
                                SUBJ_LABEL, run_base_c, char(condition_display), ...
                                min_n, EEG_final.trials);
                        end
                    end

                    saved_paths = {};
                    status_condition = "empty_after_rejection";
                    if ~rej_info.excluded && EEG_final.trials > 0
                        saved_paths = helpers.save_final_epoched_outputs( ...
                            EEG_final, base_stem, OUT_DIR, step_cfg, cfg, helpers);
                        for k = 1:numel(saved_paths)
                            outputs_written{end+1} = saved_paths{k}; %#ok<AGROW>
                        end
                        status_condition = "saved";
                    elseif rej_info.excluded
                        status_condition = "excluded";
                        helpers.log_msg_default( ...
                            'prep_06_epoching: %s | %s | condition=%s dataset excluded.', ...
                            SUBJ_LABEL, run_base_c, char(condition_display));
                    else
                        helpers.log_msg_default( ...
                            ['prep_06_epoching: %s | %s | condition=%s dataset ' ...
                            'empty after rejection.'], ...
                            SUBJ_LABEL, run_base_c, char(condition_display));
                    end

                    condition_epoch_qc = helpers.build_epoch_rejection_qc_table( ...
                        rej_info, step_cfg, cfg, SUBJ_LABEL, run_base, ...
                        MODE_BASELINE, condition_label, "prep_06_epoching");
                    if isempty(run_epoch_qc_rows)
                        run_epoch_qc_rows = condition_epoch_qc;
                    else
                        run_epoch_qc_rows = [run_epoch_qc_rows; condition_epoch_qc]; %#ok<AGROW>
                    end

                    condition_summary_rows = helpers.build_step06_summary_rows( ...
                        SUBJ_LABEL, run_base, ica_method, step_cfg, ...
                        MODE_BASELINE, condition_label, in_name, rej_info, ...
                        saved_paths, status_condition, ...
                        numel(idx_eeg), numel(idx_eog), numel(idx_non_eeg));
                    if isempty(run_summary_rows)
                        run_summary_rows = condition_summary_rows;
                    else
                        run_summary_rows = [run_summary_rows; condition_summary_rows]; %#ok<AGROW>
                    end
                end

                if isempty(run_summary_rows)
                    helpers.log_msg_default( ...
                        'prep_06_epoching: %s | %s | WARNING: no baseline output written.', ...
                        SUBJ_LABEL, run_base_c);
                end

            otherwise
                error('Unsupported cfg.prep_06.epoching_mode: %s', char(step_cfg.epoching_mode));
        end

        if ~isempty(run_summary_rows)
            if isempty(summary_rows)
                summary_rows = run_summary_rows;
            else
                summary_rows = [summary_rows; run_summary_rows]; %#ok<AGROW>
            end

            if step_cfg.write_run_summary_table
                run_summary_path = fullfile( ...
                    QC_METHOD_DIR, ...
                    sprintf('%s_%s_%s_prep06_run_summary.csv', ...
                    char(step_cfg.qc_timestamp), SUBJ_LABEL, run_base_c));

                helpers.write_qc_table(run_summary_rows, run_summary_path, ...
                    step_cfg.qc_table_delimiter);

                summary_files{end+1} = run_summary_path; %#ok<AGROW>
            end
        end

        if ~isempty(run_epoch_qc_rows)
            if isempty(epoch_qc_rows)
                epoch_qc_rows = run_epoch_qc_rows;
            else
                epoch_qc_rows = [epoch_qc_rows; run_epoch_qc_rows]; %#ok<AGROW>
            end

            epoch_qc_path = fullfile(QC_METHOD_DIR, sprintf( ...
                '%s_%s_%s_epoch_rej.csv', ...
                char(step_cfg.qc_timestamp), SUBJ_LABEL, run_base_c));
            helpers.write_qc_table(run_epoch_qc_rows, epoch_qc_path, ...
                step_cfg.qc_table_delimiter);
            summary_files{end+1} = epoch_qc_path; %#ok<AGROW>
        end
    end

    % Required collector input: always write the subject-level summary.
    if ~isempty(summary_rows)
        subject_summary_path = fullfile( ...
            QC_METHOD_DIR, ...
            sprintf('%s_%s_prep06_summary.csv', ...
            char(step_cfg.qc_timestamp), SUBJ_LABEL));

        helpers.write_qc_table(summary_rows, subject_summary_path, ...
            step_cfg.qc_table_delimiter);

        summary_files{end+1} = subject_summary_path; 
    end

    % Fixed final part of Step 06: refresh the all-subject summaries from
    % the latest subject-level QC files. Atomic writes make this safe when
    % subjects finish in parallel; the last worker produces the full table.
    try
        [~, ~, ~, ~, group_summary_paths] = helpers.collect_prep06_summary(cfg);
        for q = 1:numel(group_summary_paths)
            summary_files{end+1} = group_summary_paths{q}; %#ok<AGROW>
        end
    catch qc_me
        helpers.log_msg_default( ...
            'prep_06_epoching: WARNING group QC collection failed: %s', qc_me.message);
    end

    if isempty(outputs_written)
        step_out.ok = false;
        step_out.message = sprintf('prep_06_epoching: no outputs written for %s.', SUBJ_LABEL);
        return;
    end

    step_out.ok = true;
    step_out.outputs = outputs_written;
    step_out.summary_files = summary_files;
    step_out.message = sprintf('prep_06_epoching: OK (%d output file(s)).', numel(outputs_written));

catch me
    helpers.log_msg_default('prep_06_epoching DEBUG CATCH | identifier=%s', me.identifier);
    helpers.log_msg_default('prep_06_epoching DEBUG CATCH | message=%s', me.message);

    try
        for si = 1:numel(me.stack)
            helpers.log_msg_default( ...
                'prep_06_epoching DEBUG STACK | #%d | file=%s | name=%s | line=%d', ...
                si, me.stack(si).file, me.stack(si).name, me.stack(si).line);
        end
    catch
    end

    step_out.ok = false;
    step_out.message = sprintf('prep_06_epoching: %s', me.message);
end
end
