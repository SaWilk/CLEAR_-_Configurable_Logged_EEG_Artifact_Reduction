% =========================================================================
% FILE: eeg_pipeline_config.m
% =========================================================================
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
function cfg = eeg_pipeline_config()
% EEG_PIPELINE_CONFIG
%
% PURPOSE
%   Define all user-facing settings for the EEG preprocessing pipeline.
%
% INPUT
%   Edit this file.
%
% OUTPUT
%   cfg : full configuration struct for run_eeg_pipeline.m
%
% REQUIREMENTS
%   - EEGLAB with ERPLAB plugin
%   - FASTER
%   - (AMICA - optional)
%   - (cleanline - optional)
%   - (zapline-plus - optional) https://eeglab.org/plugins/zapline-plus/ 

% Saskia Wilken Dec 2025

bootstrap_log = fullfile(tempdir, 'eeg_pipeline_config_bootstrap.log');
helpers = eeg_pipeline_helpers(bootstrap_log);

% =========================================================================
% USER SETTINGS
% Edit the cfg.* fields in this section.
%
% PATH CONCEPT
%   source_eeg_root   = fresh/raw BrainVision files before BIDS formatting
%   source_beh_root   = optional project-specific raw behavior/log files
%   bids_root         = BIDS-formatted raw dataset
%                       -> output of Step 01
%                       -> input of Steps 02-06
%   derivatives_root  = preprocessing outputs from Steps 02-06
% =========================================================================

cfg = struct();

% One shared timestamp for all QC files produced by this pipeline run.
% Filenames start with yyyy-mm-dd-hh-mm so runs can be compared directly.
cfg.qc = struct();
cfg.qc.filename_timestamp_format = 'yyyy-mm-dd-HH-MM';
cfg.qc.run_timestamp = string(datestr(now, cfg.qc.filename_timestamp_format));
cfg.qc.table_delimiter = ';';

% -------------------------------------------------------------------------
% Project identity
% -------------------------------------------------------------------------
cfg.pipeline = struct();
cfg.pipeline.name        = " "; % set recognizable name: project name used in cfg and logsheader
cfg.pipeline.step_prefix = " ";                % step 02-06 function prefix, needed to find step-functions. Keep as "eeg" unless you have a good reason to change it.

cfg.constants = struct();
cfg.constants.log_prefix_master = " "; % master log filename prefix

cfg.bids = struct();
cfg.bids.dataset_folder_name = " ";   % BIDS dataset folder name (if you have multiple datasets in the same raw folder)
cfg.bids.task_label          = " ";   % BIDS task label of EEG dataset
cfg.bids.session_label       = " ";         % BIDS session label


% -------------------------------------------------------------------------
% Profile / paths
% Configure ALL machine-specific path profiles here.
%
% To add a new profile later:
%   1) duplicate one block below
%   2) give it a new name
%   3) optionally set cfg.paths.profile_override to that name
% -------------------------------------------------------------------------
cfg.paths = struct();

cfg.paths.branch_by_ica_method = true; % create separate 04/05/06 folders per ICA method

cfg.paths.profile_override = ""; % leave empty for automatic profile selection; "pc" | "server_windows" | "hpc_hummel"

cfg.paths.profile_paths = struct();

% Load local paths from separate file eeg_pipeline_local_paths.m; 
% adjust local and HPC paths to data there
cfg.paths.profile_paths = eeg_pipeline_local_paths();

% only set these if paths deviate but you do not want to change the profile
cfg.paths.bids_root_override        = "";
cfg.paths.derivatives_root_override = "";
cfg.paths.source_eeg_root_override  = "";
cfg.paths.source_beh_root_override  = "";

% =========================================================================
% TOOLBOX PATHS
% =========================================================================
cfg.toolboxes = struct();

local_paths = eeg_pipeline_local_paths();   %% Load local paths from separate file eeg_pipeline_local_paths.m; 
% adjust local and HPC paths for toolboxes there (EEGLab, FASTER, ERPLab)

cfg.toolboxes.path_eeglab_pc     = string(local_paths.toolboxes.eeglab_pc);
cfg.toolboxes.path_eeglab_server = string(local_paths.toolboxes.eeglab_server);
cfg.toolboxes.path_eeglab_hpc    = string(local_paths.toolboxes.eeglab_hpc);

cfg.toolboxes.path_faster_pc     = string(local_paths.toolboxes.faster_pc);
cfg.toolboxes.path_faster_server = string(local_paths.toolboxes.faster_server);
cfg.toolboxes.path_faster_hpc    = string(local_paths.toolboxes.faster_hpc);

cfg.toolboxes.path_erplab_pc     = string(local_paths.toolboxes.erplab_pc);
cfg.toolboxes.path_erplab_server = string(local_paths.toolboxes.erplab_server);
cfg.toolboxes.path_erplab_hpc    = string(local_paths.toolboxes.erplab_hpc);


cfg.toolboxes.erplab = struct();
cfg.toolboxes.erplab.use_genpath = true;

cfg.toolboxes.use_genpath = false; % add toolbox subfolders recursively

cfg.toolboxes.eeglab = struct();
cfg.toolboxes.eeglab.no_update_check_on_hpc = true; % suppress EEGLAB update checks on HPC
cfg.toolboxes.eeglab.nogui = true;                  % start EEGLAB without GUI

% -------------------------------------------------------------------------
% Overwrite behavior
% -------------------------------------------------------------------------
cfg.io = struct();
cfg.io.overwrite_mode          = "skip"; % "skip" | "delete" | "if_older_than"
cfg.io.overwrite_if_older_than = "";       % cutoff date for "if_older_than", 
% either "DD.MM.YYYY" or "YYYY-MM-DD", optionally with time in 24h format: HH:MM or HH:MM:SS 

% =========================================================================
% INTERNAL SETUP
% =========================================================================
this_file = mfilename('fullpath');
root_dir  = fileparts(this_file);

cfg.this_file = this_file;
cfg.root_dir  = root_dir;

% =========================================================================
% CONSTANTS
% =========================================================================
cfg.constants.valid_sub_id_regex = '^\d{3}$';          % valid subject IDs, default: three digits like "001"
cfg.constants.log_prefix_subject = 'sub';              % subject log prefix
cfg.constants.datestr_master     = 'yyyymmdd_HHMMSS';  % master log timestamp format
cfg.constants.datestr_subject    = 'yyyymmdd_HHMMSS_FFF'; % subject log timestamp format

% =========================================================================
% ENVIRONMENT  -- do not edit, will be automatically detected at runtime
% =========================================================================
cfg.env = struct();
cfg.env.mode         = helpers.detect_env_mode();      % "pc" | "server" | "hpc"
cfg.env.machine_kind = helpers.detect_machine_kind();  % concrete machine/profile family
cfg.env.hostname     = helpers.get_hostname();         % host name

cfg.env.is_slurm      = ~isempty(getenv('SLURM_JOB_ID')); % true if running under SLURM
cfg.env.slurm_job_id  = string(helpers.get_env_first_nonempty({'SLURM_JOB_ID'}));       % SLURM job id
cfg.env.slurm_cluster = string(helpers.get_env_first_nonempty({'SLURM_CLUSTER_NAME'})); % SLURM cluster name

% SLURM execution was tested on the University of Leipzig HPC with MATLAB R2024b.
% The pipeline was submitted through an external sbatch script and executed
% successfully on a compute node. The fields above record the SLURM context
% (job ID and cluster name: is_slurm = 1, cluster sc) in the pipeline log.
% Job submission and resource requests were handled outside MATLAB.

% =========================================================================
% RESOLVED PATHS -- do not edit, will be resolved at runtime based on profile and environment
% =========================================================================
cfg.paths.profile = helpers.default_profile_for_mode(cfg.env.mode, cfg.env.machine_kind); % default profile by environment

profile_env = helpers.get_env_first_nonempty({'EEG_PIPELINE_PROFILE'}); % optional env override
if strlength(profile_env) > 0
    cfg.paths.profile = string(profile_env);
end

if strlength(string(cfg.paths.profile_override)) > 0
    cfg.paths.profile = string(cfg.paths.profile_override);
end

profile_name = char(string(cfg.paths.profile));
if ~isfield(cfg.paths.profile_paths, profile_name)
    error('Unknown cfg.paths.profile="%s". Please define it in cfg.paths.profile_paths.', string(cfg.paths.profile));
end

profile_cfg = cfg.paths.profile_paths.(profile_name);


% -------------------------------------------------------------------------
% Base paths from selected profile
% -------------------------------------------------------------------------
cfg.paths.source_eeg_root  = string(profile_cfg.source_eeg_root);
cfg.paths.source_beh_root  = string(profile_cfg.source_beh_root);
cfg.paths.bids_root        = string(profile_cfg.bids_root);
cfg.paths.derivatives_root = string(profile_cfg.derivatives_root);
cfg.paths.logs_dir = fullfile(fileparts(cfg.paths.derivatives_root), 'logs', 'runlog_pipeline'); % log folder in data-directory

% -------------------------------------------------------------------------
% Optional environment overrides
% Intended for batch/HPC/SLURM test runs without editing this config file
% -------------------------------------------------------------------------
bids_env = helpers.get_env_first_nonempty({'EEG_PIPELINE_BIDS_ROOT'});
derivatives_env = helpers.get_env_first_nonempty({'EEG_PIPELINE_DERIVATIVES_ROOT'});
source_eeg_env = helpers.get_env_first_nonempty({'EEG_PIPELINE_SOURCE_EEG_ROOT'});
source_beh_env = helpers.get_env_first_nonempty({'EEG_PIPELINE_SOURCE_BEH_ROOT'});

if strlength(bids_env) > 0
    cfg.paths.bids_root = string(bids_env);
end

if strlength(derivatives_env) > 0
    cfg.paths.derivatives_root = string(derivatives_env);
end

if strlength(source_eeg_env) > 0
    cfg.paths.source_eeg_root = string(source_eeg_env);
end

if strlength(source_beh_env) > 0
    cfg.paths.source_beh_root = string(source_beh_env);
end

% -------------------------------------------------------------------------
% Explicit config overrides
% Highest priority because they are set directly in this file (in Profile 
% paths section above) and intended for manual runs. Environment variables 
% are more intended for batch/HPC/test runs without editing this config file.
% -------------------------------------------------------------------------
if strlength(string(cfg.paths.bids_root_override)) > 0
    cfg.paths.bids_root = string(cfg.paths.bids_root_override);
end

if strlength(string(cfg.paths.derivatives_root_override)) > 0
    cfg.paths.derivatives_root = string(cfg.paths.derivatives_root_override);
end

if strlength(string(cfg.paths.source_eeg_root_override)) > 0
    cfg.paths.source_eeg_root = string(cfg.paths.source_eeg_root_override);
end

if strlength(string(cfg.paths.source_beh_root_override)) > 0
    cfg.paths.source_beh_root = string(cfg.paths.source_beh_root_override);
end

% =========================================================================
% SUBJECTS
% =========================================================================
cfg.subjects = struct();
cfg.subjects.list   = [ ]; % explicit subject list, e.g. {'211','212'}, leave 
% empty to autodetect from source_eeg_root using cfg.constants.valid_sub_id_regex
cfg.subjects.min_id = []; % process all subjects with a higher ID than...
% numeric/string ID, no lower cutoff if left empty 

% =========================================================================
% PARALLEL
% =========================================================================
cfg.parallel = struct();
cfg.parallel.enable         = true;   % allow parallel execution
cfg.parallel.force_workers  = 20;     % explicit worker count, to keep peace with IT admins. If left empty, will use all available cores.
% for automatic determination (recommended)

% =========================================================================
% STEP TOGGLES
% =========================================================================
cfg.steps = struct();

cfg.steps.enable_downstream_rerun = true; % if true, sets all downstream steps 
% to run when a step is set to run. E.g. if Step 03 is set to run, but output 
% for steps 04-06 already exists from a previous run, Steps 04-06 will 
% automatically also be set to run

cfg.steps.prep_01_bids_formatting = struct( ...
    'run', true, ...                % Step 01 creates/updates cfg.paths.bids_root from source_*_root
    'overwrite_mode', "delete", ...
    'overwrite_if_older_than', "");

cfg.steps.prep_02_triggerfix = struct( ...
    'run', true, ...
    'overwrite_mode', "delete", ...
    'overwrite_if_older_than', "");

cfg.steps.prep_03_until_ica = struct( ...
    'run', true, ...
    'overwrite_mode', "delete", ...
    'overwrite_if_older_than', "");

cfg.steps.prep_04_ica = struct( ...
    'run', true, ...
    'overwrite_mode', "delete", ...
    'overwrite_if_older_than', "");

cfg.steps.prep_05_after_ica = struct( ...
    'run', true, ...
    'overwrite_mode', "delete", ...
    'overwrite_if_older_than', "");

cfg.steps.prep_06_epoching = struct( ...
    'run', true, ...
    'overwrite_mode', "delete", ...
    'overwrite_if_older_than', "");

% =========================================================================
% STEP FUNCTION HANDLES -- do not edit, will be resolved at runtime
% =========================================================================
cfg.step_fns = struct();
cfg.step_fns.prep_01_bids_formatting = str2func(char(cfg.pipeline.step_prefix + "_prep01_bids_formatting"));
cfg.step_fns.prep_02_triggerfix      = str2func(char(cfg.pipeline.step_prefix + "_prep02_triggerfix"));
cfg.step_fns.prep_03_until_ica       = str2func(char(cfg.pipeline.step_prefix + "_prep03_untilica"));
cfg.step_fns.prep_04_ica             = str2func(char(cfg.pipeline.step_prefix + "_prep04_ica"));
cfg.step_fns.prep_05_after_ica       = str2func(char(cfg.pipeline.step_prefix + "_prep05_after_ica"));
cfg.step_fns.prep_06_epoching        = str2func(char(cfg.pipeline.step_prefix + "_prep06_epoching"));

% =========================================================================
% STEP 01: BIDS FORMATTING
% Step behavior only. Input/output locations come from cfg.paths.
% =========================================================================
cfg.prep_01 = struct();

cfg.prep_01.do_eeg = true;  % copy/rename raw BrainVision EEG into BIDS
cfg.prep_01.do_beh = false; % copy project-specific CF behavior files # HOWTO: what are CF files? specific format needed?

cfg.prep_01.try_eeglab_bids_export           = false; % additionally try pop_exportbids after copying; doesn't work, leave disabled
cfg.prep_01.write_readme_if_exporter_did_not = true; % write README if exporter did not create dataset-level description

cfg.prep_01.copy_eeg_sidecar_log_to_events = false; % copy project-specific CF log as *_events.log

cfg.prep_01.raw_eeg_regex = '^B_(\d{3})(?:_(\d{3}))?\.vhdr$'; % raw EEG 
% filename pattern: Example: 
% ^              start of the filename
% B_             literal text: B_
% (\d{3})        capture group 1: exactly three digits, e.g. 001 or 123 = subject ID
% (?: ... )      non-capturing group; used only for grouping, not extracted as separate output
% _(\d{3})       underscore plus exactly three digits = optional run ID
% ?              makes the whole previous group optional
% \.             literal dot before the file extension
% vhdr           literal file extension text: vhdr
% $              end of the filename
% so in the example B_001.vhdr, B_001_002.vhdr would match but not B_1.vhdr
% B_0001.vhdr, A_001.vhdr B_001_02.vhdr B_001.eeg, ... 

cfg.prep_01.existing_bids_vhdr_regex = ...
    '^sub-(\d+)_ses-(\d+)_task-([A-Za-z0-9]+)(?:_run-(\d+))?_eeg\.vhdr$'; % existing BIDS EEG header pattern used when do_eeg=false
   
cfg.prep_01.session_label = cfg.bids.session_label; % get session label defined in project identity
cfg.prep_01.task_label    = cfg.bids.task_label;    % get task label defined in project identity

% =========================================================================
% STEP 02: TRIGGERFIX
% =========================================================================

% This section can be adjusted to paradigms including no phase-specific
% structure and to paradigms with specific phases:

% A) PARADIGM WITHOUT PHASES (should be used when there are no specific start markers for individual phases)
%   Settings:
%    - use_gating_from_start_markers = false
%    - name triggers per category 
%    - blocking.count_scope = "global"
%    - fill triggerfix.blocking.category to rename triggers
%    - set enable_first_match_replacements = false
%    - phase_strategy as trigger_only (or block_only)
%    - phase-specific renaming empty
%
% B) PARADIGM WITH PHASES
%    - use_gating_from_start_markers = true
%    - Fill gates.start_markers. accordingly with phase numbers and start
%       markers, e.g. 'phase1',    "S 92", ...
%    - name triggers per category
%    - blocking.count_scope = "phase"
%    - adjust triggerfix.blocking.category to the right number of
%      categories but leave new trigger names empty
%    - optional: enable_first_match_replacements = true, and set
%      first_match_replacements to correct phase-specific trigger
%    - phase_strategy "trigger_then_block_fallback"
%    - enter phase-specific new codes   


cfg.paradigms.myParadigm.triggerfix = struct();

% cfg.steps.prep_02_triggerfix.run_raw_order_qc = false; 
% %find behavior log file (only if you want to use RAW QC triggerfix --> DO NOT USE at the moment)
% %if false skip Raw QC block and go on with 1) Phases
% 
% %%% RAW QC Trigger from Behavior files 
% % (WARNING: structure implemented, but not running yet, DO NOT USE)
% cfg.paradigms.myParadigm.triggerfix.run_raw_order_qc = false;
% 
% %Enter column labels from behavioral data sets
% cfg.paradigms.myParadigm.triggerfix.behavior_log_column_event_type = ' ';
% cfg.paradigms.myParadigm.triggerfix.behavior_log_column_code       = ' ';
% cfg.paradigms.myParadigm.triggerfix.behavior_log_column_time       = ' ';
% cfg.paradigms.myParadigm.triggerfix.behavior_log_time_unit         = " ";
% 
% cfg.paradigms.myParadigm.triggerfix.raw_qc_keep_tokens      = [" "," "," "," "," "," "," "]; %list of trigger
% cfg.paradigms.myParadigm.triggerfix.raw_qc_bin_size_s       = 1;
% cfg.paradigms.myParadigm.triggerfix.raw_qc_max_rows         = 20000;
% cfg.paradigms.myParadigm.triggerfix.raw_qc_write_csv_on_ok  = false;
% 
% %Event types
% cfg.paradigms.myParadigm.triggerfix.behavior_log_map = { ...
%     '', '',      ' '; ...
%     ' ', ' ',  ''; ...
% };
% 
% cfg.paradigms.myParadigm.triggerfix.allow_multiple_runs = false;
% cfg.paradigms.myParadigm.triggerfix.multiple_vhdr_policy = " "; % most_recent
% cfg.paradigms.myParadigm.triggerfix.input_vhdr_pattern = "";  
% cfg.paradigms.myParadigm.triggerfix.use_explicit_chanlist = false;
% cfg.paradigms.myParadigm.triggerfix.explicit_chanlist = 1:66;
% 
% %labels
% cfg.paradigms.myParadigm.triggerfix.task_label = cfg.bids.task_label;
% cfg.paradigms.myParadigm.triggerfix.session_label = cfg.bids.session_label;
% 
% %%% optional output QC override
% cfg.paradigms.myParadigm.triggerfix.qc_out_dir = "";

%%% 1) Phases: Enter start markers for your phases if use_gating_from_start_markers = true

cfg.paradigms.myParadigm.triggerfix.use_gating_from_start_markers = false; % true if there are phases, false if there are no phases in your paradigm
%If true, you need to enter start markers for your phases below (see point 1) Phases).

cfg.paradigms.myParadigm.triggerfix.gates = struct();
cfg.paradigms.myParadigm.triggerfix.gates.start_markers = struct( ...
    'phase1',    " ", ...
    'phase2', " ");

%%% 2) Name Triggers per category in your paradigm
% add more blocks if necessary
cfg.paradigms.myParadigm.triggerfix.raw_triggers = struct();
cfg.paradigms.myParadigm.triggerfix.raw_triggers.rawA = " ";   
cfg.paradigms.myParadigm.triggerfix.raw_triggers.rawB = " ";   
cfg.paradigms.myParadigm.triggerfix.raw_triggers.rawC = " ";   
cfg.paradigms.myParadigm.triggerfix.raw_triggers.rawD = " ";   


%%% 3) Blocking/Counting:renaming and counting event triggers per phase
cfg.paradigms.myParadigm.triggerfix.blocking = struct();
cfg.paradigms.myParadigm.triggerfix.blocking.count_scope = " "; 
% global for counting across all trials (e.g. with your paradigm does not include phases); 
% "phase" for counting within phases if cfg.paradigms.myParadigm.triggerfix.use_gating_from_start_markers = true and if cfg.paradigms.myParadigm.triggerfix.gates.start_markers are set accordingly.
% Starting markers themselves are not counted and not renamed;

%Old and new names for trigger renaming; see phase-specific trigger
%renaming below
%Add more blocks if necessary!
%'n' is the amount of triggers that should be renamed: eg. 10 means that
%the first 10 triggers found are renamed (if counted individually for each phase, it refers to counting within the phase and not globally). 
% Inf for all triggers
cfg.paradigms.myParadigm.triggerfix.blocking.categoryA = struct();
cfg.paradigms.myParadigm.triggerfix.blocking.categoryA.raw_key = "rawA";
cfg.paradigms.myParadigm.triggerfix.blocking.categoryA.blocks = { ...
    struct('n', inf, 'code', " ")  ...
};

cfg.paradigms.myParadigm.triggerfix.blocking.categoryB = struct();
cfg.paradigms.myParadigm.triggerfix.blocking.categoryB.raw_key = "rawB";
cfg.paradigms.myParadigm.triggerfix.blocking.categoryB.blocks = { ...
    struct('n', inf, 'code', " ")  ...
};

cfg.paradigms.myParadigm.triggerfix.blocking.categoryC = struct();
cfg.paradigms.myParadigm.triggerfix.blocking.categoryC.raw_key = "rawC";
cfg.paradigms.myParadigm.triggerfix.blocking.categoryC.blocks = { ...
    struct('n', inf, 'code', " ")  ...
};
cfg.paradigms.myParadigm.triggerfix.blocking.categoryD = struct();
cfg.paradigms.myParadigm.triggerfix.blocking.categoryD.raw_key = "rawD";
cfg.paradigms.myParadigm.triggerfix.blocking.categoryD.blocks = { ...
    struct('n', inf, 'code', " ")  ...
};

cfg.paradigms.myParadigm.triggerfix.enable_first_match_replacements = false; %true if you want to replace the first accuring trigger;
%false if the same renaming rule applies for all triggers of the same category within a phase
%false if paradigm without phases

cfg.paradigms.myParadigm.triggerfix.first_match_replacements = {
    struct('match_code'," ", 'replace_code'," ",    'max_replacements',1),
    struct('match_code'," ", 'replace_code'," ",'max_replacements',1)
};

cfg.paradigms.myParadigm.triggerfix.phase_strategy = " "; 
%"trigger_only" remapping only following start trigger; useful if triggers
%have already been checked or corrected before pipeline
%"block_only" remapping following counting within blocks; useful if
% start triggers are missing
% "trigger_then_block_fallback" remapping following start triggers, if less
% than min_remap switch to block counting; can also be used for paradigms
% without phases

%%% 4) Phase-specific trigger renaming 
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming = false; 

% Enter new codes after renaming per phase and category
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules = struct();

cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase1.categoryA.code = " ";
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase1.categoryB.code = " ";
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase1.categoryC.code = " ";
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase1.categoryD.code = " ";

cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase2.categoryA.code = " ";
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase2.categoryB.code = " ";
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase2.categoryC.code = " ";
cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.phase2.categoryD.code = " ";

cfg.paradigms.myParadigm.triggerfix.trigger_phase_min_remaps = 5; % minimal number of expected remaps in total
cfg.paradigms.myParadigm.triggerfix.trigger_phase_min_phases_with_remaps = 2; %minimal number of extpected remaps per phase
cfg.paradigms.myParadigm.triggerfix.trigger_phase_max_phase_share = 0.80; % max percentage of remaps in phase, if higher start triggers not plausible and fallback to blocks


% =========================================================================
% STEP 03: UNTIL ICA
% =========================================================================
cfg.prep_03 = struct();

% -------------------------------------------------------------------------
% SUMMARY OPTION
% -------------------------------------------------------------------------
% ICA-training QC: Save a summary of how many epochs were rejected from the ICA training
% dataset and how many remain.
cfg.prep_03.write_run_summary_table = true;

% -------------------------------------------------------------------------
% CROP DATASET (OPTIONAL)
% -------------------------------------------------------------------------
% Keep one continuous section between a start and an end marker.
% Remove data before and after this section.
% Pauses within the section are kept.

% Enable cropping. When false, the crop settings below are ignored.
cfg.prep_03.crop_to_task_markers = false;

% If a marker is missing, use the corresponding recording boundary:
% first sample for a missing start, last sample for a missing end.
% Existing markers are kept. If both are missing, keep the full recording.
% If false, stop Step 03 when either marker is missing.
cfg.prep_03.substitute_crop_markers = true;

% Event codes defining the section to keep.
% For each boundary, use the first matching entry in EEG.event.
% Multiple alternative codes are supported, e.g. {'S 91', 'S 92'}, to crop from first occurence of either marker.
% The end must occur after the selected start.
cfg.prep_03.crop_start_marker = 'S 91';
cfg.prep_03.crop_end_marker   = 'S 97';

% Additional seconds to keep [before start, after end].
% The window is limited to the available recording.
cfg.prep_03.crop_padding_sec = [0 0];

% -------------------------------------------------------------------------
% IMPORTANT make sure these include your channel labels for AUX/EOG, otherwise channels will be included as EEG in ICA
% -------------------------------------------------------------------------
cfg.prep_03.eog_channel_labels     = {'IO1','IO2','LO1','LO2'}; % ocular channels (detecting eye movements/blinks)
cfg.prep_03.scr_channel_labels     = {'EDA', 'SCR', 'GSR_MR_100_xx'}; % skin conductance response channels
cfg.prep_03.startle_channel_labels = {'Startle'}; % Startle response channels
cfg.prep_03.ekg_channel_labels     = {'ECG', 'EKG'}; % Heart rate channels

cfg.prep_03.downsample_hz = 250; % downsample frequency

% -------------------------------------------------------------------------
% Filter settings
% -------------------------------------------------------------------------
cfg.prep_03.highpass_hz          = 0.1; % set lower if you are interested in low-frequency components
cfg.prep_03.lowpass_hz           = 40; % set higher if you are interested in higher frequencies
cfg.prep_03.ica_prep_highpass_hz = 1; % only for the ica training set; leave if possible as ICA is sensitive towards slow drifts

% -------------------------------------------------------------------------
% Bad channel detection and interpolation
% -------------------------------------------------------------------------
cfg.prep_03.bad_channel_detection_method = "clean_rawdata"; % "clean_rawdata" | "pop_rejchan" | "off"
% Note: clean_rawdata used to be called "auto"

% Flat/invalid EEG-channel detection is applied exactly once, independently
% of the selected bad-channel backend and always after cropping. AUX channels
% are only removed if they are non-finite or completely constant.
cfg.prep_03.flat_channel_detection = struct();
cfg.prep_03.flat_channel_detection.enable = true;
cfg.prep_03.flat_channel_detection.mode = "cumulative_fraction"; % "cumulative_fraction" | "continuous_seconds"
cfg.prep_03.flat_channel_detection.max_flat_fraction = 0.10; % >=10% of complete post-crop recording, not necessarily continuously
cfg.prep_03.flat_channel_detection.continuous_flat_sec = 5; % only used for mode="continuous_seconds"
cfg.prep_03.flat_channel_detection.step_tolerance_uV = 0;

% Only used for bad_channel_detection_method = "clean_rawdata". Its own
% flatline criterion is disabled because flatness is already checked above.
cfg.prep_03.clean_rawdata_channel_corr_threshold = 0.80;

% Only used for bad_channel_detection_method = "pop_rejchan"
cfg.prep_03.pop_rejchan_z_threshold  = 2.5;
cfg.prep_03.pop_rejchan_freqrange_hz = [1, cfg.prep_03.lowpass_hz + 10];

% Applied to final bad EEG channel list
cfg.prep_03.interpolate_bad_channels_before_ica = true;
cfg.prep_03.interp_method = 'spherical';

% Step 03 debug/intermediate exports.
% Master switch. Default false = no Step 03 intermediate debug files.
% If true, the individual switches below decide which stages are written.
cfg.prep_03.save_intermediate_steps = false;

% Save after final bad EEG channel list has been applied.
% In this pipeline, bad EEG channels are usually interpolated rather than
% permanently removed.
cfg.prep_03.save_intermediate_after_bad_channel_rejection = true;

% Save after rereferencing.
cfg.prep_03.save_intermediate_after_rereference = true;

% Save after high-pass filtering.
cfg.prep_03.save_intermediate_after_highpass = true;

% Save after low-pass filtering.
cfg.prep_03.save_intermediate_after_lowpass = true;

cfg.prep_03.intermediate_savemode = 'twofiles';

% -------------------------------------------------------------------------
% Re-Referencing
% -------------------------------------------------------------------------
% "keep"    = do not rereference in Step 03
% "avg"     = average reference
% "mastoid" = rereference to mastoids listed below
%
% Default should usually be "avg" to match the preprocessing handout.
% Keep cfg.prep_06.reference_mode = "keep" unless you intentionally want a
% second rereference during epoching.
cfg.prep_03.reference_mode            = "avg";  % "keep" | "avg" | "mastoid"
cfg.prep_03.reference_exclude_non_eeg = true;   % do not rereference EOG/SCR/Startle/EKG
cfg.prep_03.mastoid_channel_labels    = {'T9','T10'};

% -------------------------------------------------------------------------
% Line Noise Filtering
% -------------------------------------------------------------------------

cfg.prep_03.line_noise_method         = "zapline"; % "zapline" | "pop_cleanline" | "notch" | "off"
cfg.prep_03.line_noise_frequencies_hz = [50 100]; % in europe, set to [60 120] in US
cfg.prep_03.line_noise_ratio          = 1;
cfg.prep_03.line_noise_fb_cleanline   = true; % use cleanline if zapline fails to remove line noise (# TODO: criterion to be determined)
cfg.prep_03.line_noise_fb_notch       = false; % if fallback is used, apply notch filter to line noise frequencies if both zapline and cleanline fail

cfg.prep_03.pop_cleanline_bandwidth_hz      = 4;
cfg.prep_03.pop_cleanline_p_value           = 0.01;
cfg.prep_03.pop_cleanline_scanforlines      = true; % leave on usually as it improves line noise detection
cfg.prep_03.pop_cleanline_winsize_sec       = 2;
cfg.prep_03.pop_cleanline_winstep_sec       = 1;
cfg.prep_03.pop_cleanline_tau               = 50;
cfg.prep_03.pop_cleanline_pad               = 4;
cfg.prep_03.pop_cleanline_taperbandwidth_hz = 4;
cfg.prep_03.pop_cleanline_norm_spectrum     = 0;
cfg.prep_03.pop_cleanline_computepower      = 0;
cfg.prep_03.pop_cleanline_verbose           = false;

cfg.prep_03.ica_prep_epoch_rejection_method = "erplab"; % "erplab" | "faster_ptp" | "mad_variance" | "none"
% ERPLAB ICA-prep rejection.
% Same criteria as final Step 06 rejection, but more lenient:
%   final:     +/-200 uV, 50 uV step, 100 ms flatline
%   ICA-prep:  +/-300 uV, 75 uV step, 200 ms flatline
cfg.prep_03.ica_prep_erplab_epoch_rejection = struct();

% Check only EEG channels, not EOG/SCR/Startle/EKG.
cfg.prep_03.ica_prep_erplab_epoch_rejection.channel_scope = "eeg";

% [] = whole ICA-training regepoch.
cfg.prep_03.ica_prep_erplab_epoch_rejection.twindow_ms = [];

cfg.prep_03.ica_prep_erplab_epoch_rejection.clear_existing_flags = true;

% 1) Exclude very large voltages.
cfg.prep_03.ica_prep_erplab_epoch_rejection.use_extreme_voltage = true;
cfg.prep_03.ica_prep_erplab_epoch_rejection.extreme_voltage_uV  = 300;
cfg.prep_03.ica_prep_erplab_epoch_rejection.flag_extreme_voltage = 1;

% 2) Exclude large sample-to-sample voltage jumps.
cfg.prep_03.ica_prep_erplab_epoch_rejection.use_sample_diff = true;
cfg.prep_03.ica_prep_erplab_epoch_rejection.sample_diff_uV  = 75;
cfg.prep_03.ica_prep_erplab_epoch_rejection.flag_sample_diff = 2;

% 3) Optional flatline/blocking rejection. This may reject unexpectedly
% many epochs, so it is off by default and should be enabled deliberately.
cfg.prep_03.ica_prep_erplab_epoch_rejection.use_flatline = false;
cfg.prep_03.ica_prep_erplab_epoch_rejection.flatline_tolerance_uV = 0.5;
cfg.prep_03.ica_prep_erplab_epoch_rejection.flatline_duration_ms  = 200;
cfg.prep_03.ica_prep_erplab_epoch_rejection.flag_flatline = 3;

cfg.prep_03.ica_prep_erplab_epoch_rejection.review = "off";
cfg.prep_03.ica_prep_erplab_epoch_rejection.history = "off";
cfg.prep_03.ica_prep_erplab_epoch_rejection.lowpass_hz = -1;

% MAD ICA-prep rejection settings.
% Only used when cfg.prep_03.ica_prep_epoch_rejection_method == "mad_variance".
cfg.prep_03.ica_prep_mad_z_threshold = 3;
cfg.prep_03.ica_prep_mad_use_logvar  = true;
cfg.prep_03.ica_prep_max_reject_prop = 1.00;

% -------------------------------------------------------------------------
% FASTER/PTP ICA-prep epoch rejection
% Only used when cfg.prep_03.ica_prep_epoch_rejection_method == "faster_ptp".
%
% ICA-prep rejection should usually be more lenient than final Step 06
% rejection because it only cleans the temporary ICA-training dataset.
%
% To use FASTER only: set use_faster=true and use_ptp=false.
% To use PTP only:    set use_faster=false and use_ptp=true.
% To use both:        set both to true.
% -------------------------------------------------------------------------
cfg.prep_03.ica_prep_faster_ptp_epoch_rejection = struct();

cfg.prep_03.ica_prep_faster_ptp_epoch_rejection.use_faster   = true;
cfg.prep_03.ica_prep_faster_ptp_epoch_rejection.faster_z     = 4;
cfg.prep_03.ica_prep_faster_ptp_epoch_rejection.use_robust_z = true;

cfg.prep_03.ica_prep_faster_ptp_epoch_rejection.use_ptp       = true;
cfg.prep_03.ica_prep_faster_ptp_epoch_rejection.ptp_uV_thresh = 100;

% 1.00 means disabled. Example: 0.50 would stop Step 03 if >50% of
% ICA-training epochs are removed.
cfg.prep_03.ica_prep_faster_ptp_epoch_rejection.max_reject_prop = 1.00;

% =========================================================================
% STEP 04: ICA
% =========================================================================
cfg.prep_04 = struct();

cfg.prep_04.ica_method                   = "runica"; % "runica" | "amica"
cfg.prep_04.use_extended_infomax         = true;
cfg.prep_04.interrupt_ica                = 'off';
cfg.prep_04.use_pca_rank_if_interpolated = true;
cfg.prep_04.amica_require_no_spaces_on_windows = true;
cfg.prep_04.ica_channel_scope = "eeg_eog";
% Step 04 derives the task filter from cfg.bids.task_label and requires an
% exact *_forica.set / *_preica.set pair for every processed run.

% AMICA is intentionally fixed to one model in Step 04. Increasing the
% mixture-model count is not exposed here. 
% max_iter is an upper bound. Reaching it with otherwise valid output creates
% a warning rather than rejection. Raising it increases worst-case runtime;
% invalid/non-finite output remains a hard failure.
cfg.prep_04.amica_max_iter = 2000;
cfg.prep_04.amica_write_update_norm_history = false;
cfg.prep_04.amica_check_convergence = true;
cfg.prep_04.amica_fail_on_nonconvergence = true;
cfg.prep_04.amica_convergence_min_iterations = 50;
cfg.prep_04.amica_convergence_tail_window = 20;
cfg.prep_04.amica_keep_tmp_on_qc_failure = false;
cfg.prep_04.write_run_qc_table = false;
cfg.prep_04.write_subject_qc_table = true;
cfg.prep_04.qc_table_delimiter = ';';

% =========================================================================
% STEP 05: AFTER ICA / ICLABEL
% =========================================================================
cfg.prep_05 = struct();

cfg.prep_05.clear_subject_ica_comps_dir = true; % remove existing QA PNGs only
% for the current subject/task/run before exporting replacements

% Every named ICLabel artifact class is independently configurable. "Other"
% and low-Brain are broader rules and therefore remain opt-in. A HIGHER
% probability threshold removes FEWER components; a lower threshold removes
% more. Inspect validation-sample component tables and topographies before
% changing values for a cohort.
cfg.prep_05.iclabel_remove_eye           = true;
cfg.prep_05.iclabel_remove_muscle        = true;
cfg.prep_05.iclabel_remove_heart         = true;
cfg.prep_05.iclabel_remove_linenoise     = true;
cfg.prep_05.iclabel_remove_channoise     = true;
cfg.prep_05.iclabel_remove_other         = false;
cfg.prep_05.iclabel_remove_low_brain     = false;

cfg.prep_05.iclabel_eye_remove_thr       = 0.85;
cfg.prep_05.iclabel_muscle_remove_thr    = 0.85;
cfg.prep_05.iclabel_heart_remove_thr     = 0.85;
cfg.prep_05.iclabel_linenoise_remove_thr = 0.85;
cfg.prep_05.iclabel_channoise_remove_thr = 0.85;
cfg.prep_05.iclabel_other_remove_thr     = 1.01;
cfg.prep_05.iclabel_brain_min_keep_thr   = 0.00;

cfg.prep_05.save_ic_topos_png   = true;
cfg.prep_05.iclabel_edge_margin = 0.10;

cfg.prep_05.ic_topo_dpi        = 300;
cfg.prep_05.ic_topo_fig_cm     = [0 0 18 18];
cfg.prep_05.ic_topo_electrodes = 'off';

%--------------------------------------------------------------------------
% SUMMARY OPTION
%--------------------------------------------------------------------------
% Save QC tables for ICA component rejection. The component table contains
% ICLabel probabilities and the remove/keep decision for each component.
% Run- and subject-level summaries report how many components were removed
% and which rejection criteria were responsible. All-subject summaries are
% refreshed automatically after all subjects have finished.

% Two-level before/after signal QC. Warnings retain the cleaned dataset.
% Extreme metrics are deliberately very broad; one extreme metric still only
% warns. A signal-QC failure requires at least two simultaneous extreme
% metrics. Invalid/non-finite output remains an immediate technical failure.
% "eeg" excludes EOG from the comparison.
cfg.prep_05.signal_qc_enable = true;
cfg.prep_05.signal_qc_fail_on_violation = true;
cfg.prep_05.signal_qc_channel_scope = "eeg"; % "eeg" | "all"
cfg.prep_05.signal_qc_max_prop_ic_removed = 0.95;
cfg.prep_05.signal_qc_min_remaining_components = 2;
cfg.prep_05.signal_qc_min_median_channel_correlation = 0.80;
cfg.prep_05.signal_qc_max_relative_change_rms = 0.75;
cfg.prep_05.signal_qc_min_rms_ratio = 0.50;
cfg.prep_05.signal_qc_max_rms_ratio = 1.10;
cfg.prep_05.signal_qc_hard_min_median_channel_correlation = 0.10;
cfg.prep_05.signal_qc_hard_max_relative_change_rms = 10.00;
cfg.prep_05.signal_qc_hard_min_rms_ratio = 0.10;
cfg.prep_05.signal_qc_hard_max_rms_ratio = 10.00;
cfg.prep_05.signal_qc_min_extreme_metrics_to_fail = 2; % independent problem domains, not correlated raw metrics
cfg.prep_05.signal_qc_fail_on_nonfinite = true;
cfg.prep_05.signal_qc_fail_on_flat_channels = true;
cfg.prep_05.signal_qc_flat_std_epsilon = 1e-8;

% Optional validation-sample diagnostic for RUNICA and AMICA. MI is disabled
% in routine runs because it has no universal decision threshold.
cfg.prep_05.compute_decomposition_qc = false;
cfg.prep_05.decomposition_qc_max_samples = 5000;
cfg.prep_05.decomposition_qc_mi_bins = 20;

cfg.prep_05.write_component_table       = true; % table with one row per ICA 
% component: ICLabel probabilities and remove/keep decision
cfg.prep_05.write_run_summary_table     = true; % optional duplicate per-run summary
cfg.prep_05.write_subject_summary_table = true; % one subject-level summary 
% file combining all run summaries for this subject
cfg.prep_05.qc_table_delimiter          = ';';

% =========================================================================
% STEP 06: EPOCHING + FINAL ARTIFACT REJECTION
% =========================================================================
cfg.prep_06 = struct();

% -------------------------------------------------------------------------
% General mode selection
% -------------------------------------------------------------------------
cfg.prep_06.epoching_mode  = "baseline";   % "baseline" | "event_locked"
cfg.prep_06.overwrite_mode = "";

% -------------------------------------------------------------------------
% Saving
% -------------------------------------------------------------------------
cfg.prep_06.save_final_only         = true; % save only one file per step
cfg.prep_06.save_intermediate_steps = false; % save output files after each 
% preprocessing sub-step (not fully implemented yet; if you require this please 
% contact saskia.wilken@uni-hamburg.de)

% -------------------------------------------------------------------------
% Referencing in Step 06
% Default is KEEP because rereferencing usually already happened in Step 03.
% Only change this if you explicitly want a second rereference here.
% -------------------------------------------------------------------------
cfg.prep_06.reference_mode         = "keep";   % "keep" | "avg" | "mastoid"
cfg.prep_06.mastoid_channel_labels = {'T9','T10'};

% -------------------------------------------------------------------------
% Baseline correction
% Mainly relevant for event_locked ERP-style epochs.
% Usually keep false for continuous/resting-state baseline regepochs.
% -------------------------------------------------------------------------
cfg.prep_06.do_baseline_correction = false;
cfg.prep_06.base_start_ms          = -200;
cfg.prep_06.base_end_ms            = 0;

% -------------------------------------------------------------------------
% EVENT-LOCKED mode settings
% Used only when cfg.prep_06.epoching_mode == "event_locked"
% -------------------------------------------------------------------------
cfg.prep_06.events_phase = {}; % enter here triggers that mark where your epochs shoudl start
% example entries: { ...
    % 'S 201','S 241', ...
    % 'S 2021','S 2421','S 2022','S 2422', ...
    % 'S 203','S 213','S 223','S 233','S 243', ...
    % 'S 2041','S 2441','S 2042','S 2442','S 2043','S 2443', ...
    % 'S 205','S 245' ...
    % }
% To propagate freely chosen event-locked condition names into the QC tables,
% group these event codes in min_trials_per_condition_codes below.

cfg.prep_06.epoch_start_s = -0.4; % start of epoch relative to event in seconds
cfg.prep_06.epoch_end_s   =  2.6; % end of epoch relative to event in seconds

% -------------------------------------------------------------------------
% BASELINE mode settings
% Used only when cfg.prep_06.epoching_mode == "baseline"
% -------------------------------------------------------------------------
cfg.prep_06.regepoch_length_sec = 10; % length of epochs to be created
cfg.prep_06.regepoch_step_sec = 10; % seconds between starts of consecutive 
% regepochs; same as length = non-overlapping epochs without gaps

cfg.prep_06.baseline_has_conditions = false;

% Ignored while baseline_has_conditions=false. If enabled, define arbitrary
% names as rows of {condition_name, marker prefixes starting that condition}.
% These names are propagated to output filenames and QC tables, for example:
% cfg.prep_06.baseline_condition_definitions = { ...
%     'condition_a', {'S 11','S 12'}; ...
%     'condition_b', {'S 21','S 22'} ...
%     };
cfg.prep_06.baseline_condition_definitions = {};
cfg.prep_06.baseline_start_condition = "";
cfg.prep_06.baseline_end_markers = {};
cfg.prep_06.baseline_end_condition = "";

% -------------------------------------------------------------------------
% Artifact rejection
% -------------------------------------------------------------------------
cfg.prep_06.do_artifact_rejection = true; %# HOWTO: do we have suggestions when to use which?

% Optional first-pass hard absolute-amplitude rejection.
% Usually keep this false when using ERPLAB, because ERPLAB's extreme-voltage
% rule can implement the same kind of threshold.
cfg.prep_06.do_initial_hard_threshold_rejection = false;
cfg.prep_06.initial_hard_threshold_uv           = 100;

% Select exactly one final epoch-rejection method.
%
%   "erplab"       = use cfg.prep_06.erplab_epoch_rejection (what we agreed
%   on in the kolloq)
%   "faster_ptp"   = use cfg.prep_06.faster_ptp_epoch_rejection
%   "mad_variance" = use cfg.prep_06.mad_z_threshold / mad_use_logvar
%   "none"         = skip final epoch rejection
%
cfg.prep_06.epoch_rejection_method = "erplab";  % "erplab" | "faster_ptp" | "mad_variance" | "none"

% Subject-level exclusion after epoch rejection.
% 1 means disabled. Example: 0.50 would exclude subjects with >50% rejected epochs.
cfg.prep_06.max_reject_prop = 1;

% Warning only (no exclusion): report all subjects with >25% rejected epochs
% once more at the very end of the console output and in the master run log.
cfg.prep_06.warn_if_reject_prop_gt = 0.25;

% -------------------------------------------------------------------------
% ERPLAB epoch rejection
% Only used when cfg.prep_06.epoch_rejection_method == "erplab".
% -------------------------------------------------------------------------
cfg.prep_06.erplab_epoch_rejection = struct();

cfg.prep_06.erplab_epoch_rejection.channel_scope = "eeg";
cfg.prep_06.erplab_epoch_rejection.twindow_ms = [];
cfg.prep_06.erplab_epoch_rejection.clear_existing_flags = true;

cfg.prep_06.erplab_epoch_rejection.use_extreme_voltage = true;
cfg.prep_06.erplab_epoch_rejection.extreme_voltage_uV  = 100;
cfg.prep_06.erplab_epoch_rejection.flag_extreme_voltage = 1;

cfg.prep_06.erplab_epoch_rejection.use_sample_diff = true;
cfg.prep_06.erplab_epoch_rejection.sample_diff_uV  = 50;
cfg.prep_06.erplab_epoch_rejection.flag_sample_diff = 2;

% Optional only: flatline rejection may reject unexpectedly many epochs.
% Keep false unless its effect has been inspected for the current dataset.
cfg.prep_06.erplab_epoch_rejection.use_flatline = false;
cfg.prep_06.erplab_epoch_rejection.flatline_tolerance_uV = 0.5;
cfg.prep_06.erplab_epoch_rejection.flatline_duration_ms  = 100;
cfg.prep_06.erplab_epoch_rejection.flag_flatline = 3;

cfg.prep_06.erplab_epoch_rejection.review = "off";
cfg.prep_06.erplab_epoch_rejection.history = "off";
cfg.prep_06.erplab_epoch_rejection.lowpass_hz = -1;

% -------------------------------------------------------------------------
% FASTER/PTP epoch rejection
% Only used when cfg.prep_06.epoch_rejection_method == "faster_ptp".
%
% To use FASTER only: set use_faster=true and use_ptp=false.
% To use PTP only:    set use_faster=false and use_ptp=true.
% To use both:        set both to true.
% -------------------------------------------------------------------------
cfg.prep_06.faster_ptp_epoch_rejection = struct();

cfg.prep_06.faster_ptp_epoch_rejection.use_faster    = true;
cfg.prep_06.faster_ptp_epoch_rejection.faster_z      = 3;
cfg.prep_06.faster_ptp_epoch_rejection.use_robust_z  = false;

cfg.prep_06.faster_ptp_epoch_rejection.use_ptp       = true;
cfg.prep_06.faster_ptp_epoch_rejection.ptp_uV_thresh = 100;

% -------------------------------------------------------------------------
% MAD variance epoch rejection
% Only used when cfg.prep_06.epoch_rejection_method == "mad_variance".
% -------------------------------------------------------------------------
cfg.prep_06.mad_z_threshold = 3;
cfg.prep_06.mad_use_logvar  = true;

% -------------------------------------------------------------------------
% Reject datasets if too few valid epochs/trials remain.
%
% event_locked:
%   checks minimum trial counts for the event-code groups listed below.
%
% baseline:
%   checks minimum valid regepochs separately for every configured condition.
%   Without conditions, the check applies once to the complete recording.
%   The code list below is ignored in baseline mode.
% -------------------------------------------------------------------------
cfg.prep_06.min_trials_per_condition_enable      = true; 
cfg.prep_06.min_trials_per_condition_min_n       = 3; % min num of trials in 
% each condition so participant is not excluded. Suggestion: at least 10,
% but you might need to be pragmatic. 
cfg.prep_06.min_trials_per_condition_zero_tol_ms = 2; % jitter allowed around trigger
cfg.prep_06.min_trials_per_condition_codes = {}; % adjust this to conditions 
% in your setup that should have at least min_trials_per_condition
% enter like this: { ...
%    'condition_name', {'S XXX','S XXY'}; ...
%    }

% -------------------------------------------------------------------------
% SUMMARY OPTION
% -------------------------------------------------------------------------
% Save QC summaries for final epoch rejection. The tables report the number
% of total, rejected and remaining epochs, including the rejection method
% and individual rejection reasons. Subject- and all-subject summaries are
% created automatically to provide an overview across runs and subjects.

% Step 06 also refreshes the corresponding all-subject summaries automatically.
cfg.prep_06.write_run_summary_table     = true;
cfg.prep_06.write_subject_summary_table = true;
cfg.prep_06.qc_table_delimiter          = ';';

end
