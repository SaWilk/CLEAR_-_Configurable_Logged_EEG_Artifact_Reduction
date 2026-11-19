% =========================================================================
% FILE: run_eeg_pipeline.m
% =========================================================================
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
function run_eeg_pipeline(config_spec, varargin)
% RUN_EEG_PIPELINE Unified EEG preprocessing runner.
%
% WHAT THIS SCRIPT DOES
%   - Loads all user-facing settings from eeg_pipeline_config.m
%   - Initializes toolboxes
%   - Discovers subjects or uses explicitly requested subjects
%   - Preplans step execution using folder-based overwrite logic
%   - Runs enabled preprocessing steps serially or in parallel
%   - Writes one master log and one subject log per subject
%
% INPUT
%   Required:
%     - eeg_pipeline_config.m in the same folder
%     - eeg_pipeline_helpers.m on the MATLAB path
%     - external step functions on the MATLAB path or in ./steps
%
%   Optional call-time subject override:
%     run_eeg_pipeline('211','212','213')
%     run_eeg_pipeline({'211','212','213'})
%
% OUTPUT
%   - Step 01 BIDS raw output under cfg.paths.bids_root
%   - Steps 02-06 derivatives under cfg.paths.derivatives_root
%   - Logs under <derivatives_root>/logs/
%
% NOTES
%   - The user should normally edit ONLY eeg_pipeline_config.m
%   - This runner intentionally stays thin and delegates utilities to
%     eeg_pipeline_helpers.m
%
% REQUIREMENTS
%   - EEGLAB
%   - FASTER
%   - (AMICA - optional)
%   - (cleanline - optional)
%
% Saskia Wilken Dez 2025

% =========================================================================
% ROOT / PATH SETUP
% =========================================================================
this_file = mfilename('fullpath');
root_dir  = fileparts(this_file);
steps_dir = fullfile(root_dir, 'steps');

addpath(root_dir);

if exist(steps_dir, 'dir') ~= 7
    error('Steps directory not found: %s', steps_dir);
end
addpath(steps_dir);

if exist('eeg_pipeline_helpers', 'file') ~= 2
    error('Helper file not found on path. Expected in root or steps: %s | %s', root_dir, steps_dir);
end

if nargin < 1 || isempty(config_spec)
    error(['You must pass the config function as first argument, e.g. ' ...
        'run_eeg_pipeline(''eeg_pipeline_config_baseline'').']);
end

bootstrap_log = fullfile(tempdir, 'run_eeg_pipeline_bootstrap.log');
helpers = eeg_pipeline_helpers(bootstrap_log);

% =========================================================================
% RESOLVE AND LOAD CONFIG
% =========================================================================
% A config struct is accepted for programmatic calls and tests. Normal user
% calls should continue to pass the config function/name.
if isstruct(config_spec)
    cfg = config_spec;
    config_name = "internal_config_struct";
    config_file = "";
    if isfield(cfg, 'config_name') && strlength(string(cfg.config_name)) > 0
        config_name = string(cfg.config_name);
    end
    if isfield(cfg, 'config_file') && strlength(string(cfg.config_file)) > 0
        config_file = string(cfg.config_file);
    end
else
    [config_fn, config_name, config_file] = ...
        helpers.resolve_config_function(config_spec, root_dir);
    cfg = config_fn();
end

% -------------------------------------------------------------------------
% Internal runtime defaults
% -------------------------------------------------------------------------
if ~isfield(cfg, 'parallel') || ~isstruct(cfg.parallel)
    cfg.parallel = struct();
end

if ~isfield(cfg.parallel, 'enable') || isempty(cfg.parallel.enable)
    cfg.parallel.enable = false;
end

if ~isfield(cfg.parallel, 'force_workers')
    cfg.parallel.force_workers = [];
end

cfg.parallel.pool_is_thread = false;  % internal runtime flag, set by runner
cfg.parallel.pool_type      = "none"; % internal runtime flag, set by runner

cfg.runner_file     = this_file;
cfg.runner_root_dir = root_dir;
cfg.config_name     = string(config_name);
cfg.config_file     = string(config_file);

if nargin > 1
    subject_args = varargin;

    if numel(subject_args) && 1 && iscell(subject_args{1})
        cfg.subjects.list = subject_args{1};
    else
        cfg.subjects.list = subject_args;
    end

    cfg.subjects.min_id = [];

end

% =========================================================================
% MASTER LOG
% =========================================================================
% Store logs next to the derivative outputs:
%
%   <derivatives_root>/logs
%
% This deliberately overrides older cfg.paths.logs_dir defaults that pointed
% to the runner folder, so master and subject logs stay with the output.
cfg.paths.logs_dir = helpers.resolve_logs_dir(cfg);

logs_dir = char(string(cfg.paths.logs_dir));

master_log = fullfile( ...
    logs_dir, ...
    sprintf('%s_%s.log', ...
        char(string(cfg.constants.log_prefix_master)), ...
        datestr(now, char(string(cfg.constants.datestr_master)))));

helpers = eeg_pipeline_helpers(master_log);

% =========================================================================
% PIPELINE NAME
% =========================================================================
pipeline_name = "unnamed_pipeline";
if isfield(cfg, 'pipeline') && isfield(cfg.pipeline, 'name') && ...
        strlength(string(cfg.pipeline.name)) > 0
    pipeline_name = string(cfg.pipeline.name);
end

% =========================================================================
% RUN HEADER
% =========================================================================
helpers.log_msg(master_log, '=== PIPELINE START %s ===', datestr(now));
helpers.log_msg(master_log, 'pipeline_name    : %s', char(pipeline_name));
helpers.log_msg(master_log, 'config_name      : %s', char(string(cfg.config_name)));
helpers.log_msg(master_log, 'config_file      : %s', char(string(cfg.config_file)));
helpers.log_msg(master_log, 'step_prefix      : %s', char(string(cfg.pipeline.step_prefix)));
helpers.log_msg(master_log, 'runner_root_dir  : %s', root_dir);
helpers.log_msg(master_log, 'steps_dir        : %s', steps_dir);
helpers.log_msg(master_log, 'env_mode         : %s', char(string(cfg.env.mode)));
helpers.log_msg(master_log, 'machine_kind     : %s', char(string(cfg.env.machine_kind)));
helpers.log_msg(master_log, 'hostname         : %s', char(string(cfg.env.hostname)));
helpers.log_msg(master_log, ...
    'is_slurm         : %d | SLURM_JOB_ID=%s | SLURM_CLUSTER_NAME=%s', ...
    cfg.env.is_slurm, ...
    char(string(cfg.env.slurm_job_id)), ...
    char(string(cfg.env.slurm_cluster)));
helpers.log_msg(master_log, 'profile          : %s', char(string(cfg.paths.profile)));
helpers.log_msg(master_log, 'source_eeg_root  : %s', char(string(cfg.paths.source_eeg_root)));
helpers.log_msg(master_log, 'source_beh_root  : %s', char(string(cfg.paths.source_beh_root)));
helpers.log_msg(master_log, 'bids_root        : %s', char(string(cfg.paths.bids_root)));
helpers.log_msg(master_log, 'derivatives_root : %s', char(string(cfg.paths.derivatives_root)));
helpers.log_msg(master_log, 'logs_dir         : %s', char(string(cfg.paths.logs_dir)));
helpers.log_msg(master_log, 'task_label       : %s', char(string(cfg.bids.task_label)));
helpers.log_msg(master_log, 'session_label    : %s', char(string(cfg.bids.session_label)));
helpers.log_msg(master_log, 'overwrite_mode   : %s', char(string(cfg.io.overwrite_mode)));
helpers.log_msg(master_log, 'overwrite_date   : %s', char(string(cfg.io.overwrite_if_older_than)));

helpers.log_msg(master_log, ...
    ['step04 ICA: method=%s scope=%s | AMICA single_model=1 ' ...
     'max_iter=%d convergence_check=%d invalid_output_hard_fail=%d ' ...
     'write_update_norm=%d'], ...
    char(string(cfg.prep_04.ica_method)), ...
    char(string(cfg.prep_04.ica_channel_scope)), ...
    cfg.prep_04.amica_max_iter, ...
    cfg.prep_04.amica_check_convergence, ...
    cfg.prep_04.amica_fail_on_nonconvergence, ...
    cfg.prep_04.amica_write_update_norm_history);

helpers.log_msg(master_log, ...
    ['step05 iclabel enabled: eye=%d mus=%d heart=%d line=%d ch=%d ' ...
     'other=%d low_brain=%d'], ...
    cfg.prep_05.iclabel_remove_eye, ...
    cfg.prep_05.iclabel_remove_muscle, ...
    cfg.prep_05.iclabel_remove_heart, ...
    cfg.prep_05.iclabel_remove_linenoise, ...
    cfg.prep_05.iclabel_remove_channoise, ...
    cfg.prep_05.iclabel_remove_other, ...
    cfg.prep_05.iclabel_remove_low_brain);
helpers.log_msg(master_log, ...
    ['step05 iclabel thresholds: eye=%.2f mus=%.2f heart=%.2f ' ...
     'line=%.2f ch=%.2f other=%.2f brain_min=%.2f edge=%.2f'], ...
    cfg.prep_05.iclabel_eye_remove_thr, ...
    cfg.prep_05.iclabel_muscle_remove_thr, ...
    cfg.prep_05.iclabel_heart_remove_thr, ...
    cfg.prep_05.iclabel_linenoise_remove_thr, ...
    cfg.prep_05.iclabel_channoise_remove_thr, ...
    cfg.prep_05.iclabel_other_remove_thr, ...
    cfg.prep_05.iclabel_brain_min_keep_thr, ...
    cfg.prep_05.iclabel_edge_margin);
helpers.log_msg(master_log, ...
    ['step05 signal QC: enabled=%d scope=%s | extreme_prop_IC=%.3f ' ...
     'extreme_min_remaining=%d'], ...
    cfg.prep_05.signal_qc_enable, ...
    char(string(cfg.prep_05.signal_qc_channel_scope)), ...
    cfg.prep_05.signal_qc_max_prop_ic_removed, ...
    cfg.prep_05.signal_qc_min_remaining_components);
helpers.log_msg(master_log, ...
    ['step05 signal QC warning limits: min_median_corr=%.3f | ' ...
     'max_rel_change_rms=%.3f | rms_ratio=[%.3f %.3f]'], ...
    cfg.prep_05.signal_qc_min_median_channel_correlation, ...
    cfg.prep_05.signal_qc_max_relative_change_rms, ...
    cfg.prep_05.signal_qc_min_rms_ratio, ...
    cfg.prep_05.signal_qc_max_rms_ratio);
helpers.log_msg(master_log, ...
    ['step05 signal QC extreme limits: min_median_corr=%.3f | ' ...
     'max_rel_change_rms=%.3f | rms_ratio=[%.3f %.3f] | ' ...
     'required_together=%d | hard_fail=%d'], ...
    cfg.prep_05.signal_qc_hard_min_median_channel_correlation, ...
    cfg.prep_05.signal_qc_hard_max_relative_change_rms, ...
    cfg.prep_05.signal_qc_hard_min_rms_ratio, ...
    cfg.prep_05.signal_qc_hard_max_rms_ratio, ...
    cfg.prep_05.signal_qc_min_extreme_metrics_to_fail, ...
    cfg.prep_05.signal_qc_fail_on_violation);
helpers.log_msg(master_log, ...
    ['step05 decomposition QC: enabled=%d | residual_MI_samples=%d | ' ...
     'bins=%d'], ...
    cfg.prep_05.compute_decomposition_qc, ...
    cfg.prep_05.decomposition_qc_max_samples, ...
    cfg.prep_05.decomposition_qc_mi_bins);

helpers.log_msg(master_log, ...
    ['step06: mode=%s | ref=%s | epoch=[%.3f %.3f] s | hard_thresh_apply=%d | hard_thresh=%.1f uV | ' ...
     'baseline_apply=%d | baseline=[%d %d] ms | max_reject_prop=%.3f | warn_reject_prop=%.3f'], ...
    char(string(cfg.prep_06.epoching_mode)), ...
    char(string(cfg.prep_06.reference_mode)), ...
    cfg.prep_06.epoch_start_s, ...
    cfg.prep_06.epoch_end_s, ...
    cfg.prep_06.do_initial_hard_threshold_rejection, ...
    cfg.prep_06.initial_hard_threshold_uv, ...
    cfg.prep_06.do_baseline_correction, ...
    cfg.prep_06.base_start_ms, ...
    cfg.prep_06.base_end_ms, ...
    cfg.prep_06.max_reject_prop, ...
    helpers.getfield_safe(cfg.prep_06, 'warn_if_reject_prop_gt', 0.25));

% =========================================================================
% MASTER TOOLBOX INIT
% =========================================================================
helpers.init_toolboxes(cfg);
helpers.log_msg(master_log, 'Toolboxes initialized (master).');

% =========================================================================
% SUBJECT DISCOVERY
% =========================================================================
sub_ids = helpers.discover_subjects(cfg);
helpers.log_msg(master_log, 'Found %d subject(s).', numel(sub_ids));

% =========================================================================
% PARALLEL SETUP
% =========================================================================
use_parallel      = helpers.resolve_parallel_enable(cfg);
pool_obj          = [];
pool_started_here = false;

if use_parallel
    if isempty(getenv('MATLAB_PREFDIR'))
        pref_dir = fullfile(tempdir, 'matlab_prefs');
        setenv('MATLAB_PREFDIR', pref_dir);
        if exist(pref_dir, 'dir') ~= 7
            mkdir(pref_dir);
        end
    end

    n_workers = helpers.resolve_worker_count(cfg, master_log);
    helpers.log_msg(master_log, 'Parallel requested (%d workers).', n_workers);

    try
        pool_obj = gcp('nocreate');

        if isempty(pool_obj)
            parpool('local', n_workers);
            pool_obj = gcp('nocreate');
            pool_started_here = true;
        end

        cfg.parallel.pool_is_thread = false;
        cfg.parallel.pool_type      = "none";

        if ~isempty(pool_obj)
            cfg.parallel.pool_is_thread = isa(pool_obj, 'parallel.ThreadPool');
            cfg.parallel.pool_type      = string(class(pool_obj));
        end

        helpers.log_msg(master_log, ...
            'Parallel pool type: %s | thread_based=%d', ...
            char(string(cfg.parallel.pool_type)), ...
            cfg.parallel.pool_is_thread);

        if ~isempty(pool_obj) && ~cfg.parallel.pool_is_thread
            try
                cmd_root  = sprintf('addpath(''%s'');', strrep(root_dir,  '''', ''''''));
                cmd_steps = sprintf('addpath(''%s'');', strrep(steps_dir, '''', ''''''));

                pctRunOnAll(cmd_root);
                pctRunOnAll(cmd_steps);
                helpers.log_msg(master_log, 'Worker paths updated: root + steps');
            catch me_path
                helpers.log_msg(master_log, ...
                    'WARNING: Could not push paths to workers (%s). Continuing.', ...
                    me_path.message);
            end
        end

        if cfg.parallel.pool_is_thread
            helpers.log_msg(master_log, ...
                'Thread pool detected -> initializing EEGLAB in master.');

            if cfg.toolboxes.eeglab.nogui
                if cfg.env.mode == "hpc" && cfg.toolboxes.eeglab.no_update_check_on_hpc
                    try
                        setpref('eeglab', 'plugin_update_check', 0);
                        setpref('eeglab', 'update_check', 0);
                        setpref('eeglab', 'version_check', 0);
                    catch me_pref
                        helpers.log_msg(master_log, ...
                            'WARNING: setpref failed (%s). Continuing.', ...
                            me_pref.message);
                    end
                end
                eeglab('nogui');
            else
                eeglab;
            end

            helpers.log_msg(master_log, 'EEGLAB initialized (master, thread pool).');
        end

    catch me_pool
        if helpers.is_parallel_license_error(me_pool)
            helpers.log_msg(master_log, ...
                'WARNING: Parallel license unavailable. Falling back to serial. (%s)', ...
                me_pool.message);
        else
            helpers.log_msg(master_log, ...
                'WARNING: Could not start parallel pool. Falling back to serial. (%s)', ...
                me_pool.message);
        end

        try
            pool_obj = gcp('nocreate');
            if ~isempty(pool_obj) && pool_started_here
                delete(pool_obj);
            end
        catch
        end

        use_parallel                = false;
        cfg.parallel.enable         = false;
        cfg.parallel.pool_is_thread = false;
        cfg.parallel.pool_type      = "none";
        pool_obj                    = [];
        pool_started_here           = false;
    end
else
    helpers.log_msg(master_log, 'Parallel disabled (serial run).');
    cfg.parallel.pool_is_thread = false;
    cfg.parallel.pool_type      = "none";
end

% =========================================================================
% AMICA ON HPC -> FORCE SERIAL
% =========================================================================
force_serial_due_to_amica = ...
    use_parallel && ...
    (cfg.env.mode == "hpc") && ...
    cfg.steps.prep_04_ica.run && ...
    (string(cfg.prep_04.ica_method) == "amica");

if force_serial_due_to_amica
    helpers.log_msg(master_log, ...
        'HPC + AMICA subject loop -> forcing serial execution.');

    use_parallel                = false;
    cfg.parallel.enable         = false;
    cfg.parallel.pool_is_thread = false;
    cfg.parallel.pool_type      = "none";

    if ~isempty(pool_obj) && pool_started_here
        try
            delete(pool_obj);
            helpers.log_msg(master_log, 'Closed pool that was started for parallel execution.');
        catch me_close
            helpers.log_msg(master_log, ...
                'WARNING: Could not close pool after forcing serial mode (%s).', ...
                me_close.message);
        end
        
    end
end

% =========================================================================
% PREPLAN
% =========================================================================
subject_plans = helpers.build_subject_plans(cfg, sub_ids, master_log);

keep_mask = arrayfun(@(x) x.any_step_to_run, subject_plans);
subject_plans = subject_plans(keep_mask);

helpers.log_msg(master_log, ...
    'Planning complete: %d/%d subject(s) require work.', ...
    numel(subject_plans), numel(sub_ids));

subject_plans = helpers.sort_subject_plans_by_expected_cost(subject_plans);

% =========================================================================
% EXECUTION
% =========================================================================
n_sub = numel(subject_plans);
status = repmat(struct('subj', '', 'ok', false, 'message', '', 'logfile', ''), n_sub, 1);

if n_sub == 0
    helpers.log_msg(master_log, '=== PIPELINE END %s ===', datestr(now));
    helpers.log_msg(master_log, 'No subjects required work. Nothing to do.');
    return;
end

if use_parallel
    parfor i = 1:n_sub
        status(i) = helpers.run_one_subject(subject_plans(i), cfg); 
    end
    
else
    for i = 1:n_sub
        status(i) = helpers.run_one_subject(subject_plans(i), cfg);
    end
end

% Write one compact status index after all serial/parallel workers finish.
% This is the primary place to find every failed subject and its log path.
try
    pipeline_status_path = helpers.write_pipeline_status_summary(status, cfg);
    helpers.log_msg(master_log, ...
        'Pipeline subject-status table: %s', char(pipeline_status_path));
catch status_me
    helpers.log_msg(master_log, ...
        'WARNING: Could not write pipeline subject-status table: %s', ...
        status_me.message);
end

% Consolidate ICA QC automatically. Only the compact overview is written;
% full details remain in the per-subject component and QC tables.
if logical(helpers.getfield_safe(cfg.steps.prep_04_ica, 'run', false)) || ...
        logical(helpers.getfield_safe(cfg.steps.prep_05_after_ica, 'run', false))
    try
        [~, ~, ~, ica_qc_overview, ica_qc_overview_path] = ...
            helpers.collect_prep05_summary(cfg);
        helpers.log_ica_qc_overview( ...
            ica_qc_overview, master_log, ica_qc_overview_path);
    catch ica_qc_me
        helpers.log_msg(master_log, ...
            'WARNING: Automatic ICA QC overview could not be written: %s', ...
            ica_qc_me.message);
    end
end

% Combine ICA training summaries after all subjects have finished.
if cfg.steps.prep_03_until_ica.run && ...
        helpers.getfield_safe(cfg.prep_03, 'write_run_summary_table', true)

    try
        [~, summary_files] = helpers.collect_prep03_summary(cfg);

        for k = 1:numel(summary_files)
            helpers.log_msg(master_log, ...
                'ICA training summary saved: %s', summary_files{k});
        end

    catch qc_me
        helpers.log_msg(master_log, ...
            'WARNING: Final Step-03 QC collection failed: %s', ...
            qc_me.message);
    end
end

% Refresh the group summary once after every worker has finished, then build
% one consolidated warning for the subjects processed in this run. The
% warning itself is emitted only after the normal final summary below so it
% remains the last console output.
high_rejection_warning = "";
if isfield(cfg, 'steps') && isfield(cfg.steps, 'prep_06_epoching') && ...
        logical(helpers.getfield_safe(cfg.steps.prep_06_epoching, 'run', false))
    try
        [t_prep06_all, ~, ~, ~, ~] = helpers.collect_prep06_summary(cfg);
        processed_subject_ids = string({status.subj});
        warning_threshold = helpers.getfield_safe( ...
            cfg.prep_06, 'warn_if_reject_prop_gt', 0.25);
        [~, high_rejection_warning] = helpers.build_high_epoch_rejection_warning( ...
            t_prep06_all, processed_subject_ids, ...
            helpers.getfield_safe(cfg.prep_04, 'ica_method', "unknown"), ...
            helpers.resolve_qc_timestamp(cfg), warning_threshold);
    catch qc_me
        helpers.log_msg(master_log, ...
            'WARNING: Final Step-06 QC collection failed: %s', qc_me.message);
    end
end


% =========================================================================
% FINAL SUMMARY
% =========================================================================
ok_mask = [status.ok];
n_ok    = sum(ok_mask);
n_fail  = sum(~ok_mask);

helpers.log_msg(master_log, '=== PIPELINE END %s ===', datestr(now));
helpers.log_msg(master_log, 'Completed: %d ok | %d failed', n_ok, n_fail);

if n_fail > 0
    fail_idx = find(~ok_mask);
    expected_exclusion_mask = false(size(fail_idx));
    failure_details = strings(numel(fail_idx), 1);

    helpers.log_msg(master_log, 'Failed subjects:');

    for ii = 1:numel(fail_idx)
        k = fail_idx(ii);

        this_msg   = string(status(k).message);
        this_msg_l = lower(strtrim(this_msg));

        is_expected_exclusion = ...
            contains(this_msg_l, 'prep_06_epoching failed for sub-') && ...
            ( ...
                contains(this_msg_l, 'prep_06_epoching: no outputs written for sub-') || ...
                (contains(this_msg_l, 'prep_06_epoching: error: dataset') && contains(this_msg_l, 'is empty')) ...
            );

        expected_exclusion_mask(ii) = is_expected_exclusion;
        compact_msg = regexprep(this_msg, '\s+', ' ');
        failure_details(ii) = "sub-" + string(status(k).subj) + ...
            ": " + compact_msg;

        helpers.log_msg(master_log, ...
            '  sub-%s | expected_exclusion=%d | %s | log=%s', ...
            char(string(status(k).subj)), ...
            is_expected_exclusion, ...
            char(this_msg), ...
            char(string(status(k).logfile)));
    end

    n_expected   = sum(expected_exclusion_mask);
    n_unexpected = n_fail - n_expected;

    helpers.log_msg(master_log, ...
        'Failure breakdown: %d expected exclusions | %d unexpected failures', ...
        n_expected, n_unexpected);

    if n_unexpected == 0
        warning( ...
            'run_eeg_pipeline:ExpectedSubjectExclusions', ...
            ['Pipeline finished with %d expected Step-06 exclusion(s)/empty-dataset case(s) ' ...
             '(%d/%d subjects not written). See logs.'], ...
            n_expected, n_fail, n_sub);
    else
        preview_count = min(3, numel(failure_details));
        error('run_eeg_pipeline:SubjectFailures', ...
            ['Pipeline finished with failures (%d/%d). First failure(s): ' ...
             '%s. See the pipeline subject-status table, ICA-QC overview, ' ...
             'and linked subject logs.'], ...
            n_fail, n_sub, char(strjoin(failure_details(1:preview_count), ' | ')));
    end
end

if strlength(high_rejection_warning) > 0
    helpers.log_msg(master_log, ...
        '================================================================');
    helpers.log_msg(master_log, '%s', char(high_rejection_warning));
    helpers.log_msg(master_log, ...
        '================================================================');
    warning('run_eeg_pipeline:HighEpochRejection', ...
        '%s', char(high_rejection_warning));
end

end
