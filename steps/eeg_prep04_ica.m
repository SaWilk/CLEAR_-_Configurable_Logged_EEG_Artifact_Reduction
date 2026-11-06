function step_out = eeg_prep04_ica(subj_id, cfg, paths, helpers)
% EEG_PREP04_ICA
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
%
% Run ICA on *_forica.set and transfer weights to *_preica.set.
%
% Outputs:
%   *_ica_applied.set
%
% Input:
%   - Step 03 ICA-training dataset: *_forica.set
%   - Matching continuous dataset:  *_preica.set
%
% Design note:
%   This step is intended to be configurable from cfg.prep_04.
%   AMICA is deliberately restricted to one ICA model because the standard
%   EEGLAB/ICLabel cleaning path consumes one unmixing matrix.
%
% Separation-quality reference:
%   Delorme et al. (2012), Independent EEG Sources Are Dipolar.
%   https://doi.org/10.1371/journal.pone.0030135
%
% Saskia Wilken Dez 2025

%% ========================================================================
%  OUTPUT INIT
% ========================================================================
step_out = struct( ...
    'ok', false, ...
    'skipped', false, ...
    'message', '', ...
    'outputs', {{}} );

subj_label = sprintf('sub-%s', subj_id);

%% ========================================================================
%  STEP CFG DEFAULTS
% ========================================================================
step_cfg = struct();

% ICA method: "runica" | "amica"
step_cfg.ica_method = "runica";

% runica options
step_cfg.use_extended_infomax = true;
step_cfg.interrupt_ica        = 'off';

% Rank logic
step_cfg.use_pca_rank_if_interpolated = true;

% AMICA guard on Windows
step_cfg.amica_require_no_spaces_on_windows = true;

% AMICA temp handling
step_cfg.amica_tmp_root          = "";
step_cfg.amica_delete_tmp        = true;
step_cfg.amica_keep_tmp_on_error = false;

% AMICA convergence and QC. Invalid/non-finite AMICA output remains a hard
% failure. Reaching amica_max_iter with otherwise valid output is retained as
% a warning so a large cohort does not fail for a diagnostic-only criterion.
step_cfg.amica_max_iter                         = 2000;
step_cfg.amica_write_update_norm_history        = false;
step_cfg.amica_check_convergence                = true;
step_cfg.amica_fail_on_nonconvergence           = true;
step_cfg.amica_convergence_min_iterations       = 50;
step_cfg.amica_convergence_tail_window          = 20;
step_cfg.amica_keep_tmp_on_qc_failure           = false;
step_cfg.write_run_qc_table                     = false;
step_cfg.write_subject_qc_table                 = true;
step_cfg.qc_table_delimiter                     = ';';

% Overwrite override
step_cfg.overwrite_mode = "";

% ICA channel selection
step_cfg.ica_channel_scope = "eeg_eog"; % "all" | "eeg" | "eeg_eog"



%% ========================================================================
%  MERGE OVERRIDES FROM CFG
% ========================================================================
if isfield(cfg, 'prep_04') && isstruct(cfg.prep_04)
    step_cfg = helpers.merge_structs_recursive(step_cfg, cfg.prep_04);
end

if isfield(cfg, 'steps') && isfield(cfg.steps, 'prep_04_ica') && isstruct(cfg.steps.prep_04_ica)
    if isfield(cfg.steps.prep_04_ica, 'overwrite_mode') && ...
            strlength(string(cfg.steps.prep_04_ica.overwrite_mode)) > 0
        step_cfg.overwrite_mode = string(cfg.steps.prep_04_ica.overwrite_mode);
    end
end

overwrite_mode = helpers.resolve_overwrite_mode(cfg, step_cfg.overwrite_mode);
ica_method = lower(string(step_cfg.ica_method));

if ~ismember(ica_method, ["runica","amica"])
    error('prep04_ica: unsupported cfg.prep_04.ica_method: %s', char(ica_method));
end

if ica_method == "amica"
    helpers.validate_amica_config(step_cfg);
end

%% ========================================================================
%  PATHS
% ========================================================================
if ~isfield(paths, 'prep_03_out_dir_for_ica') || ...
        strlength(string(paths.prep_03_out_dir_for_ica)) == 0
    error('prep04_ica: paths.prep_03_out_dir_for_ica is missing or empty.');
end

if ~isfield(paths, 'prep_03_out_dir_until_ica') || ...
        strlength(string(paths.prep_03_out_dir_until_ica)) == 0
    error('prep04_ica: paths.prep_03_out_dir_until_ica is missing or empty.');
end

if ~isfield(paths, 'prep_04_out_dir') || ...
        strlength(string(paths.prep_04_out_dir)) == 0
    error('prep04_ica: paths.prep_04_out_dir is missing or empty.');
end

in_dir_forica = paths.prep_03_out_dir_for_ica;
in_dir_preica = paths.prep_03_out_dir_until_ica;
out_dir_after = paths.prep_04_out_dir;

if ~isfield(paths, 'qc_dir') || strlength(string(paths.qc_dir)) == 0
    error('prep04_ica: paths.qc_dir is missing or empty.');
end

ica_method_tag = lower(regexprep(char(ica_method), '[^\w\-]', '_'));
qc_method_dir  = fullfile(paths.qc_dir, ica_method_tag);

helpers.ensure_dir(out_dir_after);
helpers.ensure_dir(qc_method_dir);

%% ========================================================================
%  FIND INPUTS
% ========================================================================
run_inventory = helpers.resolve_step04_run_inventory(paths, cfg);
if ~run_inventory.valid
    error('prep04_ica:Step03RunInventoryInvalid', ...
        '%s | %s | %s', subj_label, ...
        char(run_inventory.issue_code), ...
        char(run_inventory.issue_message));
end

helpers.log_msg_default( ...
    'prep04_ica: %s | configured task=%s | matched Step-03 run pairs=%d', ...
    subj_label, char(run_inventory.task_label), ...
    numel(run_inventory.matched_run_bases));

%% ========================================================================
%  AMICA GUARDS
% ========================================================================
if ica_method == "amica"
    if ispc && isfield(step_cfg, 'amica_require_no_spaces_on_windows') && ...
            step_cfg.amica_require_no_spaces_on_windows

        eeglab_root = string(helpers.get_env_or_empty("EEGLAB_ROOT"));
        amica_path  = which('runamica15');

        if isempty(amica_path)
            error('AMICA requested, but runamica15 not found on path (AMICA plugin missing?).');
        end

        if contains(string(amica_path), ' ')
            error('AMICA requested, but runamica15 path contains spaces (Windows AMICA may fail): %s', amica_path);
        end

        if strlength(eeglab_root) > 0 && contains(eeglab_root, ' ')
            error('AMICA requested, but EEGLAB_ROOT contains spaces (Windows AMICA may fail): %s', char(eeglab_root));
        end
    end
end

%% ========================================================================
%  MAIN LOOP
% ========================================================================
outputs_written = {};
qc_rows = table();

for fi = 1:numel(run_inventory.matched_run_bases)

    forica_name = char(run_inventory.matched_forica_names(fi));
    preica_name = char(run_inventory.matched_preica_names(fi));
    run_base    = run_inventory.matched_run_bases(fi);
    run_base_c  = char(run_base);

    out_name = [run_base_c '_ica_applied.set'];
    out_path = fullfile(out_dir_after, out_name);

    [do_run, reason, ~] = helpers.step_should_run_outputs({out_path}, overwrite_mode, cfg);
    helpers.log_msg_default('prep04_ica: %s | %s | %s', subj_label, run_base_c, char(string(reason)));

    if ~do_run
        outputs_written{end+1} = out_path; %#ok<AGROW>
        continue;
    end

    if overwrite_mode == "delete" && exist(out_path, 'file') == 2
        helpers.safe_delete_set(out_path);
    end

    %% --------------------------------------------------------------------
    %  LOAD INPUTS
    % ---------------------------------------------------------------------
    ica_prep_eeg = helpers.safe_load_set(in_dir_forica, forica_name, helpers);
    preica_eeg   = helpers.safe_load_set(in_dir_preica, preica_name, helpers);

    ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
        'prep04_ica: start ICA on _forica dataset');
    ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
        sprintf('prep04_ica: loaded forica=%s', forica_name));

    preica_eeg = helpers.append_eeg_comment(preica_eeg, ...
        'prep04_ica: will apply ICA weights to _preica dataset');
    preica_eeg = helpers.append_eeg_comment(preica_eeg, ...
        sprintf('prep04_ica: loaded preica=%s', preica_name));

    %% --------------------------------------------------------------------
    %  CHANNEL CONSISTENCY CHECK
    % ---------------------------------------------------------------------
    if preica_eeg.nbchan ~= ica_prep_eeg.nbchan
        error(['prep04_ica: channel count mismatch between preica and forica ' ...
               'for %s | preica=%d | forica=%d'], ...
               run_base_c, preica_eeg.nbchan, ica_prep_eeg.nbchan);
    end

    labels_preica = string({preica_eeg.chanlocs.labels});
    labels_forica = string({ica_prep_eeg.chanlocs.labels});

    labels_preica = lower(strtrim(labels_preica));
    labels_forica = lower(strtrim(labels_forica));

    if ~isequal(labels_preica, labels_forica)
        error('prep04_ica: channel label/order mismatch between preica and forica for %s.', run_base_c);
    end

        %% --------------------------------------------------------------------
    %  ICA CHANNEL SELECTION
    % ---------------------------------------------------------------------
    ica_channel_scope = lower(strtrim(string(step_cfg.ica_channel_scope)));

    if isfield(ica_prep_eeg, 'chanlocs') && ...
            ~isempty(ica_prep_eeg.chanlocs) && ...
            isfield(ica_prep_eeg.chanlocs, 'type')

        chan_types = lower(strtrim(string({ica_prep_eeg.chanlocs.type})));
    else
        chan_types = repmat("eeg", 1, ica_prep_eeg.nbchan);
    end

    switch ica_channel_scope
        case "all"
            ica_chan_idx = 1:ica_prep_eeg.nbchan;

        case "eeg"
            ica_chan_idx = find(chan_types == "eeg");

        case "eeg_eog"
            ica_chan_idx = find(chan_types == "eeg" | chan_types == "eog");

        otherwise
            error('prep04_ica: unsupported cfg.prep_04.ica_channel_scope: %s', ...
                char(ica_channel_scope));
    end

    if isempty(ica_chan_idx)
        error('prep04_ica: no channels selected for ICA with ica_channel_scope="%s".', ...
            char(ica_channel_scope));
    end

    helpers.log_msg_default( ...
        'prep04_ica: %s | %s | ICA channel scope=%s | selected=%d/%d channels', ...
        subj_label, run_base_c, char(ica_channel_scope), ...
        numel(ica_chan_idx), ica_prep_eeg.nbchan);

    ica_train_eeg = pop_select(ica_prep_eeg, 'channel', ica_chan_idx);
    ica_train_eeg = eeg_checkset(ica_train_eeg);

    ica_train_eeg = helpers.append_eeg_comment(ica_train_eeg, sprintf( ...
        'prep04_ica: ICA channel scope=%s | selected %d/%d channels from _forica dataset', ...
        char(ica_channel_scope), numel(ica_chan_idx), ica_prep_eeg.nbchan));

    %% --------------------------------------------------------------------
    %  RANK-SAFE PCA LOGIC
    % ---------------------------------------------------------------------
    interpolated_count = 0;

    if isfield(preica_eeg, 'etc') && isfield(preica_eeg.etc, 'interpolated_channel_indices') && ...
            ~isempty(preica_eeg.etc.interpolated_channel_indices)
        interpolated_count = numel(preica_eeg.etc.interpolated_channel_indices);
    elseif isfield(preica_eeg, 'chaninfo') && isfield(preica_eeg.chaninfo, 'bad') && ...
            ~isempty(preica_eeg.chaninfo.bad)
        interpolated_count = numel(preica_eeg.chaninfo.bad);
    end

    X = double(reshape(ica_train_eeg.data, ...
        ica_train_eeg.nbchan, ...
        ica_train_eeg.pnts * ica_train_eeg.trials));

    rank_forica = helpers.compute_data_rank_svd(X);

    use_pca  = false;
    pca_rank = [];

    if isfield(step_cfg, 'use_pca_rank_if_interpolated') && step_cfg.use_pca_rank_if_interpolated
        if rank_forica < ica_train_eeg.nbchan
            use_pca  = true;
            pca_rank = max(rank_forica, 1);

            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
                ['prep04_ica: rank-safe PCA: nbchan=%d rank(forica)=%d ' ...
                 'interpolated_count(preica)=%d => pca_rank=%d'], ...
                ica_train_eeg.nbchan, rank_forica, interpolated_count, pca_rank));

            helpers.log_msg_default( ...
                ['prep04_ica: %s | %s | rank-safe PCA: nbchan=%d rank(forica)=%d ' ...
                 'interpolated_count(preica)=%d => pca_rank=%d'], ...
                subj_label, run_base_c, ica_train_eeg.nbchan, rank_forica, interpolated_count, pca_rank);
        else
            ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, sprintf( ...
                'prep04_ica: rank-safe PCA: nbchan=%d rank(forica)=%d => no explicit PCA dimension', ...
                ica_train_eeg.nbchan, rank_forica));

            helpers.log_msg_default( ...
                'prep04_ica: %s | %s | rank-safe PCA: nbchan=%d rank(forica)=%d => no explicit PCA dimension', ...
                subj_label, run_base_c, ica_train_eeg.nbchan, rank_forica);
        end
    else
        ica_prep_eeg = helpers.append_eeg_comment(ica_prep_eeg, ...
            'prep04_ica: rank-safe PCA disabled by config');
    end

    %% --------------------------------------------------------------------
    %  RUN ICA
    % ---------------------------------------------------------------------
    ica_runtime_timer = tic;
    amica_tmp_dir = "";
    amica_qc = helpers.default_amica_qc();

    switch ica_method

        case "amica"
            x = double(reshape(ica_train_eeg.data, ...
                ica_train_eeg.nbchan, ...
                ica_train_eeg.pnts * ica_train_eeg.trials));

            if use_pca
                pcakeep = pca_rank;
            else
                pcakeep = max(rank_forica, 1);
            end

            amica_tmp_dir = string(helpers.make_unique_amica_tmpdir(step_cfg, subj_label, run_base_c));
            helpers.log_msg_default( ...
                'prep04_ica: %s | %s | AMICA tmp dir: %s', ...
                subj_label, run_base_c, char(amica_tmp_dir));

            keep_tmp_on_error = isfield(step_cfg, 'amica_keep_tmp_on_error') && step_cfg.amica_keep_tmp_on_error;
            delete_tmp_after  = isfield(step_cfg, 'amica_delete_tmp') && step_cfg.amica_delete_tmp;
            keep_tmp_on_qc_failure = logical(step_cfg.amica_keep_tmp_on_qc_failure);
            amica_qc_failed = false;
            amica_failure_qc_written = false;

            try
                % num_models is intentionally fixed at one. Increasing it
                % would produce several unmixing matrices that the current
                % ICLabel/component-subtraction path cannot use correctly.
                [ica_train_eeg.icaweights, ica_train_eeg.icasphere, mods] = runamica15( ...
                    x, ...
                    'num_models', 1, ...
                    'pcakeep', pcakeep, ...
                    'max_iter', round(double(step_cfg.amica_max_iter)), ...
                    'write_nd', double(logical(step_cfg.amica_write_update_norm_history)), ...
                    'outdir', char(amica_tmp_dir));

                amica_qc = helpers.evaluate_amica_convergence( ...
                    mods, ica_train_eeg.icaweights, ica_train_eeg.icasphere, ...
                    pcakeep, ica_train_eeg.nbchan, step_cfg);

                if isfinite(amica_qc.final_update_norm_max)
                    final_update_text = string(sprintf( ...
                        '%.12g', amica_qc.final_update_norm_max));
                elseif ~logical(step_cfg.amica_write_update_norm_history)
                    final_update_text = "not_saved";
                else
                    final_update_text = "nonfinite";
                end
                helpers.log_msg_default( ...
                    ['prep04_ica: %s | %s | AMICA convergence=%s | iter=%d/%d | ' ...
                     'hit_cap=%d | final_LL=%.12g | final_update_max=%s'], ...
                    subj_label, run_base_c, char(amica_qc.status), ...
                    amica_qc.n_iterations, round(double(step_cfg.amica_max_iter)), ...
                    amica_qc.hit_max_iter, amica_qc.ll_final, ...
                    char(final_update_text));

                if logical(step_cfg.amica_check_convergence) && ~amica_qc.passed
                    amica_qc_failed = true;
                    ica_runtime_seconds = toc(ica_runtime_timer);
                    failure_row = helpers.build_step04_ica_qc_row( ...
                        cfg, subj_label, run_base, ica_method, "fail", ...
                        amica_qc.failure_code, amica_qc.failure_reason, ...
                        amica_qc.recommended_action, rank_forica, pcakeep, ...
                        ica_train_eeg.nbchan, size(x, 2), ica_runtime_seconds, ...
                        step_cfg, amica_qc, amica_tmp_dir, out_path);
                    helpers.write_step04_run_qc( ...
                        failure_row, qc_method_dir, subj_label, run_base_c, step_cfg);
                    qc_rows = helpers.append_step04_qc_row(qc_rows, failure_row);
                    helpers.write_step04_subject_qc( ...
                        qc_rows, qc_method_dir, subj_label, step_cfg);
                    amica_failure_qc_written = true;

                    if logical(step_cfg.amica_fail_on_nonconvergence)
                        error('prep04_ica:AMICANonConvergence', ...
                            ['AMICA QC failed for %s | %s. %s Recommended action: %s'], ...
                            subj_label, run_base_c, char(amica_qc.failure_reason), ...
                            char(amica_qc.recommended_action));
                    end
                end

                ica_train_eeg.icawinv     = pinv(ica_train_eeg.icaweights * ica_train_eeg.icasphere);
                ica_train_eeg.icachansind = 1:ica_train_eeg.nbchan;

                ica_rank_used = pcakeep;

                ica_train_eeg = eeg_checkset(ica_train_eeg);
                ica_train_eeg = helpers.append_eeg_comment(ica_train_eeg, sprintf( ...
                    'prep04_ica: AMICA done. rank_used=%d | tmpdir=%s', ...
                    ica_rank_used, char(amica_tmp_dir)));

                if delete_tmp_after
                    helpers.safe_rmdir(char(amica_tmp_dir));
                    helpers.log_msg_default( ...
                        'prep04_ica: %s | %s | deleted AMICA tmp dir: %s', ...
                        subj_label, run_base_c, char(amica_tmp_dir));
                end

            catch ME
                is_runtime_failure = ~amica_failure_qc_written;
                if is_runtime_failure
                    ica_runtime_seconds = toc(ica_runtime_timer);
                    runtime_failure_row = helpers.build_step04_ica_qc_row( ...
                        cfg, subj_label, run_base, ica_method, "fail", ...
                        "AMICA_RUNTIME_ERROR", string(ME.message), ...
                        ['Check the AMICA installation and the Step-03 ' ...
                         'training data/rank, then rerun once. If AMICA ' ...
                         'fails again, use RUNICA consistently for the cohort. ' ...
                         'ICLabel thresholds cannot repair an ICA runtime failure.'], ...
                        rank_forica, pcakeep, ica_train_eeg.nbchan, size(x, 2), ...
                        ica_runtime_seconds, step_cfg, amica_qc, ...
                        amica_tmp_dir, out_path);
                    helpers.write_step04_run_qc( ...
                        runtime_failure_row, qc_method_dir, subj_label, ...
                        run_base_c, step_cfg);
                    qc_rows = helpers.append_step04_qc_row( ...
                        qc_rows, runtime_failure_row);
                    helpers.write_step04_subject_qc( ...
                        qc_rows, qc_method_dir, subj_label, step_cfg);
                end

                keep_this_tmp = keep_tmp_on_error || ...
                    (amica_qc_failed && keep_tmp_on_qc_failure);
                if keep_this_tmp
                    helpers.log_msg_default( ...
                        ['prep04_ica: %s | %s | AMICA failed; keeping tmp dir for debugging: %s | %s'], ...
                        subj_label, run_base_c, char(amica_tmp_dir), ME.message);
                else
                    helpers.safe_rmdir(char(amica_tmp_dir));
                    helpers.log_msg_default( ...
                        ['prep04_ica: %s | %s | AMICA failed; tmp dir deleted: %s | %s'], ...
                        subj_label, run_base_c, char(amica_tmp_dir), ME.message);
                end
                if is_runtime_failure
                    error('prep04_ica:AMICARuntimeFailure', ...
                        ['%s | %s | %s Recommended action: Check the AMICA ' ...
                         'installation and the Step-03 training data/rank, ' ...
                         'then rerun once. If AMICA fails again, use RUNICA ' ...
                         'consistently for the cohort. ICLabel thresholds ' ...
                         'cannot repair an ICA runtime failure.'], ...
                        subj_label, run_base_c, ME.message);
                else
                    rethrow(ME);
                end
            end

        case "runica"
            interrupt_ica = 'off';
            if isfield(step_cfg, 'interrupt_ica')
                interrupt_ica = step_cfg.interrupt_ica;
            end

            try
                if use_pca
                    if isfield(step_cfg, 'use_extended_infomax') && step_cfg.use_extended_infomax
                        ica_train_eeg  = pop_runica(ica_train_eeg , ...
                            'extended', 1, ...
                            'pca', pca_rank, ...
                            'interrupt', interrupt_ica);
                    else
                        ica_train_eeg  = pop_runica(ica_train_eeg , ...
                            'pca', pca_rank, ...
                            'interrupt', interrupt_ica);
                    end
                else
                    use_extended = true;
                    if isfield(step_cfg, 'use_extended_infomax')
                        use_extended = step_cfg.use_extended_infomax;
                    end

                    if use_extended
                        ica_train_eeg  = pop_runica(ica_train_eeg , ...
                            'extended', 1, ...
                            'interrupt', interrupt_ica);
                    else
                        ica_train_eeg  = pop_runica(ica_train_eeg , ...
                            'interrupt', interrupt_ica);
                    end
                end

                % Without an explicit PCA dimension, pop_runica can reduce the rank itself.
                ica_rank_used = helpers.validate_ica_matrices( ...
                    ica_train_eeg.icaweights, ica_train_eeg.icasphere, ...
                    pca_rank, ica_train_eeg.nbchan, "runica");

                if ~use_pca && ica_rank_used < ica_train_eeg.nbchan
                    helpers.log_msg_default( ...
                        'prep04_ica: %s | %s | EEGLAB selected %d components for %d ICA channels.', ...
                        subj_label, run_base_c, ica_rank_used, ica_train_eeg.nbchan);
                end

                ica_train_eeg  = eeg_checkset(ica_train_eeg );
                ica_train_eeg  = helpers.append_eeg_comment(ica_train_eeg , sprintf( ...
                    'prep04_ica: runica done. rank_used=%d', ica_rank_used));
            catch ME
                ica_runtime_seconds = toc(ica_runtime_timer);
                failure_row = helpers.build_step04_ica_qc_row( ...
                    cfg, subj_label, run_base, ica_method, "fail", ...
                    "RUNICA_ERROR", string(ME.message), ...
                    ['Check the Step-03 training data, sample count, and ' ...
                     'estimated rank, then rerun once. If RUNICA fails ' ...
                     'again, try AMICA before excluding the dataset. ' ...
                     'ICLabel thresholds cannot repair an ICA failure.'], ...
                    rank_forica, max(rank_forica, 1), ica_train_eeg.nbchan, ...
                    size(X, 2), ica_runtime_seconds, step_cfg, amica_qc, ...
                    "", out_path);
                helpers.write_step04_run_qc( ...
                    failure_row, qc_method_dir, subj_label, run_base_c, step_cfg);
                qc_rows = helpers.append_step04_qc_row(qc_rows, failure_row);
                helpers.write_step04_subject_qc( ...
                    qc_rows, qc_method_dir, subj_label, step_cfg);
                error('prep04_ica:RUNICAFailure', ...
                    ['%s | %s | %s Recommended action: Check the Step-03 ' ...
                     'training data, sample count, and estimated rank, then ' ...
                     'rerun once. If RUNICA fails again, try AMICA before ' ...
                     'excluding the dataset. ICLabel thresholds cannot ' ...
                     'repair an ICA failure.'], ...
                    subj_label, run_base_c, ME.message);
            end
    end

    ica_runtime_seconds = toc(ica_runtime_timer);

    %% --------------------------------------------------------------------
    %  TRANSFER ICA TO PREICA
    % ---------------------------------------------------------------------
    preica_eeg.icawinv     = ica_train_eeg.icawinv;
    preica_eeg.icasphere   = ica_train_eeg.icasphere;
    preica_eeg.icaweights  = ica_train_eeg.icaweights;
    preica_eeg.icachansind = ica_chan_idx;

    if ~isfield(preica_eeg, 'etc') || isempty(preica_eeg.etc)
        preica_eeg.etc = struct();
    end

    preica_eeg.etc.prep04_ica = struct();
    preica_eeg.etc.prep04_ica.method             = char(ica_method);
    preica_eeg.etc.prep04_ica.interpolated_count = interpolated_count;
    preica_eeg.etc.prep04_ica.rank_forica        = rank_forica;
    preica_eeg.etc.prep04_ica.rank_used          = ica_rank_used;
    preica_eeg.etc.prep04_ica.ica_channel_scope   = char(ica_channel_scope);
    preica_eeg.etc.prep04_ica.ica_channel_indices = ica_chan_idx;
    preica_eeg.etc.prep04_ica.ica_channel_labels  = {preica_eeg.chanlocs(ica_chan_idx).labels};
    preica_eeg.etc.prep04_ica.runtime_seconds     = ica_runtime_seconds;
    preica_eeg.etc.prep04_ica.amica_convergence  = amica_qc;

    preica_eeg = eeg_checkset(preica_eeg);

    preica_eeg = helpers.append_eeg_comment(preica_eeg, sprintf( ...
        'prep04_ica: ICA weights transferred from %s', forica_name));

    preica_eeg = helpers.append_eeg_comment(preica_eeg, sprintf( ...
        'prep04_ica: ica_method=%s | interpolated_count=%d | rank_forica=%d | rank_used=%d', ...
        char(ica_method), interpolated_count, rank_forica, ica_rank_used));

    %% --------------------------------------------------------------------
    %  SAVE
    % ---------------------------------------------------------------------
    preica_eeg = helpers.safe_save_set(preica_eeg, out_dir_after, out_name, helpers, cfg);
    helpers.log_msg_default('prep04_ica: saved: %s', out_path);

    final_ica_status = "pass";
    final_failure_code = "";
    final_failure_reason = "";
    final_recommended_action = "";
    if ica_method == "amica" && logical(step_cfg.amica_check_convergence) && ...
            amica_qc.status == "warning"
        final_ica_status = "warning";
        final_failure_code = amica_qc.warning_code;
        final_failure_reason = amica_qc.warning_reason;
        final_recommended_action = amica_qc.recommended_action;
    elseif ica_method == "amica" && ...
            logical(step_cfg.amica_check_convergence) && ~amica_qc.passed
        % This branch is reachable only when the user explicitly configured
        % fatal AMICA QC not to abort. Keep the output visibly flagged.
        final_ica_status = "warning";
        final_failure_code = amica_qc.failure_code;
        final_failure_reason = amica_qc.failure_reason;
        final_recommended_action = amica_qc.recommended_action;
    end

    success_row = helpers.build_step04_ica_qc_row( ...
        cfg, subj_label, run_base, ica_method, final_ica_status, ...
        final_failure_code, final_failure_reason, final_recommended_action, ...
        rank_forica, ica_rank_used, ica_train_eeg.nbchan, size(X, 2), ...
        ica_runtime_seconds, step_cfg, amica_qc, amica_tmp_dir, out_path);
    helpers.write_step04_run_qc( ...
        success_row, qc_method_dir, subj_label, run_base_c, step_cfg);

    qc_rows = helpers.append_step04_qc_row(qc_rows, success_row);

    outputs_written{end+1} = out_path; %#ok<AGROW>
end

%% ========================================================================
%  FINALIZE
% ========================================================================
if isempty(outputs_written)
    step_out.ok = false;
    step_out.message = sprintf( ...
        'prep04_ica: no task-matched runs produced an output for %s.', ...
        subj_label);
    return;
end

step_out.ok = true;
step_out.skipped = false;
step_out.message = sprintf('prep04_ica: OK (%d output file(s)).', numel(outputs_written));
step_out.outputs = outputs_written;

helpers.write_step04_subject_qc(qc_rows, qc_method_dir, subj_label, step_cfg);

end
