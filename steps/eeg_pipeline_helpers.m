% =========================================================================
% FILE: eeg_pipeline_helpers.m
% =========================================================================
function helpers = eeg_pipeline_helpers(default_log_file)
% EEG_PIPELINE_HELPERS Utility factory for the unified EEG runner.
%
% WHAT THIS FILE DOES
%   - Returns a struct of helper handles used by the runner and step files
%
% INPUT
%   - default_log_file : log file used by helpers.log_msg_default(...)
%
% OUTPUT
%   - helpers struct with function handles
%
% Saskia Wilken Dez 2025

helpers = struct();

% -------------------------------------------------------------------------
% Config-building helpers
% -------------------------------------------------------------------------
helpers.detect_env_mode          = @detect_env_mode_impl;
helpers.detect_machine_kind      = @detect_machine_kind_impl;
helpers.default_profile_for_mode = @default_profile_for_mode_impl;
helpers.get_hostname             = @get_hostname_impl;
helpers.get_env_first_nonempty   = @get_env_first_nonempty_impl;
helpers.get_raw_trigger_from_key = @get_raw_trigger_from_key_impl;
helpers.map_trigger_by_table     = @map_trigger_by_table_impl;
helpers.default_prep03_cfg       = @default_prep03_cfg_impl;
helpers.default_prep06_cfg       = @default_prep06_cfg_impl;

% -------------------------------------------------------------------------
% Logging and basic filesystem helpers
% -------------------------------------------------------------------------
helpers.log_msg                  = @(log_file, varargin) log_msg_impl(log_file, varargin{:});
helpers.log_msg_default          = @(varargin) log_msg_impl(default_log_file, varargin{:});
helpers.ensure_dir               = @ensure_dir_impl;
helpers.resolve_logs_dir         = @resolve_logs_dir_impl;
helpers.clear_directory_contents = @clear_directory_contents_impl;

% -------------------------------------------------------------------------
% Environment / worker helpers
% -------------------------------------------------------------------------
helpers.get_env_or_empty          = @get_env_or_empty_impl;
helpers.get_slurm_cpus_per_task   = @get_slurm_cpus_per_task_impl;
helpers.is_parallel_license_error = @is_parallel_license_error_impl;

% -------------------------------------------------------------------------
% Runner / planning helpers
% -------------------------------------------------------------------------
helpers.init_toolboxes                      = @init_toolboxes_impl;
helpers.discover_subjects                   = @discover_subjects_impl;
helpers.resolve_parallel_enable             = @resolve_parallel_enable_impl;
helpers.resolve_worker_count                = @resolve_worker_count_impl;
helpers.resolve_config_function             = @resolve_config_function_impl;
helpers.build_paths                         = @build_paths_impl;
helpers.build_subject_plans                 = @build_subject_plans_impl;
helpers.sort_subject_plans_by_expected_cost = @sort_subject_plans_by_expected_cost_impl;
helpers.run_one_subject                     = @run_one_subject_impl;

% -------------------------------------------------------------------------
% Overwrite / rerun helpers
% -------------------------------------------------------------------------
helpers.resolve_overwrite_mode      = @resolve_overwrite_mode_impl;
helpers.resolve_overwrite_policy    = @resolve_overwrite_policy_impl;
helpers.step_should_run_outputs     = @step_should_run_outputs_impl;
helpers.step_should_run_from_folder = @step_should_run_from_folder_impl;
helpers.get_step_subject_folder     = @get_step_subject_folder_impl;

% -------------------------------------------------------------------------
% EEG load / save / BIDS helpers
% -------------------------------------------------------------------------
helpers.safe_delete_set = @safe_delete_set_impl;
helpers.safe_save_set   = @safe_save_set_impl;
helpers.safe_load_set   = @safe_load_set_impl;
helpers.find_bids_vhdr  = @find_bids_vhdr_impl;
helpers.safe_load_bv    = @safe_load_bv_impl;
helpers.getfield_safe   = @getfield_safe_impl;

% -------------------------------------------------------------------------
% EEG comment / trigger helpers
% -------------------------------------------------------------------------
helpers.append_eeg_comment     = @append_eeg_comment_impl;
helpers.normalize_trigger_type = @normalize_trigger_type_impl;

% -------------------------------------------------------------------------
% EEG utility helpers used by step files
% -------------------------------------------------------------------------
helpers.normalize_event_types                  = @normalize_event_types_impl;
helpers.normalize_epoching_mode_value          = @normalize_epoching_mode_value_impl;
helpers.get_channel_indices_by_type            = @get_channel_indices_by_type_impl;
helpers.apply_reference_mode                   = @apply_reference_mode_impl;
helpers.build_epoching_output_paths            = @build_epoching_output_paths_impl;
helpers.normalize_event_list                   = @normalize_event_list_impl;
helpers.get_present_events                     = @get_present_events_impl;
helpers.preview_event_types                    = @preview_event_types_impl;
helpers.evaluate_min_trials_per_condition      = @evaluate_min_trials_per_condition_impl;
helpers.build_step06_summary_row               = @build_step06_summary_row_impl;
helpers.build_step06_summary_rows              = @build_step06_summary_rows_impl;
helpers.build_bad_channel_qc_table             = @build_bad_channel_qc_table_impl;
helpers.build_epoch_rejection_qc_table         = @build_epoch_rejection_qc_table_impl;
helpers.write_qc_table                         = @write_qc_table_impl;
helpers.resolve_qc_timestamp                   = @resolve_qc_timestamp_impl;
helpers.collect_bad_channel_qc                 = @collect_bad_channel_qc_impl;
helpers.collect_prep06_summary                 = @collect_prep06_summary_impl;
helpers.build_high_epoch_rejection_warning     = @build_high_epoch_rejection_warning_impl;
helpers.save_intermediate_set                  = @save_intermediate_set_impl;
helpers.apply_hard_epoch_threshold_rejection   = @apply_hard_epoch_threshold_rejection_impl;
helpers.apply_fallback_epoch_rejection         = @apply_fallback_epoch_rejection_impl;
helpers.create_baseline_condition_datasets     = @create_baseline_condition_datasets_impl;
helpers.normalize_event_types                 = @normalize_event_types_impl;
helpers.normalize_epoching_mode_value         = @normalize_epoching_mode_value_impl;
helpers.get_channel_indices_by_type           = @get_channel_indices_by_type_impl;
helpers.apply_reference_mode                  = @apply_reference_mode_impl;
helpers.build_epoching_output_paths           = @build_epoching_output_paths_impl;
helpers.normalize_event_list                  = @normalize_event_list_impl;
helpers.get_present_events                    = @get_present_events_impl;
helpers.preview_event_types                   = @preview_event_types_impl;
helpers.evaluate_min_trials_per_condition     = @evaluate_min_trials_per_condition_impl;
helpers.build_step06_summary_row              = @build_step06_summary_row_impl;
helpers.build_step06_summary_rows             = @build_step06_summary_rows_impl;
helpers.build_bad_channel_qc_table            = @build_bad_channel_qc_table_impl;
helpers.build_epoch_rejection_qc_table        = @build_epoch_rejection_qc_table_impl;
helpers.write_qc_table                        = @write_qc_table_impl;
helpers.resolve_qc_timestamp                  = @resolve_qc_timestamp_impl;
helpers.collect_bad_channel_qc                = @collect_bad_channel_qc_impl;
helpers.collect_prep06_summary                = @collect_prep06_summary_impl;
helpers.build_ica_training_summary            = @build_ica_training_summary_impl;
helpers.write_ica_training_summary            = @write_ica_training_summary_impl;
helpers.collect_prep03_summary                = @collect_prep03_summary_impl;
helpers.build_high_epoch_rejection_warning    = @build_high_epoch_rejection_warning_impl;
helpers.save_intermediate_set                 = @save_intermediate_set_impl;
helpers.apply_hard_epoch_threshold_rejection  = @apply_hard_epoch_threshold_rejection_impl;
helpers.apply_fallback_epoch_rejection        = @apply_fallback_epoch_rejection_impl;
helpers.create_baseline_condition_datasets    = @create_baseline_condition_datasets_impl;
helpers.resolve_baseline_condition_definitions = @resolve_baseline_condition_definitions_impl;
helpers.build_epoching_output_stem             = @build_epoching_output_stem_impl;
helpers.finalize_epoched_dataset               = @finalize_epoched_dataset_impl;
helpers.save_final_epoched_outputs             = @save_final_epoched_outputs_impl;
helpers.build_eeg_key_token_stream_with_time   = @build_eeg_key_token_stream_with_time_impl;
helpers.find_first_event_latency               = @find_first_event_latency_impl;
helpers.crop_internal_breaks                   = @crop_internal_breaks_impl;
helpers.ensure_channel_types                   = @ensure_channel_types_impl;
helpers.find_flat_or_invalid_channels          = @find_flat_or_invalid_channels_impl;
helpers.detect_bad_channels_clean_rawdata      = @detect_bad_channels_clean_rawdata_impl;
helpers.apply_filter_to_subset_only            = @apply_filter_to_subset_only_impl;
helpers.remove_line_noise_from_subset          = @remove_line_noise_from_subset_impl;
helpers.apply_jointprob_safely                 = @apply_jointprob_safely_impl;
helpers.apply_shared_epoch_rejection           = @apply_shared_epoch_rejection_impl;
helpers.apply_erplab_epoch_rejection           = @apply_erplab_epoch_rejection_impl;
helpers.reject_ica_prep_epochs_by_mad_variance = @reject_ica_prep_epochs_by_mad_variance_impl;
helpers.compute_data_rank_svd                  = @compute_data_rank_svd_impl;
helpers.make_unique_amica_tmpdir               = @make_unique_amica_tmpdir_impl;
helpers.safe_rmdir                             = @safe_rmdir_impl;
helpers.write_ic_topography_pngs               = @write_ic_topography_pngs_impl;
helpers.merge_structs_recursive                = @merge_structs_recursive_impl;


% -------------------------------------------------------------------------
% Behavior-log helpers
% -------------------------------------------------------------------------
helpers.find_behavior_log = @find_behavior_log_impl;
helpers.read_behavior_log = @read_behavior_log_impl;

% -------------------------------------------------------------------------
% Raw QC helper
% -------------------------------------------------------------------------
helpers.raw_qc_behavior_vs_eeg_and_write_csv = @raw_qc_behavior_vs_eeg_and_write_csv_impl;

end

% =========================================================================
% CONFIG-BUILDING HELPERS
% =========================================================================
function value = get_env_first_nonempty_impl(names)
value = "";

if nargin < 1 || isempty(names)
    return;
end

if ischar(names) || isstring(names)
    names = cellstr(string(names));
end

for i = 1:numel(names)
    tmp = getenv(char(string(names{i})));
    if ~isempty(tmp)
        value = string(tmp);
        return;
    end
end
end

function hn = get_hostname_impl()
hn = "";

cands = ["COMPUTERNAME","HOSTNAME"];
for i = 1:numel(cands)
    tmp = getenv(char(cands(i)));
    if ~isempty(tmp)
        hn = string(tmp);
        return;
    end
end

try
    [status, out] = system('hostname');
    if status == 0
        hn = string(strtrim(out));
    end
catch
end
end

function mode = detect_env_mode_impl(varargin)
legacy_env_prefix = "";
if nargin >= 1 && ~isempty(varargin{1})
    legacy_env_prefix = string(varargin{1});
end

env_names = {'EEG_PIPELINE_ENV_MODE'};
if strlength(strtrim(legacy_env_prefix)) > 0
    env_names{end+1} = [char(legacy_env_prefix) '_ENV_MODE']; %#ok<AGROW>
end

mode = string(get_env_first_nonempty_impl(env_names));
mode = lower(strtrim(mode));

if any(mode == ["pc","server","hpc"])
    return;
end

machine_kind = detect_machine_kind_impl(legacy_env_prefix);

switch machine_kind
    case "hpc_hummel"
        mode = "hpc";
    case "server_windows"
        mode = "server";
    otherwise
        mode = "pc";
end
end

function machine_kind = detect_machine_kind_impl(varargin)
legacy_env_prefix = "";
if nargin >= 1 && ~isempty(varargin{1})
    legacy_env_prefix = string(varargin{1});
end

machine_kind = "unknown";

env_names = {'EEG_PIPELINE_MACHINE_KIND'};
if strlength(strtrim(legacy_env_prefix)) > 0
    env_names{end+1} = [char(legacy_env_prefix) '_MACHINE_KIND']; %#ok<AGROW>
end

override = string(get_env_first_nonempty_impl(env_names));
override = lower(strtrim(override));

if any(override == ["local_windows","server_windows","hpc_hummel"])
    machine_kind = override;
    return;
end

hostname = lower(strtrim(get_hostname_impl()));

if strlength(hostname) > 0 && contains(hostname, "hummel")
    machine_kind = "hpc_hummel";
    return;
end

if ~isempty(getenv('SLURM_JOB_ID'))
    machine_kind = "hpc_hummel";
    return;
end

if strlength(hostname) > 0 && startsWith(hostname, "vdi")
    machine_kind = "server_windows";
    return;
end

if ispc
    machine_kind = "local_windows";
    return;
end
end

function profile = default_profile_for_mode_impl(mode, machine_kind)
mode         = string(lower(strtrim(mode)));
machine_kind = string(lower(strtrim(machine_kind)));

switch mode
    case "hpc"
        profile = "hpc_hummel";

    case "server"
        profile = "server_windows";

    case "pc"
        if machine_kind == "server_windows"
            profile = "server_windows";
        else
            profile = "pc";
        end

    otherwise
        profile = "pc";
end
end

function out = merge_structs_recursive_impl(base, override)
if nargin < 1 || isempty(base)
    out = override;
    return;
end

if nargin < 2 || isempty(override)
    out = base;
    return;
end

if ~isstruct(base) || ~isstruct(override)
    out = override;
    return;
end

out = base;
override_fields = fieldnames(override);

for i = 1:numel(override_fields)
    fn = override_fields{i};

    if ~isfield(out, fn)
        out.(fn) = override.(fn);
        continue;
    end

    if isstruct(out.(fn)) && isstruct(override.(fn))
        out.(fn) = merge_structs_recursive_impl(out.(fn), override.(fn));
    else
        out.(fn) = override.(fn);
    end
end
end

% =========================================================================
% LOGGING / FILESYSTEM
% =========================================================================
function log_msg_impl(log_file, varargin)
message_text = sprintf(varargin{:});
timestamp    = datestr(now, 'yyyy-mm-dd HH:MM:SS');

fprintf('[%s] %s\n', timestamp, message_text);

log_file = char(string(log_file));

try
    [parent_dir, ~, ~] = fileparts(log_file);
    if ~isempty(parent_dir)
        ensure_dir_impl(parent_dir);
    end
catch
end

fid = fopen(log_file, 'a');
if fid >= 0
    fprintf(fid, '[%s] %s\n', timestamp, message_text);
    fclose(fid);
end
end

function log_msg_file_only_impl(log_file, varargin)
message_text = sprintf(varargin{:});
timestamp    = datestr(now, 'yyyy-mm-dd HH:MM:SS');

log_file = char(string(log_file));

try
    [parent_dir, ~, ~] = fileparts(log_file);
    if ~isempty(parent_dir)
        ensure_dir_impl(parent_dir);
    end
catch
end

fid = fopen(log_file, 'a');
if fid >= 0
    fprintf(fid, '[%s] %s\n', timestamp, message_text);
    fclose(fid);
end
end

function ensure_dir_impl(path_in)
if exist(path_in, 'dir') ~= 7
    mkdir(path_in);
end
end

function logs_dir = resolve_logs_dir_impl(cfg)
% Resolve the pipeline log folder.
%
% Logs are intentionally stored next to the derivative output folders:
%
%   <derivatives_root>/logs
%
% This keeps run logs together with the generated preprocessing outputs
% instead of mixing them into the code folder or a temporary bootstrap path.

logs_dir = '';

if nargin < 1 || ~isstruct(cfg)
    error('resolve_logs_dir: cfg must be a struct.');
end

if isfield(cfg, 'paths') && isstruct(cfg.paths) && ...
        isfield(cfg.paths, 'derivatives_root') && ...
        strlength(string(cfg.paths.derivatives_root)) > 0

    logs_dir = fullfile(char(string(cfg.paths.derivatives_root)), 'logs');

elseif isfield(cfg, 'paths') && isstruct(cfg.paths) && ...
        isfield(cfg.paths, 'logs_dir') && ...
        strlength(string(cfg.paths.logs_dir)) > 0

    % Fallback for older configs that do not yet define derivatives_root.
    logs_dir = char(string(cfg.paths.logs_dir));

elseif isfield(cfg, 'root_dir') && strlength(string(cfg.root_dir)) > 0

    % Last-resort fallback.
    logs_dir = fullfile(char(string(cfg.root_dir)), 'logs');

else
    error('resolve_logs_dir: could not resolve logs_dir from cfg.paths.derivatives_root, cfg.paths.logs_dir, or cfg.root_dir.');
end

ensure_dir_impl(logs_dir);
end

function clear_directory_contents_impl(path_in)
path_in = char(string(path_in));

if exist(path_in, 'dir') ~= 7
    return;
end

dir_info = dir(path_in);
real_mask = ~ismember({dir_info.name}, {'.','..'});
dir_info = dir_info(real_mask);

for k = 1:numel(dir_info)
    full_item = fullfile(path_in, dir_info(k).name);
    if dir_info(k).isdir
        rmdir(full_item, 's');
    else
        delete(full_item);
    end
end
end

% =========================================================================
% ENVIRONMENT / WORKERS
% =========================================================================
function value = get_env_or_empty_impl(name)
tmp = getenv(name);
if isempty(tmp)
    value = "";
else
    value = string(tmp);
end
end

function n_workers = get_slurm_cpus_per_task_impl()
n_workers = [];
value = getenv('SLURM_CPUS_PER_TASK');

if ~isempty(value)
    tmp = str2double(value);
    if ~isnan(tmp) && tmp >= 1
        n_workers = tmp;
    end
end
end

function tf = is_parallel_license_error_impl(me)
tf = false;

try
    message_text = lower(string(me.message));
catch
    message_text = "";
end

try
    message_id = lower(string(me.identifier));
catch
    message_id = "";
end

tf = tf || contains(message_text, "license manager error -4");
tf = tf || (contains(message_text, "maximum number of users") && contains(message_text, "toolbox"));
tf = tf || contains(message_text, "distrib_computing_toolbox");
tf = tf || (contains(message_text, "unable to check out a license") && contains(message_text, "parallel"));
tf = tf || (contains(message_id, "license") && contains(message_text, "check out"));
end

% =========================================================================
% RUNNER / PLANNING
% =========================================================================
function init_toolboxes_impl(cfg)
addpath(cfg.root_dir);

eeglab_root = resolve_toolbox_root_impl(cfg, "eeglab");
faster_root = resolve_toolbox_root_impl(cfg, "faster");
erplab_root = resolve_toolbox_root_impl(cfg, "erplab");

if strlength(eeglab_root) > 0
    if exist(char(eeglab_root), 'dir') == 7
        addpath(char(eeglab_root));
    end
end

if strlength(faster_root) > 0
    if exist(char(faster_root), 'dir') == 7
        if cfg.toolboxes.use_genpath
            addpath(genpath(char(faster_root)));
        else
            addpath(char(faster_root));
        end
    end
end

if strlength(erplab_root) > 0
    if exist(char(erplab_root), 'dir') == 7
        erplab_use_genpath = true;

        if isfield(cfg.toolboxes, 'erplab') && ...
                isstruct(cfg.toolboxes.erplab) && ...
                isfield(cfg.toolboxes.erplab, 'use_genpath')
            erplab_use_genpath = logical(cfg.toolboxes.erplab.use_genpath);
        end

        if erplab_use_genpath
            addpath(genpath(char(erplab_root)));
        else
            addpath(char(erplab_root));
        end
    end
end

if exist('eeglab', 'file') ~= 2
    error('EEGLAB not found. Expected eeglab.m under: %s', eeglab_root);
end
end

function root = resolve_toolbox_root_impl(cfg, which_toolbox)
which_toolbox = string(which_toolbox);
env_name = upper(which_toolbox) + "_ROOT";
root = string(getenv(env_name));

if strlength(root) > 0
    return;
end

mode = string(cfg.env.mode);

switch mode
    case "pc"
        field_name = "path_" + which_toolbox + "_pc";
    case "server"
        field_name = "path_" + which_toolbox + "_server";
    case "hpc"
        field_name = "path_" + which_toolbox + "_hpc";
    otherwise
        field_name = "";
end

if strlength(field_name) > 0 && isfield(cfg.toolboxes, char(field_name))
    root = string(cfg.toolboxes.(char(field_name)));
else
    root = "";
end
end

function sub_ids = discover_subjects_impl(cfg)
sub_ids = {};
discovery_root = "";

% -------------------------------------------------------------------------
% 1) Explicit subject list always wins
% -------------------------------------------------------------------------
if isfield(cfg, 'subjects') && isfield(cfg.subjects, 'list') && ~isempty(cfg.subjects.list)
    sub_ids = cfg.subjects.list;
    discovery_root = "cfg.subjects.list";

else
    % ---------------------------------------------------------------------
    % 2) Decide where discovery should happen
    %    - If Step 01 runs, discover from raw EEG source files
    %    - Otherwise discover from existing BIDS sub-* folders
    % ---------------------------------------------------------------------
    use_step01_source_discovery = ...
        isfield(cfg, 'steps') && ...
        isfield(cfg.steps, 'prep_01_bids_formatting') && ...
        isfield(cfg.steps.prep_01_bids_formatting, 'run') && ...
        cfg.steps.prep_01_bids_formatting.run;

    if use_step01_source_discovery
        source_root = char(string(cfg.paths.source_eeg_root));
        discovery_root = string(source_root);

        if exist(source_root, 'dir') ~= 7
            error('Step 01 subject discovery failed: source_eeg_root does not exist: %s', source_root);
        end

        if isfield(cfg, 'prep_01') && isfield(cfg.prep_01, 'raw_eeg_regex') && ...
                strlength(string(cfg.prep_01.raw_eeg_regex)) > 0
            raw_regex = char(string(cfg.prep_01.raw_eeg_regex));
        else
            raw_regex = '^.*?(\d{3})(?:_(\d{3}))?\.vhdr$'; %raw_regex = '^.*?(\d{3})(?:_(\d{3}))?\.vhdr$';
        end
        
        dir_info = dir(fullfile(source_root, '**', '*.vhdr'));
        %dir_info = dir(fullfile(source_root, '*.vhdr'));
        tmp_ids = {};

        for k = 1:numel(dir_info)
            this_name = dir_info(k).name;
            tok = regexp(this_name, raw_regex, 'tokens', 'once');

            if ~isempty(tok) && ~isempty(tok{1})
                tmp_ids{end+1} = char(string(tok{1})); %#ok<AGROW>
            end
        end

        sub_ids = unique(tmp_ids, 'stable');

    else
        bids_root = char(string(cfg.paths.bids_root));
        discovery_root = string(bids_root);

        dir_info = dir(fullfile(bids_root, 'sub-*'));
        dir_info = dir_info([dir_info.isdir]);

        sub_ids = {dir_info.name};
        sub_ids = cellfun(@(x) erase(x, 'sub-'), sub_ids, 'UniformOutput', false);
    end
end

if isstring(sub_ids)
    sub_ids = cellstr(sub_ids(:));
elseif ischar(sub_ids)
    sub_ids = {sub_ids};
elseif iscell(sub_ids)
    sub_ids = sub_ids(:);
    sub_ids = cellfun(@(x) char(string(x)), sub_ids, 'UniformOutput', false);
elseif isnumeric(sub_ids)
    sub_ids = arrayfun(@(x) sprintf('%03d', x), sub_ids(:), 'UniformOutput', false);
else
    sub_ids = cellstr(string(sub_ids(:)));
end

sub_ids = sub_ids(:);

valid_regex = cfg.constants.valid_sub_id_regex;
keep_mask = ~cellfun(@isempty, regexp(sub_ids, valid_regex, 'once'));
sub_ids = sub_ids(keep_mask);

if isempty(sub_ids)
    error('No valid subject IDs found in %s (after regex filter).', char(string(discovery_root)));
end

sub_num = cellfun(@str2double, sub_ids);
[~, sort_ix] = sort(sub_num);
sub_ids = sub_ids(sort_ix);

use_min = false;
min_id_num = NaN;

if isfield(cfg, 'subjects') && isfield(cfg.subjects, 'min_id')
    min_id_raw = cfg.subjects.min_id;

    if ~(isempty(min_id_raw) || ...
            (isstring(min_id_raw) && strlength(min_id_raw) == 0) || ...
            (ischar(min_id_raw) && isempty(strtrim(min_id_raw))))
        min_id_num = str2double(string(min_id_raw));
        use_min = ~isnan(min_id_num) && isfinite(min_id_num);
    end
end

if use_min
    sub_ids = sub_ids(cellfun(@str2double, sub_ids) >= min_id_num);
end

if isempty(sub_ids)
    if use_min
        error('No subjects remain after min_id >= %03d filter.', round(min_id_num));
    else
        error('No subjects remain after filtering (unexpected).');
    end
end
end

function use_parallel = resolve_parallel_enable_impl(cfg)
use_parallel = false;

if isfield(cfg, 'parallel') && isfield(cfg.parallel, 'enable')
    use_parallel = logical(cfg.parallel.enable);
end
end

function n_workers = resolve_worker_count_impl(cfg, master_log)
if ~isempty(cfg.parallel.force_workers)
    n_workers = cfg.parallel.force_workers;
    log_msg_impl(master_log, ...
        'Resolved worker count from cfg.parallel.force_workers=%d', ...
        n_workers);
    return;
end

worker_env = getenv('EEG_PIPELINE_WORKERS');
if ~isempty(worker_env)
    tmp = str2double(worker_env);
    if ~isnan(tmp) && tmp >= 1
        n_workers = tmp;
        log_msg_impl(master_log, ...
            'Resolved worker count from EEG_PIPELINE_WORKERS=%d', ...
            n_workers);
        return;
    end
end

machine_kind = "";
if isfield(cfg, 'env') && isfield(cfg.env, 'machine_kind')
    machine_kind = string(cfg.env.machine_kind);
end

profile = "";
if isfield(cfg, 'paths') && isfield(cfg.paths, 'profile')
    profile = string(cfg.paths.profile);
end

switch machine_kind
    case "server_windows"
        n_workers = 4;

    case "local_windows"
        n_workers = 2;

    case "hpc_hummel"
        tmp = get_slurm_cpus_per_task_impl();
        if ~isempty(tmp)
            n_workers = tmp;
        else
            n_workers = feature('numcores');
        end

    otherwise
        switch profile
            case "server_windows"
                n_workers = 4;
            case "pc"
                n_workers = 2;
            case "hpc_hummel"
                tmp = get_slurm_cpus_per_task_impl();
                if ~isempty(tmp)
                    n_workers = tmp;
                else
                    n_workers = feature('numcores');
                end
            otherwise
                n_workers = min(2, feature('numcores'));
        end
end

n_workers = max(1, round(n_workers));

if ~strcmp(machine_kind, "hpc_hummel")
    try
        cluster_obj = parcluster('local');
        if ~isempty(cluster_obj.NumWorkers) && isnumeric(cluster_obj.NumWorkers)
            n_workers = min(n_workers, cluster_obj.NumWorkers);
        end
    catch
    end
end

log_msg_impl(master_log, ...
    'Resolved worker count=%d (machine_kind=%s, profile=%s)', ...
    n_workers, machine_kind, profile);
end

function [config_fn, config_name, config_file] = resolve_config_function_impl(config_spec, root_dir)
config_file = "";

if isa(config_spec, 'function_handle')
    config_fn   = config_spec;
    config_name = func2str(config_spec);
    config_file = which(config_name);
    return;
end

config_text = char(string(config_spec));
config_text = strtrim(config_text);

if isempty(config_text)
    error('Config argument is empty.');
end

config_dir = '';
[maybe_dir, maybe_name, maybe_ext] = fileparts(config_text);

if ~isempty(maybe_dir)
    config_dir  = maybe_dir;
    config_name = maybe_name;
else
    config_name = config_text;
    if endsWith(config_name, '.m', 'IgnoreCase', true)
        [~, config_name] = fileparts(config_name);
    end
end

if ~isempty(config_dir)
    if exist(config_dir, 'dir') ~= 7
        error('Config directory not found: %s', config_dir);
    end
    addpath(config_dir);
end

if exist(config_name, 'file') ~= 2
    candidate_in_root        = fullfile(root_dir, [config_name '.m']);
    candidate_in_root_parent = fullfile(fileparts(root_dir), [config_name '.m']);
    if exist(candidate_in_root, 'file') == 2
        addpath(root_dir);
    elseif exist(candidate_in_root_parent, 'file') == 2
        addpath(fileparts(root_dir))
    end
end

if exist(config_name, 'file') ~= 2
    if ~isempty(maybe_ext)
        error('Config file not found: %s', config_text);
    else
        error('Config function not found on path: %s', config_name);
    end
end

config_fn   = str2func(config_name);
config_file = which(config_name);

if isempty(config_file)
    error('Could not resolve config function file for: %s', config_name);
end
end

function paths = build_paths_impl(cfg, subj_id)
paths = struct();

paths.root_dir         = cfg.root_dir;
paths.source_eeg_root  = char(string(cfg.paths.source_eeg_root));
paths.source_beh_root  = char(string(cfg.paths.source_beh_root));
paths.bids_root        = char(string(cfg.paths.bids_root));
paths.derivatives_root = char(string(cfg.paths.derivatives_root));
paths.logs_dir         = resolve_logs_dir_impl(cfg);

paths.subj_label = sprintf('sub-%s', subj_id);

session_label = ""; % 01
if isfield(cfg, 'bids') && isfield(cfg.bids, 'session_label') && strlength(string(cfg.bids.session_label)) > 0
    session_label = string(cfg.bids.session_label);
end

task_label = "";
if isfield(cfg, 'bids') && isfield(cfg.bids, 'task_label') && strlength(string(cfg.bids.task_label)) > 0
    task_label = string(cfg.bids.task_label);
end

paths.session_label   = char(session_label);
paths.bids_task_label = char(task_label);

% BIDS locations
paths.bids_sub_dir    = fullfile(paths.bids_root, paths.subj_label);
paths.bids_ses_dir    = fullfile(paths.bids_sub_dir, ['ses-' char(session_label)]);
paths.prep_01_out_dir = paths.bids_ses_dir;

% Derivatives roots
paths.step_02_root           = fullfile(paths.derivatives_root, '01_trigger_fix');
paths.step_03_until_ica_root = fullfile(paths.derivatives_root, '02_until_ica');
paths.step_03_for_ica_root   = fullfile(paths.derivatives_root, '03_for_ica');

ica_tag = "runica";
if isfield(cfg, 'prep_04') && isfield(cfg.prep_04, 'ica_method')
    ica_tag = string(cfg.prep_04.ica_method);
end

suffix = "";
if isfield(cfg.paths, 'branch_by_ica_method') && cfg.paths.branch_by_ica_method
    suffix = "_" + ica_tag;
end

paths.step_04_root = fullfile(paths.derivatives_root, char("04_after_ica"      + suffix));
paths.step_05_root = fullfile(paths.derivatives_root, char("05_until_epoching" + suffix));
paths.step_06_root = fullfile(paths.derivatives_root, char("06_epoched"        + suffix));

% Only create shared roots here.
% Do NOT create subject-specific folders eagerly, otherwise empty folders
% appear already during preplanning or for excluded subjects.
ensure_dir_impl(paths.step_02_root);
ensure_dir_impl(paths.step_03_until_ica_root);
ensure_dir_impl(paths.step_03_for_ica_root);
ensure_dir_impl(paths.step_04_root);
ensure_dir_impl(paths.step_05_root);
ensure_dir_impl(paths.step_06_root);

% Subject-specific step folders
paths.prep_02_out_dir           = fullfile(paths.step_02_root, paths.subj_label);
paths.prep_03_out_dir_until_ica = fullfile(paths.step_03_until_ica_root, paths.subj_label);
paths.prep_03_out_dir_for_ica   = fullfile(paths.step_03_for_ica_root, paths.subj_label);
paths.prep_04_out_dir           = fullfile(paths.step_04_root, paths.subj_label);
paths.prep_05_out_dir           = fullfile(paths.step_05_root, paths.subj_label);
paths.prep_06_out_dir           = fullfile(paths.step_06_root, paths.subj_label);

% Unified quality-control root. Logs remain separate because they are
% diagnostic text streams; all user-facing QC artifacts live below qc/.
paths.qc_root = fullfile(paths.derivatives_root, 'qc');
ensure_dir_impl(paths.qc_root);

paths.qc_ica_training_root   = fullfile(paths.qc_root, '03_ica_training');
paths.qc_break_crop_root     = fullfile(paths.qc_root, '03_break_cropping');
paths.qc_bad_chans_root      = fullfile(paths.qc_root, '03_bad_chans');
paths.qc_ica_components_root = fullfile(paths.qc_root, '05_ica_comps');
paths.qc_epoch_rej_root      = fullfile(paths.qc_root, '06_epoch_rej');

ensure_dir_impl(paths.qc_ica_training_root);
ensure_dir_impl(paths.qc_break_crop_root);
ensure_dir_impl(paths.qc_bad_chans_root);
ensure_dir_impl(paths.qc_ica_components_root);
ensure_dir_impl(paths.qc_epoch_rej_root);

paths.qc_ica_components_subj_dir = fullfile(paths.qc_ica_components_root, paths.subj_label);
paths.qc_bad_chans_subj_dir       = fullfile(paths.qc_bad_chans_root, paths.subj_label);
paths.qc_epoch_rej_subj_dir       = fullfile(paths.qc_epoch_rej_root, paths.subj_label);

% Backward-compatible aliases for Step 05 and older callers. Their values
% now point into qc/05_ica_comps; no new derivatives/checks tree is created.
paths.checks_root = paths.qc_root;
paths.checks_ica_components_root = paths.qc_ica_components_root;
paths.checks_ica_components_subj_dir = paths.qc_ica_components_subj_dir;
paths.checks_ica_components_rej_dir  = fullfile(paths.checks_ica_components_subj_dir, 'rej');
paths.checks_ica_components_edge_dir = fullfile(paths.checks_ica_components_subj_dir, 'edge');

paths.qc_dir = fullfile(paths.qc_root, paths.subj_label);
end

function subject_plans = build_subject_plans_impl(cfg, sub_ids, master_log)
step_names = { ...
    'prep_01_bids_formatting', ...
    'prep_02_triggerfix', ...
    'prep_03_until_ica', ...
    'prep_04_ica', ...
    'prep_05_after_ica', ...
    'prep_06_epoching'};

subject_plans = repmat(struct( ...
    'subj_id', '', ...
    'any_step_to_run', false, ...
    'steps', struct()), numel(sub_ids), 1);

for i = 1:numel(sub_ids)
    subj_id = sub_ids{i};
    paths   = build_paths_impl(cfg, subj_id);

    plan = struct();
    plan.subj_id = subj_id;
    plan.any_step_to_run = false;
    plan.steps = struct();

    for s = 1:numel(step_names)
        step_name = step_names{s};
        step_cfg  = cfg.steps.(step_name);

        info = struct();
        info.run = false;
        info.reason = "step disabled";
        info.step_folder = "";
        info.folder_info = struct();
        info.delete_before_run = false;
        info.policy = struct();

        if ~step_cfg.run
            plan.steps.(step_name) = info;
            continue;
        end

        policy = resolve_overwrite_policy_impl(cfg, step_cfg);
        step_folder = get_step_subject_folder_impl(paths, step_name);
        [do_run, reason, folder_info] = step_should_run_from_folder_impl(step_folder, policy);

        info.run = do_run;
        info.reason = reason;
        info.step_folder = step_folder;
        info.folder_info = folder_info;
        info.policy = policy;
        info.delete_before_run = do_run && folder_info.exists && ~folder_info.is_empty;

        plan.steps.(step_name) = info;
    end

    if cfg.steps.enable_downstream_rerun
        plan = propagate_downstream_reruns_impl(plan, step_names, master_log, i);
    end

    run_flags = false(1, numel(step_names));
    for s = 1:numel(step_names)
        run_flags(s) = plan.steps.(step_names{s}).run;
    end
    plan.any_step_to_run = any(run_flags);

    subject_plans(i) = plan;

    % # CHECK: can this differ per subject within same pipeline, i.e. same runlog? otherwise maybe only log once?
    log_msg_impl(master_log, ...
        'Preplan sub-%s | 01=%d | 02=%d | 03=%d | 04=%d | 05=%d | 06=%d', ...
        subj_id, ...
        plan.steps.prep_01_bids_formatting.run, ...
        plan.steps.prep_02_triggerfix.run, ...
        plan.steps.prep_03_until_ica.run, ...
        plan.steps.prep_04_ica.run, ...
        plan.steps.prep_05_after_ica.run, ...
        plan.steps.prep_06_epoching.run);
end
end

function plan = propagate_downstream_reruns_impl(plan, step_names, master_log, i) % # TODO: is passing i the only way to not log the forced re-run repeatedly
triggered = false;

for s = 1:numel(step_names)
    step_name = step_names{s};
    info = plan.steps.(step_name);

    if info.run
        triggered = true;
        plan.steps.(step_name) = info;
        continue;
    end

    if triggered
        if isfield(info, 'policy') && ~isempty(info.policy)
            info.run = true;
            info.reason = "rerun forced because earlier enabled step will be regenerated";

            if i == 1
                log_msg_impl(master_log, ...
                    'Forced rerun of downstream steps: 01=%d | 02=%d | 03=%d | 04=%d | 05=%d | 06=%d', ...
                    plan.steps.prep_01_bids_formatting.run, ...
                    plan.steps.prep_02_triggerfix.run, ...
                    plan.steps.prep_03_until_ica.run, ...
                    plan.steps.prep_04_ica.run, ...
                    plan.steps.prep_05_after_ica.run, ...
                    plan.steps.prep_06_epoching.run);
            end

            if isfield(info, 'folder_info') && isstruct(info.folder_info) && ...
                    isfield(info.folder_info, 'exists') && isfield(info.folder_info, 'is_empty')
                info.delete_before_run = info.folder_info.exists && ~info.folder_info.is_empty;
            else
                info.delete_before_run = false;
            end

            plan.steps.(step_name) = info;
        end
    end
end
end

function subject_plans = sort_subject_plans_by_expected_cost_impl(subject_plans)
if isempty(subject_plans)
    return;
end

weights = zeros(numel(subject_plans), 1);

for i = 1:numel(subject_plans)
    s = subject_plans(i).steps;
    weights(i) = ...
        100 * double(s.prep_04_ica.run) + ...
        20 * double(s.prep_03_until_ica.run) + ...
        10 * double(s.prep_01_bids_formatting.run) + ...
        10 * double(s.prep_05_after_ica.run) + ...
        5 * double(s.prep_06_epoching.run) + ...
        1 * double(s.prep_02_triggerfix.run);
end

[~, ix] = sort(weights, 'descend');
subject_plans = subject_plans(ix);
end

function out = run_one_subject_impl(subject_plan, cfg)
subj_id = subject_plan.subj_id;

out = struct('subj', subj_id, 'ok', false, 'message', '', 'logfile', '');

logs_dir = resolve_logs_dir_impl(cfg);
cfg.paths.logs_dir = logs_dir;

sub_log = fullfile( ...
    logs_dir, ...
    sprintf('%s-%s_%s.log', ...
    cfg.constants.log_prefix_subject, ...
    subj_id, ...
    datestr(now, cfg.constants.datestr_subject)));

out.logfile = sub_log;

helpers = eeg_pipeline_helpers(sub_log);
paths = struct();

try
    helpers.log_msg(sub_log, '--- START sub-%s ---', subj_id);
    t_subject = tic;

    is_thread_pool = isfield(cfg, 'parallel') && ...
        isfield(cfg.parallel, 'pool_is_thread') && ...
        cfg.parallel.pool_is_thread;

    if is_thread_pool
        helpers.log_msg(sub_log, ...
            'Thread pool -> skipping init_toolboxes + eeglab init inside worker.');
    else
        init_toolboxes_impl(cfg);

        if cfg.toolboxes.eeglab.nogui
            if cfg.env.mode == "hpc" && cfg.toolboxes.eeglab.no_update_check_on_hpc
                try
                    setpref('eeglab', 'plugin_update_check', 0);
                    setpref('eeglab', 'update_check', 0);
                    setpref('eeglab', 'version_check', 0);
                catch me_pref
                    helpers.log_msg(sub_log, ...
                        'WARNING: setpref failed (%s). Continuing.', ...
                        me_pref.message);
                end
            end
            eeglab('nogui');
        else
            eeglab;
        end

        helpers.log_msg(sub_log, 'EEGLAB initialized.');
    end

    paths = build_paths_impl(cfg, subj_id);

    helpers.log_msg(sub_log, ...
        'BIDS context: session=%s | task=%s | bids_ses_dir=%s', ...
        string(paths.session_label), ...
        string(paths.bids_task_label), ...
        string(paths.bids_ses_dir));

    % Step 01
    run_step_with_logging_impl( ...
        'prep_01_bids_formatting', ...
        'Step 01: BIDS formatting', ...
        subject_plan, cfg, paths, helpers, sub_log, subj_id);

    % Step 02
    run_step_with_logging_impl( ...
        'prep_02_triggerfix', ...
        'Step 02: triggerfix', ...
        subject_plan, cfg, paths, helpers, sub_log, subj_id);

    % Step 03
    run_step_with_logging_impl( ...
        'prep_03_until_ica', ...
        'Step 03: until ICA', ...
        subject_plan, cfg, paths, helpers, sub_log, subj_id);

    % Step 04
    run_step_with_logging_impl( ...
        'prep_04_ica', ...
        'Step 04: ICA', ...
        subject_plan, cfg, paths, helpers, sub_log, subj_id);

    % Step 05
    run_step_with_logging_impl( ...
        'prep_05_after_ica', ...
        'Step 05: IC rejection (ICLabel)', ...
        subject_plan, cfg, paths, helpers, sub_log, subj_id);

    % Step 06
    run_step_with_logging_impl( ...
        'prep_06_epoching', ...
        'Step 06: epoching + final rejection', ...
        subject_plan, cfg, paths, helpers, sub_log, subj_id);

    cleanup_empty_subject_dirs_impl(paths, sub_log);

    helpers.log_msg(sub_log, 'TOTAL subject runtime: %.2f min', toc(t_subject) / 60);
    helpers.log_msg(sub_log, '--- END sub-%s OK ---', subj_id);

    out.ok = true;

catch me
    try
        cleanup_empty_subject_dirs_impl(paths, sub_log);
    catch
    end

    out.ok = false;
    out.message = me.message;

    helpers.log_msg(sub_log, 'ERROR: %s', me.message);
    log_msg_file_only_impl(sub_log, '%s', getReport(me, 'extended', 'hyperlinks', 'off'));

    try
        [parent_dir, base_name, ext] = fileparts(sub_log);
        err_log = fullfile(parent_dir, sprintf('%s_ERR%s', base_name, ext));
        if exist(sub_log, 'file')
            movefile(sub_log, err_log);
            out.logfile = err_log;
        end
    catch
    end
end
end

function run_step_with_logging_impl(step_name, step_label, subject_plan, cfg, paths, helpers, log_file, subj_id)
step_info = subject_plan.steps.(step_name);

if step_info.run
    maybe_clear_step_folder_impl(paths, step_name, subject_plan, helpers, cfg, log_file);

    helpers.log_msg(log_file, '%s', step_label);
    t_step = tic;

    step_out = feval(cfg.step_fns.(step_name), subj_id, cfg, paths, helpers);

    helpers.log_msg(log_file, '%s runtime: %.2f min', step_label, toc(t_step) / 60);

    if ~step_out.ok
        error('%s failed for sub-%s: %s', step_name, subj_id, step_out.message);
    end
else
    helpers.log_msg(log_file, ...
        '%s -> skipped by preplan (%s)', ...
        step_label, step_info.reason);
end
end

function maybe_clear_step_folder_impl(paths, step_name, subject_plan, helpers, cfg, log_file) %#ok<INUSD>
info = subject_plan.steps.(step_name);

if ~info.delete_before_run
    return;
end

step_folder = get_step_subject_folder_impl(paths, step_name);

helpers.log_msg(log_file, 'Clearing step folder before rerun: %s', step_folder);
clear_directory_contents_impl(step_folder);
end

function cleanup_empty_subject_dirs_impl(paths, log_file)
if nargin < 1 || ~isstruct(paths) || isempty(fieldnames(paths))
    return;
end

candidate_fields = { ...
    'checks_ica_components_rej_dir', ...
    'checks_ica_components_edge_dir', ...
    'checks_ica_components_subj_dir', ...
    'qc_dir', ...
    'prep_06_out_dir', ...
    'prep_05_out_dir', ...
    'prep_04_out_dir', ...
    'prep_03_out_dir_for_ica', ...
    'prep_03_out_dir_until_ica', ...
    'prep_02_out_dir'};

for i = 1:numel(candidate_fields)
    fn = candidate_fields{i};
    if isfield(paths, fn)
        prune_empty_dir_tree_impl(paths.(fn), log_file);
    end
end
end

function was_removed = prune_empty_dir_tree_impl(path_in, log_file)
was_removed = false;

path_in = char(string(path_in));
if isempty(path_in) || exist(path_in, 'dir') ~= 7
    return;
end

dir_info = dir(path_in);
real_mask = ~ismember({dir_info.name}, {'.','..'});
dir_info = dir_info(real_mask);

for k = 1:numel(dir_info)
    if dir_info(k).isdir
        prune_empty_dir_tree_impl(fullfile(path_in, dir_info(k).name), log_file);
    end
end

dir_info = dir(path_in);
real_mask = ~ismember({dir_info.name}, {'.','..'});
dir_info = dir_info(real_mask);

if isempty(dir_info)
    try
        rmdir(path_in);
        was_removed = true;

        if nargin >= 2 && ~isempty(log_file)
            log_msg_impl(log_file, 'Removed empty directory: %s', path_in);
        end
    catch
    end
end
end


% =========================================================================
% OVERWRITE / RERUN HELPERS
% =========================================================================
function overwrite_mode = resolve_overwrite_mode_impl(cfg, step_overwrite_mode)
overwrite_mode = string(cfg.io.overwrite_mode);

if nargin >= 2 && strlength(string(step_overwrite_mode)) > 0
    overwrite_mode = string(step_overwrite_mode);
end

if ~ismember(overwrite_mode, ["delete","skip","if_older_than"])
    overwrite_mode = "delete";
end
end

function policy = resolve_overwrite_policy_impl(cfg, step_cfg)
policy = struct();
policy.mode = string(cfg.io.overwrite_mode);
policy.cutoff_raw = "";
policy.cutoff_datenum = NaN;

if isfield(cfg, 'io') && isfield(cfg.io, 'overwrite_if_older_than')
    policy.cutoff_raw = string(cfg.io.overwrite_if_older_than);
end

if nargin >= 2 && isstruct(step_cfg)
    if isfield(step_cfg, 'overwrite_mode') && strlength(string(step_cfg.overwrite_mode)) > 0
        policy.mode = string(step_cfg.overwrite_mode);
    end
    if isfield(step_cfg, 'overwrite_if_older_than') && strlength(string(step_cfg.overwrite_if_older_than)) > 0
        policy.cutoff_raw = string(step_cfg.overwrite_if_older_than);
    end
end

if ~ismember(policy.mode, ["delete","skip","if_older_than"])
    policy.mode = "delete";
end

if policy.mode == "if_older_than"
    policy.cutoff_datenum = parse_cutoff_to_datenum_impl(policy.cutoff_raw);
    if isnan(policy.cutoff_datenum)
        error('overwrite_mode="if_older_than" requires a valid cutoff date. Got: %s', policy.cutoff_raw);
    end
end
end

function dn = parse_cutoff_to_datenum_impl(x)
dn = NaN;

if nargin < 1 || isempty(x)
    return;
end

if isnumeric(x) && isscalar(x) && isfinite(x)
    dn = x;
    return;
end

x = char(string(x));
x = strtrim(x);

if isempty(x)
    return;
end

time_formats = { ...
    'yyyy-mm-dd HH:MM:SS', ...
    'yyyy-mm-dd HH:MM', ...
    'yyyy-mm-dd', ...
    'dd.mm.yyyy HH:MM:SS', ...
    'dd.mm.yyyy HH:MM', ...
    'dd.mm.yyyy'};

for k = 1:numel(time_formats)
    try
        dn = datenum(x, time_formats{k});
        if ~isnan(dn)
            return;
        end
    catch
    end
end

try
    dn = datenum(datetime(x));
catch
end
end

function [do_run, reason, needs_regen] = step_should_run_outputs_impl(out_files, overwrite_mode, cfg)
needs_regen = false;

if nargin < 1 || isempty(out_files)
    out_files = {};
end

if nargin < 2 || isempty(overwrite_mode)
    overwrite_mode = "delete";
end

if nargin < 3 || isempty(cfg)
    cfg = struct();
end

overwrite_mode = lower(strtrim(string(overwrite_mode)));

if ~ismember(overwrite_mode, ["delete","skip","if_older_than"])
    overwrite_mode = "delete";
end

if ischar(out_files) || isstring(out_files)
    out_files = {out_files};
end

if ~iscell(out_files)
    out_files = {out_files};
end

exists_mask   = false(size(out_files));
file_datenums = nan(size(out_files));

for k = 1:numel(out_files)
    f = out_files{k};

    if iscell(f)
        if isempty(f)
            f = '';
        else
            f = f{1};
        end
    end

    f = char(string(f));

    if isempty(f)
        exists_mask(k) = false;
        continue;
    end

    file_info = dir(f);

    if ~isempty(file_info)
        exists_mask(k) = true;
        file_datenums(k) = file_info(1).datenum;
    else
        exists_mask(k) = false;
    end
end

n_exist = sum(exists_mask);

if n_exist == 0
    do_run = true;
    reason = "no outputs present";
    return;
end

if n_exist < numel(out_files)
    needs_regen = true;
    do_run = true;
    reason = sprintf('partial outputs exist (%d/%d) -> regenerate', n_exist, numel(out_files));
    return;
end

switch overwrite_mode

    case "skip"
        do_run = false;
        reason = "all outputs exist -> skip";

    case "delete"
        do_run = true;
        reason = "all outputs exist -> delete + regenerate";

    case "if_older_than"
        cutoff_raw = "";

        if isfield(cfg, 'io') && isstruct(cfg.io) && ...
                isfield(cfg.io, 'overwrite_if_older_than')
            cutoff_raw = string(cfg.io.overwrite_if_older_than);
        end

        cutoff_datenum = parse_cutoff_to_datenum_impl(cutoff_raw);

        if isnan(cutoff_datenum)
            error('overwrite_mode="if_older_than" requires a valid cutoff date. Got: %s', cutoff_raw);
        end

        if any(isnan(file_datenums))
            do_run = true;
            reason = "one or more output file dates unavailable -> regenerate";
            return;
        end

        oldest_output_datenum = min(file_datenums);

        if oldest_output_datenum < cutoff_datenum
            do_run = true;
            reason = sprintf( ...
                'one or more outputs older than cutoff %s -> regenerate', ...
                datestr(cutoff_datenum, 'yyyy-mm-dd HH:MM:SS'));
        else
            do_run = false;
            reason = sprintf( ...
                'all outputs newer than cutoff %s -> skip', ...
                datestr(cutoff_datenum, 'yyyy-mm-dd HH:MM:SS'));
        end

    otherwise
        do_run = true;
        reason = "unknown overwrite mode -> regenerate";
end
end

function [do_run, reason, info] = step_should_run_from_folder_impl(step_folder, policy)
info = struct();
info.exists  = false;
info.datenum = NaN;
info.is_empty = true;

step_folder = char(string(step_folder));

if exist(step_folder, 'dir') ~= 7
    do_run = true;
    reason = "output folder missing -> run";
    return;
end

info.exists = true;

dir_info = dir(step_folder);
real_mask = ~ismember({dir_info.name}, {'.','..'});
real_info = dir_info(real_mask);

info.is_empty = isempty(real_info);

folder_info = dir(step_folder);
if ~isempty(folder_info)
    info.datenum = folder_info.datenum;
end

if info.is_empty
    do_run = true;
    reason = "output folder exists but is empty -> run";
    return;
end

switch policy.mode
    case "skip"
        do_run = false;
        reason = "output folder exists and non-empty -> skip";

    case "delete"
        do_run = true;
        reason = "output folder exists and non-empty -> delete + regenerate";

    case "if_older_than"
        if isnan(info.datenum)
            do_run = true;
            reason = "folder date unavailable -> regenerate";
        elseif info.datenum < policy.cutoff_datenum
            do_run = true;
            reason = "output folder older than cutoff -> delete + regenerate";
        else
            do_run = false;
            reason = "output folder newer than cutoff -> skip";
        end

    otherwise
        do_run = true;
        reason = "unknown policy -> regenerate";
end
end

function step_folder = get_step_subject_folder_impl(paths, step_name)
switch step_name
    case 'prep_01_bids_formatting'
        step_folder = paths.prep_01_out_dir;

    case 'prep_02_triggerfix'
        step_folder = paths.prep_02_out_dir;

    case 'prep_03_until_ica'
        step_folder = paths.prep_03_out_dir_until_ica;

    case 'prep_04_ica'
        step_folder = paths.prep_04_out_dir;

    case 'prep_05_after_ica'
        step_folder = paths.prep_05_out_dir;

    case 'prep_06_epoching'
        step_folder = paths.prep_06_out_dir;

    otherwise
        error('Unknown step name: %s', step_name);
end
end

% =========================================================================
% SAVE / LOAD / BIDS HELPERS
% =========================================================================
function safe_delete_set_impl(set_file)
if nargin < 1 || isempty(set_file)
    return;
end

if iscell(set_file)
    if isempty(set_file)
        return;
    end
    set_file = set_file{1};
end

set_file = char(string(set_file));
if isempty(set_file)
    return;
end

[parent_dir, base_name, ~] = fileparts(set_file);

for ext = {'.set', '.fdt'}
    f = fullfile(parent_dir, [base_name ext{1}]);
    if exist(f, 'file') == 2
        delete(f);
    end
end
end

function EEG = safe_save_set_impl(EEG, out_dir, out_fname, helpers, cfg) %#ok<INUSD>
out_dir   = force_char_scalar_impl(out_dir);
out_fname = force_char_scalar_impl(out_fname);

ensure_dir_impl(out_dir);

EEG.filename = force_char_scalar_impl(getfield_safe_impl(EEG, 'filename', ''));
EEG.filepath = force_char_scalar_impl(getfield_safe_impl(EEG, 'filepath', ''));

if contains(EEG.filename, filesep) || contains(EEG.filename, '/')
    EEG.filename = '';
end

EEG = pop_saveset(EEG, 'filename', out_fname, 'filepath', out_dir, 'savemode', 'twofiles');

if nargin >= 4 && isstruct(helpers) && isfield(helpers, 'log_msg_default')
    helpers.log_msg_default('Saved set: %s', fullfile(out_dir, out_fname));
end
end

function EEG = safe_load_set_impl(in_dir, in_fname, helpers)
in_dir   = force_char_scalar_impl(in_dir);
in_fname = force_char_scalar_impl(in_fname);

if exist(in_dir, 'dir') ~= 7
    error('safe_load_set: input directory not found: %s', in_dir);
end

full_path = fullfile(in_dir, in_fname);
if exist(full_path, 'file') ~= 2
    error('safe_load_set: file not found: %s', full_path);
end

EEG = pop_loadset('filename', in_fname, 'filepath', in_dir);
EEG = eeg_checkset(EEG);

if nargin >= 3 && isstruct(helpers) && isfield(helpers, 'log_msg_default')
    helpers.log_msg_default('Loaded set: %s', full_path);
end
end

function [vhdr_dir, vhdr_name] = find_bids_vhdr_impl(paths, subj_id, helpers)
vhdr_dir  = '';
vhdr_name = '';

candidate_dirs = {};

if isfield(paths, 'bids_ses_dir') && strlength(string(paths.bids_ses_dir)) > 0
    candidate_dirs{end+1} = fullfile(char(string(paths.bids_ses_dir)), 'eeg'); %#ok<AGROW>
end

if isfield(paths, 'bids_sub_dir') && strlength(string(paths.bids_sub_dir)) > 0
    if isfield(paths, 'session_label') && strlength(string(paths.session_label)) > 0
        candidate_dirs{end+1} = fullfile( ...
            char(string(paths.bids_sub_dir)), ...
            ['ses-' char(string(paths.session_label))], ...
            'eeg'); %#ok<AGROW>
    end
    candidate_dirs{end+1} = fullfile(char(string(paths.bids_sub_dir)), 'eeg'); %#ok<AGROW>
end

candidate_dirs = unique(candidate_dirs, 'stable');

task_label = "";
if isfield(paths, 'bids_task_label') && strlength(string(paths.bids_task_label)) > 0
    task_label = string(paths.bids_task_label);
end

best = [];
best_dir = '';

for d = 1:numel(candidate_dirs)
    eeg_dir = candidate_dirs{d};

    if exist(eeg_dir, 'dir') ~= 7
        continue;
    end

    candidates = [];
    if strlength(task_label) > 0
        pattern = sprintf('*task-%s*_eeg.vhdr', char(task_label));
        candidates = dir(fullfile(eeg_dir, pattern));
    end

    if isempty(candidates)
        candidates = dir(fullfile(eeg_dir, '*.vhdr'));
    end

    if isempty(candidates)
        continue;
    end

    [~, ix] = max([candidates.datenum]);
    best = candidates(ix);
    best_dir = eeg_dir;
    break;
end

if isempty(best)
    if nargin >= 3 && isfield(helpers, 'log_msg_default')
        helpers.log_msg_default( ...
            'prep_03_until_ica: BIDS fallback: no *.vhdr found for sub-%s (checked: %s)', ...
            subj_id, strjoin(string(candidate_dirs), ' | '));
    end
    return;
end

vhdr_dir  = best_dir;
vhdr_name = best.name;

if nargin >= 3 && isfield(helpers, 'log_msg_default')
    helpers.log_msg_default('prep_03_until_ica: BIDS fallback: using vhdr=%s', ...
        fullfile(vhdr_dir, vhdr_name));
end
end

function EEG = safe_load_bv_impl(vhdr_dir, vhdr_name, helpers)
vhdr_dir  = force_char_scalar_impl(vhdr_dir);
vhdr_name = force_char_scalar_impl(vhdr_name);

if exist(vhdr_dir, 'dir') ~= 7
    error('safe_load_bv: directory not found: %s', vhdr_dir);
end

full_path = fullfile(vhdr_dir, vhdr_name);
if exist(full_path, 'file') ~= 2
    error('safe_load_bv: file not found: %s', full_path);
end

if exist('pop_loadbv', 'file') ~= 2
    error('safe_load_bv: pop_loadbv not found (EEGLAB BrainVision loader missing).');
end

EEG = pop_loadbv(vhdr_dir, vhdr_name);
EEG = eeg_checkset(EEG);

if nargin >= 3 && isstruct(helpers) && isfield(helpers, 'log_msg_default')
    helpers.log_msg_default('Loaded BrainVision: %s', full_path);
end
end

function out = force_char_scalar_impl(x)
if isstring(x)
    x = x(:);
    if isempty(x)
        out = '';
    else
        out = char(x(1));
    end
    return;
end

if iscell(x)
    if isempty(x)
        out = '';
    else
        out = force_char_scalar_impl(x{1});
    end
    return;
end

if ischar(x)
    if isempty(x)
        out = '';
    else
        out = x(1, :);
    end
    return;
end

if isempty(x)
    out = '';
    return;
end

out = char(string(x(1)));
end

function value = getfield_safe_impl(S, field_name, default_value)
if isstruct(S) && isfield(S, field_name)
    value = S.(field_name);
else
    value = default_value;
end
end

% =========================================================================
% EEG COMMENT / TRIGGER
% =========================================================================
function EEG = append_eeg_comment_impl(EEG, line_text)
try
    if ~isfield(EEG, 'comments') || isempty(EEG.comments)
        EEG.comments = line_text;
    else
        EEG.comments = sprintf('%s\n%s', EEG.comments, line_text);
    end
catch
end
end

function token = normalize_trigger_type_impl(t)
if isnumeric(t)
    token = strtrim(num2str(t));
    return;
end

token = char(string(t));
token = strtrim(token);
token = regexprep(token, '\s+', ' ');

match_1 = regexp(token, '^S(\d+)$', 'tokens', 'once');
if ~isempty(match_1)
    token = ['S ' match_1{1}];
    return;
end

match_2 = regexp(token, '^S\s+(\d+)$', 'tokens', 'once');
if ~isempty(match_2)
    token = ['S ' match_2{1}];
    return;
end
end

function token = get_raw_trigger_from_key_impl(raw_triggers, key_name)
key_name = force_char_scalar_impl(key_name);

if isempty(key_name)
    token = '';
    return;
end

if isstruct(raw_triggers) && isfield(raw_triggers, key_name)
    token = normalize_trigger_type_impl(raw_triggers.(key_name));
else
    token = normalize_trigger_type_impl(key_name);
end
end

function new_type = map_trigger_by_table_impl(current_type, map_table, raw_triggers)
new_type = '';

if isempty(map_table)
    return;
end

current_type = normalize_trigger_type_impl(current_type);

for r = 1:size(map_table, 1)
    raw_key   = map_table{r,1};
    target_id = map_table{r,2};

    raw_token = get_raw_trigger_from_key_impl(raw_triggers, raw_key);

    if strcmp(current_type, raw_token)
        new_type = normalize_trigger_type_impl(target_id);
        return;
    end
end
end

% =========================================================================
% EEG UTILITIES
% =========================================================================
function EEG = normalize_event_types_impl(EEG)
if isfield(EEG, 'event') && ~isempty(EEG.event)
    try
        tmp = cellfun(@char, {EEG.event.type}, 'UniformOutput', false);
        [EEG.event.type] = tmp{:};
    catch
    end
end
end

function mode = normalize_epoching_mode_value_impl(mode_in)
mode = lower(strtrim(char(string(mode_in))));
mode = regexprep(mode, '\s+', ' ');
end

function [idx_eeg, idx_eog, idx_non_eeg] = get_channel_indices_by_type_impl(EEG)
idx_eeg = [];
idx_eog = [];
idx_non_eeg = [];

if ~isfield(EEG, 'chanlocs') || isempty(EEG.chanlocs) || ~isfield(EEG.chanlocs, 'type')
    idx_eeg = (1:EEG.nbchan)';
    return;
end

types = lower(string({EEG.chanlocs.type}));
idx_eeg = find(types == "eeg");
idx_eog = find(types == "eog");
idx_non_eeg = find(~(types == "eeg" | types == "eog"));

idx_eeg = idx_eeg(:);
idx_eog = idx_eog(:);
idx_non_eeg = idx_non_eeg(:);
end

function EEG_out = apply_reference_mode_impl(EEG_in, step_cfg, helpers, context_label)
EEG_out = EEG_in;

if nargin < 4 || isempty(context_label)
    context_label = 'reference';
end

context_label = char(string(context_label));

[idx_eeg, ~, ~] = get_channel_indices_by_type_impl(EEG_out);

reference_mode = "keep";
if isfield(step_cfg, 'reference_mode') && strlength(string(step_cfg.reference_mode)) > 0
    reference_mode = lower(strtrim(string(step_cfg.reference_mode)));
end

if reference_mode == "average"
    reference_mode = "avg";
end

reference_exclude_non_eeg = true;
if isfield(step_cfg, 'reference_exclude_non_eeg') && ~isempty(step_cfg.reference_exclude_non_eeg)
    reference_exclude_non_eeg = logical(step_cfg.reference_exclude_non_eeg);
end

switch reference_mode

    case {"keep","none","off"}
        EEG_out = helpers.append_eeg_comment(EEG_out, sprintf( ...
            '%s: reference kept unchanged', context_label));

        if ~isfield(EEG_out, 'etc') || isempty(EEG_out.etc)
            EEG_out.etc = struct();
        end
        EEG_out.etc.reference_mode_applied = 'keep';

    case "avg"
        if isempty(idx_eeg)
            helpers.log_msg_default('%s: WARNING no EEG channels found for average reference.', context_label);
            EEG_out = helpers.append_eeg_comment(EEG_out, sprintf( ...
                '%s: average reference skipped (no EEG channels)', context_label));

            if ~isfield(EEG_out, 'etc') || isempty(EEG_out.etc)
                EEG_out.etc = struct();
            end
            EEG_out.etc.reference_mode_applied = 'avg_skipped_no_eeg';
            return;
        end

        if reference_exclude_non_eeg
            exclude_idx = setdiff(1:EEG_out.nbchan, idx_eeg);
            EEG_out = pop_reref(EEG_out, [], 'exclude', exclude_idx);
            EEG_out = helpers.append_eeg_comment(EEG_out, sprintf( ...
                '%s: average reference applied (EEG-only, n=%d)', ...
                context_label, numel(idx_eeg)));
        else
            EEG_out = pop_reref(EEG_out, []);
            EEG_out = helpers.append_eeg_comment(EEG_out, sprintf( ...
                '%s: average reference applied (all channels, n=%d)', ...
                context_label, EEG_out.nbchan));
        end

        EEG_out = eeg_checkset(EEG_out);

        if ~isfield(EEG_out, 'etc') || isempty(EEG_out.etc)
            EEG_out.etc = struct();
        end
        EEG_out.etc.reference_mode_applied = 'avg';

    case "mastoid"
        if ~isfield(step_cfg, 'mastoid_channel_labels') || numel(step_cfg.mastoid_channel_labels) < 2
            error('%s: mastoid_channel_labels must contain two labels for reference_mode="mastoid".', ...
                context_label);
        end

        mastoid_labels = cellstr(string(step_cfg.mastoid_channel_labels));
        mastoid_idx = zeros(1, numel(mastoid_labels));

        all_labels = {EEG_out.chanlocs.labels};

        for k = 1:numel(mastoid_labels)
            this_idx = find(strcmpi(all_labels, mastoid_labels{k}), 1, 'first');

            if isempty(this_idx)
                error('%s: mastoid reference channel not found: %s', ...
                    context_label, mastoid_labels{k});
            end

            mastoid_idx(k) = this_idx;
        end

        if reference_exclude_non_eeg
            exclude_idx = setdiff(1:EEG_out.nbchan, idx_eeg);
            EEG_out = pop_reref(EEG_out, mastoid_idx, 'exclude', exclude_idx);
        else
            EEG_out = pop_reref(EEG_out, mastoid_idx);
        end

        EEG_out = eeg_checkset(EEG_out);

        EEG_out = helpers.append_eeg_comment(EEG_out, sprintf( ...
            '%s: mastoid reference applied using %s', ...
            context_label, strjoin(string(mastoid_labels), ', ')));

        if ~isfield(EEG_out, 'etc') || isempty(EEG_out.etc)
            EEG_out.etc = struct();
        end
        EEG_out.etc.reference_mode_applied = 'mastoid';
        EEG_out.etc.reference_mastoid_labels = mastoid_labels;

    otherwise
        error('%s: unsupported reference_mode="%s". Use "keep", "avg", or "mastoid".', ...
            context_label, char(reference_mode));
end
end

function output_spec = build_epoching_output_paths_impl(run_base, out_dir, step_cfg, idx_eeg, idx_eog, idx_non_eeg)
output_spec = struct();
output_spec.all_paths = {};

mode_raw = step_cfg.epoching_mode;
mode = normalize_epoching_mode_value_impl(mode_raw);

if strcmp(mode, 'event_locked')
    base_stem = build_epoching_output_stem_impl(run_base, "", false);
    output_spec.all_paths = build_output_paths_for_base_stem_epoching_impl( ...
        base_stem, out_dir, step_cfg, idx_eeg, idx_eog, idx_non_eeg);

elseif strcmp(mode, 'baseline')
    has_conditions = logical(getfield_safe_impl(step_cfg, 'baseline_has_conditions', false));

    if has_conditions
        [condition_names, ~, ~, ~] = resolve_baseline_condition_definitions_impl(step_cfg);
        if isempty(condition_names)
            error(['cfg.prep_06.baseline_has_conditions=true, but no baseline condition ' ...
                'definitions were provided.']);
        end
    else
        condition_names = "";
    end

    for c = 1:numel(condition_names)
        base_stem = build_epoching_output_stem_impl( ...
            run_base, condition_names(c), has_conditions);
        condition_paths = build_output_paths_for_base_stem_epoching_impl( ...
            base_stem, out_dir, step_cfg, idx_eeg, idx_eog, idx_non_eeg);
        output_spec.all_paths = [output_spec.all_paths; condition_paths(:)]; %#ok<AGROW>
    end

else
    error('Unsupported cfg.prep_06.epoching_mode: raw=>>%s<< | normalized=>>%s<<', ...
        char(string(mode_raw)), mode);
end
end

function base_stem = build_epoching_output_stem_impl(run_base, condition_name, include_condition)
base_stem = string(run_base);

if nargin >= 3 && logical(include_condition)
    condition_name = string(condition_name);
    condition_name = strtrim(condition_name(1));
    if strlength(condition_name) == 0
        error('A non-empty condition name is required when include_condition=true.');
    end

    condition_token = lower(string(sanitize_filename_impl(condition_name)));
    base_stem = base_stem + "_cond-" + condition_token;
end

base_stem = base_stem + "_epoched_final";
end

function out_path = save_intermediate_set_impl(EEG, out_dir, base_stem, overwrite_mode, cfg, savemode, helpers) %#ok<INUSD>
if nargin < 6 || isempty(savemode)
    savemode = 'twofiles';
end

out_name = char(string(base_stem) + ".set");
out_path = fullfile(out_dir, out_name);

if exist(out_path, 'file') == 2 && overwrite_mode == "skip"
    return;
end

if overwrite_mode == "delete" && exist(out_path, 'file') == 2
    safe_delete_set_impl(out_path);
end

EEG = pop_saveset(EEG, ...
    'filename', out_name, ...
    'filepath', out_dir, ...
    'savemode', savemode);

if nargin >= 7 && isstruct(helpers) && isfield(helpers, 'log_msg_default')
    helpers.log_msg_default('Saved intermediate set: %s', out_path);
end
end

function [EEG_out, info] = apply_hard_epoch_threshold_rejection_impl(EEG_in, idx_eeg, thresh_uv)
EEG_out = EEG_in;

info = struct();
info.n_total    = EEG_in.trials;
info.n_rejected = 0;
info.n_kept     = EEG_in.trials;
info.thresh_uv  = thresh_uv;
info.rejected_epochs = [];

if isempty(idx_eeg) || EEG_in.trials < 1
    return;
end

if isempty(thresh_uv) || ~isscalar(thresh_uv) || ~isfinite(thresh_uv) || thresh_uv <= 0
    return;
end

data = EEG_in.data(idx_eeg, :, :);
bad = squeeze(any(any(abs(data) > thresh_uv, 1), 2));
bad = bad(:);

bad_epochs = find(bad);

if isempty(bad_epochs)
    return;
end

EEG_out = pop_rejepoch(EEG_in, bad_epochs, 0);
EEG_out = eeg_checkset(EEG_out);

info.n_rejected = numel(bad_epochs);
info.n_kept     = EEG_out.trials;
info.rejected_epochs = bad_epochs(:)';
end

function [EEG_out, info] = apply_fallback_epoch_rejection_impl(EEG_in, idx_eeg, step_cfg)
EEG_out = EEG_in;

info = struct();
info.n_total    = EEG_in.trials;
info.n_rejected = 0;
info.n_kept     = EEG_in.trials;
info.robust_z   = isfield(step_cfg, 'faster_use_robust_z') && step_cfg.faster_use_robust_z;

if EEG_in.trials < 1 || isempty(idx_eeg)
    return;
end

bad_faster = false(EEG_in.trials, 1);
bad_ptp    = false(EEG_in.trials, 1);

if isfield(step_cfg, 'use_faster') && step_cfg.use_faster && exist('epoch_properties', 'file') == 2
    props = epoch_properties(EEG_in, idx_eeg);

    if ~isempty(props) && size(props, 1) ~= EEG_in.trials && size(props, 2) == EEG_in.trials
        props = props.';
    end

    if ~isempty(props) && size(props, 1) == EEG_in.trials
        if info.robust_z
            med = median(props, 1, 'omitnan');
            madv = median(abs(props - med), 1, 'omitnan');
            denom = 1.4826 .* madv;
            denom(denom == 0 | isnan(denom)) = Inf;
            zmat = (props - med) ./ denom;
        else
            mu = mean(props, 1, 'omitnan');
            sd = std(props, 0, 1, 'omitnan');
            sd(sd == 0 | isnan(sd)) = Inf;
            zmat = (props - mu) ./ sd;
        end

        bad_faster = any(abs(zmat) > step_cfg.faster_z_thresh, 2);
    end
end

if isfield(step_cfg, 'use_ptp') && step_cfg.use_ptp
    data = double(EEG_in.data(idx_eeg, :, :));
    ptp  = squeeze(max(data, [], 2) - min(data, [], 2));
    bad_ptp = any(ptp > step_cfg.ptp_uV_thresh, 1)';
end

bad = bad_faster | bad_ptp;
bad_epochs = find(bad);

if isempty(bad_epochs)
    return;
end

EEG_out = pop_rejepoch(EEG_in, bad_epochs, 0);
EEG_out = eeg_checkset(EEG_out);

info.n_rejected = numel(bad_epochs);
info.n_kept     = EEG_out.trials;
end

function [condition_datasets, condition_names] = create_baseline_condition_datasets_impl(EEG, step_cfg, helpers, run_base)
condition_datasets = {};

if ~isfield(EEG, 'event') || isempty(EEG.event)
    error('No EEG.event present -> cannot segment baseline conditions.');
end

if ~isfield(EEG, 'srate') || isempty(EEG.srate)
    error('EEG.srate missing -> cannot segment baseline conditions.');
end

[condition_names, marker_prefixes, start_condition, end_condition] = ...
    resolve_baseline_condition_definitions_impl(step_cfg);

if isempty(condition_names)
    error(['No baseline condition definitions found. Use ' ...
        'cfg.prep_06.baseline_condition_definitions.']);
end

end_markers = getfield_safe_impl(step_cfg, 'baseline_end_markers', {});
event_times = [];
event_codes = strings(0,1);

for k = 1:numel(EEG.event)
    code = normalize_trigger_type_impl(EEG.event(k).type);

    if strcmpi(code, 'boundary')
        continue;
    end


    is_condition_marker = false;
    for c = 1:numel(condition_names)
        if matches_any_prefix_impl(code, marker_prefixes{c})
            is_condition_marker = true;
            break;
        end
    end

    if is_condition_marker || matches_any_exact_impl(code, end_markers)
        event_codes(end+1,1) = string(code); %#ok<AGROW>
        event_times(end+1,1) = double(EEG.event(k).latency) / double(EEG.srate); %#ok<AGROW>
    end
end

if isempty(event_times)
    error('No configured baseline condition markers found in the recording.');
end

[event_times, sort_ix] = sort(event_times);
event_codes = event_codes(sort_ix);

recording_end_s = double(EEG.pnts) / double(EEG.srate);
sample_eps = 1.0 / double(EEG.srate);
current_condition = start_condition;
current_t1 = 0;

seg_condition = strings(0,1);
seg_t1 = [];
seg_t2 = [];

for i = 1:numel(event_codes)
    code = event_codes(i);
    t_ev = event_times(i);

    if t_ev <= current_t1 + sample_eps
        continue;
    end

    next_condition = current_condition;
    if matches_any_exact_impl(code, end_markers)
        next_condition = end_condition;
    else
        for c = 1:numel(condition_names)
            if matches_any_prefix_impl(code, marker_prefixes{c})
                next_condition = condition_names(c);
                break;
            end
        end
    end

    if next_condition ~= current_condition
        seg_condition(end+1,1) = current_condition; %#ok<AGROW>
        seg_t1(end+1,1) = current_t1; %#ok<AGROW>
        seg_t2(end+1,1) = t_ev; %#ok<AGROW>
        current_condition = next_condition;
        current_t1 = t_ev;
    end
end

if current_t1 < recording_end_s - sample_eps
    seg_condition(end+1,1) = current_condition; %#ok<AGROW>
    seg_t1(end+1,1) = current_t1; %#ok<AGROW>
    seg_t2(end+1,1) = recording_end_s; %#ok<AGROW>
end

if isempty(seg_t1)
    error('Could not derive any baseline condition segments.');
end

baseline_duration = (seg_t2(end)-seg_t1(1))/60;

helpers.log_msg_default( ...
    'prep_06_epoching: %s | derived %d baseline segments across conditions: %s | total duration: %.02f minutes', ...
    char(string(run_base)), numel(seg_t1), strjoin(cellstr(condition_names), ', '), baseline_duration);

condition_parts = repmat({{}}, numel(condition_names), 1);
epoch_len = double(step_cfg.regepoch_length_sec);
epoch_step = double(step_cfg.regepoch_step_sec);
if epoch_step <= 0
    epoch_step = epoch_len;
end

for s = 1:numel(seg_t1)
    t1 = seg_t1(s);
    t2 = seg_t2(s);
    if (t2 - t1) < epoch_len
        continue;
    end

    condition_ix = find(strcmpi(condition_names, seg_condition(s)), 1, 'first');
    if isempty(condition_ix)
        error('Derived unknown baseline condition: %s', char(seg_condition(s)));
    end

    EEG_seg = pop_select(EEG, 'time', [t1, t2 - sample_eps]);
    EEG_seg = eeg_checkset(EEG_seg);
    try
        EEG_ep = eeg_regepochs( ...
            EEG_seg, ...
            'recurrence', epoch_step, ...
            'limits', [0 epoch_len], ...
            'eventtype', 'regepoch');
    catch ME
        EEG_ep = append_eeg_comment_impl(EEG_ep, sprintf( ...
        'prep_06_epoching: regepoch failed for segment %d | chunk=[%.3f %.3f] s | regepoch_length=%.1f s | regepoch_step=%.1f s', ...
        s, t1, t2, epoch_len, epoch_step));
        continue
    end
    EEG_ep = eeg_checkset(EEG_ep);
    EEG_ep.etc.baseline_condition = char(condition_names(condition_ix));
    EEG_ep = append_eeg_comment_impl(EEG_ep, sprintf( ...
        'prep_06_epoching: baseline_condition=%s | chunk=[%.3f %.3f] s | regepoch_length=%.1f s | regepoch_step=%.1f s', ...
        condition_names(condition_ix), t1, t2, epoch_len, epoch_step));
    condition_parts{condition_ix}{end+1} = EEG_ep; %#ok<AGROW>
end

condition_datasets = cell(numel(condition_names), 1);
for c = 1:numel(condition_names)
    condition_datasets{c} = merge_eeg_sets_impl(condition_parts{c});
end
end

function [condition_names, marker_prefixes, start_condition, end_condition] = resolve_baseline_condition_definitions_impl(step_cfg)
condition_names = strings(0,1);
marker_prefixes = {};

definitions = getfield_safe_impl(step_cfg, 'baseline_condition_definitions', {});
if ~isempty(definitions)
    if ~iscell(definitions) || size(definitions, 2) ~= 2
        error(['cfg.prep_06.baseline_condition_definitions must be an N-by-2 cell array: ' ...
            '{condition_name, marker_prefixes}.']);
    end

    for r = 1:size(definitions, 1)
        this_name = strtrim(string(definitions{r,1}));
        if isempty(this_name)
            this_name = "";
        else
            this_name = this_name(1);
        end
        this_markers = normalize_event_list_impl(definitions{r,2});
        if strlength(this_name) == 0 || isempty(this_markers)
            error('Baseline condition definition row %d has an empty name or marker list.', r);
        end
        condition_names(end+1,1) = this_name; %#ok<AGROW>
        marker_prefixes{end+1,1} = cellstr(this_markers); %#ok<AGROW>
    end
end

if isempty(condition_names)
    start_condition = "";
    end_condition = "";
    return;
end

if numel(unique(lower(condition_names))) ~= numel(condition_names)
    error('Baseline condition names must be unique (case-insensitive).');
end

start_condition = strtrim(string(getfield_safe_impl(step_cfg, 'baseline_start_condition', "")));
if isempty(start_condition)
    start_condition = "";
else
    start_condition = start_condition(1);
end
if strlength(start_condition) == 0 && ~isempty(condition_names)
    start_condition = condition_names(1);
end
start_ix = find(strcmpi(condition_names, start_condition), 1, 'first');
if isempty(start_ix)
    error('baseline_start_condition="%s" is not defined.', char(start_condition));
end
start_condition = condition_names(start_ix);

end_condition = strtrim(string(getfield_safe_impl(step_cfg, 'baseline_end_condition', start_condition)));
if isempty(end_condition)
    end_condition = "";
else
    end_condition = end_condition(1);
end
if strlength(end_condition) == 0
    end_condition = start_condition;
end
end_ix = find(strcmpi(condition_names, end_condition), 1, 'first');
if isempty(end_ix)
    error('baseline_end_condition="%s" is not defined.', char(end_condition));
end
end_condition = condition_names(end_ix);
end

function [EEG_final, rej_info] = finalize_epoched_dataset_impl( ...
    EEG_ep, base_stem, out_dir, step_cfg, cfg, helpers, subj_label, run_label)

EEG_final = EEG_ep;

rej_info = struct();
rej_info.excluded                        = false;
rej_info.excluded_by_max_reject_prop     = false;
rej_info.excluded_by_min_trials_rule     = false;
rej_info.exclusion_reason                = "";
rej_info.n_total                         = EEG_ep.trials;
rej_info.n_rejected_hard                 = 0;
rej_info.n_rejected_sophisticated        = 0;
rej_info.n_rejected_total                = 0;
rej_info.n_kept                          = EEG_ep.trials;
rej_info.rejection_method                = "";
rej_info.min_trials_required             = NaN;
rej_info.min_trials_condition_counts     = "";
rej_info.min_trials_insufficient_conditions = "";
rej_info.epoch_condition_labels          = derive_epoch_condition_labels_impl(EEG_ep, step_cfg);
rej_info.reason_masks                    = struct();
rej_info.reason_enabled                  = struct();
rej_info.reason_settings                 = struct();
rej_info.n_rejected_extreme_voltage      = 0;
rej_info.n_rejected_sample_diff          = 0;
rej_info.n_rejected_flatline             = 0;
rej_info.n_rejected_faster               = 0;
rej_info.n_rejected_ptp                  = 0;
rej_info.n_rejected_mad_variance         = 0;

n_original_epochs = double(EEG_ep.trials);
remaining_original_epochs = 1:n_original_epochs;
rej_info.reason_masks.hard_threshold = false(n_original_epochs, 1);
rej_info.reason_enabled.hard_threshold = logical(step_cfg.do_initial_hard_threshold_rejection);
rej_info.reason_settings.hard_threshold_uv = step_cfg.initial_hard_threshold_uv;

if isfield(step_cfg, 'epoch_rejection_method') && ...
        strlength(string(step_cfg.epoch_rejection_method)) > 0
    rejection_method = lower(strtrim(string(step_cfg.epoch_rejection_method)));
else
    rejection_method = "erplab";
end

if any(rejection_method == ["mad","mad_variance","mad_epoch_rejection"])
    rejection_method = "mad_variance";
end

if ~ismember(rejection_method, ["erplab","faster_ptp","mad_variance","none"])
    error(['Unsupported cfg.prep_06.epoch_rejection_method="%s". ' ...
        'Use "erplab", "faster_ptp", "mad_variance", or "none".'], char(rejection_method));
end

rej_info.rejection_method = rejection_method;

if step_cfg.save_intermediate_steps && ~step_cfg.save_final_only
    save_intermediate_set_impl( ...
        EEG_ep, out_dir, string(base_stem) + "_stage-epoched", ...
        "delete", cfg, step_cfg.savemode, helpers);
end

[idx_eeg, ~, ~] = get_channel_indices_by_type_impl(EEG_ep);
EEG_work = EEG_ep;

if step_cfg.do_artifact_rejection

    if isempty(idx_eeg) || EEG_work.trials < 1
        EEG_work = helpers.append_eeg_comment(EEG_work, ...
            'prep_06_epoching: artifact rejection skipped (no EEG channels or no epochs)');
    else

        % -----------------------------------------------------------------
        % Optional first-pass hard threshold
        % -----------------------------------------------------------------
        if step_cfg.do_initial_hard_threshold_rejection
            [EEG_work, hard_info] = apply_hard_epoch_threshold_rejection_impl( ...
                EEG_work, idx_eeg, step_cfg.initial_hard_threshold_uv);

            rej_info.n_rejected_hard = hard_info.n_rejected;
            rej_info.n_kept = EEG_work.trials;

            hard_current = hard_info.rejected_epochs(:)';
            hard_current = hard_current(hard_current >= 1 & hard_current <= numel(remaining_original_epochs));
            hard_original = remaining_original_epochs(hard_current);
            rej_info.reason_masks.hard_threshold(hard_original) = true;
            remaining_original_epochs(hard_current) = [];

            EEG_work = helpers.append_eeg_comment(EEG_work, sprintf( ...
                'prep_06_epoching: hard threshold rejection | abs(amplitude) > %.1f uV | rejected=%d/%d | kept=%d', ...
                step_cfg.initial_hard_threshold_uv, ...
                hard_info.n_rejected, ...
                hard_info.n_total, ...
                hard_info.n_kept));

            helpers.log_msg_default( ...
                'prep_06_epoching: %s | %s | hard rejection=%d/%d | kept=%d | threshold=%.1f uV', ...
                char(string(subj_label)), char(string(run_label)), ...
                hard_info.n_rejected, hard_info.n_total, hard_info.n_kept, ...
                step_cfg.initial_hard_threshold_uv);

            if step_cfg.save_intermediate_steps && ~step_cfg.save_final_only
                save_intermediate_set_impl( ...
                    EEG_work, out_dir, string(base_stem) + "_stage-hardrejected", ...
                    "delete", cfg, step_cfg.savemode, helpers);
            end
        else
            EEG_work = helpers.append_eeg_comment(EEG_work, ...
                'prep_06_epoching: hard threshold rejection skipped by config');
        end

        % -----------------------------------------------------------------
        % Sophisticated / backend-specific rejection
        % -----------------------------------------------------------------
        if EEG_work.trials >= 1

            switch rejection_method

                case "none"
                    EEG_work = helpers.append_eeg_comment(EEG_work, ...
                        'prep_06_epoching: epoch rejection skipped because epoch_rejection_method="none"');

                    helpers.log_msg_default( ...
                        'prep_06_epoching: %s | %s | epoch rejection skipped method=none', ...
                        char(string(subj_label)), char(string(run_label)));

                case "erplab"
                    if ~isfield(step_cfg, 'erplab_epoch_rejection') || ...
                            ~isstruct(step_cfg.erplab_epoch_rejection)
                        error('cfg.prep_06.erplab_epoch_rejection is missing, but epoch_rejection_method="erplab".');
                    end

                    erplab_reject_cfg = step_cfg.erplab_epoch_rejection;
                    erplab_reject_cfg.enable = true; % method selects ERPLAB; no user-facing second switch

                    [EEG_work, erplab_info] = apply_erplab_epoch_rejection_impl( ...
                        EEG_work, idx_eeg, erplab_reject_cfg, helpers, subj_label, run_label);

                    rej_info.n_rejected_sophisticated = erplab_info.n_rejected;
                    rej_info.n_kept = EEG_work.trials;

                    [rej_info, remaining_original_epochs] = record_backend_reason_masks_impl( ...
                        rej_info, remaining_original_epochs, "erplab", erplab_info, erplab_reject_cfg);

                    EEG_work = helpers.append_eeg_comment(EEG_work, sprintf( ...
                        ['prep_06_epoching: ERPLAB rejection | rejected=%d/%d | kept=%d | ' ...
                        'extreme_voltage=%d | sample_diff=%d | flatline=%d'], ...
                        erplab_info.n_rejected, ...
                        erplab_info.n_before, ...
                        erplab_info.n_kept, ...
                        erplab_info.n_rejected_extreme_voltage, ...
                        erplab_info.n_rejected_sample_diff, ...
                        erplab_info.n_rejected_flatline));

                    helpers.log_msg_default( ...
                        ['prep_06_epoching: %s | %s | ERPLAB rejection=%d/%d | kept=%d | ' ...
                        'extreme_voltage=%d | sample_diff=%d | flatline=%d'], ...
                        char(string(subj_label)), char(string(run_label)), ...
                        erplab_info.n_rejected, erplab_info.n_before, erplab_info.n_kept, ...
                        erplab_info.n_rejected_extreme_voltage, ...
                        erplab_info.n_rejected_sample_diff, ...
                        erplab_info.n_rejected_flatline);

                                case "mad_variance"

                    z_thresh = 3;
                    if isfield(step_cfg, 'mad_z_threshold') && ...
                            ~isempty(step_cfg.mad_z_threshold)
                        z_thresh = step_cfg.mad_z_threshold;
                    end

                    use_logvar = true;
                    if isfield(step_cfg, 'mad_use_logvar') && ...
                            ~isempty(step_cfg.mad_use_logvar)
                        use_logvar = logical(step_cfg.mad_use_logvar);
                    end

                    [EEG_work, mad_info] = helpers.reject_ica_prep_epochs_by_mad_variance( ...
                        EEG_work, ...
                        idx_eeg, ...
                        z_thresh, ...
                        use_logvar);

                    rej_info.n_rejected_sophisticated = mad_info.n_rejected;
                    rej_info.n_kept = EEG_work.trials;

                    [rej_info, remaining_original_epochs] = record_backend_reason_masks_impl( ...
                        rej_info, remaining_original_epochs, "mad_variance", mad_info, step_cfg);

                    EEG_work = helpers.append_eeg_comment(EEG_work, sprintf( ...
                        ['prep_06_epoching: MAD variance rejection | rejected=%d/%d | kept=%d | ' ...
                         'z=%.2f | logvar=%d'], ...
                        mad_info.n_rejected, ...
                        mad_info.n_before, ...
                        EEG_work.trials, ...
                        z_thresh, ...
                        use_logvar));

                    helpers.log_msg_default( ...
                        ['prep_06_epoching: %s | %s | MAD variance rejection=%d/%d | kept=%d | ' ...
                         'z=%.2f | logvar=%d'], ...
                        char(string(subj_label)), char(string(run_label)), ...
                        mad_info.n_rejected, ...
                        mad_info.n_before, ...
                        EEG_work.trials, ...
                        z_thresh, ...
                        use_logvar);

                case "faster_ptp"
                    if ~isfield(step_cfg, 'faster_ptp_epoch_rejection') || ...
                            ~isstruct(step_cfg.faster_ptp_epoch_rejection)
                        error('cfg.prep_06.faster_ptp_epoch_rejection is missing, but epoch_rejection_method="faster_ptp".');
                    end

                    faster_ptp_cfg = step_cfg.faster_ptp_epoch_rejection;
                    faster_ptp_cfg.enable = true; % method selects FASTER/PTP; no user-facing second switch

                    [EEG_work, faster_ptp_info] = apply_shared_epoch_rejection_impl( ...
                        EEG_work, faster_ptp_cfg);

                    rej_info.n_rejected_sophisticated = faster_ptp_info.n_rejected;
                    rej_info.n_kept = EEG_work.trials;

                    [rej_info, remaining_original_epochs] = record_backend_reason_masks_impl( ...
                        rej_info, remaining_original_epochs, "faster_ptp", faster_ptp_info, faster_ptp_cfg);

                    EEG_work = helpers.append_eeg_comment(EEG_work, sprintf( ...
                        'prep_06_epoching: FASTER/PTP rejection | rejected=%d/%d | kept=%d', ...
                        faster_ptp_info.n_rejected, faster_ptp_info.n_before, EEG_work.trials));

                    helpers.log_msg_default( ...
                        'prep_06_epoching: %s | %s | FASTER/PTP rejection=%d/%d | kept=%d', ...
                        char(string(subj_label)), char(string(run_label)), ...
                        faster_ptp_info.n_rejected, faster_ptp_info.n_before, EEG_work.trials);

                otherwise
                    error(['Unsupported cfg.prep_06.epoch_rejection_method="%s". ' ...
                        'Use "erplab", "faster_ptp", "mad_variance", or "none".'], ...
                        char(rejection_method));
            end

            if step_cfg.save_intermediate_steps && ~step_cfg.save_final_only
                save_intermediate_set_impl( ...
                    EEG_work, out_dir, string(base_stem) + "_stage-artifactrejected", ...
                    "delete", cfg, step_cfg.savemode, helpers);
            end
        else
            helpers.log_msg_default( ...
                'prep_06_epoching: %s | %s | no epochs left after hard threshold rejection', ...
                char(string(subj_label)), char(string(run_label)));
        end
    end
else
    EEG_work = helpers.append_eeg_comment(EEG_work, ...
        'prep_06_epoching: artifact rejection disabled by config');
end

rej_info.n_rejected_total = max(0, rej_info.n_total - EEG_work.trials);
rej_info.n_kept = EEG_work.trials;

if rej_info.n_total > 0
    prop_rejected = rej_info.n_rejected_total / rej_info.n_total;
else
    prop_rejected = 0;
end

apply_max_reject_exclusion = ...
    isfield(step_cfg, 'max_reject_prop') && ...
    ~isempty(step_cfg.max_reject_prop) && ...
    isscalar(step_cfg.max_reject_prop) && ...
    isfinite(step_cfg.max_reject_prop) && ...
    (step_cfg.max_reject_prop >= 0);

if apply_max_reject_exclusion && (prop_rejected > step_cfg.max_reject_prop)
    rej_info.excluded                    = true;
    rej_info.excluded_by_max_reject_prop = true;
    rej_info.exclusion_reason            = "max_reject_prop";

    EEG_work = helpers.append_eeg_comment(EEG_work, sprintf( ...
        ['prep_06_epoching: dataset excluded | rejected %.1f%% of epochs ' ...
        '(threshold %.1f%%) | hard=%d | sophisticated=%d | backend=%s'], ...
        100 * prop_rejected, ...
        100 * step_cfg.max_reject_prop, ...
        rej_info.n_rejected_hard, ...
        rej_info.n_rejected_sophisticated, ...
        char(rejection_method)));

    helpers.log_msg_default( ...
        'prep_06_epoching: %s | %s | dataset excluded | rejected %.1f%% of epochs | backend=%s', ...
        char(string(subj_label)), char(string(run_label)), ...
        100 * prop_rejected, char(rejection_method));

    EEG_final = EEG_work;
    return;
end

EEG_final = EEG_work;

if step_cfg.do_baseline_correction && EEG_final.trials >= 1
    EEG_final = pop_rmbase(EEG_final, [step_cfg.base_start_ms step_cfg.base_end_ms]);
    EEG_final = eeg_checkset(EEG_final);
    EEG_final = helpers.append_eeg_comment(EEG_final, sprintf( ...
        'prep_06_epoching: baseline correction applied [%d %d] ms', ...
        step_cfg.base_start_ms, step_cfg.base_end_ms));

    if step_cfg.save_intermediate_steps && ~step_cfg.save_final_only
        save_intermediate_set_impl( ...
            EEG_final, out_dir, string(base_stem) + "_stage-baselinecorrected", ...
            "delete", cfg, step_cfg.savemode, helpers);
    end
else
    EEG_final = helpers.append_eeg_comment(EEG_final, ...
        'prep_06_epoching: baseline correction skipped');
end
end

function saved_paths = save_final_epoched_outputs_impl(EEG_final, base_stem, out_dir, step_cfg, cfg, helpers)
saved_paths = {};

[idx_eeg, idx_eog, idx_non_eeg] = get_channel_indices_by_type_impl(EEG_final);

if step_cfg.split_non_eeg_channels
    [primary_idx, secondary_idx] = split_final_channel_indices_epoching_impl( ...
        idx_eeg, idx_eog, idx_non_eeg, step_cfg);

    if isempty(primary_idx)
        error('No primary channels available for final EEG output.');
    end

    EEG_primary = pop_select(EEG_final, 'channel', primary_idx);
    EEG_primary = eeg_checkset(EEG_primary);
    EEG_primary.setname = char(string(base_stem) + "_EEG");

    primary_name = char(string(base_stem) + "_EEG.set");
    primary_path = fullfile(out_dir, primary_name);

    EEG_primary = helpers.safe_save_set(EEG_primary, out_dir, primary_name, helpers, cfg);
    helpers.log_msg_default('prep_06_epoching: saved: %s', primary_path);

    saved_paths{end+1,1} = primary_path; %#ok<AGROW>

    if ~isempty(secondary_idx)
        EEG_secondary = pop_select(EEG_final, 'channel', secondary_idx);
        EEG_secondary = eeg_checkset(EEG_secondary);
        EEG_secondary.setname = char(string(base_stem) + "_NON_EEG");

        secondary_name = char(string(base_stem) + "_NON_EEG.set");
        secondary_path = fullfile(out_dir, secondary_name);

        EEG_secondary = helpers.safe_save_set(EEG_secondary, out_dir, secondary_name, helpers, cfg);
        helpers.log_msg_default('prep_06_epoching: saved: %s', secondary_path);

        saved_paths{end+1,1} = secondary_path; %#ok<AGROW>
    end
else
    EEG_full = EEG_final;
    EEG_full.setname = char(string(base_stem));

    out_name = char(string(base_stem) + ".set");
    out_path = fullfile(out_dir, out_name);

    EEG_full = helpers.safe_save_set(EEG_full, out_dir, out_name, helpers, cfg);
    helpers.log_msg_default('prep_06_epoching: saved: %s', out_path);

    saved_paths{end+1,1} = out_path; %#ok<AGROW>
end
end

function paths_out = build_output_paths_for_base_stem_epoching_impl(base_stem, out_dir, step_cfg, idx_eeg, idx_eog, idx_non_eeg)
paths_out = {};

if step_cfg.split_non_eeg_channels
    paths_out{end+1,1} = fullfile(out_dir, char(string(base_stem) + "_EEG.set")); %#ok<AGROW>

    [~, secondary_idx] = split_final_channel_indices_epoching_impl( ...
        idx_eeg, idx_eog, idx_non_eeg, step_cfg);

    if ~isempty(secondary_idx)
        paths_out{end+1,1} = fullfile(out_dir, char(string(base_stem) + "_NON_EEG.set")); %#ok<AGROW>
    end
else
    paths_out{end+1,1} = fullfile(out_dir, char(string(base_stem) + ".set")); %#ok<AGROW>
end
end

function [primary_idx, secondary_idx] = split_final_channel_indices_epoching_impl(idx_eeg, idx_eog, idx_non_eeg, step_cfg)
if isfield(step_cfg, 'eeg_only_keep_eog') && step_cfg.eeg_only_keep_eog
    primary_idx = unique([idx_eeg(:); idx_eog(:)]);
    secondary_idx = idx_non_eeg(:);
else
    primary_idx = idx_eeg(:);
    secondary_idx = unique([idx_eog(:); idx_non_eeg(:)]);
end
end

function tf = matches_any_prefix_impl(code, prefix_list)
tf = false;

if ischar(prefix_list) || isstring(prefix_list)
    prefix_list = cellstr(string(prefix_list));
end

for k = 1:numel(prefix_list)
    if startsWith(string(code), string(prefix_list{k}))
        tf = true;
        return;
    end
end
end

function tf = matches_any_exact_impl(code, exact_list)
tf = false;

if ischar(exact_list) || isstring(exact_list)
    exact_list = cellstr(string(exact_list));
end

for k = 1:numel(exact_list)
    if string(code) == string(exact_list{k})
        tf = true;
        return;
    end
end
end

function EEG_merged = merge_eeg_sets_impl(parts)
EEG_merged = [];

if isempty(parts)
    return;
end

EEG_merged = parts{1};
for k = 2:numel(parts)
    EEG_merged = pop_mergeset(EEG_merged, parts{k}, 0);
    EEG_merged = eeg_checkset(EEG_merged);
end
end

function [tokens, times_s] = build_eeg_key_token_stream_with_time_impl(EEG)
if ~isfield(EEG,'event') || isempty(EEG.event)
    tokens  = strings(0,1);
    times_s = zeros(0,1);
    return;
end
if ~isfield(EEG,'srate') || isempty(EEG.srate)
    error('EEG.srate missing/empty');
end

n = numel(EEG.event);
tokens  = strings(0,1);
times_s = zeros(0,1);

for k = 1:n
    t = normalize_trigger_type_impl(EEG.event(k).type);
    if strcmpi(t, 'boundary'); continue; end
    tokens(end+1,1)  = string(t);
    times_s(end+1,1) = double(EEG.event(k).latency) / double(EEG.srate);
end
end

function [marker, latency] = find_first_event_latency_impl(EEG, event_type)
latency = [];
marker = [];

if ~isfield(EEG, 'event') || isempty(EEG.event)
    return;
end

if ischar(event_type) || isstring(event_type)
    event_type = cellstr(string(event_type));
end

target_types = cellfun(@normalize_trigger_type_impl, ...
    event_type, 'UniformOutput', false);

for k = 1:numel(EEG.event)
    current_type = normalize_trigger_type_impl(EEG.event(k).type);

    if any(strcmp(current_type, target_types))
        latency = EEG.event(k).latency;
        marker = current_type;
        return;
    end
end
end

function [EEG, info] = crop_internal_breaks_impl(EEG, step_cfg)
% CROP_INTERNAL_BREAKS_IMPL
%
% Remove internal task breaks from continuous EEG data.
%
% Methods:
%
%   "off"
%       Do nothing.
%
%   "markers"
%       Detect breaks from explicit break start/end markers.
%
%   "trial_count"
%       Strict validation within a task window defined by
%       break_first_marker and break_last_marker.
%
%       The first occurrence of break_first_marker defines the beginning
%       of the relevant task data. The last occurrence of break_last_marker
%       defines the end of the relevant task data.
%
%       Events before/after this window are ignored.
%
%       Break cropping is performed only when ALL configured criteria
%       inside this task window are matched exactly:
%
%       - exact total number of trial markers
%       - exact number of temporal breaks
%       - exact number of trials in every block
%
% If any criterion fails, no data are removed.

info = struct();

info.method                    = string(step_cfg.break_crop_method);
info.status                    = "OFF";
info.message                   = "";

info.first_marker              = "";
info.last_marker               = "";

info.n_breaks_found            = 0;
info.n_breaks_removed          = 0;
info.n_trial_markers           = 0;
info.n_blocks_detected         = NaN;

info.observed_trials_per_block = [];
info.boundary_trial_indices    = [];
info.break_windows_sec         = zeros(0,2);
info.removed_seconds           = 0;


method = lower(strtrim(string(step_cfg.break_crop_method)));

if isempty(method)
    method = "off";
else
    method = method(1);
end

info.method = method;

if method == "off"
    return;
end


% =========================================================================
% Basic validation
% =========================================================================

if ~isfield(step_cfg, 'break_padding_sec') || ...
        numel(step_cfg.break_padding_sec) ~= 2

    error(['crop_internal_breaks: break_padding_sec must contain exactly ' ...
        'two values [after_previous before_next].']);
end

padding_after  = double(step_cfg.break_padding_sec(1));
padding_before = double(step_cfg.break_padding_sec(2));

if any(~isfinite([padding_after padding_before])) || ...
        padding_after < 0 || padding_before < 0

    error(['crop_internal_breaks: break_padding_sec values must be ' ...
        'finite and >= 0.']);
end

if ~isfield(EEG, 'srate') || ...
        ~isscalar(EEG.srate) || ...
        ~isfinite(EEG.srate) || ...
        EEG.srate <= 0

    error('crop_internal_breaks: EEG.srate must be finite and > 0.');
end

if ~isfield(EEG, 'event') || isempty(EEG.event)

    info.status  = "SKIPPED_VALIDATION_FAILED";
    info.message = "No EEG events available for break detection.";

    handle_break_validation_failure_impl( ...
        step_cfg, info.message);

    return;
end


% =========================================================================
% Marker-based method
% =========================================================================

if method == "markers"

    start_lat = get_matching_event_latencies_impl( ...
        EEG, step_cfg.break_start_marker);

    end_lat = get_matching_event_latencies_impl( ...
        EEG, step_cfg.break_end_marker);

    start_lat = sort(double(start_lat));
    end_lat   = sort(double(end_lat));

    if isempty(start_lat) || isempty(end_lat)

        info.status = "SKIPPED_VALIDATION_FAILED";
        info.message = ...
            "Break start/end markers were not found; break cropping skipped.";

        handle_break_validation_failure_impl( ...
            step_cfg, info.message);

        return;
    end

    if numel(start_lat) ~= numel(end_lat)

        info.status = "SKIPPED_VALIDATION_FAILED";

        info.message = sprintf( ...
            ['Different number of break start/end markers found ' ...
             '(%d starts, %d ends).'], ...
            numel(start_lat), numel(end_lat));

        handle_break_validation_failure_impl( ...
            step_cfg, info.message);

        return;
    end

    break_windows = zeros(numel(start_lat), 2);

    for b = 1:numel(start_lat)

        if end_lat(b) <= start_lat(b)

            info.status = "SKIPPED_VALIDATION_FAILED";

            info.message = sprintf( ...
                'Break %d has an end marker before its start marker.', b);

            handle_break_validation_failure_impl( ...
                step_cfg, info.message);

            return;
        end

        t_start = ...
            (start_lat(b) - 1) / double(EEG.srate);

        t_end = ...
            (end_lat(b) - 1) / double(EEG.srate);

        break_windows(b,:) = [ ...
            t_start + padding_after, ...
            t_end   - padding_before];
    end

    info.status = "OK";

    info.message = sprintf( ...
        'Detected %d marker-defined break(s).', ...
        size(break_windows,1));


% =========================================================================
% Strict trial-count method
% =========================================================================

elseif method == "trial_count"

    % ---------------------------------------------------------------------
    % Validate configuration
    % ---------------------------------------------------------------------

    n_blocks = ...
        double(step_cfg.break_expected_n_blocks);

    trials_per_block = ...
        double(step_cfg.break_trials_per_block);

    min_gap_sec = ...
        double(step_cfg.break_min_gap_sec);


    if isempty(n_blocks) || isempty(trials_per_block)

        error(['crop_internal_breaks: trial_count mode requires ' ...
            'break_expected_n_blocks and break_trials_per_block.']);
    end


    if ~isscalar(n_blocks) || ...
            ~isfinite(n_blocks) || ...
            n_blocks < 2 || ...
            n_blocks ~= round(n_blocks)

        error(['crop_internal_breaks: break_expected_n_blocks must be ' ...
            'an integer >= 2.']);
    end


    if ~isscalar(trials_per_block) || ...
            ~isfinite(trials_per_block) || ...
            trials_per_block < 1 || ...
            trials_per_block ~= round(trials_per_block)

        error(['crop_internal_breaks: break_trials_per_block must be ' ...
            'a positive integer.']);
    end


    if ~isscalar(min_gap_sec) || ...
            ~isfinite(min_gap_sec) || ...
            min_gap_sec < 0

        error(['crop_internal_breaks: break_min_gap_sec must be ' ...
            'a finite scalar >= 0.']);
    end


    % Exactly one trial-marker TYPE must be configured.
    trial_marker_cfg = string(step_cfg.break_trial_marker);
    trial_marker_cfg = trial_marker_cfg( ...
        strlength(strtrim(trial_marker_cfg)) > 0);

    if numel(trial_marker_cfg) ~= 1

        error(['crop_internal_breaks: trial_count mode requires exactly ' ...
            'one break_trial_marker.']);
    end


    % Exactly one task-start marker TYPE must be configured.
    first_marker_cfg = string(step_cfg.break_first_marker);
    first_marker_cfg = first_marker_cfg( ...
        strlength(strtrim(first_marker_cfg)) > 0);

    if numel(first_marker_cfg) ~= 1

        error(['crop_internal_breaks: trial_count mode requires exactly ' ...
            'one break_first_marker.']);
    end


    % Exactly one task-end marker TYPE must be configured.
    last_marker_cfg = string(step_cfg.break_last_marker);
    last_marker_cfg = last_marker_cfg( ...
        strlength(strtrim(last_marker_cfg)) > 0);

    if numel(last_marker_cfg) ~= 1

        error(['crop_internal_breaks: trial_count mode requires exactly ' ...
            'one break_last_marker.']);
    end


    expected_first_marker = string( ...
        normalize_trigger_type_impl(first_marker_cfg(1)));

    expected_last_marker = string( ...
        normalize_trigger_type_impl(last_marker_cfg(1)));


    expected_n_trials = ...
        n_blocks * trials_per_block;

    expected_n_breaks = ...
        n_blocks - 1;


    % ---------------------------------------------------------------------
    % Determine relevant task window
    %
    % The FIRST occurrence of break_first_marker defines the beginning.
    % The LAST occurrence of break_last_marker defines the end.
    %
    % This deliberately ignores unrelated events before/after the task.
    % It also allows break_first_marker to be identical to the trial marker
    % (e.g. S 1), even when that marker occurs many times.
    % ---------------------------------------------------------------------

    start_marker_lat = get_matching_event_latencies_impl( ...
        EEG, first_marker_cfg);

    end_marker_lat = get_matching_event_latencies_impl( ...
        EEG, last_marker_cfg);

    start_marker_lat = sort(double(start_marker_lat));
    end_marker_lat   = sort(double(end_marker_lat));


    if isempty(start_marker_lat)

        info.status = "SKIPPED_VALIDATION_FAILED";

        info.message = sprintf( ...
            'Configured task-start marker %s was not found.', ...
            expected_first_marker);

        handle_break_validation_failure_impl( ...
            step_cfg, info.message);

        return;
    end


    if isempty(end_marker_lat)

        info.status = "SKIPPED_VALIDATION_FAILED";

        info.message = sprintf( ...
            'Configured task-end marker %s was not found.', ...
            expected_last_marker);

        handle_break_validation_failure_impl( ...
            step_cfg, info.message);

        return;
    end


    task_start_lat = start_marker_lat(1);
    task_end_lat   = end_marker_lat(end);


    if task_end_lat < task_start_lat

        info.status = "SKIPPED_VALIDATION_FAILED";

        info.message = sprintf( ...
            ['Configured task-end marker %s occurs before ' ...
             'task-start marker %s.'], ...
            expected_last_marker, ...
            expected_first_marker);

        handle_break_validation_failure_impl( ...
            step_cfg, info.message);

        return;
    end


    info.first_marker = expected_first_marker;
    info.last_marker  = expected_last_marker;


    % ---------------------------------------------------------------------
    % Find trial markers ONLY within the configured task window
    % ---------------------------------------------------------------------

    trial_lat = get_matching_event_latencies_impl( ...
        EEG, trial_marker_cfg);

    trial_lat = sort(double(trial_lat));

    trial_lat = trial_lat( ...
        trial_lat >= task_start_lat & ...
        trial_lat <= task_end_lat);

    info.n_trial_markers = ...
        numel(trial_lat);


    % ---------------------------------------------------------------------
    % Detect temporal breaks between consecutive task trials
    % ---------------------------------------------------------------------

    if numel(trial_lat) >= 2

        trial_times = ...
            (trial_lat - 1) / double(EEG.srate);

        trial_gaps = ...
            diff(trial_times);

        boundary_idx = ...
            find(trial_gaps >= min_gap_sec);

    else

        trial_times = ...
            (trial_lat - 1) / double(EEG.srate);

        boundary_idx = [];
    end


    info.boundary_trial_indices = ...
        boundary_idx;

    info.n_breaks_found = ...
        numel(boundary_idx);


    % ---------------------------------------------------------------------
    % Derive observed block sizes from ALL sufficiently long gaps
    % ---------------------------------------------------------------------

    if isempty(trial_lat)

        block_counts = [];

    else

        block_starts = ...
            [1 boundary_idx + 1];

        block_ends = ...
            [boundary_idx numel(trial_times)];

        block_counts = ...
            block_ends - block_starts + 1;
    end


    info.observed_trials_per_block = ...
        block_counts;

    info.n_blocks_detected = ...
        numel(block_counts);


    % ---------------------------------------------------------------------
    % STRICT VALIDATION
    %
    % ALL criteria must match exactly.
    % There is deliberately no tolerance and no heuristic selection.
    % ---------------------------------------------------------------------

    validation_errors = strings(0,1);


    if info.n_trial_markers ~= expected_n_trials

        validation_errors(end+1,1) = sprintf( ... %#ok<AGROW>
            'expected %d trial markers but found %d', ...
            expected_n_trials, ...
            info.n_trial_markers);
    end


    if info.n_breaks_found ~= expected_n_breaks

        validation_errors(end+1,1) = sprintf( ... %#ok<AGROW>
            'expected %d breaks >= %.1f s but found %d', ...
            expected_n_breaks, ...
            min_gap_sec, ...
            info.n_breaks_found);
    end


    if numel(block_counts) ~= n_blocks || ...
            ~all(block_counts == trials_per_block)

        validation_errors(end+1,1) = sprintf( ... %#ok<AGROW>
            'expected block trial counts %s but found %s', ...
            mat2str(repmat(trials_per_block, 1, n_blocks)), ...
            mat2str(block_counts));
    end


    % Any mismatch -> leave EEG completely unchanged.
    if ~isempty(validation_errors)

        info.status = ...
            "SKIPPED_VALIDATION_FAILED";

        info.message = ...
            "Strict break-crop validation failed: " + ...
            strjoin(validation_errors, " | ");

        handle_break_validation_failure_impl( ...
            step_cfg, info.message);

        return;
    end


    % ---------------------------------------------------------------------
    % All criteria passed exactly -> build removal windows
    % ---------------------------------------------------------------------

    break_windows = ...
        zeros(expected_n_breaks, 2);


    for b = 1:expected_n_breaks

        left_trial_idx = ...
            boundary_idx(b);

        right_trial_idx = ...
            boundary_idx(b) + 1;


        break_windows(b,1) = ...
            trial_times(left_trial_idx) + ...
            padding_after;


        break_windows(b,2) = ...
            trial_times(right_trial_idx) - ...
            padding_before;
    end


    info.status = "OK";

    info.message = sprintf( ...
        ['Strict validation passed within task window %s -> %s: ' ...
         '%d trials, %d breaks, block counts %s.'], ...
        expected_first_marker, ...
        expected_last_marker, ...
        expected_n_trials, ...
        expected_n_breaks, ...
        mat2str(block_counts));


else

    error(['crop_internal_breaks: unknown break_crop_method="%s". ' ...
        'Use "off", "markers", or "trial_count".'], ...
        char(method));
end


% =========================================================================
% Validate removal windows before changing EEG
% =========================================================================

valid_windows = ...
    break_windows(:,2) > break_windows(:,1);


if ~all(valid_windows)

    info.status = ...
        "SKIPPED_VALIDATION_FAILED";

    info.message = ...
        "At least one detected break is shorter than the configured padding.";

    info.break_windows_sec = ...
        zeros(0,2);

    info.n_breaks_removed = 0;
    info.removed_seconds  = 0;

    handle_break_validation_failure_impl( ...
        step_cfg, info.message);

    return;
end


% =========================================================================
% Remove breaks
% =========================================================================

break_windows = ...
    sortrows(break_windows, 1);

info.break_windows_sec = ...
    break_windows;

info.n_breaks_found = ...
    size(break_windows,1);

info.removed_seconds = ...
    sum(break_windows(:,2) - break_windows(:,1));


% Remove backwards so earlier time coordinates remain valid.
for b = size(break_windows,1):-1:1

    EEG = pop_select( ...
        EEG, ...
        'notime', ...
        break_windows(b,:));

    EEG = eeg_checkset(EEG);
end


info.n_breaks_removed = ...
    size(break_windows,1);


info.message = string(info.message) + sprintf( ...
    ' Removed %d break(s), %.1f s total.', ...
    info.n_breaks_removed, ...
    info.removed_seconds);

end


function latencies = get_matching_event_latencies_impl(EEG, event_types)
% Return latencies of all events matching any configured event type.

latencies = [];

if isempty(event_types) || ...
        ~isfield(EEG, 'event') || isempty(EEG.event)

    return;
end

if ischar(event_types) || isstring(event_types)
    event_types = cellstr(string(event_types));
end

target_types = cellfun( ...
    @normalize_trigger_type_impl, ...
    event_types, ...
    'UniformOutput', false);

for k = 1:numel(EEG.event)

    current_type = ...
        normalize_trigger_type_impl(EEG.event(k).type);

    if any(strcmp(current_type, target_types))

        latencies(end+1) = ... %#ok<AGROW>
            double(EEG.event(k).latency);
    end
end

end


function handle_break_validation_failure_impl(step_cfg, message_text)
% Handle ambiguous internal break structure.

action = lower(strtrim(string(step_cfg.break_on_validation_fail)));

if isempty(action)
    action = "skip";
else
    action = action(1);
end

switch action

    case "skip"
        % Caller returns the original continuous EEG unchanged.

    case "error"
        error('crop_internal_breaks: %s', char(string(message_text)));

    otherwise
        error(['crop_internal_breaks: unknown ' ...
            'break_on_validation_fail="%s". ' ...
            'Use "skip" or "error".'], ...
            char(action));
end

end



function EEG = ensure_channel_types_impl(EEG, step_cfg)
if ~isfield(EEG, 'chanlocs') || isempty(EEG.chanlocs)
    return;
end

labels = {EEG.chanlocs.labels};

for k = 1:numel(EEG.chanlocs)
    EEG.chanlocs(k).type = 'EEG';
end

set_type_by_labels_local(step_cfg.eog_channel_labels,     'EOG');
set_type_by_labels_local(step_cfg.scr_channel_labels,     'SCR');
set_type_by_labels_local(step_cfg.startle_channel_labels, 'Startle');
set_type_by_labels_local(step_cfg.ekg_channel_labels,     'EKG');

EEG = eeg_checkset(EEG);

    function set_type_by_labels_local(label_list, type_name)
        for i = 1:numel(label_list)
            idx = find(strcmpi(labels, label_list{i}));
            for j = 1:numel(idx)
                EEG.chanlocs(idx(j)).type = type_name;
            end
        end
    end
end

function [flat_indices, flat_labels, info] = find_flat_or_invalid_channels_impl(EEG, candidate_indices, detection_cfg)
flat_indices = [];
flat_labels  = {};
info = struct();

if isempty(candidate_indices)
    return;
end

if nargin < 3 || ~isstruct(detection_cfg)
    error('flat-channel detection settings must be provided as a struct.');
end

candidate_indices = candidate_indices(:)';
data_2d = double(reshape(EEG.data(candidate_indices, :, :), numel(candidate_indices), []));

mode = "cumulative_fraction";
if isfield(detection_cfg, 'mode') && strlength(string(detection_cfg.mode)) > 0
    mode = lower(strtrim(string(detection_cfg.mode)));
    mode = mode(1);
end

step_tolerance_uV = 0;
if isfield(detection_cfg, 'step_tolerance_uV') && ~isempty(detection_cfg.step_tolerance_uV)
    step_tolerance_uV = double(detection_cfg.step_tolerance_uV);
end

if ~isscalar(step_tolerance_uV) || ~isfinite(step_tolerance_uV) || step_tolerance_uV < 0
    error('flat_channel_detection.step_tolerance_uV must be a finite scalar >= 0.');
end

has_invalid = any(~isfinite(data_2d), 2);
flat_fraction = zeros(numel(candidate_indices), 1);
max_contiguous_flat_sec = zeros(numel(candidate_indices), 1);
is_flat = false(numel(candidate_indices), 1);
criterion_threshold = NaN;

recording_duration_sec = NaN;
if isscalar(EEG.srate) && isfinite(EEG.srate) && EEG.srate > 0
    recording_duration_sec = max(size(data_2d, 2) - 1, 0) / double(EEG.srate);
end

if size(data_2d, 2) < 2
    is_flat(:) = true;
else
    finite_pairs = isfinite(data_2d(:, 1:end-1)) & isfinite(data_2d(:, 2:end));
    flat_intervals = finite_pairs & ...
        (abs(diff(data_2d, 1, 2)) <= step_tolerance_uV);

    flat_fraction = sum(flat_intervals, 2) ./ size(flat_intervals, 2);

    switch mode
        case "cumulative_fraction"
            max_flat_fraction = 0.10;
            if isfield(detection_cfg, 'max_flat_fraction') && ...
                    ~isempty(detection_cfg.max_flat_fraction)
                max_flat_fraction = double(detection_cfg.max_flat_fraction);
            end

            if ~isscalar(max_flat_fraction) || ~isfinite(max_flat_fraction) || ...
                    max_flat_fraction <= 0 || max_flat_fraction > 1
                error('flat_channel_detection.max_flat_fraction must be in (0, 1].');
            end

            criterion_threshold = max_flat_fraction;
            is_flat = flat_fraction >= max_flat_fraction;

        case "continuous_seconds"
            continuous_flat_sec = 5;
            if isfield(detection_cfg, 'continuous_flat_sec') && ...
                    ~isempty(detection_cfg.continuous_flat_sec)
                continuous_flat_sec = double(detection_cfg.continuous_flat_sec);
            end

            if ~isscalar(continuous_flat_sec) || ~isfinite(continuous_flat_sec) || ...
                    continuous_flat_sec <= 0
                error('flat_channel_detection.continuous_flat_sec must be a finite scalar > 0.');
            end

            if ~isscalar(EEG.srate) || ~isfinite(EEG.srate) || EEG.srate <= 0
                error('EEG.srate must be a finite scalar > 0 for continuous flat-channel detection.');
            end

            for ch = 1:size(flat_intervals, 1)
                padded = [false, flat_intervals(ch, :), false];
                transitions = diff(padded);
                run_starts = find(transitions == 1);
                run_ends = find(transitions == -1) - 1;

                if ~isempty(run_starts)
                    max_flat_steps = max(run_ends - run_starts + 1);
                    max_contiguous_flat_sec(ch) = max_flat_steps / double(EEG.srate);
                end
            end

            criterion_threshold = continuous_flat_sec;
            is_flat = max_contiguous_flat_sec >= continuous_flat_sec;

        otherwise
            error(['flat_channel_detection.mode must be "cumulative_fraction" ' ...
                'or "continuous_seconds". Got: %s'], char(mode));
    end
end

is_bad = is_flat | has_invalid;

flat_indices = candidate_indices(is_bad(:)');

if ~isempty(flat_indices)
    flat_labels = {EEG.chanlocs(flat_indices).labels};
end

info.mode = mode;
info.step_tolerance_uV = step_tolerance_uV;
info.criterion_threshold = criterion_threshold;
info.recording_duration_sec = recording_duration_sec;
info.n_samples = size(data_2d, 2);
info.candidate_indices = candidate_indices;
info.candidate_labels = string({EEG.chanlocs(candidate_indices).labels});
info.flat_fraction = flat_fraction(:)';
info.max_contiguous_flat_sec = max_contiguous_flat_sec(:)';
info.has_invalid = has_invalid(:)';
info.is_flat = is_flat(:)';
end

function [bad_indices, bad_labels] = detect_bad_channels_clean_rawdata_impl(EEG, eeg_indices, corr_threshold)
bad_indices = [];
bad_labels  = {};

if isempty(eeg_indices)
    return;
end

if exist('clean_rawdata', 'file') ~= 2
    return;
end

EEG_tmp = EEG;
EEG_tmp = pop_select(EEG_tmp, 'channel', eeg_indices);
EEG_tmp = eeg_checkset(EEG_tmp);

labels_before = {EEG_tmp.chanlocs.labels};

% Flat-channel detection has already been performed centrally in Step 03.
% Disable clean_rawdata's own continuous-flatline criterion here so each
% channel is evaluated for flatness exactly once.
EEG_clean = clean_rawdata(EEG_tmp, -1, -1, corr_threshold, -1, -1, -1);
EEG_clean = eeg_checkset(EEG_clean);

labels_after = {EEG_clean.chanlocs.labels};
removed_labels = setdiff(labels_before, labels_after, 'stable');

if isempty(removed_labels)
    return;
end

all_labels = {EEG.chanlocs.labels};

for i = 1:numel(removed_labels)
    idx = find(strcmpi(all_labels, removed_labels{i}), 1, 'first');
    if ~isempty(idx)
        bad_indices(end+1) = idx; %#ok<AGROW>
    end
end

bad_indices = unique(bad_indices);
bad_labels  = {EEG.chanlocs(bad_indices).labels};
end

function EEG = apply_filter_to_subset_only_impl(EEG, subset_indices, locutoff_hz, hicutoff_hz, label_for_log)
if isempty(subset_indices)
    return;
end

original_data = EEG.data;

EEG = pop_eegfiltnew(EEG, 'locutoff', locutoff_hz, 'hicutoff', hicutoff_hz, 'usefftfilt', 1);
EEG = eeg_checkset(EEG);

non_subset = setdiff(1:EEG.nbchan, subset_indices);
EEG.data(non_subset, :) = original_data(non_subset, :);

EEG = eeg_checkset(EEG);

if nargin >= 5 && ~isempty(label_for_log)
    EEG = append_eeg_comment_impl(EEG, ...
        sprintf('%s: applied only to channels %s', label_for_log, mat2str(subset_indices)));
end
end

function [EEG, did_apply, clean_log] = remove_line_noise_from_subset_impl(EEG, subset_indices, step_cfg, plugin_path, helpers)
did_apply = false;
clean_log = struct();

if contains(lower(step_cfg.line_noise_method), 'zap')
    method = 'zapline';
elseif contains(lower(step_cfg.line_noise_method), 'clean')
    method = 'cleanline';
elseif contains(lower(step_cfg.line_noise_method), 'notch')
    method = 'notch';
else
    helpers.log_msg_default(sprintf('\tLine Noise Removal: ERROR removal method - %s - not recognized.', step_cfg.line_noise_method));
    return
end

end

if isempty(subset_indices)
    return;
end

if exist('pop_cleanline', 'file') ~= 2
    return;
end

plugs = dir(fullfile(plugin_path, '*line*'));
original_data = EEG.data;

% Backward-compatible fallbacks in case older configs are used
bandwidth_hz      = getfield_safe_impl(step_cfg, 'pop_cleanline_bandwidth_hz', 2);
p_value           = getfield_safe_impl(step_cfg, 'pop_cleanline_p_value', 0.01);
scanforlines      = getfield_safe_impl(step_cfg, 'pop_cleanline_scanforlines', false);
winsize_sec       = getfield_safe_impl(step_cfg, 'pop_cleanline_winsize_sec', 4);
winstep_sec       = getfield_safe_impl(step_cfg, 'pop_cleanline_winstep_sec', 1);
tau_val           = getfield_safe_impl(step_cfg, 'pop_cleanline_tau', 100);
pad_val           = getfield_safe_impl(step_cfg, 'pop_cleanline_pad', 2);
taperbandwidth_hz = getfield_safe_impl(step_cfg, 'pop_cleanline_taperbandwidth_hz', 2);
norm_spectrum     = getfield_safe_impl(step_cfg, 'pop_cleanline_norm_spectrum', 0);
compute_power     = getfield_safe_impl(step_cfg, 'pop_cleanline_computepower', 0);
verbose_flag      = getfield_safe_impl(step_cfg, 'pop_cleanline_verbose', false);

try
    EEG_tmp = pop_select(EEG, 'channel', subset_indices);
    EEG_tmp = eeg_checkset(EEG_tmp);

    fs = EEG_tmp.srate;
    freqs = step_cfg.line_noise_frequencies_hz;
    freqs = freqs(freqs < fs / 2); % only keep frequencies below Nyquist, as that is also the highest frequency for the lowpass filter.

    clean_log.freqs = freqs;

    if isempty(freqs)
        did_apply = true;
        log_msg_default_impl('\tLine Noise Removal: WARNING Specified frequencies below nyquist.');
        return;
    end
    
    if strcmp(method, "zapline")  
        if ~any(cellfun(@(x) contains(x, 'zapline'), {plugs.name})) % check if zapline plugin installed, otherwise use cleanline
            helpers.log_msg_default('prep03_untilica: WARNING zapline-plus was not found on path, continuing with cleanline.');
            method = 'cleanline';
        else
            clean_log.zapline = struct();
            [EEG_tmp.data, clean_log.zapline.config, clean_log.zapline.analytics] = ...
                clean_data_with_zapline_plus(EEG_tmp.data, fs, struct('noisefreqs', freqs, 'plotResults', false, 'saveSpectra', true));
            clean_log.zapline.applied = true;
            
            if clean_log.zapline.analytics.ratioNoiseClean > step_cfg.line_noise_ratio % check if noise ratio above acceptable threshold
                if step_cfg.line_noise_fb_cleanline % check if fallback to cleanline allowed
                    clean_log.fallback_to_cleanline = true;
                    method = 'cleanline';
                    helpers.log_msg_default('\tLine Noise Removal: Zapline did not work optimally, using cleanline in next step.');
                else
                    helpers.log_msg_default(sprintf('\tLine Noise Removal: WARNING Zapline applied, remaining noise ratio %s.', clean_log.zapline.analytics.ratioNoiseClean));
                end
            else
                helpers.log_msg_default(sprintf('\tLine Noise Removal: Zapline applied succesfully. Noise ratio %s.', clean_log.zapline.analytics.ratioNoiseClean));
            end
        end
    end
   
    if strcmp(method, "cleanline")
        if ~any(cellfun(@(x) contains(lower(x), 'cleanline'),{plugs.name})) % check if cleanline plugin installed
            if step_cfg.line_noise_fb_notch
                clean_log.fallback_to_cleanline = false;
                clean_log.fallback_to_notch     = true;
                method = 'notch';
                helpers.log_msg_default('\tLine Noise Removal: WARNING cleanline was not found on path. Using Notch filter as fallback.');
            else
                helpers.log_msg_default('\tLine Noise Removal: WARNING cleanline was not found on path. Continuing without removing line noise.');
                return
            end
        else
            clean_log.cleanline = struct();
            clean_log.cleanline.analytics = struct();

            if isfield(clean_log, 'zapline') && isfield(clean_log.zapline, 'config')
                % if zapline was applied, take parameters for noise ratio calculation from there
                winSize = clean_log.zapline.config.winSizeCompleteSpectrum;
                detect_winSize = clean_log.zapline.config.detectionWinsize;
                pxx_log_before = clean_log.zapline.analytics.cleanSpectrumLog;
                psd_freqs = clean_log.zapline.analytics.frequencies;
            else
                % otherwise use the same logic to calculate the noise ratio as in zapline
                winSize = floor(length(EEG_tmp.data)/8/fs);
                detect_winSize = 6;
                [pxx_log_before, psd_freqs] = pwelch(EEG_tmp.data',hanning(winSize*fs),[],[],fs);
                pxx_log_before = 10*log10(pxx_log_before);
                clean_log.cleanline.analytics.rawSpectrumLog = pxx_log_before;
                clean_log.cleanline.analytics.frequencies = psd_freqs;
            end

            % make sure cleanline calls functions from own path
            cleanline_dir = fullfile(plugin_path, plugs(find(cellfun(@(x) contains(lower(x), 'cleanline'),{plugs.name}))).name);
            addpath(genpath(cleanline_dir), '-begin');   % puts it first on matlab paths

            EEG_tmp = pop_cleanline(EEG_tmp, ...
                'bandwidth',        bandwidth_hz, ...
                'chanlist',         1:size(EEG_tmp.data, 1), ...
                'computepower',     compute_power, ...
                'linefreqs',        freqs, ...
                'normSpectrum',     norm_spectrum, ...
                'p',                p_value, ...
                'pad',              pad_val, ...
                'plotfigures',      0, ...
                'scanforlines',     double(scanforlines), ...
                'sigtype',          'Channels', ...
                'taperbandwidth',   taperbandwidth_hz, ...
                'tau',              tau_val, ...
                'verb',             double(verbose_flag), ...
                'winsize',          winsize_sec, ...
                'winstep',          winstep_sec);
            
            clean_log.cleanline.applied = true;

            % calculate power spectrum after cleanline
            pxx_log_after = pwelch(single(EEG_tmp.data)',hanning(winSize*fs),[],[],fs);
            pxx_log_after = 10*log10(pxx_log_after);

            clean_log.cleanline.analytics.cleanSpectrumLog = pxx_log_after;
            clean_log.cleanline.analytics.ratioNoiseBefore = [];
            clean_log.cleanline.analytics.ratioNoiseAfter = [];

            for f = freqs % calculate noise ratio for each frequency and append to log
                clean_log.cleanline.analytics.ratioNoiseAfter(end+1)  = 10^((mean(mean(pxx_log_after(noise_idx,:),2)) - mean(pxx_log_after(surround_idx,:),'all'))/10);
            end

            % if noise ratio still above acceptable threshold, apply notch filter
            % filter
            if clean_log.cleanline.analytics.ratioNoiseAfter > step_cfg.line_noise_ratio && step_cfg.line_noise_fb_notch
                clean_log.fallback_to_notch = true;
                method = 'notch';
                helpers.log_msg_default(sprintf('\tLine Noise Removal: After Zap-/Cleanline 50 Hz noise ratio at %d. Applying notch filter.', clean_log.cleanline.analytics.ratioNoiseAfter(1)));
            end
        end
    end
    if strcmp(method, "notch")
        % use EEGLab notch filter?
    end

    EEG.data(subset_indices, :) = EEG_tmp.data;
    did_apply = true;

catch ME
    EEG.data = original_data;
    did_apply = false;
    helpers.log_msg_default(sprintf('remove_line_noise_from_subset failed: %s (function: %s, line: %d)', ME.message, ME.stack(1).name, ME.stack(1).line));
    return
end

EEG = eeg_checkset(EEG);
end

function [EEG, did_apply] = apply_jointprob_safely_impl(EEG, local_threshold, global_threshold)
did_apply = false;

if EEG.nbchan < 2
    return;
end

try
    if isfield(EEG, 'chanlocs') && isfield(EEG.chanlocs, 'type')
        types = lower(string({EEG.chanlocs.type}));
        candidate_mask = (types == "eeg") | (types == "eog");
        candidate_idx  = find(candidate_mask);
    else
        candidate_idx = 1:EEG.nbchan;
    end

    if numel(candidate_idx) < 2
        return;
    end

    data_2d = double(reshape(EEG.data(candidate_idx, :, :), numel(candidate_idx), []));
    chan_var = var(data_2d, 0, 2);

    valid_mask = isfinite(chan_var) & (chan_var > 0);
    valid_idx_local = find(valid_mask);

    if numel(valid_idx_local) < 2
        return;
    end

    valid_idx = candidate_idx(valid_idx_local);

    EEG = pop_jointprob(EEG, 1, valid_idx, local_threshold, global_threshold, 0, 1, 0, [], 0);
    EEG = eeg_checkset(EEG);
    did_apply = true;

catch me
    EEG = append_eeg_comment_impl(EEG, sprintf('ica-prep: pop_jointprob failed: %s', me.message));
    did_apply = false;
end
end

function [EEG, info] = reject_ica_prep_epochs_by_mad_variance_impl(EEG, chan_idx, z_thresh, use_logvar)
info = struct();
info.did_apply       = false;
info.z_thresh        = z_thresh;
info.use_logvar      = logical(use_logvar);
info.n_before        = EEG.trials;
info.n_rejected      = 0;
info.n_kept          = EEG.trials;
info.rejected_epochs = [];

if EEG.trials < 2 || isempty(chan_idx)
    return;
end

X = double(EEG.data(chan_idx, :, :));
n_chan  = size(X, 1);
n_epoch = size(X, 3);

v = zeros(n_chan, n_epoch);
for e = 1:n_epoch
    v(:, e) = var(X(:, :, e), 0, 2);
end

if use_logvar
    v = log10(v + eps);
end

z = zeros(size(v));

for c = 1:n_chan
    x_c  = v(c, :);
    med  = median(x_c);
    madv = median(abs(x_c - med));
    denom = (1.4826 * madv) + eps;
    z(c, :) = (x_c - med) ./ denom;
end

bad_epoch_mask = any(abs(z) > z_thresh, 1);
bad_epochs = find(bad_epoch_mask);

if isempty(bad_epochs)
    return;
end

EEG = pop_rejepoch(EEG, bad_epoch_mask, 0);
EEG = eeg_checkset(EEG);

if ~isfield(EEG, 'etc') || isempty(EEG.etc)
    EEG.etc = struct();
end

EEG.etc.ica_prep_mad_rejection = struct();
EEG.etc.ica_prep_mad_rejection.z_thresh = z_thresh;
EEG.etc.ica_prep_mad_rejection.use_logvar = use_logvar;
EEG.etc.ica_prep_mad_rejection.rejected_epochs = bad_epochs;

info.did_apply       = true;
info.n_rejected      = numel(bad_epochs);
info.n_kept          = EEG.trials;
info.rejected_epochs = bad_epochs;
end

function [EEG, info] = apply_shared_epoch_rejection_impl(EEG, reject_cfg)
% APPLY_SHARED_EPOCH_REJECTION_IMPL
%
% Shared FASTER/PTP epoch rejection for already epoched EEGLAB datasets.
%
% Used by:
%   - Step 03 ICA-prep rejection when method="faster_ptp"
%   - Step 06 final epoch rejection when method="faster_ptp"
%
% Logic:
%   1) optional FASTER epoch_properties outlier detection
%   2) optional peak-to-peak amplitude threshold
%   3) reject union of bad epochs

info = struct();
info.did_apply       = false;
info.n_before        = 0;
info.n_rejected      = 0;
info.n_kept          = 0;
info.rejected_epochs = [];

info.use_faster      = false;
info.have_faster     = false;
info.use_ptp         = false;
info.use_robust_z    = true;
info.faster_z        = NaN;
info.ptp_uV_thresh   = NaN;

info.n_bad_faster    = 0;
info.n_bad_ptp       = 0;
info.rejected_epochs_faster = [];
info.rejected_epochs_ptp = [];

if nargin < 2 || isempty(reject_cfg) || ~isstruct(reject_cfg)
    return;
end

if ~isfield(EEG, 'trials') || isempty(EEG.trials)
    return;
end

info.n_before = EEG.trials;
info.n_kept   = EEG.trials;

enable = true;
if isfield(reject_cfg, 'enable') && ~isempty(reject_cfg.enable)
    enable = logical(reject_cfg.enable);
end

if EEG.trials < 1 || ~enable
    return;
end

if ~isfield(EEG, 'chanlocs') || isempty(EEG.chanlocs)
    return;
end

if isfield(EEG.chanlocs, 'type')
    idx_eeg = find(strcmpi({EEG.chanlocs.type}, 'EEG'));
else
    idx_eeg = 1:EEG.nbchan;
end

idx_eeg = idx_eeg(:)';

if isempty(idx_eeg)
    return;
end

use_faster = false;
if isfield(reject_cfg, 'use_faster') && ~isempty(reject_cfg.use_faster)
    use_faster = logical(reject_cfg.use_faster);
end

use_ptp = false;
if isfield(reject_cfg, 'use_ptp') && ~isempty(reject_cfg.use_ptp)
    use_ptp = logical(reject_cfg.use_ptp);
end

use_robust_z = true;
if isfield(reject_cfg, 'use_robust_z') && ~isempty(reject_cfg.use_robust_z)
    use_robust_z = logical(reject_cfg.use_robust_z);
end

faster_z = 3;
if isfield(reject_cfg, 'faster_z') && ~isempty(reject_cfg.faster_z)
    faster_z = double(reject_cfg.faster_z);
end

ptp_uV_thresh = 100;
if isfield(reject_cfg, 'ptp_uV_thresh') && ~isempty(reject_cfg.ptp_uV_thresh)
    ptp_uV_thresh = double(reject_cfg.ptp_uV_thresh);
end

info.use_faster    = use_faster;
info.use_ptp       = use_ptp;
info.use_robust_z  = use_robust_z;
info.faster_z      = faster_z;
info.ptp_uV_thresh = ptp_uV_thresh;

bad_faster = false(EEG.trials, 1);
bad_ptp    = false(EEG.trials, 1);

% -------------------------------------------------------------------------
% FASTER epoch_properties
% -------------------------------------------------------------------------
info.have_faster = (exist('epoch_properties', 'file') == 2);

if use_faster && info.have_faster

    props = epoch_properties(EEG, idx_eeg);

    if ~isempty(props) && size(props, 1) ~= EEG.trials && size(props, 2) == EEG.trials
        props = props.';
    end

    if ~isempty(props) && size(props, 1) == EEG.trials

        props = double(props);

        if use_robust_z
            med = median(props, 1, 'omitnan');
            madv = median(abs(props - med), 1, 'omitnan');
            denom = 1.4826 .* madv;
            denom(denom == 0 | isnan(denom)) = Inf;
            zmat = (props - med) ./ denom;
        else
            mu = mean(props, 1, 'omitnan');
            sd = std(props, 0, 1, 'omitnan');
            sd(sd == 0 | isnan(sd)) = Inf;
            zmat = (props - mu) ./ sd;
        end

        bad_faster = any(abs(zmat) > faster_z, 2);
    end
end

% -------------------------------------------------------------------------
% Peak-to-peak threshold
% -------------------------------------------------------------------------
if use_ptp
    data = double(EEG.data(idx_eeg, :, :));
    ptp  = max(data, [], 2) - min(data, [], 2);
    ptp  = reshape(ptp, numel(idx_eeg), EEG.trials);

    bad_ptp = any(ptp > ptp_uV_thresh, 1)';
end

bad = bad_faster | bad_ptp;
bad_epochs = find(bad);

info.n_bad_faster = sum(bad_faster);
info.n_bad_ptp    = sum(bad_ptp);
info.rejected_epochs_faster = find(bad_faster(:))';
% Assign overlapping FASTER+PTP epochs to FASTER first so reason counts
% remain additive and equal the union rejected by this backend.
info.rejected_epochs_ptp = find(bad_ptp(:) & ~bad_faster(:))';

if ~isempty(bad_epochs)
    EEG = pop_rejepoch(EEG, bad_epochs, 0);
    EEG = eeg_checkset(EEG);
end

info.did_apply       = true;
info.n_rejected      = numel(bad_epochs);
info.n_kept          = EEG.trials;
info.rejected_epochs = bad_epochs(:)';

if ~isfield(EEG, 'etc') || isempty(EEG.etc)
    EEG.etc = struct();
end

EEG.etc.shared_epoch_rejection = info;
end

function [EEG_out, info] = apply_erplab_epoch_rejection_impl( ...
    EEG_in, idx_eeg, reject_cfg, helpers, subj_label, run_label)

% APPLY_ERPLAB_EPOCH_REJECTION_IMPL
%
% Uses ERPLAB artifact-detection functions on already epoched/segmented
% EEGLAB datasets:
%
%   pop_artextval    : extreme voltage threshold
%   pop_artdiff      : sample-to-sample voltage difference
%   pop_artflatline  : optional blocking / flatline detection (off by default)
%
% The function also creates the minimal ERPLAB-compatible EVENTLIST / epoch
% fields needed for artificial regepochs, such as ICA-prep 1-s epochs or
% baseline 10-s epochs.

EEG_out = EEG_in;

info = struct();
info.did_apply = false;
info.toolbox   = 'ERPLAB';
info.functions_called = {};
info.n_before  = EEG_in.trials;
info.n_rejected = 0;
info.n_kept = EEG_in.trials;
info.rejected_epochs = [];
info.n_rejected_extreme_voltage = 0;
info.n_rejected_sample_diff = 0;
info.n_rejected_flatline = 0;
info.rejected_epochs_extreme_voltage = [];
info.rejected_epochs_sample_diff = [];
info.rejected_epochs_flatline = [];
info.reason_assignment = "exclusive_first_match";
info.channel_scope = "";
info.n_channels_checked = 0;
info.twindow_ms = [];
info.lowpass_hz = [];
info.review = "";
info.history = "";

if nargin < 5
    subj_label = "";
end

if nargin < 6
    run_label = "";
end

if EEG_in.trials < 1
    return;
end

if ~isfield(reject_cfg, 'enable') || ~reject_cfg.enable
    return;
end

required_erplab_functions = {};

if isfield(reject_cfg, 'use_extreme_voltage') && logical(reject_cfg.use_extreme_voltage)
    required_erplab_functions{end+1} = 'pop_artextval'; %#ok<AGROW>
end

if isfield(reject_cfg, 'use_sample_diff') && logical(reject_cfg.use_sample_diff)
    required_erplab_functions{end+1} = 'pop_artdiff'; %#ok<AGROW>
end

if isfield(reject_cfg, 'use_flatline') && logical(reject_cfg.use_flatline)
    required_erplab_functions{end+1} = 'pop_artflatline'; %#ok<AGROW>
end

for f = 1:numel(required_erplab_functions)
    if exist(required_erplab_functions{f}, 'file') ~= 2
        error(['ERPLAB function %s was not found on the MATLAB path. ' ...
            'Check cfg.toolboxes.path_erplab_* and make sure ERPLAB is installed/loaded.'], ...
            required_erplab_functions{f});
    end
end

channel_scope = "eeg";
if isfield(reject_cfg, 'channel_scope') && strlength(string(reject_cfg.channel_scope)) > 0
    channel_scope = lower(strtrim(string(reject_cfg.channel_scope)));
end
info.channel_scope = channel_scope;

switch channel_scope
    case "eeg"
        chan_idx = idx_eeg(:)';
    case "all"
        chan_idx = 1:EEG_in.nbchan;
    otherwise
        error('cfg.*.erplab_epoch_rejection.channel_scope must be "eeg" or "all". Got: %s', ...
            char(channel_scope));
end

if isempty(chan_idx)
    helpers.log_msg_default( ...
        'ERPLAB rejection skipped: %s | %s | no channels selected for scope=%s.', ...
        char(string(subj_label)), char(string(run_label)), char(channel_scope));
    return;
end

info.n_channels_checked = numel(chan_idx);

twindow_ms = resolve_erplab_twindow_impl(EEG_in, reject_cfg);
info.twindow_ms = twindow_ms;

review = 'off';
if isfield(reject_cfg, 'review') && strlength(string(reject_cfg.review)) > 0
    review = char(string(reject_cfg.review));
end
info.review = review;

history_mode = 'off';
if isfield(reject_cfg, 'history') && strlength(string(reject_cfg.history)) > 0
    history_mode = char(string(reject_cfg.history));
end
info.history = history_mode;

lowpass_hz = -1;
if isfield(reject_cfg, 'lowpass_hz') && ~isempty(reject_cfg.lowpass_hz)
    lowpass_hz = double(reject_cfg.lowpass_hz);
end
info.lowpass_hz = lowpass_hz;

clear_existing_flags = true;
if isfield(reject_cfg, 'clear_existing_flags')
    clear_existing_flags = logical(reject_cfg.clear_existing_flags);
end

EEG_work = EEG_in;
EEG_work = ensure_erplab_epoch_eventlist_compat_impl(EEG_work);

%% LL: add-on to save original trial number for trial-wise analysis combined with behavioral data
% --- store original trial index per epoch (before pop_rejepoch removes trials) ---
try
    if isfield(EEG_work,'epoch') && ~isempty(EEG_work.epoch) && isfield(EEG_work,'trials')
        nT = EEG_work.trials;
        nE = numel(EEG_work.epoch);
        for e = 1:min(nT, nE)
            EEG_work.epoch(e).orig_trial_index = e; % 1..nTrials before rejection
        end
    end
catch
    % If metadata write fails, continue preprocessing
end
%% LL add-on end

if ~isfield(EEG_work, 'reject') || ~isstruct(EEG_work.reject)
    EEG_work.reject = struct();
end

if ~isfield(EEG_work.reject, 'rejmanual') || isempty(EEG_work.reject.rejmanual) || clear_existing_flags
    EEG_work.reject.rejmanual = zeros(1, EEG_work.trials);
end

if ~isfield(EEG_work.reject, 'rejmanualE') || isempty(EEG_work.reject.rejmanualE) || clear_existing_flags
    EEG_work.reject.rejmanualE = zeros(EEG_work.nbchan, EEG_work.trials);
end

if clear_existing_flags
    EEG_work = clear_erplab_artifact_flags_impl(EEG_work);
end

% -------------------------------------------------------------------------
% 1) Extreme voltage via ERPLAB pop_artextval
% -------------------------------------------------------------------------
use_extreme_voltage = isfield(reject_cfg, 'use_extreme_voltage') && ...
    logical(reject_cfg.use_extreme_voltage);

if use_extreme_voltage
    extreme_voltage_uV = double(getfield_safe_impl(reject_cfg, 'extreme_voltage_uV', 200));
    flag_extreme = validate_erplab_flag_impl( ...
        getfield_safe_impl(reject_cfg, 'flag_extreme_voltage', 1), ...
        'flag_extreme_voltage');

    bad_before = erplab_rejmanual_mask_impl(EEG_work);

    EEG_work = pop_artextval(EEG_work, ...
        'Channel',   chan_idx, ...
        'Flag',      flag_extreme, ...
        'Threshold', [-abs(extreme_voltage_uV) abs(extreme_voltage_uV)], ...
        'Twindow',   twindow_ms, ...
        'LowPass',   lowpass_hz, ...
        'Review',    review, ...
        'History',   history_mode);

    EEG_work = eeg_checkset(EEG_work);

    bad_after = erplab_rejmanual_mask_impl(EEG_work);
    new_bad = bad_after & ~bad_before;
    info.n_rejected_extreme_voltage = sum(new_bad);
    info.rejected_epochs_extreme_voltage = find(new_bad(:))';
    info.functions_called{end+1} = 'pop_artextval';
end

% -------------------------------------------------------------------------
% 2) Sample-to-sample voltage difference via ERPLAB pop_artdiff
% -------------------------------------------------------------------------
use_sample_diff = isfield(reject_cfg, 'use_sample_diff') && ...
    logical(reject_cfg.use_sample_diff);

if use_sample_diff
    sample_diff_uV = double(getfield_safe_impl(reject_cfg, 'sample_diff_uV', 50));
    flag_sample = validate_erplab_flag_impl( ...
        getfield_safe_impl(reject_cfg, 'flag_sample_diff', 2), ...
        'flag_sample_diff');

    bad_before = erplab_rejmanual_mask_impl(EEG_work);

    EEG_work = pop_artdiff(EEG_work, ...
        'Channel',   chan_idx, ...
        'Flag',      flag_sample, ...
        'Threshold', abs(sample_diff_uV), ...
        'Twindow',   twindow_ms, ...
        'LowPass',   lowpass_hz, ...
        'Review',    review, ...
        'History',   history_mode);

    EEG_work = eeg_checkset(EEG_work);

    bad_after = erplab_rejmanual_mask_impl(EEG_work);
    new_bad = bad_after & ~bad_before;
    info.n_rejected_sample_diff = sum(new_bad);
    info.rejected_epochs_sample_diff = find(new_bad(:))';
    info.functions_called{end+1} = 'pop_artdiff';
end

% -------------------------------------------------------------------------
% 3) Flatline / blocking via ERPLAB pop_artflatline
% -------------------------------------------------------------------------
use_flatline = isfield(reject_cfg, 'use_flatline') && ...
    logical(reject_cfg.use_flatline);

if use_flatline
    flatline_tolerance_uV = double(getfield_safe_impl(reject_cfg, 'flatline_tolerance_uV', 0.5));
    flatline_duration_ms  = double(getfield_safe_impl(reject_cfg, 'flatline_duration_ms', 100));
    flag_flatline = validate_erplab_flag_impl( ...
        getfield_safe_impl(reject_cfg, 'flag_flatline', 3), ...
        'flag_flatline');

    bad_before = erplab_rejmanual_mask_impl(EEG_work);

    EEG_work = pop_artflatline(EEG_work, ...
        'Channel',   chan_idx, ...
        'Flag',      flag_flatline, ...
        'Threshold', [-abs(flatline_tolerance_uV) abs(flatline_tolerance_uV)], ...
        'Duration',  flatline_duration_ms, ...
        'Twindow',   twindow_ms, ...
        'LowPass',   lowpass_hz, ...
        'Review',    review, ...
        'History',   history_mode);

    EEG_work = eeg_checkset(EEG_work);

    bad_after = erplab_rejmanual_mask_impl(EEG_work);
    new_bad = bad_after & ~bad_before;
    info.n_rejected_flatline = sum(new_bad);
    info.rejected_epochs_flatline = find(new_bad(:))';
    info.functions_called{end+1} = 'pop_artflatline';
end

bad_union = erplab_rejmanual_mask_impl(EEG_work);
bad_epochs = find(bad_union);

info.did_apply = true;
info.n_rejected = numel(bad_epochs);
info.rejected_epochs = bad_epochs(:)';

if isempty(bad_epochs)
    info.n_kept = EEG_work.trials;

    if ~isfield(EEG_work, 'etc') || isempty(EEG_work.etc)
        EEG_work.etc = struct();
    end
    EEG_work.etc.prep_erplab_epoch_rejection = info;

    EEG_out = EEG_work;

    helpers.log_msg_default( ...
        'ERPLAB rejection: %s | %s | no bad epochs | checked_channels=%d | functions=%s', ...
        char(string(subj_label)), char(string(run_label)), ...
        info.n_channels_checked, strjoin(string(info.functions_called), '+'));

    return;
end

if numel(bad_epochs) == EEG_work.trials
    info.n_kept = 0;
    EEG_work.trials = 0;
else
    EEG_work = pop_rejepoch(EEG_work, bad_epochs, 0);
    EEG_work = eeg_checkset(EEG_work);
    info.n_kept = EEG_work.trials;
end

if ~isfield(EEG_work, 'etc') || isempty(EEG_work.etc)
    EEG_work.etc = struct();
end
EEG_work.etc.prep_erplab_epoch_rejection = info;

EEG_out = EEG_work;

helpers.log_msg_default( ...
    ['ERPLAB rejection: %s | %s | rejected=%d/%d | kept=%d | ' ...
    'extreme_voltage=%d | sample_diff=%d | flatline=%d | checked_channels=%d | functions=%s'], ...
    char(string(subj_label)), char(string(run_label)), ...
    info.n_rejected, info.n_before, info.n_kept, ...
    info.n_rejected_extreme_voltage, ...
    info.n_rejected_sample_diff, ...
    info.n_rejected_flatline, ...
    info.n_channels_checked, ...
    strjoin(string(info.functions_called), '+'));
end

function EEG = ensure_erplab_epoch_eventlist_compat_impl(EEG)
% Create the minimal ERPLAB-compatible EVENTLIST / epoch fields required by
% ERPLAB artifact-detection functions. This is especially important for
% artificial regepochs from eeg_regepochs.

if EEG.trials < 1
    return;
end

if ~isfield(EEG, 'epoch') || isempty(EEG.epoch)
    error('ERPLAB epoch rejection requires EEG.epoch. The dataset must be epoched/segmented first.');
end

eventinfo_template = struct( ...
    'item',      [], ...
    'bini',      0, ...
    'nbin',      0, ...
    'binlabel',  '', ...
    'code',      '', ...
    'codelabel', '', ...
    'type',      '', ...
    'latency',   0, ...
    'duration',  [], ...
    'enable',    1, ...
    'flag',      uint16(0), ...
    'urevent',   []);

eventinfo = repmat(eventinfo_template, 0, 1);
item_counter = 0;

for e = 1:EEG.trials

    if isfield(EEG.epoch, 'eventtype')
        event_types = coerce_to_cell_impl(EEG.epoch(e).eventtype);
    else
        event_types = {};
    end

    if isfield(EEG.epoch, 'eventlatency')
        event_lats = coerce_to_cell_impl(EEG.epoch(e).eventlatency);
    else
        event_lats = {};
    end

    if isempty(event_types)
        event_types = {'erplab_epoch_anchor'};
    end

    if isempty(event_lats)
        event_lats = {0};
    end

    n_items = max([numel(event_types), numel(event_lats), 1]);

    type_cells = cell(1, n_items);
    lat_nums   = zeros(1, n_items);
    item_ids   = zeros(1, n_items);
    flags      = zeros(1, n_items, 'uint16');
    bini       = zeros(1, n_items);
    nbin       = zeros(1, n_items);

    for j = 1:n_items
        this_type = event_types{min(j, numel(event_types))};
        this_type = char(string(normalize_trigger_type_impl(this_type)));

        if isempty(this_type)
            this_type = 'erplab_epoch_anchor';
        end

        this_lat = scalarize_latency_ms_impl(event_lats{min(j, numel(event_lats))});
        if ~isfinite(this_lat)
            this_lat = 0;
        end

        item_counter = item_counter + 1;

        eventinfo(item_counter, 1) = eventinfo_template;
        eventinfo(item_counter).item      = item_counter;
        eventinfo(item_counter).bini      = 0;
        eventinfo(item_counter).nbin      = 0;
        eventinfo(item_counter).binlabel  = '';
        eventinfo(item_counter).code      = this_type;
        eventinfo(item_counter).codelabel = '';
        eventinfo(item_counter).type      = this_type;
        eventinfo(item_counter).latency   = this_lat;
        eventinfo(item_counter).duration  = [];
        eventinfo(item_counter).enable    = 1;
        eventinfo(item_counter).flag      = uint16(0);
        eventinfo(item_counter).urevent   = [];

        type_cells{j} = this_type;
        lat_nums(j)   = this_lat;
        item_ids(j)   = item_counter;
    end

    % ERPLAB's markartifacts() looks for the event at latency exactly 0.
    % If no event is exactly 0, use the event closest to 0 as anchor.
    [~, zero_ix] = min(abs(lat_nums));
    lat_nums(zero_ix) = 0;
    eventinfo(item_ids(zero_ix)).latency = 0;

    EEG.epoch(e).eventtype    = type_cells;
    EEG.epoch(e).eventlatency = lat_nums;
    EEG.epoch(e).eventitem    = item_ids;
    EEG.epoch(e).eventflag    = flags;
    EEG.epoch(e).eventbini    = bini;
    EEG.epoch(e).eventnbin    = nbin;
end

EEG.EVENTLIST = struct();
EEG.EVENTLIST.setname = getfield_safe_impl(EEG, 'setname', '');
EEG.EVENTLIST.filename = '';
EEG.EVENTLIST.filepath = '';
EEG.EVENTLIST.trialsperbin = [];
EEG.EVENTLIST.eventinfo = eventinfo;

% Keep bdf present but without RT fields. This prevents ERPLAB from trying
% to synchronize reaction-time artifact flags in datasets without RT info.
EEG.EVENTLIST.bdf = struct();

if ~isfield(EEG, 'reject') || ~isstruct(EEG.reject)
    EEG.reject = struct();
end

if ~isfield(EEG.reject, 'rejmanual') || isempty(EEG.reject.rejmanual)
    EEG.reject.rejmanual = zeros(1, EEG.trials);
end

if ~isfield(EEG.reject, 'rejmanualE') || isempty(EEG.reject.rejmanualE)
    EEG.reject.rejmanualE = zeros(EEG.nbchan, EEG.trials);
end

% Also make EEG.event compatible. Some ERPLAB internals may inspect
% EEG.event directly rather than EEG.EVENTLIST.eventinfo.
if isfield(EEG, 'event') && ~isempty(EEG.event)
    n_events = numel(EEG.event);

    if ~isfield(EEG.event, 'item')
        for k = 1:n_events
            EEG.event(k).item = k;
        end
    end

    if ~isfield(EEG.event, 'flag')
        for k = 1:n_events
            EEG.event(k).flag = uint16(0);
        end
    end

    if ~isfield(EEG.event, 'bini')
        for k = 1:n_events
            EEG.event(k).bini = 0;
        end
    end

    if ~isfield(EEG.event, 'nbin')
        for k = 1:n_events
            EEG.event(k).nbin = 0;
        end
    end
end

% Some ERPLAB code also expects these top-level EVENTLIST fields.
if ~isfield(EEG.EVENTLIST, 'nbin')
    EEG.EVENTLIST.nbin = 0;
end
if ~isfield(EEG.EVENTLIST, 'bininfo')
    EEG.EVENTLIST.bininfo = struct([]);
end
end

function EEG = clear_erplab_artifact_flags_impl(EEG)
if ~isfield(EEG, 'reject') || ~isstruct(EEG.reject)
    EEG.reject = struct();
end

EEG.reject.rejmanual  = zeros(1, EEG.trials);
EEG.reject.rejmanualE = zeros(EEG.nbchan, EEG.trials);

if isfield(EEG, 'epoch') && ~isempty(EEG.epoch)
    for e = 1:min(EEG.trials, numel(EEG.epoch))
        if isfield(EEG.epoch, 'eventflag')
            n_flags = numel(EEG.epoch(e).eventflag);
            if n_flags < 1
                n_flags = 1;
            end
            EEG.epoch(e).eventflag = zeros(1, n_flags, 'uint16');
        end
    end
end

if isfield(EEG, 'EVENTLIST') && isfield(EEG.EVENTLIST, 'eventinfo') && ...
        ~isempty(EEG.EVENTLIST.eventinfo) && isfield(EEG.EVENTLIST.eventinfo, 'flag')
    for i = 1:numel(EEG.EVENTLIST.eventinfo)
        EEG.EVENTLIST.eventinfo(i).flag = uint16(0);
    end
end
EEG = eeg_checkset(EEG);

end

function bad = erplab_rejmanual_mask_impl(EEG)
n_trials = EEG.trials;
bad = false(n_trials, 1);

if ~isfield(EEG, 'reject') || ~isstruct(EEG.reject)
    return;
end

if ~isfield(EEG.reject, 'rejmanual') || isempty(EEG.reject.rejmanual)
    return;
end

tmp = EEG.reject.rejmanual(:) ~= 0;
n = min(numel(tmp), n_trials);
bad(1:n) = tmp(1:n);
end

function flag = validate_erplab_flag_impl(flag_raw, field_name)
flag = double(flag_raw);

if isempty(flag) || ~isscalar(flag) || ~isfinite(flag) || flag ~= round(flag)
    error('ERPLAB artifact flag %s must be a finite integer from 1 to 8. Got: %s', ...
        field_name, mat2str(flag_raw));
end

flag = round(flag);

if flag < 1 || flag > 8
    error(['ERPLAB artifact flag %s must be between 1 and 8. Got %d. ' ...
        'Use e.g. 1=extreme voltage, 2=sample diff, 3=flatline.'], ...
        field_name, flag);
end
end

function twindow_ms = resolve_erplab_twindow_impl(EEG, reject_cfg)
twindow_ms = [];

if isfield(reject_cfg, 'twindow_ms')
    twindow_ms = reject_cfg.twindow_ms;
end

if isempty(twindow_ms)
    twindow_ms = [double(EEG.xmin) double(EEG.xmax)] * 1000;
else
    twindow_ms = double(twindow_ms);
end

if numel(twindow_ms) ~= 2 || any(~isfinite(twindow_ms))
    error('ERPLAB epoch rejection twindow_ms must be [] or [start end] in ms.');
end

twindow_ms = sort(twindow_ms(:)');

epoch_ms = [double(EEG.xmin) double(EEG.xmax)] * 1000;

if twindow_ms(1) < epoch_ms(1) - 2 || twindow_ms(2) > epoch_ms(2) + 2
    error(['ERPLAB epoch rejection twindow_ms=[%.3f %.3f] is outside epoch limits ' ...
        '[%.3f %.3f] ms.'], ...
        twindow_ms(1), twindow_ms(2), epoch_ms(1), epoch_ms(2));
end

% Clamp tiny floating-point differences at the epoch borders.
twindow_ms(1) = max(twindow_ms(1), epoch_ms(1));
twindow_ms(2) = min(twindow_ms(2), epoch_ms(2));

if twindow_ms(2) <= twindow_ms(1)
    error('ERPLAB epoch rejection twindow_ms has zero/negative width: [%.3f %.3f].', ...
        twindow_ms(1), twindow_ms(2));
end
end

function r = compute_data_rank_svd_impl(X)
% Robust numerical rank via SVD with explicit tolerance.
% X is expected to be [channels x samples].

if nargin < 1 || isempty(X)
    r = 0;
    return;
end

X = double(X);

if any(~isfinite(X(:)))
    % Conservative fallback if the data contain invalid values.
    r = size(X, 1);
    return;
end

% Center per channel to reduce mean-offset effects.
X = X - mean(X, 2);

s = svd(X, 'econ');

if isempty(s)
    r = 0;
    return;
end

tol = max(size(X)) * eps(max(s));
r = sum(s > tol);

% Safety clamp
r = min(r, size(X, 1));
end

function outdir = make_unique_amica_tmpdir_impl(step_cfg, subj_label, run_base)
% Create and return a unique AMICA temp directory for one subject/run.

if isfield(step_cfg, 'amica_tmp_root') && strlength(string(step_cfg.amica_tmp_root)) > 0
    rootdir = char(string(step_cfg.amica_tmp_root));
else
    rootdir = tempdir;
end

ensure_dir_impl(rootdir);

subj_label = sanitize_filename_impl(subj_label);
run_base   = sanitize_filename_impl(run_base);

tmp_stub = tempname(rootdir);
[~, tmp_base] = fileparts(tmp_stub);

folder_name = sprintf('amica_tmp_%s_%s_%s', subj_label, run_base, tmp_base);
outdir = fullfile(rootdir, folder_name);

if exist(outdir, 'dir') ~= 7
    mkdir(outdir);
end
end

function safe_rmdir_impl(folder_path)
folder_path = char(string(folder_path));

if isempty(folder_path)
    return;
end

if exist(folder_path, 'dir') == 7
    try
        rmdir(folder_path, 's');
    catch
        % Do not crash pipeline on tmp cleanup failure.
    end
end
end

function s = sanitize_filename_impl(s)
s = char(string(s));
s = strtrim(s);

if isempty(s)
    s = 'x';
    return;
end

s = regexprep(s, '[^\w\-]', '_');
end

function write_ic_topography_pngs_impl(EEG, ic_list, out_dir, file_prefix, tag, topo_cfg, classif)
if isempty(ic_list)
    return;
end

ensure_dir_impl(out_dir);

if isfield(EEG, 'icachansind') && ~isempty(EEG.icachansind)
    chanlocs_ica = EEG.chanlocs(EEG.icachansind);
else
    chanlocs_ica = EEG.chanlocs(1:size(EEG.icawinv, 1));
end

for ii = 1:numel(ic_list)
    ic = ic_list(ii);

    fig = figure('Visible', 'off', 'Color', 'w');
    ax = axes(fig); %#ok<LAXES>
    axis(ax, 'off');

    try
        topoplot(EEG.icawinv(:, ic), chanlocs_ica, ...
            'electrodes', topo_cfg.ic_topo_electrodes);

        if nargin >= 7 && ~isempty(classif) && size(classif, 2) >= 7
            ttl = sprintf([ ...
                '%s | IC %d (B %.2f M %.2f E %.2f H %.2f L %.2f C %.2f O %.2f) -> %s'], ...
                file_prefix, ic, ...
                classif(ic, 1), classif(ic, 2), classif(ic, 3), ...
                classif(ic, 4), classif(ic, 5), classif(ic, 6), ...
                classif(ic, 7), upper(tag));
        else
            ttl = sprintf('%s | IC %d -> %s', file_prefix, ic, upper(tag));
        end

        title(ttl, 'Interpreter', 'none', 'FontSize', 13);

    catch me_plot
        clf(fig);
        axis off;
        text(0, 0.5, sprintf('%s | IC %d\nCould not plot:\n%s', ...
            file_prefix, ic, me_plot.message), ...
            'Interpreter', 'none');
    end

    png_name = sprintf('%s_IC%03d_%s.png', file_prefix, ic, tag);
    png_path = fullfile(out_dir, png_name);

    set(fig, ...
        'PaperUnits', 'centimeters', ...
        'PaperPosition', topo_cfg.ic_topo_fig_cm);

    print(fig, png_path, '-dpng', sprintf('-r%d', topo_cfg.ic_topo_dpi));
    close(fig);
end
end

function target_events = normalize_event_list_impl(event_list)
target_events = strings(0,1);

if isempty(event_list)
    return;
end

if ischar(event_list) || isstring(event_list)
    event_list = cellstr(string(event_list));
end

for i = 1:numel(event_list)
    tok = string(normalize_trigger_type_impl(event_list{i}));
    if strlength(tok) > 0
        target_events(end+1,1) = tok; %#ok<AGROW>
    end
end

target_events = unique(target_events, 'stable');
end

function present_events = get_present_events_impl(EEG, target_events)
present_events = strings(0,1);

if ~isfield(EEG, 'event') || isempty(EEG.event)
    return;
end

all_types = strings(0,1);
for k = 1:numel(EEG.event)
    tok = string(normalize_trigger_type_impl(EEG.event(k).type));
    if tok == "boundary" || strlength(tok) == 0
        continue;
    end
    all_types(end+1,1) = tok; %#ok<AGROW>
end

all_types = unique(all_types, 'stable');
present_events = intersect(target_events, all_types, 'stable');
end

function preview = preview_event_types_impl(EEG, n_max)
preview = strings(0,1);

if nargin < 2 || isempty(n_max)
    n_max = 25;
end

if ~isfield(EEG, 'event') || isempty(EEG.event)
    return;
end

all_types = strings(0,1);
for k = 1:numel(EEG.event)
    tok = string(normalize_trigger_type_impl(EEG.event(k).type));
    if tok == "boundary" || strlength(tok) == 0
        continue;
    end
    all_types(end+1,1) = tok; %#ok<AGROW>
end

all_types = unique(all_types, 'stable');
preview = all_types(1:min(n_max, numel(all_types)));
end

function [ok, info] = evaluate_min_trials_per_condition_impl(EEG, condition_spec, min_trials_required, zero_tol_ms)
info = struct();
info.ok                    = true;
info.min_required          = NaN;
info.zero_tol_ms           = NaN;
info.condition_codes       = strings(0,1);
info.raw_condition_codes   = strings(0,1);
info.counts                = zeros(0,1);
info.counts_joined         = "";
info.insufficient_codes    = strings(0,1);
info.insufficient_joined   = "";

if nargin < 3 || isempty(min_trials_required) || ~isscalar(min_trials_required) || ...
        ~isfinite(min_trials_required) || min_trials_required < 0
    min_trials_required = 0;
end
min_trials_required = round(double(min_trials_required));
info.min_required   = min_trials_required;

if nargin < 4 || isempty(zero_tol_ms) || ~isscalar(zero_tol_ms) || ...
        ~isfinite(zero_tol_ms) || zero_tol_ms < 0
    zero_tol_ms = 2;
end
info.zero_tol_ms = double(zero_tol_ms);

[group_names, group_members, flat_raw_codes] = parse_condition_group_spec_impl(condition_spec);

info.condition_codes     = group_names;
info.raw_condition_codes = flat_raw_codes;
info.counts              = zeros(numel(group_names), 1);

if isempty(group_names)
    ok = true;
    info.ok = ok;
    return;
end

if ~isfield(EEG, 'epoch') || isempty(EEG.epoch) || EEG.trials < 1
    info.counts = zeros(numel(group_names), 1);
    info.counts_joined = format_condition_count_map_impl(group_names, info.counts);
    info.insufficient_codes = group_names;
    info.insufficient_joined = strjoin(cellstr(info.insufficient_codes), ', ');
    ok = false;
    info.ok = ok;
    return;
end

n_epoch = min(double(EEG.trials), numel(EEG.epoch));

for e = 1:n_epoch
    matched_raw_code = extract_epoch_time_locking_condition_code_impl( ...
        EEG.epoch(e), flat_raw_codes, info.zero_tol_ms);

    if strlength(matched_raw_code) == 0
        continue;
    end

    for g = 1:numel(group_names)
        if any(group_members{g} == matched_raw_code)
            info.counts(g) = info.counts(g) + 1;
            break;
        end
    end
end

info.counts_joined = format_condition_count_map_impl(group_names, info.counts);
info.insufficient_codes = group_names(info.counts < min_trials_required);

if isempty(info.insufficient_codes)
    info.insufficient_joined = "";
    ok = true;
else
    info.insufficient_joined = strjoin(cellstr(info.insufficient_codes), ', ');
    ok = false;
end

info.ok = ok;
end


function [group_names, group_members, flat_raw_codes] = parse_condition_group_spec_impl(condition_spec)
group_names   = strings(0,1);
group_members = {};
flat_raw_codes = strings(0,1);

if isempty(condition_spec)
    return;
end

if ischar(condition_spec) || isstring(condition_spec)
    condition_spec = cellstr(string(condition_spec));
end

if ~iscell(condition_spec)
    error('min_trials condition spec must be a cell, string, or char array.');
end

% An N-by-2 table is unambiguous for N>1. A single grouped condition is a
% 1-by-2 vector, so recognize it when the second entry contains its code list
% as a nested cell. A plain {'S 1','S 2'} event list remains ungrouped.
is_single_group = isvector(condition_spec) && numel(condition_spec) == 2 && ...
    iscell(condition_spec{1,2});
is_grouped_cell = ismatrix(condition_spec) && size(condition_spec,2) == 2 && ...
    (~isvector(condition_spec) || is_single_group);

if is_grouped_cell
    for r = 1:size(condition_spec, 1)
        this_name = string(strtrim(char(string(condition_spec{r,1}))));
        this_codes = normalize_event_list_impl(condition_spec{r,2});

        if strlength(this_name) == 0
            error('Grouped min-trials condition spec contains an empty group name in row %d.', r);
        end

        if isempty(this_codes)
            error('Grouped min-trials condition spec contains no event codes in row %d.', r);
        end

        group_names(end+1,1) = this_name; %#ok<AGROW>
        group_members{end+1,1} = this_codes(:); %#ok<AGROW>
        flat_raw_codes = [flat_raw_codes; this_codes(:)]; %#ok<AGROW>
    end

    flat_raw_codes = unique(flat_raw_codes, 'stable');

else
    flat_raw_codes = normalize_event_list_impl(condition_spec);
    group_names = flat_raw_codes;
    group_members = cell(numel(flat_raw_codes), 1);

    for i = 1:numel(flat_raw_codes)
        group_members{i} = flat_raw_codes(i);
    end
end
end

function code = extract_epoch_time_locking_condition_code_impl(epoch_info, relevant_codes, zero_tol_ms)
code = "";

if nargin < 3 || isempty(zero_tol_ms) || ~isscalar(zero_tol_ms) || ~isfinite(zero_tol_ms)
    zero_tol_ms = 2;
end

event_types = {};
event_lats  = {};

if isstruct(epoch_info)
    if isfield(epoch_info, 'eventtype')
        event_types = coerce_to_cell_impl(epoch_info.eventtype);
    end
    if isfield(epoch_info, 'eventlatency')
        event_lats = coerce_to_cell_impl(epoch_info.eventlatency);
    end
end

if isempty(event_types)
    return;
end

n_items = max(numel(event_types), max(1, numel(event_lats)));
type_vec = strings(n_items, 1);
lat_vec  = nan(n_items, 1);

for i = 1:n_items
    this_type = event_types{min(i, numel(event_types))};
    type_vec(i) = string(normalize_trigger_type_impl(this_type));

    if ~isempty(event_lats)
        this_lat = event_lats{min(i, numel(event_lats))};
        lat_vec(i) = scalarize_latency_ms_impl(this_lat);
    end
end

relevant_mask = ismember(type_vec, relevant_codes);

if ~any(relevant_mask)
    return;
end

zero_hits = find(relevant_mask & isfinite(lat_vec) & abs(lat_vec) <= zero_tol_ms, 1, 'first');
if ~isempty(zero_hits)
    code = type_vec(zero_hits);
    return;
end

relevant_hits = find(relevant_mask);

if numel(relevant_hits) == 1
    code = type_vec(relevant_hits);
    return;
end

finite_hits = relevant_hits(isfinite(lat_vec(relevant_hits)));
if ~isempty(finite_hits)
    [~, ix] = min(abs(lat_vec(finite_hits)));
    code = type_vec(finite_hits(ix));
    return;
end

code = type_vec(relevant_hits(1));
end

function c = coerce_to_cell_impl(x)
if isempty(x)
    c = {};
elseif iscell(x)
    c = x(:);
elseif isstring(x)
    c = cellstr(x(:));
elseif ischar(x)
    c = {x};
elseif isnumeric(x) || islogical(x)
    c = num2cell(x(:));
else
    c = {x};
end
end

function lat_ms = scalarize_latency_ms_impl(x)
lat_ms = NaN;

if iscell(x) && numel(x) == 1
    x = x{1};
end

if isempty(x)
    return;
end

if isstring(x) || ischar(x)
    lat_ms = str2double(strrep(char(string(x)), ',', '.'));
    return;
end

if isnumeric(x) || islogical(x)
    x = double(x);
    lat_ms = x(1);
    return;
end

try
    x = double(x);
    lat_ms = x(1);
catch
    lat_ms = NaN;
end
end

function joined = format_condition_count_map_impl(condition_codes, counts)
if isempty(condition_codes)
    joined = "";
    return;
end

parts = strings(numel(condition_codes), 1);

for i = 1:numel(condition_codes)
    parts(i) = string(sprintf('%s=%d', char(condition_codes(i)), counts(i)));
end

joined = strjoin(cellstr(parts), ' | ');
end

function row = build_step06_summary_row_impl( ...
    subj_label, run_base, ica_method, step_cfg, ...
    epoching_mode, condition_label, ...
    input_name, rej_info, saved_paths, status_label, ...
    n_eeg, n_eog, n_non_eeg)

if nargin < 9 || isempty(saved_paths)
    saved_paths = {};
end

output_paths_joined = "";
if ~isempty(saved_paths)
    output_paths_joined = strjoin(string(saved_paths), ' | ');
end

prop_rejected_total = NaN;
if isfield(rej_info, 'n_total') && rej_info.n_total > 0
    prop_rejected_total = rej_info.n_rejected_total / rej_info.n_total;
end

shared_enable   = false;
shared_faster_z = NaN;
shared_ptp      = NaN;
shared_robust   = false;

if isfield(step_cfg, 'faster_ptp_epoch_rejection') && isstruct(step_cfg.faster_ptp_epoch_rejection)
    fp_cfg = step_cfg.faster_ptp_epoch_rejection;
    shared_enable = lower(string(getfield_safe_impl(step_cfg, 'epoch_rejection_method', ""))) == "faster_ptp";
    shared_faster_z = getfield_safe_impl(fp_cfg, 'faster_z', NaN);
    shared_ptp = getfield_safe_impl(fp_cfg, 'ptp_uV_thresh', NaN);
    shared_robust = logical(getfield_safe_impl(fp_cfg, 'use_robust_z', false));
end

excluded_by_max_reject_prop = logical(getfield_safe_impl(rej_info, 'excluded_by_max_reject_prop', false));
excluded_by_min_trials_rule = logical(getfield_safe_impl(rej_info, 'excluded_by_min_trials_rule', false));
excluded_any_rule           = logical(getfield_safe_impl(rej_info, 'excluded', false));
exclusion_reason            = string(getfield_safe_impl(rej_info, 'exclusion_reason', ""));

min_trials_rule_enabled = logical(getfield_safe_impl(step_cfg, 'min_trials_per_condition_enable', false));
min_trials_min_n        = getfield_safe_impl(step_cfg, 'min_trials_per_condition_min_n', NaN);
min_trials_counts       = string(getfield_safe_impl(rej_info, 'min_trials_condition_counts', ""));
min_trials_insufficient = string(getfield_safe_impl(rej_info, 'min_trials_insufficient_conditions', ""));

qc_timestamp = string(getfield_safe_impl(step_cfg, 'qc_timestamp', ""));
settings_json = safe_jsonencode_impl(step_cfg);
rejection_method = string(getfield_safe_impl(rej_info, 'rejection_method', ...
    getfield_safe_impl(step_cfg, 'epoch_rejection_method', "")));

n_extreme = double(getfield_safe_impl(rej_info, 'n_rejected_extreme_voltage', 0));
n_sample  = double(getfield_safe_impl(rej_info, 'n_rejected_sample_diff', 0));
n_flat    = double(getfield_safe_impl(rej_info, 'n_rejected_flatline', 0));
n_faster  = double(getfield_safe_impl(rej_info, 'n_rejected_faster', 0));
n_ptp     = double(getfield_safe_impl(rej_info, 'n_rejected_ptp', 0));
n_mad     = double(getfield_safe_impl(rej_info, 'n_rejected_mad_variance', 0));

row = table( ...
    qc_timestamp, ...
    string(subj_label), ...
    string(run_base), ...
    string(ica_method), ...
    string(epoching_mode), ...
    string(condition_label), ...
    string(status_label), ...
    string(input_name), ...
    n_eeg, ...
    n_eog, ...
    n_non_eeg, ...
    rej_info.n_total, ...
    rej_info.n_rejected_hard, ...
    rej_info.n_rejected_sophisticated, ...
    rej_info.n_rejected_total, ...
    rej_info.n_kept, ...
    rejection_method, ...
    n_extreme, ...
    n_sample, ...
    n_flat, ...
    n_faster, ...
    n_ptp, ...
    n_mad, ...
    prop_rejected_total, ...
    excluded_any_rule, ...
    excluded_by_max_reject_prop, ...
    excluded_by_min_trials_rule, ...
    exclusion_reason, ...
    logical(step_cfg.do_artifact_rejection), ...
    logical(step_cfg.do_initial_hard_threshold_rejection), ...
    step_cfg.initial_hard_threshold_uv, ...
    logical(step_cfg.do_baseline_correction), ...
    step_cfg.base_start_ms, ...
    step_cfg.base_end_ms, ...
    step_cfg.max_reject_prop, ...
    getfield_safe_impl(step_cfg, 'warn_if_reject_prop_gt', 0.25), ...
    shared_enable, ...
    shared_faster_z, ...
    shared_ptp, ...
    shared_robust, ...
    min_trials_rule_enabled, ...
    min_trials_min_n, ...
    min_trials_counts, ...
    min_trials_insufficient, ...
    settings_json, ...
    string(output_paths_joined), ...
    'VariableNames', { ...
    'qc_timestamp', 'subject_id', 'run_base', 'ica_method', 'epoching_mode', 'condition', 'status', ...
    'input_set_name', ...
    'n_eeg_channels', 'n_eog_channels', 'n_non_eeg_channels', ...
    'n_epochs_total', 'n_rejected_hard', 'n_rejected_sophisticated', 'n_rejected_total', 'n_epochs_kept', ...
    'rejection_method', 'n_rejected_extreme_voltage', 'n_rejected_sample_diff', ...
    'n_rejected_flatline', 'n_rejected_faster', 'n_rejected_ptp', 'n_rejected_mad_variance', ...
    'prop_rejected_total', ...
    'excluded_any_rule', 'excluded_by_max_reject_prop', 'excluded_by_min_trials_rule', 'exclusion_reason', ...
    'artifact_rejection_enabled', 'hard_threshold_enabled', 'hard_threshold_uv', ...
    'baseline_correction_enabled', 'baseline_start_ms', 'baseline_end_ms', ...
    'max_reject_prop', 'warn_if_reject_prop_gt', ...
    'shared_rejection_enabled', 'shared_faster_z', 'shared_ptp_uV_thresh', 'shared_use_robust_z', ...
    'min_trials_rule_enabled', 'min_trials_min_n', 'min_trials_condition_counts', 'min_trials_insufficient_conditions', ...
    'settings_json', ...
    'output_set_paths'});
end


function rows = build_step06_summary_rows_impl( ...
    subj_label, run_base, ica_method, step_cfg, ...
    epoching_mode, condition_label, ...
    input_name, rej_info, saved_paths, status_label, ...
    n_eeg, n_eog, n_non_eeg)

n_total = double(getfield_safe_impl(rej_info, 'n_total', 0));
condition_labels = string(getfield_safe_impl( ...
    rej_info, 'epoch_condition_labels', repmat(string(condition_label), n_total, 1)));
condition_labels = condition_labels(:);

if numel(condition_labels) ~= n_total
    condition_labels = repmat(string(condition_label), n_total, 1);
end

if string(condition_label) ~= "event_locked"
    condition_labels(:) = string(condition_label);
end

conditions = unique(condition_labels, 'stable');
if isempty(conditions)
    conditions = string(condition_label);
end

reason_names = ["hard_threshold","extreme_voltage","sample_diff","flatline", ...
    "faster","ptp","mad_variance"];
hard_mask = get_reason_mask_impl(rej_info, 'hard_threshold', n_total);
backend_union = false(n_total, 1);
all_union = hard_mask;
for r = 2:numel(reason_names)
    this_mask = get_reason_mask_impl(rej_info, char(reason_names(r)), n_total);
    backend_union = backend_union | this_mask;
    all_union = all_union | this_mask;
end

rows = table();
for c = 1:numel(conditions)
    condition_mask = condition_labels == conditions(c);
    if ~any(condition_mask) && n_total > 0
        continue;
    end

    local_info = rej_info;
    local_info.n_total = sum(condition_mask);
    local_info.n_rejected_hard = sum(condition_mask & hard_mask);
    local_info.n_rejected_sophisticated = sum(condition_mask & backend_union);
    local_info.n_rejected_total = sum(condition_mask & all_union);
    local_info.n_kept = local_info.n_total - local_info.n_rejected_total;
    local_info.n_rejected_extreme_voltage = sum(condition_mask & ...
        get_reason_mask_impl(rej_info, 'extreme_voltage', n_total));
    local_info.n_rejected_sample_diff = sum(condition_mask & ...
        get_reason_mask_impl(rej_info, 'sample_diff', n_total));
    local_info.n_rejected_flatline = sum(condition_mask & ...
        get_reason_mask_impl(rej_info, 'flatline', n_total));
    local_info.n_rejected_faster = sum(condition_mask & ...
        get_reason_mask_impl(rej_info, 'faster', n_total));
    local_info.n_rejected_ptp = sum(condition_mask & ...
        get_reason_mask_impl(rej_info, 'ptp', n_total));
    local_info.n_rejected_mad_variance = sum(condition_mask & ...
        get_reason_mask_impl(rej_info, 'mad_variance', n_total));

    count_label = conditions(c);
    if strlength(count_label) == 0
        count_label = "all";
    end
    local_info.min_trials_condition_counts = sprintf( ...
        '%s=%d', char(count_label), local_info.n_kept);

    local_status = string(status_label);
    if local_info.n_kept == 0 && local_status == "saved"
        local_status = "empty_after_rejection";
    end

    this_row = build_step06_summary_row_impl( ...
        subj_label, run_base, ica_method, step_cfg, ...
        epoching_mode, conditions(c), input_name, local_info, ...
        saved_paths, local_status, n_eeg, n_eog, n_non_eeg);

    if isempty(rows)
        rows = this_row;
    else
        rows = [rows; this_row]; %#ok<AGROW>
    end
end
end


function timestamp = resolve_qc_timestamp_impl(cfg)
% One timestamp is resolved when the config is created and is reused by all
% subjects in that pipeline run. This makes before/after runs easy to group.
timestamp = "";

if nargin >= 1 && isstruct(cfg) && isfield(cfg, 'qc') && isstruct(cfg.qc) && ...
        isfield(cfg.qc, 'run_timestamp') && strlength(string(cfg.qc.run_timestamp)) > 0
    timestamp = string(cfg.qc.run_timestamp);
end

if strlength(timestamp) == 0
    timestamp = string(datestr(now, 'yyyy-mm-dd-HH-MM'));
end

timestamp = regexprep(timestamp(1), '[^0-9\-]', '-');
end


function out_path = write_qc_table_impl(t, out_path, delimiter)
% Write through a temporary file so concurrent subject workers never leave
% a partially written group summary behind.
if nargin < 3 || strlength(string(delimiter)) == 0
    delimiter = ';';
end

out_path = char(string(out_path));
out_dir = fileparts(out_path);
ensure_dir_impl(out_dir);

tmp_path = [tempname(out_dir) '.csv'];
cleanup_obj = onCleanup(@() delete_if_exists_impl(tmp_path)); %#ok<NASGU>

writetable(t, tmp_path, 'Delimiter', char(string(delimiter)));
[ok, msg] = movefile(tmp_path, out_path, 'f');
if ~ok
    error('Could not finalize QC table %s: %s', out_path, msg);
end
end


function delete_if_exists_impl(path_value)
if exist(path_value, 'file') == 2
    try
        delete(path_value);
    catch
    end
end
end


function json_text = safe_jsonencode_impl(value)
try
    json_text = string(jsonencode(value));
catch
    json_text = "";
end
end


function t = build_bad_channel_qc_table_impl( ...
    EEG, subj_label, run_base, bad_idx, step_cfg, flat_info, ...
    backend_reason_indices, cfg, backend_status)

if nargin < 7 || ~isstruct(backend_reason_indices)
    backend_reason_indices = struct();
end
if nargin < 8
    cfg = struct();
end
if nargin < 9 || strlength(string(backend_status)) == 0
    backend_status = "ok";
end

timestamp = resolve_qc_timestamp_impl(cfg);
settings_json = safe_jsonencode_impl(step_cfg);
backend = lower(string(getfield_safe_impl(step_cfg, 'bad_channel_detection_method', "off")));
bad_idx = unique(double(bad_idx(:)'), 'stable');
bad_idx = bad_idx(bad_idx >= 1 & bad_idx <= EEG.nbchan);
bad_labels = string({EEG.chanlocs(bad_idx).labels});

row_idx = zeros(0,1);
row_label = strings(0,1);
row_reason = strings(0,1);

% Flatness and invalid values are stored by label because AUX removal can
% shift numeric indices between flat detection and the final bad list.
if isstruct(flat_info) && isfield(flat_info, 'candidate_labels')
    candidate_labels = string(flat_info.candidate_labels(:));
    is_flat = logical(getfield_safe_impl(flat_info, 'is_flat', false(size(candidate_labels))));
    is_flat = is_flat(:);
    has_invalid = logical(getfield_safe_impl(flat_info, 'has_invalid', false(size(candidate_labels))));
    has_invalid = has_invalid(:);
    flat_mode = string(getfield_safe_impl(flat_info, 'mode', "cumulative_fraction"));

    for i = 1:numel(candidate_labels)
        current_idx = find(strcmpi({EEG.chanlocs.labels}, char(candidate_labels(i))), 1, 'first');
        if isempty(current_idx) || ~ismember(current_idx, bad_idx)
            continue;
        end

        if i <= numel(is_flat) && is_flat(i)
            if flat_mode == "continuous_seconds"
                this_reason = "flat_continuous_seconds";
            else
                this_reason = "flat_cumulative_fraction";
            end
            row_idx(end+1,1) = current_idx; %#ok<AGROW>
            row_label(end+1,1) = string(EEG.chanlocs(current_idx).labels); %#ok<AGROW>
            row_reason(end+1,1) = this_reason; %#ok<AGROW>
        end

        if i <= numel(has_invalid) && has_invalid(i)
            row_idx(end+1,1) = current_idx; %#ok<AGROW>
            row_label(end+1,1) = string(EEG.chanlocs(current_idx).labels); %#ok<AGROW>
            row_reason(end+1,1) = "invalid_nonfinite"; %#ok<AGROW>
        end
    end
end

backend_fields = fieldnames(backend_reason_indices);
for f = 1:numel(backend_fields)
    reason_name = string(backend_fields{f});
    reason_idx_raw = backend_reason_indices.(backend_fields{f});
    reason_idx = unique(double(reason_idx_raw(:)), 'stable');
    reason_idx = reason_idx(reason_idx >= 1 & reason_idx <= EEG.nbchan);
    reason_idx = intersect(reason_idx, bad_idx, 'stable');

    for i = 1:numel(reason_idx)
        row_idx(end+1,1) = reason_idx(i); %#ok<AGROW>
        row_label(end+1,1) = string(EEG.chanlocs(reason_idx(i)).labels); %#ok<AGROW>
        row_reason(end+1,1) = reason_name; %#ok<AGROW>
    end
end

if ~isempty(row_idx)
    pair_key = strcat(lower(row_label), "__", row_reason);
    [~, keep] = unique(pair_key, 'stable');
    row_idx = row_idx(keep);
    row_label = row_label(keep);
    row_reason = row_reason(keep);
end

% Preserve every rejected channel even if a backend failed to provide a
% more specific reason code.
represented = unique(lower(row_label));
for i = 1:numel(bad_idx)
    if ~ismember(lower(bad_labels(i)), represented)
        row_idx(end+1,1) = bad_idx(i); %#ok<AGROW>
        row_label(end+1,1) = bad_labels(i); %#ok<AGROW>
        row_reason(end+1,1) = "backend_unspecified"; %#ok<AGROW>
    end
end

if isempty(row_idx)
    row_idx = NaN;
    row_label = "";
    row_reason = "none";
end

n_rows = numel(row_reason);
n_reason = zeros(n_rows,1);
for i = 1:n_rows
    if row_reason(i) == "none"
        n_reason(i) = 0;
    else
        n_reason(i) = numel(unique(lower(row_label(row_reason == row_reason(i)))));
    end
end

flat_mode = string(getfield_safe_impl(flat_info, 'mode', ""));
flat_duration = double(getfield_safe_impl(flat_info, 'recording_duration_sec', NaN));
flat_tolerance = double(getfield_safe_impl(flat_info, 'step_tolerance_uV', NaN));
flat_threshold = double(getfield_safe_impl(flat_info, 'criterion_threshold', NaN));
clean_corr = double(getfield_safe_impl(step_cfg, 'clean_rawdata_channel_corr_threshold', NaN));
pop_z = double(getfield_safe_impl(step_cfg, 'pop_rejchan_z_threshold', NaN));
pop_freq = string(mat2str(getfield_safe_impl(step_cfg, 'pop_rejchan_freqrange_hz', [])));
[qc_eeg_idx, ~, ~] = get_channel_indices_by_type_impl(EEG);

t = table( ...
    repmat(timestamp, n_rows, 1), ...
    repmat("prep_03_until_ica", n_rows, 1), ...
    repmat(string(subj_label), n_rows, 1), ...
    repmat(string(run_base), n_rows, 1), ...
    row_label, row_idx, row_reason, ...
    repmat("channel_can_have_multiple_reasons", n_rows, 1), n_reason, ...
    repmat(numel(bad_idx), n_rows, 1), ...
    repmat(numel(qc_eeg_idx), n_rows, 1), ...
    repmat(backend, n_rows, 1), ...
    repmat(string(backend_status), n_rows, 1), ...
    repmat(logical(getfield_safe_impl(step_cfg, 'interpolate_bad_channels_before_ica', false)), n_rows, 1), ...
    repmat(string(getfield_safe_impl(step_cfg, 'interp_method', "")), n_rows, 1), ...
    repmat(flat_mode, n_rows, 1), ...
    repmat(flat_duration, n_rows, 1), ...
    repmat(flat_tolerance, n_rows, 1), ...
    repmat(flat_threshold, n_rows, 1), ...
    repmat(clean_corr, n_rows, 1), ...
    repmat(pop_z, n_rows, 1), ...
    repmat(pop_freq, n_rows, 1), ...
    repmat(settings_json, n_rows, 1), ...
    'VariableNames', { ...
    'qc_timestamp','pipeline_step','subject_id','run_base','channel_label','channel_index', ...
    'rejection_reason','reason_counting_rule','n_channels_rejected_for_reason','n_bad_channels_unique','n_eeg_channels_checked', ...
    'backend','backend_status','interpolated_before_ica','interpolation_method', ...
    'flat_mode','post_crop_recording_duration_sec','flat_step_tolerance_uV','flat_criterion_threshold', ...
    'clean_rawdata_corr_threshold','pop_rejchan_z_threshold','pop_rejchan_freqrange_hz','settings_json'});
end


function labels = derive_epoch_condition_labels_impl(EEG, step_cfg)
n_epochs = double(getfield_safe_impl(EEG, 'trials', 0));
labels = repmat("", n_epochs, 1);

mode = string(getfield_safe_impl(step_cfg, 'epoching_mode', "event_locked"));
mode = string(normalize_epoching_mode_value_impl(mode));
if mode == "baseline"
    if isfield(EEG, 'etc') && isstruct(EEG.etc) && ...
            isfield(EEG.etc, 'baseline_condition') && ...
            strlength(string(EEG.etc.baseline_condition)) > 0
        labels(:) = string(EEG.etc.baseline_condition);
    end
    return;
end

if mode ~= "event_locked" || n_epochs < 1 || ~isfield(EEG, 'epoch') || isempty(EEG.epoch)
    return;
end

condition_spec = getfield_safe_impl(step_cfg, 'min_trials_per_condition_codes', {});
if isempty(condition_spec)
    condition_spec = getfield_safe_impl(step_cfg, 'events_phase', {});
end

[group_names, group_members, raw_codes] = parse_condition_group_spec_impl(condition_spec);
if isempty(raw_codes)
    labels(:) = "event_locked";
    return;
end

labels(:) = "unclassified";
n = min(n_epochs, numel(EEG.epoch));
zero_tol = double(getfield_safe_impl(step_cfg, 'min_trials_per_condition_zero_tol_ms', 2));

for e = 1:n
    raw_code = extract_epoch_time_locking_condition_code_impl(EEG.epoch(e), raw_codes, zero_tol);
    if strlength(raw_code) == 0
        continue;
    end
    for g = 1:numel(group_names)
        if any(group_members{g} == raw_code)
            labels(e) = group_names(g);
            break;
        end
    end
end
end


function [rej_info, remaining_original] = record_backend_reason_masks_impl( ...
    rej_info, remaining_original, backend, backend_info, backend_cfg)

n_total = double(rej_info.n_total);
backend = string(backend);

switch backend
    case "erplab"
        reason_names = ["extreme_voltage","sample_diff","flatline"];
        index_fields = ["rejected_epochs_extreme_voltage","rejected_epochs_sample_diff","rejected_epochs_flatline"];
        enabled_values = [ ...
            logical(getfield_safe_impl(backend_cfg, 'use_extreme_voltage', false)), ...
            logical(getfield_safe_impl(backend_cfg, 'use_sample_diff', false)), ...
            logical(getfield_safe_impl(backend_cfg, 'use_flatline', false))];
    case "faster_ptp"
        reason_names = ["faster","ptp"];
        index_fields = ["rejected_epochs_faster","rejected_epochs_ptp"];
        enabled_values = [ ...
            logical(getfield_safe_impl(backend_cfg, 'use_faster', false)), ...
            logical(getfield_safe_impl(backend_cfg, 'use_ptp', false))];
    case "mad_variance"
        reason_names = "mad_variance";
        index_fields = "rejected_epochs";
        enabled_values = true;
    otherwise
        reason_names = strings(0,1);
        index_fields = strings(0,1);
        enabled_values = false(0,1);
end

for r = 1:numel(reason_names)
    mask = false(n_total, 1);
    current_idx = double(getfield_safe_impl(backend_info, char(index_fields(r)), []));
    current_idx = current_idx(:)';
    current_idx = current_idx(current_idx >= 1 & current_idx <= numel(remaining_original));
    original_idx = remaining_original(current_idx);
    mask(original_idx) = true;
    rej_info.reason_masks.(char(reason_names(r))) = mask;
    rej_info.reason_enabled.(char(reason_names(r))) = logical(enabled_values(r));
end

union_current = double(getfield_safe_impl(backend_info, 'rejected_epochs', []));
union_current = union_current(:)';
union_current = union_current(union_current >= 1 & union_current <= numel(remaining_original));
remaining_original(union_current) = [];

rej_info.n_rejected_extreme_voltage = sum(get_reason_mask_impl(rej_info, 'extreme_voltage', n_total));
rej_info.n_rejected_sample_diff = sum(get_reason_mask_impl(rej_info, 'sample_diff', n_total));
rej_info.n_rejected_flatline = sum(get_reason_mask_impl(rej_info, 'flatline', n_total));
rej_info.n_rejected_faster = sum(get_reason_mask_impl(rej_info, 'faster', n_total));
rej_info.n_rejected_ptp = sum(get_reason_mask_impl(rej_info, 'ptp', n_total));
rej_info.n_rejected_mad_variance = sum(get_reason_mask_impl(rej_info, 'mad_variance', n_total));
end


function mask = get_reason_mask_impl(rej_info, reason_name, n_total)
mask = false(n_total, 1);
if isfield(rej_info, 'reason_masks') && isstruct(rej_info.reason_masks) && ...
        isfield(rej_info.reason_masks, reason_name)
    candidate_raw = rej_info.reason_masks.(reason_name);
    candidate = logical(candidate_raw(:));
    n = min(numel(candidate), n_total);
    mask(1:n) = candidate(1:n);
end
end


function t = build_epoch_rejection_qc_table_impl( ...
    rej_info, step_cfg, cfg, subj_label, run_base, epoching_mode, condition_label, pipeline_step)

if nargin < 8 || strlength(string(pipeline_step)) == 0
    pipeline_step = "prep_06_epoching";
end
if nargin < 7
    condition_label = "event_locked";
end

n_total = double(getfield_safe_impl(rej_info, 'n_total', 0));
condition_labels = string(getfield_safe_impl(rej_info, 'epoch_condition_labels', repmat(string(condition_label), n_total, 1)));
condition_labels = condition_labels(:);
if numel(condition_labels) ~= n_total
    condition_labels = repmat(string(condition_label), n_total, 1);
end
if string(condition_label) ~= "event_locked"
    condition_labels(:) = string(condition_label);
end

method = lower(string(getfield_safe_impl(rej_info, 'rejection_method', ...
    getfield_safe_impl(step_cfg, 'epoch_rejection_method', "none"))));
artifact_rejection_enabled = logical(getfield_safe_impl(step_cfg, 'do_artifact_rejection', false));
reason_names = "hard_threshold";
reason_enabled = artifact_rejection_enabled && ...
    logical(getfield_safe_impl(step_cfg, 'do_initial_hard_threshold_rejection', false));

switch method
    case "erplab"
        erp = getfield_safe_impl(step_cfg, 'erplab_epoch_rejection', struct());
        reason_names = [reason_names, "extreme_voltage", "sample_diff", "flatline"];
        reason_enabled = [reason_enabled, ...
            logical(getfield_safe_impl(erp, 'use_extreme_voltage', false)), ...
            logical(getfield_safe_impl(erp, 'use_sample_diff', false)), ...
            logical(getfield_safe_impl(erp, 'use_flatline', false))];
    case "faster_ptp"
        fp = getfield_safe_impl(step_cfg, 'faster_ptp_epoch_rejection', struct());
        reason_names = [reason_names, "faster", "ptp"];
        reason_enabled = [reason_enabled, ...
            logical(getfield_safe_impl(fp, 'use_faster', false)), ...
            logical(getfield_safe_impl(fp, 'use_ptp', false))];
    case "mad_variance"
        reason_names = [reason_names, "mad_variance"];
        reason_enabled = [reason_enabled, true];
end
reason_enabled = logical(reason_enabled) & artifact_rejection_enabled;

all_masks = false(n_total, numel(reason_names));
for r = 1:numel(reason_names)
    all_masks(:,r) = get_reason_mask_impl(rej_info, char(reason_names(r)), n_total);
end
union_mask = any(all_masks, 2);

conditions = unique(condition_labels, 'stable');
if isempty(conditions)
    conditions = string(condition_label);
end

timestamp = resolve_qc_timestamp_impl(cfg);
ica_method = "unknown";
if isstruct(cfg) && isfield(cfg, 'prep_04')
    ica_method = string(getfield_safe_impl(cfg.prep_04, 'ica_method', "unknown"));
end
settings_json = safe_jsonencode_impl(step_cfg);
excluded = logical(getfield_safe_impl(rej_info, 'excluded', false));
exclusion_reason = string(getfield_safe_impl(rej_info, 'exclusion_reason', ""));
reason_counting_rule = "exclusive_first_match_then_union";

t = table();
for c = 1:numel(conditions)
    condition_mask = condition_labels == conditions(c);
    n_before = sum(condition_mask);
    n_any = sum(condition_mask & union_mask);
    n_kept = n_before - n_any;

    names_with_union = [reason_names, "any_reason"];
    enabled_with_union = [reason_enabled, any(reason_enabled)];

    for r = 1:numel(names_with_union)
        if names_with_union(r) == "any_reason"
            n_reason = n_any;
        else
            n_reason = sum(condition_mask & all_masks(:,r));
        end

        criterion_setting = describe_epoch_rejection_setting_impl( ...
            names_with_union(r), step_cfg);

        row = table( ...
            timestamp, string(pipeline_step), string(subj_label), string(run_base), ...
            ica_method, string(epoching_mode), conditions(c), method, ...
            names_with_union(r), logical(enabled_with_union(r)), criterion_setting, ...
            reason_counting_rule, n_before, n_reason, n_any, n_kept, ...
            excluded, exclusion_reason, settings_json, ...
            'VariableNames', { ...
            'qc_timestamp','pipeline_step','subject_id','run_base','ica_method','epoching_mode', ...
            'condition','rejection_method','rejection_reason','criterion_enabled','criterion_setting','reason_counting_rule', ...
            'n_epochs_before','n_rejected_for_reason','n_rejected_any_reason','n_epochs_kept', ...
            'dataset_excluded','exclusion_reason','settings_json'});

        if isempty(t)
            t = row;
        else
            t = [t; row]; %#ok<AGROW>
        end
    end
end
end


function description = describe_epoch_rejection_setting_impl(reason_name, step_cfg)
reason_name = string(reason_name);
description = "";

switch reason_name
    case "hard_threshold"
        description = "abs_uv=" + string(getfield_safe_impl(step_cfg, 'initial_hard_threshold_uv', NaN));
    case {"extreme_voltage","sample_diff","flatline"}
        erp = getfield_safe_impl(step_cfg, 'erplab_epoch_rejection', struct());
        switch reason_name
            case "extreme_voltage"
                description = "abs_uv=" + string(getfield_safe_impl(erp, 'extreme_voltage_uV', NaN));
            case "sample_diff"
                description = "sample_diff_uv=" + string(getfield_safe_impl(erp, 'sample_diff_uV', NaN));
            case "flatline"
                description = "tolerance_uv=" + string(getfield_safe_impl(erp, 'flatline_tolerance_uV', NaN)) + ...
                    ";duration_ms=" + string(getfield_safe_impl(erp, 'flatline_duration_ms', NaN));
        end
    case {"faster","ptp"}
        fp = getfield_safe_impl(step_cfg, 'faster_ptp_epoch_rejection', struct());
        if reason_name == "faster"
            description = "z=" + string(getfield_safe_impl(fp, 'faster_z', NaN)) + ...
                ";robust_z=" + string(getfield_safe_impl(fp, 'use_robust_z', false));
        else
            description = "ptp_uv=" + string(getfield_safe_impl(fp, 'ptp_uV_thresh', NaN));
        end
    case "mad_variance"
        description = "z=" + string(getfield_safe_impl(step_cfg, 'mad_z_threshold', NaN)) + ...
            ";logvar=" + string(getfield_safe_impl(step_cfg, 'mad_use_logvar', true));
    case "any_reason"
        description = "union_of_enabled_criteria";
end
end


function [t_all, t_by_reason, output_paths] = collect_bad_channel_qc_impl(cfg_or_qc_root)
[qc_root, timestamp, delimiter] = resolve_qc_collection_context_impl(cfg_or_qc_root);
bad_root = fullfile(qc_root, '03_bad_chans');
t_all = table();
t_by_reason = table();
output_paths = {};

if exist(bad_root, 'dir') ~= 7
    return;
end

files = dir(fullfile(bad_root, '**', '*_bad_chans.csv'));
files = files(~contains({files.name}, '_all_subjects') & ~contains({files.name}, '_by_reason'));
t_all = read_latest_qc_tables_impl(files, {'subject_id','run_base'}, delimiter);
if isempty(t_all)
    return;
end

sort_vars = intersect({'subject_id','run_base','channel_label','rejection_reason'}, ...
    t_all.Properties.VariableNames, 'stable');
if ~isempty(sort_vars)
    t_all = sortrows(t_all, sort_vars);
end

t_all.channel_rejection_row = double(strlength(string(t_all.channel_label)) > 0 & ...
    string(t_all.rejection_reason) ~= "none");

group_vars = intersect({'backend','rejection_reason','settings_json'}, ...
    t_all.Properties.VariableNames, 'stable');
t_by_reason = groupsummary(t_all, group_vars, {'sum','mean'}, ...
    {'channel_rejection_row','n_bad_channels_unique'});

all_path = fullfile(bad_root, sprintf('%s_bad_channels_all_subjects.csv', char(timestamp)));
reason_path = fullfile(bad_root, sprintf('%s_bad_channels_by_reason.csv', char(timestamp)));
write_qc_table_impl(t_all, all_path, delimiter);
write_qc_table_impl(t_by_reason, reason_path, delimiter);
output_paths = {all_path, reason_path};
end


function [t_all, t_by_method, t_pair, t_reasons, output_paths] = collect_prep06_summary_impl(cfg_or_qc_root)
[qc_root, timestamp, delimiter] = resolve_qc_collection_context_impl(cfg_or_qc_root);
epoch_root = fullfile(qc_root, '06_epoch_rej');
t_all = table();
t_by_method = table();
t_pair = table();
t_reasons = table();
output_paths = {};

if exist(epoch_root, 'dir') ~= 7
    return;
end

summary_files = dir(fullfile(epoch_root, '**', '*_prep06_summary.csv'));
summary_files = summary_files(~contains({summary_files.name}, '_all_subjects') & ...
    ~contains({summary_files.name}, '_by_method'));
t_all = read_latest_qc_tables_impl(summary_files, {'subject_id','ica_method'}, delimiter);

if ~isempty(t_all)
    t_all = normalize_prep06_summary_table_impl(t_all);
    sort_vars = intersect({'ica_method','subject_id','run_base','epoching_mode','condition'}, ...
        t_all.Properties.VariableNames, 'stable');
    if ~isempty(sort_vars)
        t_all = sortrows(t_all, sort_vars);
    end

    t_all.saved_numeric = double(string(t_all.status) == "saved");
    t_all.excluded_numeric = double(logical(t_all.excluded_any_rule));
    t_all.empty_numeric = double(string(t_all.status) == "empty_after_rejection");

    numeric_vars = intersect({ ...
        'n_eeg_channels','n_eog_channels','n_non_eeg_channels','n_epochs_total', ...
        'n_rejected_hard','n_rejected_sophisticated','n_rejected_total','n_epochs_kept', ...
        'n_rejected_extreme_voltage','n_rejected_sample_diff','n_rejected_flatline', ...
        'n_rejected_faster','n_rejected_ptp','n_rejected_mad_variance', ...
        'prop_rejected_total','saved_numeric','excluded_numeric','empty_numeric'}, ...
        t_all.Properties.VariableNames, 'stable');
    group_vars = intersect({'ica_method','epoching_mode','condition','rejection_method','settings_json'}, ...
        t_all.Properties.VariableNames, 'stable');
    t_by_method = groupsummary(t_all, group_vars, {'mean','std','median'}, numeric_vars);
    t_pair = build_paired_ica_summary_impl(t_all);

    all_path = fullfile(epoch_root, sprintf('%s_prep06_epoching_summary_all_subjects.csv', char(timestamp)));
    method_path = fullfile(epoch_root, sprintf('%s_prep06_epoching_summary_by_method_condition.csv', char(timestamp)));
    write_qc_table_impl(t_all, all_path, delimiter);
    write_qc_table_impl(t_by_method, method_path, delimiter);
    output_paths = {all_path, method_path};

    if ~isempty(t_pair)
        pair_path = fullfile(epoch_root, sprintf('%s_prep06_comparison_runica_vs_amica.csv', char(timestamp)));
        write_qc_table_impl(t_pair, pair_path, delimiter);
        output_paths{end+1} = pair_path; %#ok<AGROW>
    end
end

reason_files = dir(fullfile(epoch_root, '**', '*_epoch_rej.csv'));
reason_files = reason_files(~contains({reason_files.name}, '_all_subjects') & ...
    ~contains({reason_files.name}, '_by_condition'));
t_reasons = read_latest_qc_tables_impl(reason_files, ...
    {'subject_id','run_base','ica_method'}, delimiter);

if ~isempty(t_reasons)
    sort_vars = intersect({'ica_method','subject_id','run_base','condition','rejection_reason'}, ...
        t_reasons.Properties.VariableNames, 'stable');
    if ~isempty(sort_vars)
        t_reasons = sortrows(t_reasons, sort_vars);
    end

    reason_group_vars = intersect({ ...
        'ica_method','epoching_mode','condition','rejection_method', ...
        'rejection_reason','criterion_enabled','criterion_setting','settings_json'}, ...
        t_reasons.Properties.VariableNames, 'stable');
    reason_numeric = intersect({'n_epochs_before','n_rejected_for_reason','n_rejected_any_reason','n_epochs_kept'}, ...
        t_reasons.Properties.VariableNames, 'stable');
    t_reason_group = groupsummary(t_reasons, reason_group_vars, {'sum','mean'}, reason_numeric);

    reason_all_path = fullfile(epoch_root, sprintf('%s_epoch_rejection_reasons_all_subjects.csv', char(timestamp)));
    reason_group_path = fullfile(epoch_root, sprintf('%s_epoch_rejection_reasons_by_condition.csv', char(timestamp)));
    write_qc_table_impl(t_reasons, reason_all_path, delimiter);
    write_qc_table_impl(t_reason_group, reason_group_path, delimiter);
    output_paths{end+1} = reason_all_path; %#ok<AGROW>
    output_paths{end+1} = reason_group_path; %#ok<AGROW>
end
end


function [warning_table, warning_message] = build_high_epoch_rejection_warning_impl( ...
    t_all, processed_subject_ids, ica_method, qc_timestamp, threshold)
warning_table = table();
warning_message = "";

if nargin < 5 || isempty(threshold) || ~isscalar(threshold) || ...
        ~isfinite(threshold) || threshold < 0 || threshold > 1
    threshold = 0.25;
end

required = {'subject_id','ica_method','qc_timestamp','n_epochs_total','n_rejected_total'};
if isempty(t_all) || ~all(ismember(required, t_all.Properties.VariableNames))
    return;
end

subject_ids = string(processed_subject_ids(:));
for i = 1:numel(subject_ids)
    if ~startsWith(subject_ids(i), "sub-")
        subject_ids(i) = "sub-" + subject_ids(i);
    end
end

keep = ismember(string(t_all.subject_id), subject_ids);
if nargin >= 3 && strlength(string(ica_method)) > 0
    keep = keep & strcmpi(string(t_all.ica_method), string(ica_method));
end
if nargin >= 4 && strlength(string(qc_timestamp)) > 0
    keep = keep & string(t_all.qc_timestamp) == string(qc_timestamp);
end
t_current = t_all(keep, :);
if isempty(t_current)
    return;
end

subjects = unique(string(t_current.subject_id), 'stable');
for s = 1:numel(subjects)
    subject_mask = string(t_current.subject_id) == subjects(s);
    n_total = sum(double(t_current.n_epochs_total(subject_mask)), 'omitnan');
    n_rejected = sum(double(t_current.n_rejected_total(subject_mask)), 'omitnan');
    if n_total <= 0
        continue;
    end

    prop_rejected = n_rejected / n_total;
    if prop_rejected > threshold
        this_row = table(subjects(s), n_total, n_rejected, prop_rejected, ...
            'VariableNames', {'subject_id','n_epochs_total','n_rejected_total','prop_rejected_total'});
        if isempty(warning_table)
            warning_table = this_row;
        else
            warning_table = [warning_table; this_row]; %#ok<AGROW>
        end
    end
end

if isempty(warning_table)
    return;
end

lines = strings(height(warning_table) + 2, 1);
lines(1) = string(sprintf( ...
    'HIGH EPOCH REJECTION WARNING: %d subject(s) exceeded %.1f%% rejected epochs:', ...
    height(warning_table), 100 * threshold));
for r = 1:height(warning_table)
    lines(r + 1) = string(sprintf('  %s: %d/%d epochs rejected (%.1f%%)', ...
        char(warning_table.subject_id(r)), ...
        round(warning_table.n_rejected_total(r)), ...
        round(warning_table.n_epochs_total(r)), ...
        100 * warning_table.prop_rejected_total(r)));
end
lines(end) = "Review the timestamped tables under qc/06_epoch_rej/.";
warning_message = strjoin(lines, newline);
end


function [qc_root, timestamp, delimiter] = resolve_qc_collection_context_impl(cfg_or_qc_root)
delimiter = ';';
cfg = struct();

if nargin < 1 || isempty(cfg_or_qc_root)
    cfg = eeg_pipeline_config();
    qc_root = fullfile(char(cfg.paths.derivatives_root), 'qc');
elseif isstruct(cfg_or_qc_root)
    cfg = cfg_or_qc_root;
    qc_root = fullfile(char(cfg.paths.derivatives_root), 'qc');
else
    qc_root = char(string(cfg_or_qc_root));
end

if isstruct(cfg) && isfield(cfg, 'qc') && isstruct(cfg.qc) && ...
        isfield(cfg.qc, 'table_delimiter')
    delimiter = char(string(cfg.qc.table_delimiter));
elseif isstruct(cfg) && isfield(cfg, 'prep_06')
    delimiter = char(string(getfield_safe_impl(cfg.prep_06, 'qc_table_delimiter', ';')));
end
timestamp = resolve_qc_timestamp_impl(cfg);
end


function t_all = read_latest_qc_tables_impl(files, key_vars, delimiter)
t_all = table();
if isempty(files)
    return;
end

tables = cell(numel(files),1);
keys = strings(numel(files),1);
valid = false(numel(files),1);

for k = 1:numel(files)
    this_path = fullfile(files(k).folder, files(k).name);
    try
        t = readtable(this_path, 'Delimiter', delimiter, 'TextType', 'string');
    catch
        continue;
    end
    if isempty(t)
        continue;
    end

    key_parts = strings(1,numel(key_vars));
    key_ok = true;
    for v = 1:numel(key_vars)
        if ~ismember(key_vars{v}, t.Properties.VariableNames)
            key_ok = false;
            break;
        end
        key_parts(v) = string(t.(key_vars{v})(1));
    end
    if ~key_ok
        continue;
    end

    t.source_qc_file = repmat(string(this_path), height(t), 1);
    tables{k} = t;
    keys(k) = strjoin(cellstr(key_parts), '__');
    valid(k) = true;
end

tables = tables(valid);
keys = keys(valid);
files = files(valid);
if isempty(tables)
    return;
end

unique_keys = unique(keys, 'stable');
for i = 1:numel(unique_keys)
    candidates = find(keys == unique_keys(i));
    [~, latest_local] = max([files(candidates).datenum]);
    selected = tables{candidates(latest_local)};
    if isempty(t_all)
        t_all = selected;
    else
        t_all = append_compatible_tables_impl(t_all, selected);
    end
end
end


function out = append_compatible_tables_impl(a, b)
all_vars = union(a.Properties.VariableNames, b.Properties.VariableNames, 'stable');
a = add_missing_table_variables_impl(a, b, all_vars);
b = add_missing_table_variables_impl(b, a, all_vars);
a = a(:, all_vars);
b = b(:, all_vars);
out = [a; b];
end


function t = add_missing_table_variables_impl(t, template, all_vars)
for i = 1:numel(all_vars)
    vn = all_vars{i};
    if ismember(vn, t.Properties.VariableNames)
        continue;
    end
    if ismember(vn, template.Properties.VariableNames)
        sample = template.(vn);
        if islogical(sample)
            t.(vn) = false(height(t),1);
        elseif isnumeric(sample)
            t.(vn) = nan(height(t),1);
        elseif isstring(sample)
            t.(vn) = strings(height(t),1);
        else
            t.(vn) = repmat({[]}, height(t),1);
        end
    else
        t.(vn) = strings(height(t),1);
    end
end
end


function t = normalize_prep06_summary_table_impl(t)
n = height(t);
string_vars = {'qc_timestamp','subject_id','run_base','ica_method','epoching_mode', ...
    'condition','status','input_set_name','rejection_method','exclusion_reason', ...
    'min_trials_condition_counts','min_trials_insufficient_conditions','settings_json','output_set_paths'};
double_vars = {'n_eeg_channels','n_eog_channels','n_non_eeg_channels','n_epochs_total', ...
    'n_rejected_hard','n_rejected_sophisticated','n_rejected_total','n_epochs_kept', ...
    'n_rejected_extreme_voltage','n_rejected_sample_diff','n_rejected_flatline', ...
    'n_rejected_faster','n_rejected_ptp','n_rejected_mad_variance','prop_rejected_total', ...
    'hard_threshold_uv','baseline_start_ms','baseline_end_ms','max_reject_prop', ...
    'warn_if_reject_prop_gt', ...
    'shared_faster_z','shared_ptp_uV_thresh','min_trials_min_n'};
logical_vars = {'excluded_any_rule','excluded_by_max_reject_prop','excluded_by_min_trials_rule', ...
    'artifact_rejection_enabled','hard_threshold_enabled','baseline_correction_enabled', ...
    'shared_rejection_enabled','shared_use_robust_z','min_trials_rule_enabled'};

for i = 1:numel(string_vars)
    vn = string_vars{i};
    if ~ismember(vn, t.Properties.VariableNames)
        t.(vn) = strings(n,1);
    else
        t.(vn) = qc_to_string_column_impl(t.(vn));
    end
end
for i = 1:numel(double_vars)
    vn = double_vars{i};
    if ~ismember(vn, t.Properties.VariableNames)
        t.(vn) = nan(n,1);
    else
        t.(vn) = qc_to_double_column_impl(t.(vn));
    end
end
for i = 1:numel(logical_vars)
    vn = logical_vars{i};
    if ~ismember(vn, t.Properties.VariableNames)
        t.(vn) = false(n,1);
    else
        t.(vn) = qc_to_logical_column_impl(t.(vn));
    end
end
t.ica_method = lower(string(t.ica_method));
t.excluded_any_rule = logical(t.excluded_any_rule) | ...
    logical(t.excluded_by_max_reject_prop) | logical(t.excluded_by_min_trials_rule);
end


function out = qc_to_string_column_impl(x)
if isstring(x)
    out = x;
elseif iscell(x)
    try
        out = string(x);
    catch
        out = repmat("", numel(x), 1);
    end
else
    out = string(x);
end
out = out(:);
end


function out = qc_to_double_column_impl(x)
if isnumeric(x) || islogical(x)
    out = double(x(:));
else
    out = str2double(replace(qc_to_string_column_impl(x), ',', '.'));
end
end


function out = qc_to_logical_column_impl(x)
if islogical(x)
    out = x(:);
elseif isnumeric(x)
    out = x(:) ~= 0;
else
    s = lower(strtrim(qc_to_string_column_impl(x)));
    out = ismember(s, ["1","true","yes","y","ja"]);
end
end


function t_pair = build_paired_ica_summary_impl(t_all)
t_pair = table();
required = {'subject_id','run_base','epoching_mode','condition','ica_method', ...
    'status','n_epochs_total','n_rejected_total','n_epochs_kept','prop_rejected_total'};
if ~all(ismember(required, t_all.Properties.VariableNames))
    return;
end

pair_key = strcat(string(t_all.subject_id), "__", string(t_all.run_base), "__", ...
    string(t_all.epoching_mode), "__", string(t_all.condition));
for key = unique(pair_key)'
    row_runica = t_all(pair_key == key & lower(string(t_all.ica_method)) == "runica", :);
    row_amica = t_all(pair_key == key & lower(string(t_all.ica_method)) == "amica", :);
    if height(row_runica) ~= 1 || height(row_amica) ~= 1
        continue;
    end

    row = table( ...
        string(row_runica.subject_id(1)), string(row_runica.run_base(1)), ...
        string(row_runica.epoching_mode(1)), string(row_runica.condition(1)), ...
        string(row_runica.status(1)), string(row_amica.status(1)), ...
        row_runica.n_epochs_total(1), row_amica.n_epochs_total(1), ...
        row_runica.n_rejected_total(1), row_amica.n_rejected_total(1), ...
        row_runica.n_epochs_kept(1), row_amica.n_epochs_kept(1), ...
        row_runica.prop_rejected_total(1), row_amica.prop_rejected_total(1), ...
        row_amica.n_rejected_total(1) - row_runica.n_rejected_total(1), ...
        row_amica.n_epochs_kept(1) - row_runica.n_epochs_kept(1), ...
        row_amica.prop_rejected_total(1) - row_runica.prop_rejected_total(1), ...
        'VariableNames', { ...
        'subject_id','run_base','epoching_mode','condition','status_runica','status_amica', ...
        'n_epochs_total_runica','n_epochs_total_amica','n_rejected_total_runica','n_rejected_total_amica', ...
        'n_epochs_kept_runica','n_epochs_kept_amica','prop_rejected_total_runica','prop_rejected_total_amica', ...
        'delta_n_rejected_total_amica_minus_runica','delta_n_epochs_kept_amica_minus_runica', ...
        'delta_prop_rejected_amica_minus_runica'});
    if isempty(t_pair)
        t_pair = row;
    else
        t_pair = [t_pair; row]; %#ok<AGROW>
    end
end
end


function step_cfg = default_prep03_cfg_impl()
step_cfg = struct();

% Crop
step_cfg.crop_to_task_markers = false;
step_cfg.substitute_crop_markers = true;
step_cfg.crop_start_marker    = 'S 91';
step_cfg.crop_end_marker      = 'S 97';
step_cfg.crop_padding_sec     = [0 0];

% Internal break cropping
step_cfg.break_crop_method = "off"; % "off" | "markers" | "trial_count"

% Marker-based method
step_cfg.break_start_marker = {};
step_cfg.break_end_marker   = {};

% Strict trial-count method
step_cfg.break_trial_marker = {};

step_cfg.break_expected_n_blocks = [];
step_cfg.break_trials_per_block  = [];

% First and last non-boundary event expected in the retained recording.
step_cfg.break_first_marker = {};
step_cfg.break_last_marker  = {};

% Every gap >= this threshold is considered an internal break candidate.
step_cfg.break_min_gap_sec = 30;

% [seconds after previous trial/break-start,
%  seconds before next trial/break-end]
step_cfg.break_padding_sec = [0 0];

% "skip"  = leave continuous data unchanged if strict validation fails
% "error" = stop preprocessing
step_cfg.break_on_validation_fail = "skip";

% Write one short QC row per run when break cropping is enabled.
step_cfg.write_break_cropping_qc = true;

% Channel typing labels
step_cfg.eog_channel_labels     = {'IO1','IO2','LO1','LO2'};
step_cfg.scr_channel_labels     = {'SCR'};
step_cfg.startle_channel_labels = {'Startle'};
step_cfg.ekg_channel_labels     = {'EKG'};

% Downsample
step_cfg.downsample_hz = 250;

% Bad channel detection
step_cfg.bad_channel_detection_method = "clean_rawdata"; % "clean_rawdata" | "pop_rejchan" | "off"

% Flat/invalid EEG-channel detection is applied exactly once, independently
% of the selected bad-channel backend. AUX channels are only removed if they
% are non-finite or completely constant.
step_cfg.flat_channel_detection = struct();
step_cfg.flat_channel_detection.enable = true;
step_cfg.flat_channel_detection.mode = "cumulative_fraction"; % "cumulative_fraction" | "continuous_seconds"
step_cfg.flat_channel_detection.max_flat_fraction = 0.10; % fraction of complete post-crop recording
step_cfg.flat_channel_detection.continuous_flat_sec = 5;
step_cfg.flat_channel_detection.step_tolerance_uV = 0;

% Used when bad_channel_detection_method = "clean_rawdata".
% Flat-channel detection is disabled inside clean_rawdata because it has
% already been performed once above.
step_cfg.clean_rawdata_channel_corr_threshold = 0.80;

% Used when bad_channel_detection_method = "pop_rejchan"
step_cfg.pop_rejchan_z_threshold  = 3.29;
step_cfg.pop_rejchan_freqrange_hz = [1 125];

% Interpolation timing
step_cfg.interpolate_bad_channels_before_ica = true;
step_cfg.interp_method = 'spherical';

% Step 03 debug/intermediate exports.
% Master switch. Default false = no Step 03 intermediate debug files.
% If true, the individual switches below decide which stages are written.
step_cfg.save_intermediate_steps = false;

% Save after final bad EEG channel list has been applied.
% In this pipeline, bad EEG channels are usually interpolated rather than
% permanently removed.
step_cfg.save_intermediate_after_bad_channel_rejection = true;

% Save after rereferencing.
step_cfg.save_intermediate_after_rereference = true;

% Save after high-pass filtering.
step_cfg.save_intermediate_after_highpass = true;

% Save after low-pass filtering.
step_cfg.save_intermediate_after_lowpass = true;

step_cfg.intermediate_savemode = 'twofiles';

% Referencing
step_cfg.reference_mode            = "avg";  % "keep" | "avg" | "mastoid"
step_cfg.reference_exclude_non_eeg = true;
step_cfg.mastoid_channel_labels    = {'T9','T10'};

% Filters
step_cfg.highpass_hz          = 0.01;
step_cfg.lowpass_hz           = 40;
step_cfg.ica_prep_highpass_hz = 1;

% Line noise
step_cfg.line_noise_method          = "pop_cleanline"; % "pop_cleanline" | "off"
step_cfg.line_noise_frequencies_hz  = [50 100];
step_cfg.pop_cleanline_bandwidth_hz = 2;
step_cfg.pop_cleanline_p_value      = 0.01;
step_cfg.pop_cleanline_scanforlines      = true;
step_cfg.pop_cleanline_winsize_sec       = 2;
step_cfg.pop_cleanline_winstep_sec       = 1;
step_cfg.pop_cleanline_tau               = 50;
step_cfg.pop_cleanline_pad               = 4;
step_cfg.pop_cleanline_taperbandwidth_hz = 4;
step_cfg.pop_cleanline_norm_spectrum     = 0;
step_cfg.pop_cleanline_computepower      = 0;
step_cfg.pop_cleanline_verbose           = false;

% ICA-prep: regepochs + rejection
step_cfg.ica_prep_use_regepochs       = true;
step_cfg.ica_prep_regepoch_length_sec = 1;

% Main ICA-prep epoch-rejection method.
% Select exactly one:
%   "erplab"     = ERPLAB pop_artextval/pop_artdiff; optional pop_artflatline
%   "faster_ptp" = FASTER epoch_properties + peak-to-peak threshold
%   "mad_variance" = robust MAD rejection on epoch variance
%   "none"       = no ICA-prep epoch rejection
step_cfg.ica_prep_epoch_rejection_method = "erplab";

% Legacy jointprob settings.
% Currently retained for backward compatibility with older configs.
step_cfg.ica_prep_use_jointprob_rejection = true;
step_cfg.ica_prep_jointprob_local         = 3;
step_cfg.ica_prep_jointprob_global        = 3;

% MAD ICA-prep rejection settings.
% Only used when ica_prep_epoch_rejection_method="mad_variance".
% These are the original scalar settings used by
% reject_ica_prep_epochs_by_mad_variance_impl.
step_cfg.ica_prep_use_mad_epoch_rejection = true;
step_cfg.ica_prep_mad_z_threshold         = 4;
step_cfg.ica_prep_mad_use_logvar          = true;
step_cfg.ica_prep_max_reject_prop         = 1.00;

% ERPLAB ICA-prep rejection.
% Same logic as final Step 06 rejection, but more lenient.
step_cfg.ica_prep_erplab_epoch_rejection = struct();
step_cfg.ica_prep_erplab_epoch_rejection.enable = true;
step_cfg.ica_prep_erplab_epoch_rejection.channel_scope = "eeg";
step_cfg.ica_prep_erplab_epoch_rejection.twindow_ms = [];
step_cfg.ica_prep_erplab_epoch_rejection.clear_existing_flags = true;

step_cfg.ica_prep_erplab_epoch_rejection.use_extreme_voltage = true;
step_cfg.ica_prep_erplab_epoch_rejection.extreme_voltage_uV  = 300;
step_cfg.ica_prep_erplab_epoch_rejection.flag_extreme_voltage = 1;

step_cfg.ica_prep_erplab_epoch_rejection.use_sample_diff = true;
step_cfg.ica_prep_erplab_epoch_rejection.sample_diff_uV  = 75;
step_cfg.ica_prep_erplab_epoch_rejection.flag_sample_diff = 2;

% Optional only: flatline rejection may reject unexpectedly many epochs.
% Keep false unless its effect has been inspected for the current dataset.
step_cfg.ica_prep_erplab_epoch_rejection.use_flatline = false;
step_cfg.ica_prep_erplab_epoch_rejection.flatline_tolerance_uV = 0.5;
step_cfg.ica_prep_erplab_epoch_rejection.flatline_duration_ms  = 200;
step_cfg.ica_prep_erplab_epoch_rejection.flag_flatline = 3;

step_cfg.ica_prep_erplab_epoch_rejection.review = "off";
step_cfg.ica_prep_erplab_epoch_rejection.history = "off";
step_cfg.ica_prep_erplab_epoch_rejection.lowpass_hz = -1;

% FASTER/PTP ICA-prep rejection.
% Only used when ica_prep_epoch_rejection_method="faster_ptp".
step_cfg.ica_prep_faster_ptp_epoch_rejection = struct();

step_cfg.ica_prep_faster_ptp_epoch_rejection.enable       = true;
step_cfg.ica_prep_faster_ptp_epoch_rejection.use_faster   = true;
step_cfg.ica_prep_faster_ptp_epoch_rejection.faster_z     = 4;
step_cfg.ica_prep_faster_ptp_epoch_rejection.use_robust_z = true;

step_cfg.ica_prep_faster_ptp_epoch_rejection.use_ptp       = true;
step_cfg.ica_prep_faster_ptp_epoch_rejection.ptp_uV_thresh = 100;

% 1.00 means disabled. Example: 0.50 stops Step 03 if >50% of ICA-prep
% epochs are removed.
step_cfg.ica_prep_faster_ptp_epoch_rejection.max_reject_prop = 1.00;

% ICA-training summary CSV; metadata/logging are retained when disabled.
% The timestamp and delimiter use the shared cfg.qc settings.
step_cfg.write_run_summary_table = true;

% Overwrite override
step_cfg.overwrite_mode = "";
end


function step_cfg = default_prep06_cfg_impl()
step_cfg = struct();

% -------------------------------------------------------------------------
% GENERAL
% -------------------------------------------------------------------------
step_cfg.epoching_mode  = "event_locked";
step_cfg.overwrite_mode = "";

step_cfg.save_final_only         = true;
step_cfg.save_intermediate_steps = false;
step_cfg.savemode                = 'twofiles';

% -------------------------------------------------------------------------
% REFERENCING
% -------------------------------------------------------------------------
step_cfg.reference_mode            = "keep";
step_cfg.mastoid_channel_labels    = {'T9','T10'};
step_cfg.reference_exclude_non_eeg = true;

% -------------------------------------------------------------------------
% EVENT-LOCKED EPOCHING
% -------------------------------------------------------------------------
step_cfg.events_phase  = {};
step_cfg.epoch_start_s = -0.4;
step_cfg.epoch_end_s   =  2.6;

% -------------------------------------------------------------------------
% BASELINE EPOCHING
% -------------------------------------------------------------------------
step_cfg.regepoch_length_sec = 10;
step_cfg.regepoch_step_sec   = 10;

% true  = split baseline data into conditions using the markers below
% false = treat the complete baseline recording as one continuous condition
step_cfg.baseline_has_conditions = false;

% Generic baseline condition definitions. Each row contains a freely chosen
% condition name and the marker prefixes that start that condition.
step_cfg.baseline_condition_definitions = {};
step_cfg.baseline_start_condition        = "";
step_cfg.baseline_end_condition          = "";

step_cfg.baseline_end_markers            = {};

% -------------------------------------------------------------------------
% ARTIFACT REJECTION
% -------------------------------------------------------------------------
step_cfg.do_artifact_rejection               = true;

% Optional first-pass hard rejection.
% Usually keep this false when epoch_rejection_backend="erplab", because
% ERPLAB's extreme-value rule can implement the same threshold.
step_cfg.do_initial_hard_threshold_rejection = false;
step_cfg.initial_hard_threshold_uv           = 100;

% Select exactly one final epoch-rejection method:
%   "erplab"     = ERPLAB pop_artextval/pop_artdiff/pop_artflatline
%   "faster_ptp" = FASTER epoch_properties + peak-to-peak threshold
%   "mad_variance" = original MAD variance rejection helper
%   "none"       = no final epoch rejection
step_cfg.epoch_rejection_method = "erplab";

% Legacy / fallback settings
step_cfg.use_faster                    = true;
step_cfg.faster_z_thresh               = 3;
step_cfg.faster_use_robust_z           = true;

step_cfg.use_ptp       = true;
step_cfg.ptp_uV_thresh = 100;

step_cfg.max_reject_prop = 1;
step_cfg.warn_if_reject_prop_gt = 0.25;

% MAD variance rejection settings.
% Only used when epoch_rejection_method="mad_variance".
% Reuses reject_ica_prep_epochs_by_mad_variance_impl.
step_cfg.mad_z_threshold = 3;
step_cfg.mad_use_logvar  = true;

% -------------------------------------------------------------------------
% ERPLAB EPOCH REJECTION
% -------------------------------------------------------------------------
step_cfg.erplab_epoch_rejection = struct();

% "eeg" checks only EEG channels; "all" checks all channels.
step_cfg.erplab_epoch_rejection.channel_scope = "eeg";

% [] means use the whole epoch window.
step_cfg.erplab_epoch_rejection.twindow_ms = [];

% Clear previous EEGLAB/ERPLAB manual artifact flags before running ERPLAB.
step_cfg.erplab_epoch_rejection.clear_existing_flags = true;

% 1) Extreme voltage threshold: reject if signal exceeds +/- threshold.
step_cfg.erplab_epoch_rejection.use_extreme_voltage = true;
step_cfg.erplab_epoch_rejection.extreme_voltage_uV  = 200;
step_cfg.erplab_epoch_rejection.flag_extreme_voltage = 1;

% 2) Sample-to-sample voltage difference.
step_cfg.erplab_epoch_rejection.use_sample_diff = true;
step_cfg.erplab_epoch_rejection.sample_diff_uV  = 50;
step_cfg.erplab_epoch_rejection.flag_sample_diff = 2;

% Optional only: epoch-level flatline rejection may reject unexpectedly
% many epochs. Keep it off unless its impact has been inspected explicitly.
step_cfg.erplab_epoch_rejection.use_flatline = false;
step_cfg.erplab_epoch_rejection.flatline_tolerance_uV = 0.5;
step_cfg.erplab_epoch_rejection.flatline_duration_ms  = 100;
step_cfg.erplab_epoch_rejection.flag_flatline = 3;

step_cfg.erplab_epoch_rejection.review = "off";
step_cfg.erplab_epoch_rejection.history = "off";
step_cfg.erplab_epoch_rejection.lowpass_hz = -1;

% -------------------------------------------------------------------------
% BASELINE CORRECTION
% -------------------------------------------------------------------------
step_cfg.do_baseline_correction = false;
step_cfg.base_start_ms          = -200;
step_cfg.base_end_ms            = 0;

% -------------------------------------------------------------------------
% OUTPUT SPLITTING
% -------------------------------------------------------------------------
step_cfg.split_non_eeg_channels = false;
step_cfg.eeg_only_keep_eog      = false;

% -------------------------------------------------------------------------
% SHARED EPOCH REJECTION
% -------------------------------------------------------------------------
% FASTER/PTP epoch rejection.
% Only used when epoch_rejection_method="faster_ptp".
step_cfg.faster_ptp_epoch_rejection = struct();
step_cfg.faster_ptp_epoch_rejection.use_faster    = true;
step_cfg.faster_ptp_epoch_rejection.faster_z      = 3;
step_cfg.faster_ptp_epoch_rejection.use_robust_z  = true;
step_cfg.faster_ptp_epoch_rejection.use_ptp       = true;
step_cfg.faster_ptp_epoch_rejection.ptp_uV_thresh = 100;

% -------------------------------------------------------------------------
% MINIMUM TRIALS PER CONDITION (event_locked only)
% -------------------------------------------------------------------------
step_cfg.min_trials_per_condition_enable      = false;
step_cfg.min_trials_per_condition_min_n       = 3;
step_cfg.min_trials_per_condition_zero_tol_ms = 2;
step_cfg.min_trials_per_condition_codes       = {};

% -------------------------------------------------------------------------
% SUMMARY TABLES
% -------------------------------------------------------------------------
step_cfg.write_run_summary_table     = true;
step_cfg.write_subject_summary_table = true;
step_cfg.qc_table_delimiter          = ';';
end


% =========================================================================
% BEHAVIOR LOG HELPERS
% =========================================================================
function beh_file = find_behavior_log_impl(path_bids_root, subj_id, session_label)
if nargin < 3 || isempty(session_label)
    session_label = "01";
end

session_label = char(string(session_label));
subj_label    = sprintf('sub-%s', subj_id);
ses_label     = sprintf('ses-%s', session_label);

beh_dir = fullfile(path_bids_root, subj_label, ses_label, 'beh');

if exist(beh_dir, 'dir') ~= 7
    error('No beh directory: %s', beh_dir);
end

cands = [dir(fullfile(beh_dir, '*.log')); dir(fullfile(beh_dir, '*.txt'))];

if isempty(cands)
    error('No .log/.txt files in %s', beh_dir);
end

scores = zeros(numel(cands), 1);

for k = 1:numel(cands)
    name_lower = lower(cands(k).name);

    % Strong preference for BIDS-style subject/session naming.
    if contains(name_lower, lower(subj_label))
        scores(k) = scores(k) + 100;
    end

    if contains(name_lower, lower(ses_label))
        scores(k) = scores(k) + 50;
    end

    % Prefer files that explicitly look like behavior files.
    if contains(name_lower, '_beh.')
        scores(k) = scores(k) + 30;
    end

    % Mild preference for task-tagged BIDS files.
    if contains(name_lower, 'task-')
        scores(k) = scores(k) + 10;
    end

    % Mild preference for .log over .txt.
    if endsWith(name_lower, '.log')
        scores(k) = scores(k) + 5;
    end

    % Small backward-compatibility bonus for legacy naming.
    if contains(name_lower, 'cf_')
        scores(k) = scores(k) + 1;
    end
end

meta = [scores(:), vertcat(cands.datenum)];
[~, order] = sortrows(meta, [-1 -2]);

best = cands(order(1));
beh_file = fullfile(best.folder, best.name);
end

function beh = read_behavior_log_impl(beh_file)
raw_text = fileread(beh_file);
lines = regexp(raw_text, '\r\n|\n|\r', 'split');

header_idx = 0;
for i = 1:numel(lines)
    if startsWith(strtrim(lines{i}), 'Subject')
        header_idx = i;
        break;
    end
end

tmp_file = [tempname '.txt'];
fid = fopen(tmp_file, 'w');

if fid < 0
    error('Could not create temporary file for behavior-log import.');
end

if header_idx > 0
    for i = header_idx:numel(lines)
        fprintf(fid, '%s\n', lines{i});
    end
else
    for i = 1:numel(lines)
        fprintf(fid, '%s\n', lines{i});
    end
end

fclose(fid);

try
    opts = detectImportOptions(tmp_file, 'FileType', 'text');
catch
    opts = detectImportOptions(tmp_file, 'Delimiter', '\t', 'FileType', 'text');
end

T = readtable(tmp_file, opts);
delete(tmp_file);

T.Properties.VariableNames = matlab.lang.makeValidName(T.Properties.VariableNames);
beh = T;
end

% =========================================================================
% RAW QC WRITER
% =========================================================================
function [ok, rep] = check_subsequence_order_detailed_impl(beh_tokens, eeg_tokens)
i = 1; j = 1;
lastMatchEegIdx = 0;

while i <= numel(beh_tokens) && j <= numel(eeg_tokens)
    if beh_tokens(i) == eeg_tokens(j)
        lastMatchEegIdx = j;
        i = i + 1;
        j = j + 1;
    else
        j = j + 1;
    end
end

ok = (i > numel(beh_tokens));

rep = struct();
rep.last_match_eeg_idx = lastMatchEegIdx;

if ok
    rep.summary = sprintf('OK: %d behavior tokens found in EEG stream (in-order subsequence).', numel(beh_tokens));
    rep.missing_token = "";
    rep.beh_i = NaN;
    rep.beh_ctx = strings(0,1);
    rep.eeg_ctx = strings(0,1);
    rep.beh_ctx_i1 = NaN; rep.beh_ctx_i2 = NaN;
    rep.eeg_ctx_j1 = NaN; rep.eeg_ctx_j2 = NaN;
    return;
end

rep.missing_token = beh_tokens(i);
rep.beh_i = i;

rep.beh_ctx_i1 = max(1, i-10);
rep.beh_ctx_i2 = min(numel(beh_tokens), i+10);
rep.beh_ctx = beh_tokens(rep.beh_ctx_i1:rep.beh_ctx_i2);

rep.eeg_ctx_j1 = max(1, lastMatchEegIdx-10);
rep.eeg_ctx_j2 = min(numel(eeg_tokens), lastMatchEegIdx+30);
rep.eeg_ctx = eeg_tokens(rep.eeg_ctx_j1:rep.eeg_ctx_j2);
end

function raw_qc_behavior_vs_eeg_and_write_csv_impl(beh, EEG, subj_id, bids_base, out_dir, varargin)

arguments
    beh table
    EEG struct
    subj_id char
    bids_base char
    out_dir char
end
arguments (Repeating)
    varargin
end

opts = struct();
opts.bin_size_s                 = 1;
opts.max_rows                   = 20000;
opts.keep_tokens                = ["S 20","S 21","S 22","S 23","S 24","S 15","S 5"];
opts.write_csv_on_ok            = false;
opts.behavior_column_event_type = "EventType";
opts.behavior_column_code       = "Code";
opts.behavior_column_time       = "Time";
opts.behavior_time_unit         = "ms";
opts.behavior_log_map           = {};
opts.raw_triggers               = struct();

if numel(varargin) == 1 && isstruct(varargin{1})
    user_opts = varargin{1};
    fields = fieldnames(user_opts);
    for k = 1:numel(fields)
        opts.(fields{k}) = user_opts.(fields{k});
    end
elseif ~isempty(varargin)
    for k = 1:2:numel(varargin)
        key = string(varargin{k});
        opts.(char(key)) = varargin{k + 1};
    end
end

ensure_dir_impl(out_dir);

[beh_tok, beh_t_s] = build_beh_key_token_stream_with_time_impl(beh, opts);
[eeg_tok, eeg_t_s] = build_eeg_key_token_stream_with_time_impl(EEG);

keep_b = ismember(beh_tok, opts.keep_tokens);
beh_tok = beh_tok(keep_b);
beh_t_s = beh_t_s(keep_b);

keep_e = ismember(eeg_tok, opts.keep_tokens);
eeg_tok = eeg_tok(keep_e);
eeg_t_s = eeg_t_s(keep_e);

if isempty(beh_tok) || isempty(eeg_tok)
    return;
end

[ok, rep] = check_subsequence_order_detailed_impl(beh_tok, eeg_tok);

if ok && ~opts.write_csv_on_ok
    return;
end

is_stim_b = ismember(beh_tok, ["S 20","S 21","S 22","S 23","S 24"]);
is_stim_e = ismember(eeg_tok, ["S 20","S 21","S 22","S 23","S 24"]);

if any(is_stim_b) && any(is_stim_e)
    t_b0 = beh_t_s(find(is_stim_b, 1, 'first'));
    t_e0 = eeg_t_s(find(is_stim_e, 1, 'first'));
    delay_s = t_e0 - t_b0;
else
    delay_s = NaN;
end

if any(is_stim_b)
    beh_rel = beh_t_s - beh_t_s(find(is_stim_b, 1, 'first'));
else
    beh_rel = beh_t_s - beh_t_s(1);
end

if any(is_stim_e)
    eeg_rel = eeg_t_s - eeg_t_s(find(is_stim_e, 1, 'first'));
else
    eeg_rel = eeg_t_s - eeg_t_s(1);
end

if ~isnan(delay_s)
    beh_rel_aligned = beh_rel + delay_s;
else
    beh_rel_aligned = beh_rel;
end

bin = opts.bin_size_s;

min_t = min([0; beh_rel_aligned; eeg_rel]);
max_t = max([beh_rel_aligned; eeg_rel]);

bin_start = floor(min_t / bin) * bin;
bin_end   = ceil(max_t / bin)  * bin;

edges = bin_start:bin:bin_end;

if numel(edges) < 2
    edges = [bin_start, bin_start + bin];
end

n_bins = numel(edges) - 1;

if n_bins > opts.max_rows
    n_bins = opts.max_rows;
    edges = edges(1:n_bins + 1);
end

beh_in_bin = cell(n_bins, 1);
eeg_in_bin = cell(n_bins, 1);
n_beh      = zeros(n_bins, 1);
n_eeg      = zeros(n_bins, 1);

for bi = 1:n_bins
    t1 = edges(bi);
    t2 = edges(bi + 1);

    idx_b = beh_rel_aligned >= t1 & beh_rel_aligned < t2;
    idx_e = eeg_rel         >= t1 & eeg_rel         < t2;

    if any(idx_b)
        beh_in_bin{bi} = strjoin(beh_tok(idx_b), '|');
        n_beh(bi) = sum(idx_b);
    else
        beh_in_bin{bi} = "";
    end

    if any(idx_e)
        eeg_in_bin{bi} = strjoin(eeg_tok(idx_e), '|');
        n_eeg(bi) = sum(idx_e);
    else
        eeg_in_bin{bi} = "";
    end
end

T = table();
T.bin_start_s  = edges(1:n_bins)';
T.bin_end_s    = edges(2:n_bins + 1)';
T.beh_events   = string(beh_in_bin);
T.eeg_events   = string(eeg_in_bin);
T.n_beh_events = n_beh;
T.n_eeg_events = n_eeg;

out_csv = fullfile(out_dir, sprintf('order_mismatch_sub-%s_%s.csv', subj_id, bids_base));

fid = fopen(out_csv, 'w');
if fid < 0
    return;
end

fprintf(fid, 'subject;%s\n', subj_id);
fprintf(fid, 'bids_base;%s\n', bids_base);
fprintf(fid, 'delay_s;%s\n', num2str(delay_s));
fprintf(fid, 'bin_size_s;%g\n', bin);
fprintf(fid, 'mismatch;%d\n', ~ok);

if ~ok
    fprintf(fid, 'first_missing_token;%s\n', rep.missing_token);
    fprintf(fid, 'beh_missing_index;%d\n', rep.beh_i);
    fprintf(fid, 'last_match_eeg_index;%d\n', rep.last_match_eeg_idx);
end

fprintf(fid, '\n');
fprintf(fid, 'bin_start_s;bin_end_s;beh_events;eeg_events;n_beh_events;n_eeg_events\n');

for r = 1:height(T)
    fprintf(fid, '%.3f;%.3f;%s;%s;%d;%d\n', ...
        T.bin_start_s(r), T.bin_end_s(r), ...
        escape_semicolons_impl(T.beh_events(r)), ...
        escape_semicolons_impl(T.eeg_events(r)), ...
        T.n_beh_events(r), T.n_eeg_events(r));
end

fclose(fid);
end

function s = escape_semicolons_impl(s)
s = string(s);
s = replace(s, ";", ",");
end

function [tokens, times_s] = build_beh_key_token_stream_with_time_impl(beh, opts)
vars = string(beh.Properties.VariableNames);

col_event = string(opts.behavior_column_event_type);
col_code  = string(opts.behavior_column_code);
col_time  = string(opts.behavior_column_time);

required = [col_event, col_code, col_time];

if ~all(ismember(required, vars))
    error(['Behavior log missing required columns. Required: %s | Found: %s'], ...
        strjoin(required, ', '), strjoin(vars, ', '));
end

n_rows = height(beh);
time_s_all = nan(n_rows, 1);

time_col = beh.(char(col_time));

for r = 1:n_rows
    time_s_all(r) = convert_behavior_time_to_seconds_impl( ...
        time_col(r), opts.behavior_time_unit);
end

[~, ix] = sort(time_s_all);
beh = beh(ix, :);
time_s_all = time_s_all(ix);

tokens  = strings(0, 1);
times_s = zeros(0, 1);

map_table = opts.behavior_log_map;
if isempty(map_table)
    return;
end

event_col = beh.(char(col_event));
code_col  = beh.(char(col_code));

for r = 1:height(beh)
    event_type = string(event_col(r));
    code       = string(code_col(r));
    t          = time_s_all(r);

    for m = 1:size(map_table, 1)
        map_event = string(map_table{m,1});
        map_code  = string(map_table{m,2});
        map_ref   = string(map_table{m,3});

        if behavior_value_matches_impl(event_type, map_event) && ...
                behavior_value_matches_impl(code, map_code)

            raw_token = get_raw_trigger_from_key_impl(opts.raw_triggers, map_ref);

            if ~isempty(raw_token)
                tokens(end+1, 1)  = string(raw_token); %#ok<AGROW>
                times_s(end+1, 1) = t;                %#ok<AGROW>
            end
            break;
        end
    end
end
end

function t_s = convert_behavior_time_to_seconds_impl(time_raw, time_unit)
if iscell(time_raw)
    time_raw = time_raw{1};
end

if isstring(time_raw) || ischar(time_raw)
    t_num = str2double(strrep(char(string(time_raw)), ',', '.'));
else
    t_num = double(time_raw);
end

if isnan(t_num)
    error('Behavior-log time value could not be converted to numeric seconds/ms.');
end

switch lower(char(string(time_unit)))
    case {'ms','millisecond','milliseconds'}
        t_s = t_num / 1000;
    case {'s','sec','second','seconds'}
        t_s = t_num;
    otherwise
        error('Unsupported behavior_log_time_unit: %s', string(time_unit));
end
end

function tf = behavior_value_matches_impl(value, pattern)
value   = lower(strtrim(char(string(value))));
pattern = lower(strtrim(char(string(pattern))));

value   = regexprep(value, '\s+', ' ');
pattern = regexprep(pattern, '\s+', ' ');

if strcmp(pattern, '*')
    tf = true;
else
    tf = strcmp(value, pattern);
end
end

function summary = build_ica_training_summary_impl( ...
    EEG, n_before, is_epoched, subj_id, run_base, method, rejection_status, ...
    status, output_set_path, cfg, step_cfg)
% Summarize rejected and remaining epochs in one ICA training dataset.

% Count the remaining epochs.
% Use NaN when epoch counts do not apply to continuous data.
n_kept = NaN;

if is_epoched
    n_kept = EEG.trials;

    if isempty(EEG.data)
        n_kept = 0;
    end
else
    n_before = NaN;
end

% Calculate how many epochs were removed.
n_rejected = n_before - n_kept;

% Calculate the rejected fraction: 0.05 means 5%.
% Leave it undefined when there were no epochs to begin with.
prop_rejected = NaN;

if n_before > 0
    prop_rejected = n_rejected / n_before;
end

% Store the counts together with the dataset name and settings.
summary = struct( ...
    'qc_timestamp', resolve_qc_timestamp_impl(cfg), ...
    'subject_id', string(sprintf('sub-%s', subj_id)), ...
    'run_base', string(run_base), ...
    'rejection_method', string(method), ...
    'rejection_status', string(rejection_status), ...
    'status', string(status), ...
    'data_is_epoched', logical(is_epoched), ...
    'n_epochs_total', n_before, ...
    'n_rejected_total', n_rejected, ...
    'n_epochs_kept', n_kept, ...
    'prop_rejected_total', prop_rejected, ...
    'output_set_path', string(output_set_path), ...
    'settings_json', string(jsonencode(step_cfg)));
end

function out_path = write_ica_training_summary_impl(summary, cfg, step_cfg, helpers)
% Write the training summary to the log and, if enabled, to a CSV file.

out_path = '';

% Report the counts in the pipeline log.
helpers.log_msg_default( ...
    ['prep03_untilica: %s | %s | training summary | method=%s | ' ...
     'rejected=%g/%g | kept=%g | prop_rejected=%g | rejection_status=%s | status=%s'], ...
    char(summary.subject_id), char(summary.run_base), ...
    char(summary.rejection_method), summary.n_rejected_total, ...
    summary.n_epochs_total, summary.n_epochs_kept, ...
    summary.prop_rejected_total, char(summary.rejection_status), char(summary.status));

% Stop here if CSV output is switched off.
if ~getfield_safe_impl(step_cfg, 'write_run_summary_table', true)
    return;
end

% Use the pipeline's QC folder and CSV separator.
[qc_root, ~, delimiter] = resolve_qc_collection_context_impl(cfg);

% Include the timestamp and dataset name in the filename.
out_path = fullfile(qc_root, '03_ica_training', sprintf( ...
    '%s_%s_prep03_run_summary.csv', ...
    char(summary.qc_timestamp), char(summary.run_base)));

% Save the summary using the existing QC writer.
write_qc_table_impl(struct2table(summary), out_path, delimiter);
end

function [t_all, output_paths] = collect_prep03_summary_impl(cfg_or_qc_root)
% Combine the latest available training summaries across subjects and runs.

if nargin < 1
    cfg_or_qc_root = [];
end

% Find the QC folder and use the pipeline's CSV settings.
[qc_root, timestamp, delimiter] = ...
    resolve_qc_collection_context_impl(cfg_or_qc_root);

training_root = fullfile(qc_root, '03_ica_training');

t_all = table();
output_paths = {};

% Return empty outputs if no training-summary folder exists.
if exist(training_root, 'dir') ~= 7
    return;
end

% Find the individual run summaries.
files = dir(fullfile(training_root, '**', '*_prep03_run_summary.csv'));

% Use the most recently modified readable file for each subject and run.
t_all = read_latest_qc_tables_impl( ...
    files, {'subject_id','run_base'}, delimiter);

if isempty(t_all)
    return;
end

% Check that the required summary columns are present.
required = { ...
    'subject_id', 'run_base', 'rejection_method', 'rejection_status', ...
    'status', 'n_epochs_total', 'n_rejected_total', ...
    'n_epochs_kept', 'prop_rejected_total'};

if ~all(ismember(required, t_all.Properties.VariableNames))
    error('prep03_summary:InvalidSchema', ...
        'Selected Step-03 summaries are missing required columns below: %s', ...
        training_root);
end

% Sort the results by subject and run.
t_all = sortrows(t_all, {'subject_id','run_base'});

% Save the combined table.
out_path = fullfile(training_root, sprintf( ...
    '%s_prep03_ica_training_all_subjects.csv', char(timestamp)));

write_qc_table_impl(t_all, out_path, delimiter);

output_paths = {out_path};
end