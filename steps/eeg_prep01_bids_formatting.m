function step_out = eeg_prep01_bids_formatting(subj_id, cfg, paths, helpers)
% EEG_PREP01_BIDS_FORMATTING
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
% Step 01 of the unified EEG pipeline.
%
% WHAT THIS STEP DOES
%   - Finds fresh/raw EEG files for ONE subject
%   - Copies/renames them into BIDS structure
%   - Optionally copies behavioral logs into /beh
%   - Optionally copies one EEG-side log into /eeg as *_events.log
%   - Optionally attempts an EEGLAB pop_exportbids call afterward
%
% INPUT
%   subj_id : subject ID string, e.g. '211'
%   cfg     : full pipeline config
%   paths   : subject-specific paths built by the runner
%   helpers : helper handle struct with logging and utilities
%
% OUTPUT
%   step_out.ok      : true / false
%   step_out.message : short status/error message
%
% Saskia Wilken Dez 2025
% Refactor: cleaned path handling without compatibility aliases

step_out = struct('ok', false, 'message', '');

try
    if ~isfield(cfg, 'prep_01') || ~isstruct(cfg.prep_01)
        error('Step 01: cfg.prep_01 is missing.');
    end

    step_cfg = cfg.prep_01;

    subj_id       = char(string(subj_id));
    task_label    = char(string(step_cfg.task_label));
    session_label = char(string(step_cfg.session_label));

    do_eeg = isfield(step_cfg, 'do_eeg') && logical(step_cfg.do_eeg);
    do_beh = isfield(step_cfg, 'do_beh') && logical(step_cfg.do_beh);

    try_export_bids            = isfield(step_cfg, 'try_eeglab_bids_export') && logical(step_cfg.try_eeglab_bids_export);
    write_readme_if_needed     = isfield(step_cfg, 'write_readme_if_exporter_did_not') && logical(step_cfg.write_readme_if_exporter_did_not);
    copy_sidecar_log_to_events = isfield(step_cfg, 'copy_eeg_sidecar_log_to_events') && logical(step_cfg.copy_eeg_sidecar_log_to_events);

    re_vhdr      = char(string(step_cfg.raw_eeg_regex));
    re_bids_vhdr = char(string(step_cfg.existing_bids_vhdr_regex));

    % ---------------------------------------------------------------------
    % Resolve paths
    % No compatibility aliases. Only paths.* and cfg.paths.* are valid.
    % ---------------------------------------------------------------------
    raw_eeg_dir = resolve_path_local(paths, cfg, 'source_eeg_root');
    raw_beh_dir = resolve_path_local(paths, cfg, 'source_beh_root');

    bids_root = resolve_required_path_local(paths, cfg, 'bids_root');
    sub_label = resolve_required_char_local(paths, 'subj_label');
    bids_ses_dir = resolve_required_path_from_paths_local(paths, 'bids_ses_dir');

    ses_label = ['ses-' session_label];
    eeg_dir   = fullfile(bids_ses_dir, 'eeg');
    beh_dir   = fullfile(bids_ses_dir, 'beh');

    helpers.log_msg_default('Step 01 start for sub-%s', subj_id);
    helpers.log_msg_default('Step 01 do_eeg          : %d', do_eeg);
    helpers.log_msg_default('Step 01 do_beh          : %d', do_beh);
    helpers.log_msg_default('Step 01 source_eeg_root : %s', char(string(raw_eeg_dir)));
    helpers.log_msg_default('Step 01 source_beh_root : %s', char(string(raw_beh_dir)));
    helpers.log_msg_default('Step 01 bids_root       : %s', bids_root);
    helpers.log_msg_default('Target session folder   : %s', bids_ses_dir);

    % ---------------------------------------------------------------------
    % Basic checks / folder creation
    % ---------------------------------------------------------------------
    helpers.ensure_dir(bids_root);
    helpers.ensure_dir(bids_ses_dir);

    if do_eeg
        if strlength(string(raw_eeg_dir)) == 0
            error('Step 01: cfg.paths.source_eeg_root is empty but do_eeg=true.');
        end
        if exist(char(string(raw_eeg_dir)), 'dir') ~= 7
            error('Step 01: source_eeg_root does not exist: %s', char(string(raw_eeg_dir)));
        end
    end

    if do_beh
        if strlength(string(raw_beh_dir)) == 0 || exist(char(string(raw_beh_dir)), 'dir') ~= 7
            helpers.log_msg_default('WARNING: do_beh=true but source_beh_root is missing/empty: %s', char(string(raw_beh_dir)));
            helpers.log_msg_default('Behavior copy disabled for sub-%s.', subj_id);
            do_beh = false;
        end
    end

    wrote_description = false;

    % ---------------------------------------------------------------------
    % Resolve EEG source files
    % ---------------------------------------------------------------------
    if do_eeg
        all_vhdr_files = dir(fullfile(char(string(raw_eeg_dir)), '*.vhdr'));
        subject_vhdr_files = [];

        for k = 1:numel(all_vhdr_files)
            tokens = regexp(all_vhdr_files(k).name, re_vhdr, 'tokens', 'once');
            if isempty(tokens)
                continue;
            end

            subj_from_file = sprintf('%03d', str2double(tokens{1}));
            if strcmp(subj_from_file, subj_id)
                subject_vhdr_files = [subject_vhdr_files; all_vhdr_files(k)]; %#ok<AGROW>
            end
        end

        if isempty(subject_vhdr_files)
            error('Step 01: no raw .vhdr files found for sub-%s in %s', subj_id, char(string(raw_eeg_dir)));
        end

        [~, sort_ix] = sort({subject_vhdr_files.name});
        subject_vhdr_files = subject_vhdr_files(sort_ix);

    else
        if exist(eeg_dir, 'dir') ~= 7
            error('Step 01: do_eeg=false but BIDS eeg folder does not exist: %s', eeg_dir);
        end

        subject_vhdr_files = dir(fullfile(eeg_dir, '*_eeg.vhdr'));

        if isempty(subject_vhdr_files)
            error('Step 01: do_eeg=false but no BIDS EEG headers found for sub-%s in %s', subj_id, eeg_dir);
        end
    end

    helpers.log_msg_default('Found %d EEG header file(s) for sub-%s.', numel(subject_vhdr_files), subj_id);

    % ---------------------------------------------------------------------
    % Process each run / header
    % ---------------------------------------------------------------------
    n_processed = 0;

    for k = 1:numel(subject_vhdr_files)

        run_label = '';
        run_tag = '';
        task_label_this_file = task_label;

        if do_eeg
            src_vhdr = subject_vhdr_files(k).name;
            tokens   = regexp(src_vhdr, re_vhdr, 'tokens', 'once');

            if isempty(tokens)
                continue;
            end

            subj_num = sprintf('%03d', str2double(tokens{1}));

            has_run = (numel(tokens) >= 2) && ~isempty(tokens{2});
            if has_run
                run_label = tokens{2};
                run_tag   = ['_run-' run_label];
            end

            bids_base = sprintf('%s_%s_task-%s%s', sub_label, ses_label, task_label_this_file, run_tag);

            helpers.ensure_dir(eeg_dir);

            [~, src_base_noext] = fileparts(src_vhdr);
            src_vmrk = [src_base_noext '.vmrk'];

            if exist(fullfile(char(string(raw_eeg_dir)), [src_base_noext '.eeg']), 'file') == 2
                src_data = [src_base_noext '.eeg'];
            elseif exist(fullfile(char(string(raw_eeg_dir)), [src_base_noext '.dat']), 'file') == 2
                src_data = [src_base_noext '.dat'];
            else
                src_data = '';
            end

            if exist(fullfile(char(string(raw_eeg_dir)), src_vmrk), 'file') ~= 2
                error('Step 01: missing .vmrk for %s', src_vhdr);
            end

            if isempty(src_data)
                error('Step 01: missing .eeg/.dat for %s', src_vhdr);
            end

            [~, ~, data_ext] = fileparts(src_data);

            dst_vhdr_name = [bids_base '_eeg.vhdr'];
            dst_vmrk_name = [bids_base '_eeg.vmrk'];
            dst_data_name = [bids_base '_eeg' data_ext];

            dst_vhdr = fullfile(eeg_dir, dst_vhdr_name);
            dst_vmrk = fullfile(eeg_dir, dst_vmrk_name);
            dst_data = fullfile(eeg_dir, dst_data_name);

            helpers.log_msg_default( ...
                'Copying BrainVision triplet for sub-%s: %s -> %s', ...
                subj_id, src_vhdr, dst_vhdr_name);

            copyfile(fullfile(char(string(raw_eeg_dir)), src_vhdr), dst_vhdr);
            copyfile(fullfile(char(string(raw_eeg_dir)), src_vmrk), dst_vmrk);
            copyfile(fullfile(char(string(raw_eeg_dir)), src_data), dst_data);

            rewrite_vhdr_links_impl(dst_vhdr, dst_data_name, dst_vmrk_name);
            rewrite_vmrk_links_impl(dst_vmrk, dst_data_name);

            % -------------------------------------------------------------
            % Optional project-specific EEG-side log copy
            % -------------------------------------------------------------
            if copy_sidecar_log_to_events
                log_candidates = [ ...
                    dir(fullfile(char(string(raw_eeg_dir)), sprintf('CF_%s*.log', subj_id))); ...
                    dir(fullfile(char(string(raw_eeg_dir)), sprintf('CF_%s*.txt', subj_id))) ...
                ];

                if ~isempty(log_candidates)
                    [~, newest_ix] = max([log_candidates.datenum]);
                    src_log = fullfile(log_candidates(newest_ix).folder, log_candidates(newest_ix).name);
                    dst_log = fullfile(eeg_dir, [bids_base '_events.log']);
                    copyfile(src_log, dst_log);
                else
                    helpers.log_msg_default('WARNING: no project-specific CF sidecar log found for sub-%s', subj_id);
                end
            end

        else
            src_vhdr = subject_vhdr_files(k).name;
            tokens = regexp(src_vhdr, re_bids_vhdr, 'tokens', 'once');

            if isempty(tokens)
                helpers.log_msg_default('WARNING: skipping BIDS vhdr with unexpected name: %s', src_vhdr);
                continue;
            end

            subj_num        = sprintf('%03d', str2double(tokens{1}));
            ses_from_name   = tokens{2};
            task_from_name  = tokens{3};

            has_run = (numel(tokens) >= 4) && ~isempty(tokens{4});
            if has_run
                run_label = tokens{4};
                run_tag   = ['_run-' run_label];
            end

            task_label_this_file = task_from_name;
            bids_base = sprintf('sub-%s_ses-%s_task-%s%s', subj_num, ses_from_name, task_from_name, run_tag);
        end

        % -------------------------------------------------------------
        % Optional project-specific behavior copy
        % -------------------------------------------------------------
        if do_beh
            helpers.ensure_dir(beh_dir);

            beh_candidates = [ ...
                dir(fullfile(char(string(raw_beh_dir)), sprintf('CF_%s-*.log', subj_id))); ...
                dir(fullfile(char(string(raw_beh_dir)), sprintf('CF_%s-*.txt', subj_id))) ...
            ];

            for b = 1:numel(beh_candidates)
                beh_name = beh_candidates(b).name;
                btokens  = regexp(beh_name, '^CF_(\d{3})-(.+)\.(log|txt)$', 'tokens', 'once');

                if isempty(btokens)
                    continue;
                end

                beh_desc_raw = btokens{2};
                beh_desc     = regexprep(beh_desc_raw, '[^A-Za-z0-9]+', '');

                if isempty(beh_desc)
                    beh_desc = 'log';
                end

                beh_ext  = btokens{3};
                beh_base = sprintf('%s_%s_task-%s%s_desc-%s', ...
                    sub_label, ses_label, task_label_this_file, run_tag, beh_desc);

                src_beh = fullfile(beh_candidates(b).folder, beh_name);
                dst_beh = fullfile(beh_dir, [beh_base '_beh.' beh_ext]);

                copyfile(src_beh, dst_beh);
            end
        end

        % -------------------------------------------------------------
        % Optional EEGLAB BIDS export
        % -------------------------------------------------------------
        if do_eeg && try_export_bids
            try
                EEG = pop_loadbv(eeg_dir, [bids_base '_eeg.vhdr']);
                EEG = eeg_checkset(EEG);

                export_args = { ...
                    'subject', subj_num, ...
                    'session', session_label, ...
                    'task', task_label_this_file, ...
                    'dataformat', 'BrainVision', ...
                    'overwrite', 'on', ...
                    'bidsevent', 'off'};

                if has_run
                    export_args = [export_args, {'run', str2double(run_label)}]; %#ok<AGROW>
                end

                pop_exportbids(EEG, bids_root, export_args{:});
                wrote_description = true;

            catch ME_export
                helpers.log_msg_default([ ...
                    'WARNING: pop_exportbids failed for %s (%s). ' ...
                    'Keeping copied BrainVision-based BIDS structure.'], ...
                    bids_base, ME_export.message);
            end
        end

        n_processed = n_processed + 1;
    end

    if n_processed == 0
        error('Step 01: no valid EEG files could be processed for sub-%s.', subj_id);
    end

    % ---------------------------------------------------------------------
    % Fallback README
    % ---------------------------------------------------------------------
    if write_readme_if_needed && ~wrote_description
        readme_path = fullfile(bids_root, 'README');

        fid = fopen(readme_path, 'w');
        if fid > 0
            fprintf(fid, 'BIDS dataset organized by eeg_prep01_bids_formatting.\n');
            fprintf(fid, 'Raw BrainVision files were copied and renamed into BIDS structure.\n');
            if do_beh
                fprintf(fid, 'Project-specific CF behavior files were copied into /beh when available.\n');
            else
                fprintf(fid, 'Project-specific behavior copy was disabled.\n');
            end
            fclose(fid);
        end
    end

    step_out.ok = true;
    step_out.message = sprintf('Step 01 completed for sub-%s.', subj_id);
    helpers.log_msg_default('%s', step_out.message);

catch ME
    step_out.ok = false;
    step_out.message = ME.message;
    helpers.log_msg_default('ERROR in step 01 for sub-%s: %s', subj_id, ME.message);
end

end

% =========================================================================
% LOCAL HELPERS
% =========================================================================
function out_path = resolve_path_local(paths, cfg, field_name)
out_path = "";

if isfield(paths, field_name) && strlength(string(paths.(field_name))) > 0
    out_path = string(paths.(field_name));
    return;
end

if isfield(cfg, 'paths') && isfield(cfg.paths, field_name) && strlength(string(cfg.paths.(field_name))) > 0
    out_path = string(cfg.paths.(field_name));
    return;
end
end

function out_path = resolve_required_path_local(paths, cfg, field_name)
out_path = resolve_path_local(paths, cfg, field_name);

if strlength(string(out_path)) == 0
    error('Step 01: required path "%s" is missing or empty.', field_name);
end

out_path = char(string(out_path));
end

function out_value = resolve_required_path_from_paths_local(paths, field_name)
if ~isfield(paths, field_name) || strlength(string(paths.(field_name))) == 0
    error('Step 01: paths.%s is missing or empty.', field_name);
end

out_value = char(string(paths.(field_name)));
end

function out_value = resolve_required_char_local(S, field_name)
if ~isfield(S, field_name) || strlength(string(S.(field_name))) == 0
    error('Step 01: paths.%s is missing or empty.', field_name);
end

out_value = char(string(S.(field_name)));
end

function rewrite_vhdr_links_impl(vhdr_path, data_filename, vmrk_filename)
txt = fileread(vhdr_path);
lines = regexp(txt, '\r\n|\n|\r', 'split');

found_data = false;
found_vmrk = false;

for i = 1:numel(lines)
    if startsWith(lines{i}, 'DataFile=', 'IgnoreCase', false)
        lines{i} = ['DataFile=' data_filename];
        found_data = true;
    elseif startsWith(lines{i}, 'MarkerFile=', 'IgnoreCase', false)
        lines{i} = ['MarkerFile=' vmrk_filename];
        found_vmrk = true;
    end
end

if ~found_data
    error('Step 01: copied .vhdr is missing DataFile= entry: %s', vhdr_path);
end
if ~found_vmrk
    error('Step 01: copied .vhdr is missing MarkerFile= entry: %s', vhdr_path);
end

write_text_lines_impl(vhdr_path, lines);
end

function rewrite_vmrk_links_impl(vmrk_path, data_filename)
txt = fileread(vmrk_path);
lines = regexp(txt, '\r\n|\n|\r', 'split');

found_data = false;

for i = 1:numel(lines)
    if startsWith(lines{i}, 'DataFile=', 'IgnoreCase', false)
        lines{i} = ['DataFile=' data_filename];
        found_data = true;
    end
end

if ~found_data
    error('Step 01: copied .vmrk is missing DataFile= entry: %s', vmrk_path);
end

write_text_lines_impl(vmrk_path, lines);
end

function write_text_lines_impl(file_path, lines)
fid = fopen(file_path, 'w');
if fid < 0
    error('Step 01: could not open file for rewrite: %s', file_path);
end

cleanup_obj = onCleanup(@() fclose(fid)); 

for i = 1:numel(lines)
    fprintf(fid, '%s\n', lines{i});
end
end