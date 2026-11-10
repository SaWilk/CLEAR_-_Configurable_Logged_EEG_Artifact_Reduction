function step_out = eeg_prep02_triggerfix(subj_id, cfg, paths, helpers)
% EEG_PREP02_TRIGGERFIX
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
%
% Step 02 of the EEG pipeline.
%
% Does:
%   - Load BIDS BrainVision EEG (.vhdr) for one subject
%   - Optional RTGMN-specific RAW QC: compare CF behavior-log token order
%     against raw EEG trigger order
%   - Remap raw triggers into phase-specific or globally-applied codes using cfg.paradigms settings 
%   - Optionally disable first trials within a phase
%   - Save *_triggersfixed.set into derivatives/01_trigger_fix/sub-XXX/
%
% Important note:
%   The behavior-log branch in this step is RTGMN/CF-specific. Most users
%   will not have this custom file format. For other projects, leave
%   cfg.prep_02.run_raw_order_qc = false unless you explicitly adapt that
%   branch for your own experiment-specific logs.
%
% Saskia Wilken Dec 2025/Laura Langemeyer Sept 2026

step_out = struct('ok', false, 'skipped', false, 'out_set_file', '', 'message', '');

try
    helpers.log_msg_default('Step 02 start for sub-%s', subj_id);

    % ---------------------------------------------------------------------
    % Defaults
    % ---------------------------------------------------------------------
    step_cfg = local_default_step_cfg();

    if isfield(cfg, 'steps') && isfield(cfg.steps, 'prep_02_triggerfix') && isstruct(cfg.steps.prep_02_triggerfix)
        step_cfg = helpers.merge_structs_recursive(step_cfg, cfg.steps.prep_02_triggerfix);
    end

    if isfield(cfg, 'bids') && isstruct(cfg.bids)
        if isfield(cfg.bids, 'task_label');    step_cfg.task_label = string(cfg.bids.task_label); end
        if isfield(cfg.bids, 'session_label'); step_cfg.session_label = string(cfg.bids.session_label); end
    end

    if isfield(cfg, 'prep_02') && isstruct(cfg.prep_02)
        step_cfg = helpers.merge_structs_recursive(step_cfg, cfg.prep_02);
    end

    if isfield(step_cfg, 'rules')
        error('Step 02: triggerfix.rules is unsupported.');
    end

    overwrite_mode = helpers.resolve_overwrite_mode(cfg, step_cfg.overwrite_mode);

    % ---------------------------------------------------------------------
    % Paradigm triggerfix config
    % ---------------------------------------------------------------------
    paradigm_name = "myParadigm"; %initiates the extraction of the triggerfix paradigm set in the config

    if strlength(paradigm_name) > 0 && isfield(cfg, 'paradigms') && isfield(cfg.paradigms, paradigm_name) ...
            && isfield(cfg.paradigms.(paradigm_name), 'triggerfix')

        tf = cfg.paradigms.(paradigm_name).triggerfix;

        %print raw_triggers keys and values that step_cfg uses
        try
            rt = step_cfg.raw_triggers;
            rk = fieldnames(rt);
            for ii = 1:numel(rk)
                k = char(rk{ii});
                helpers.log_msg_default('Step 02 raw_triggers.%s = "%s"', k, char(string(rt.(k))));
            end
        catch
        end
                if isfield(tf, 'enable_first_match_replacements')
            step_cfg.enable_first_match_replacements = logical(tf.enable_first_match_replacements);
        else
            step_cfg.enable_first_match_replacements = true; % Default
        end
        
        if isfield(tf, 'phase_strategy')
            step_cfg.phase_strategy = string(tf.phase_strategy);
        end

        if isfield(tf,'trigger_phase_max_phase_share')
            step_cfg.trigger_phase_max_phase_share = double(tf.trigger_phase_max_phase_share);
        end

        if isfield(tf, 'trigger_phase_min_remaps')
            step_cfg.trigger_phase_min_remaps = double(tf.trigger_phase_min_remaps);
        end
        
        if isfield(tf,'trigger_phase_min_start_markers')
            step_cfg.trigger_phase_min_start_markers = double(tf.trigger_phase_min_start_markers);
        end
        
        if isfield(tf,'trigger_phase_min_phases_with_remaps')
            step_cfg.trigger_phase_min_phases_with_remaps = double(tf.trigger_phase_min_phases_with_remaps);
        end

        if isfield(tf, 'use_gating_from_start_markers')
            step_cfg.use_gating_from_start_markers = logical(tf.use_gating_from_start_markers);
        else
            step_cfg.use_gating_from_start_markers = true;
        end
        
        %step cfg fields
        if isfield(tf,'run_raw_order_qc'); step_cfg.run_raw_order_qc = logical(tf.run_raw_order_qc); end
        if isfield(tf,'allow_multiple_runs'); step_cfg.allow_multiple_runs = logical(tf.allow_multiple_runs); end
        if isfield(tf,'multiple_vhdr_policy'); step_cfg.multiple_vhdr_policy = string(tf.multiple_vhdr_policy); end
        if isfield(tf,'qc_out_dir'); step_cfg.qc_out_dir = string(tf.qc_out_dir); end
        
        if isfield(tf,'task_label'); step_cfg.task_label = string(tf.task_label); end
        if isfield(tf,'session_label'); step_cfg.session_label = string(tf.session_label); end
        if isfield(tf,'input_vhdr_pattern'); step_cfg.input_vhdr_pattern = string(tf.input_vhdr_pattern); end
        
        if isfield(tf,'use_explicit_chanlist'); step_cfg.use_explicit_chanlist = logical(tf.use_explicit_chanlist); end
        if isfield(tf,'explicit_chanlist'); step_cfg.explicit_chanlist = tf.explicit_chanlist; end
        
        % raw qc numeric settings
        if isfield(tf,'raw_qc_keep_tokens'); step_cfg.raw_qc_keep_tokens = tf.raw_qc_keep_tokens; end
        if isfield(tf,'raw_qc_bin_size_s'); step_cfg.raw_qc_bin_size_s = double(tf.raw_qc_bin_size_s); end
        if isfield(tf,'raw_qc_max_rows'); step_cfg.raw_qc_max_rows = double(tf.raw_qc_max_rows); end
        if isfield(tf,'raw_qc_write_csv_on_ok'); step_cfg.raw_qc_write_csv_on_ok = logical(tf.raw_qc_write_csv_on_ok); end
        
        % behavior log settings
        if isfield(tf,'behavior_log_column_event_type'); step_cfg.behavior_log_column_event_type = tf.behavior_log_column_event_type; end
        if isfield(tf,'behavior_log_column_code'); step_cfg.behavior_log_column_code = tf.behavior_log_column_code; end
        if isfield(tf,'behavior_log_column_time'); step_cfg.behavior_log_column_time = tf.behavior_log_column_time; end
        if isfield(tf,'behavior_log_time_unit'); step_cfg.behavior_log_time_unit = tf.behavior_log_time_unit; end
        if isfield(tf,'behavior_log_map'); step_cfg.behavior_log_map = tf.behavior_log_map; end 

        if isfield(tf,'log_summary_only')
            step_cfg.log_summary_only = logical(tf.log_summary_only);
        end

        if isfield(tf, 'gates') && isfield(tf.gates, 'start_markers')
            if ~isempty(tf.gates.start_markers) && ~isstruct(tf.gates.start_markers)
                error('Step 02: tf.gates.start_markers must be a struct (can be empty).');
            end
            step_cfg.phase_start_markers = struct();
            sm = tf.gates.start_markers;
            phFields = fieldnames(sm);
            for kk = 1:numel(phFields)
                pName = char(phFields{kk});
                step_cfg.phase_start_markers.(pName) = sm.(pName);
            end
        else
            step_cfg.phase_start_markers = struct();
        end

        if isfield(tf, 'blocking')
            step_cfg.blocking = tf.blocking;
        end

        if isfield(tf, 'raw_triggers')
            rt = tf.raw_triggers;
            if ~isstruct(rt); error('Step 02: tf.raw_triggers must be a struct.'); end
            step_cfg.raw_triggers = struct();
            fns = fieldnames(rt);
            for ii = 1:numel(fns)
                fn = char(fns{ii});
                step_cfg.raw_triggers.(fn) = rt.(fns{ii});
            end
        end

        if isfield(tf, 'rules')
            error('Step 02: triggerfix.rules is unsupported.');
        end

        if isfield(tf, 'first_match_replacements')
            step_cfg.first_match_replacements = tf.first_match_replacements;
        end
        if isfield(tf,'phase_specific_trigger_renaming')
            step_cfg.phase_specific_trigger_renaming = logical(tf.phase_specific_trigger_renaming);
        else
            step_cfg.phase_specific_trigger_renaming = false;
        end
        
        if isfield(tf,'phase_specific_trigger_renaming_rules')
            step_cfg.phase_specific_trigger_renaming_rules = tf.phase_specific_trigger_renaming_rules;
        end

        helpers.log_msg_default('Step 02: Using paradigm triggerfix config "%s".', paradigm_name);
    else
        helpers.log_msg_default('Step 02: No paradigm triggerfix config found -> using defaults.');
    end
    

    session_label = char(string(step_cfg.session_label));
    task_label    = char(string(step_cfg.task_label));

    % ---------------------------------------------------------------------
    % Paths
    % ---------------------------------------------------------------------
    if ~isfield(paths, 'bids_ses_dir') || strlength(string(paths.bids_ses_dir)) == 0
        paths.bids_ses_dir = fullfile(paths.bids_root, sprintf('sub-%s', subj_id), ['ses-' session_label]);
    end

    if ~isfield(paths, 'prep_02_out_dir') || strlength(string(paths.prep_02_out_dir)) == 0
        paths.prep_02_out_dir = fullfile(paths.out_root, '01_trigger_fix', sprintf('sub-%s', subj_id));
    end
    helpers.ensure_dir(paths.prep_02_out_dir);

    qc_out_dir = string(step_cfg.qc_out_dir);
    if strlength(qc_out_dir) == 0
        if isfield(paths, 'qc_dir') && strlength(string(paths.qc_dir)) > 0
            qc_out_dir = string(paths.qc_dir);
        else
            qc_out_dir = string(paths.prep_02_out_dir);
        end
    end
    helpers.ensure_dir(char(qc_out_dir));

    eeg_dir = fullfile(paths.bids_ses_dir, 'eeg');
    if exist(eeg_dir, 'dir') ~= 7
        error('Step 02: BIDS eeg directory not found: %s', eeg_dir);
    end

    % ---------------------------------------------------------------------
    % Input discovery
    % ---------------------------------------------------------------------
    if strlength(string(step_cfg.input_vhdr_pattern)) > 0
        pattern = char(string(step_cfg.input_vhdr_pattern));
    else
        pattern = sprintf('sub-%s_ses-%s_task-%s*_eeg.vhdr', subj_id, session_label, task_label);
    end

    vhdr_list = dir(fullfile(eeg_dir, pattern));
    if isempty(vhdr_list)
        error('Step 02: no BIDS EEG .vhdr found for sub-%s in %s (pattern=%s)', subj_id, eeg_dir, pattern);
    end

    [~, sort_ix] = sort({vhdr_list.name});
    vhdr_list = vhdr_list(sort_ix);

    if numel(vhdr_list) > 1 && ~step_cfg.allow_multiple_runs
        switch string(step_cfg.multiple_vhdr_policy)
            case "error"
                error('Step 02: found %d vhdr files but allow_multiple_runs=false.', numel(vhdr_list));
            case "first"
                vhdr_list = vhdr_list(1);
            otherwise % most_recent
                [~, ix] = max([vhdr_list.datenum]);
                vhdr_list = vhdr_list(ix);
        end
    end

    beh = [];
    qc_ok_beh = false;  

    if step_cfg.run_raw_order_qc
        try
            beh_file = helpers.find_behavior_log(paths.bids_root, subj_id, session_label);
            beh = helpers.read_behavior_log(beh_file);
            bad_idx = find(~isfinite(str2double(string(beh.Time))));
            helpers.log_msg_default('Bad Time count=%d', numel(bad_idx));
            helpers.log_msg_default('Bad Time raw: %s', strjoin(cellstr(string(beh.Time(bad_idx(1:min(end,10))))), ', '));
            % bad = isnan(str2double(string(beh.Time)));
            % helpers.log_msg_default('Behavior Time non-numeric count=%d / n=%d', sum(bad), height(beh));
            % helpers.log_msg_default('First bad Time values: %s', strjoin(cellstr(string(beh.Time(bad(1:min(end,sum(bad)))))), ', '));
            helpers.log_msg_default('Behavior vars: %s', strjoin(string(beh.Properties.VariableNames), ', '));
            helpers.log_msg_default('Step 02: behavior log for RAW QC: %s', beh_file);
        catch
            helpers.log_msg_default('WARNING: Step 02 RAW QC skipped (could not read behavior log).');
            beh = [];
        end
    end

    out_files = strings(0,1);
    ran_any   = false;

    % =====================================================================
    % PRECOMPUTE for generic blocking 
    % =====================================================================
    phase_marker_tokens = struct();
    has_any_phase_marker = false;

    phase_start_seen_counts = struct();
    if isfield(step_cfg, 'phase_start_markers') && isstruct(step_cfg.phase_start_markers) && ...
            step_cfg.use_gating_from_start_markers
    
        pFields = fieldnames(step_cfg.phase_start_markers);
        for kk = 1:numel(pFields)
            pName = char(pFields{kk});
            tok = helpers.normalize_trigger_type(step_cfg.phase_start_markers.(pName));
            if strlength(string(tok)) > 0
                phase_start_seen_counts.(pName) = 0;
            end
        end
    end

    if isfield(step_cfg, 'phase_start_markers') && isstruct(step_cfg.phase_start_markers) && ...
            step_cfg.use_gating_from_start_markers

        pFields = fieldnames(step_cfg.phase_start_markers);
        for kk = 1:numel(pFields)
            pName = char(pFields{kk});
            tok = helpers.normalize_trigger_type(step_cfg.phase_start_markers.(pName));
            if strlength(string(tok)) > 0
                phase_marker_tokens.(pName) = tok;
                has_any_phase_marker = true;
            end
        end
    end

    blocking = struct();
    if isfield(step_cfg,'blocking') && isstruct(step_cfg.blocking)
        blocking = step_cfg.blocking;
    end

    count_scope = "global";
    if isfield(blocking,'count_scope')
        count_scope = lower(strtrim(string(blocking.count_scope)));
    end
    if ~ismember(count_scope, ["global","phase"])
        count_scope = "global";
    end

    %If phase gating is active, phase boundaries must control
    % the remap counting semantics to avoid drift when trials are missing.
    if step_cfg.use_gating_from_start_markers && has_any_phase_marker
        count_scope = "phase";
    end

    catNames = {};
    if isstruct(blocking)
        catNames = setdiff(fieldnames(blocking), {'count_scope'});
    end

    cat_raw_tok = struct();
    for ci = 1:numel(catNames)
        cat = char(catNames{ci});
        if ~isfield(blocking, cat) || ~isstruct(blocking.(cat)); continue; end
        if ~isfield(blocking.(cat), 'raw_key'); continue; end
        raw_key = char(string(blocking.(cat).raw_key));
        if strlength(raw_key) == 0; continue; end
        tok = helpers.get_raw_trigger_from_key(step_cfg.raw_triggers, raw_key);
        if strlength(string(tok)) > 0
            cat_raw_tok.(cat) = tok;
        end
    end
  
    
    %step_cfg.raw_triggers
    try
    rt = step_cfg.raw_triggers;
    rk = fieldnames(rt);
    for ii = 1:numel(rk)
        k = char(rk{ii});
        helpers.log_msg_default('Step 02: step_cfg.raw_triggers.%s = "%s"', k, char(string(rt.(k))));
    end
    catch, end

    % computed cat_raw_tok
    try
        ck = fieldnames(cat_raw_tok);
        for ii = 1:numel(ck)
            k = char(ck{ii});
            %helpers.log_msg_default('Step 02 DEBUG: cat_raw_tok.%s = "%s"', k, char(string(cat_raw_tok.(k))));
        end
    catch, end
    
    
    try
        %helpers.log_msg_default('Step 02 DEBUG: catNames = %s', strjoin(string(catNames), ', '));
    catch, end
        cat_counter = struct();
        cat_counter_phase = struct();

    % =====================================================================
    % MAIN LOOP over vhdr
    % =====================================================================
    for f = 1:numel(vhdr_list)

        bids_vhdr = vhdr_list(f).name;
        [~, bids_base] = fileparts(bids_vhdr);

        out_set_file = fullfile(paths.prep_02_out_dir, sprintf('%s_triggersfixed.set', bids_base));
        out_set_file_char = char(string(out_set_file)); % robust

        output_check_cfg = cfg;
        if ~isfield(output_check_cfg, 'io') || ~isstruct(output_check_cfg.io)
            output_check_cfg.io = struct();
        end

        if isfield(step_cfg, 'overwrite_if_older_than') && strlength(string(step_cfg.overwrite_if_older_than)) > 0
            output_check_cfg.io.overwrite_if_older_than = string(step_cfg.overwrite_if_older_than);
        end

        [do_run, skip_reason] = helpers.step_should_run_outputs(out_set_file_char, overwrite_mode, output_check_cfg);
        if ~do_run
            out_files(end+1,1) = string(out_set_file_char); %#ok<AGROW>
            continue;
        end

        ran_any = true;

        if exist(out_set_file_char, 'file') == 2
            helpers.safe_delete_set(out_set_file_char);
        end

        helpers.log_msg_default('Step 02: loading %s', bids_vhdr);

        if step_cfg.use_explicit_chanlist
            EEG = pop_loadbv(eeg_dir, bids_vhdr, [], step_cfg.explicit_chanlist);
        else
            EEG = helpers.safe_load_bv(eeg_dir, bids_vhdr, helpers);
        end
        EEG = eeg_checkset(EEG);
        EEG = helpers.normalize_event_types(EEG);

        % Print unique normalized event types
        try
            types = strings(0);
            for ii = 1:numel(EEG.event)
                types(end+1,1) = helpers.normalize_trigger_type(EEG.event(ii).type);
            end
            u = unique(types);
            helpers.log_msg_default('Step 02: unique normalized event types count=%d', numel(u));
            helpers.log_msg_default('Step 02: unique normalized event types (first 80): %s', ...
                strjoin(cellstr(u(1:min(80,numel(u)))), ', '));
        catch me
            helpers.log_msg_default('Step 02 DEBUG: could not print event types: %s', me.message);
        end

        % ---- OPTIONAL RAW QC BEFORE REMAPPING ----
        if step_cfg.run_raw_order_qc && ~isempty(beh)
            try
                qc_cfg = struct();
                qc_cfg.bin_size_s                 = step_cfg.raw_qc_bin_size_s;
                qc_cfg.max_rows                   = step_cfg.raw_qc_max_rows;
                qc_cfg.keep_tokens                = string(step_cfg.raw_qc_keep_tokens);
                qc_cfg.write_csv_on_ok            = step_cfg.raw_qc_write_csv_on_ok;
                qc_cfg.behavior_column_event_type = string(step_cfg.behavior_log_column_event_type);
                qc_cfg.behavior_column_code       = string(step_cfg.behavior_log_column_code);
                qc_cfg.behavior_column_time       = string(step_cfg.behavior_log_column_time);
                qc_cfg.behavior_time_unit         = string(step_cfg.behavior_log_time_unit);
                qc_cfg.behavior_log_map           = step_cfg.behavior_log_map;
                qc_cfg.raw_triggers               = step_cfg.raw_triggers;

                qc_ok_beh = true;
                rep_beh = struct();
                
                [qc_ok_beh, rep_beh] = helpers.raw_qc_behavior_vs_eeg_and_write_csv( ...
                    beh, EEG, subj_id, bids_base, char(qc_out_dir), qc_cfg);
            catch me_qc
                helpers.log_msg_default('WARNING: Step 02 RAW QC failed for %s (sub-%s). Reason: %s', ...
                    bids_base, subj_id, me_qc.message);
                qc_ok_beh = false;
            end
        else
            helpers.log_msg_default('Step 02 RAW QC skipped for %s (run_raw_order_qc=%d, beh_present=%d).', ...
                bids_base, logical(step_cfg.run_raw_order_qc), ~isempty(beh));
        end
        
        % ---- PASS 1: generic blocking (with optional phase gating) ----

        % Primary/Fallback decision for phase indication by triggers
        % Phase strategy options
        %   "trigger_only"
        %   "block_only"
        %   "trigger_then_block_fallback"
        phase_strategy = string(step_cfg.phase_strategy);
        
        do_trigger = false;
        do_block   = false;
        trigger_then_fallback = false;
        
        switch lower(strtrim(phase_strategy))
            case "trigger_only"
                do_trigger = true; do_block = false;
        
            case "block_only"
                do_trigger = false; do_block = true;
        
            case {"trigger_then_block_fallback","trigger_primary_fallback_block"}
                do_trigger = true; do_block = true;
                trigger_then_fallback = true;
        
            otherwise
                helpers.log_msg_default('Step 02: WARNING unknown phase_strategy="%s" -> default trigger_then_block_fallback', ...
                    char(phase_strategy));
                do_trigger = true; do_block = true;
                trigger_then_fallback = true;
        end
        
        %global block remapping without phases
        if ~has_any_phase_marker
        
            cat_counter = struct(); 

            cat_total_found = struct();   
            cat_remap_to = struct();      
        
            for x = 1:numel(EEG.event)
        
                current_type = helpers.normalize_trigger_type(EEG.event(x).type);
        
                % find matched category by raw token
                matched_cat = "";
                catKeys = fieldnames(cat_raw_tok);
                for ci = 1:numel(catKeys)
                    cat = catKeys{ci};
                    if strcmp(current_type, cat_raw_tok.(cat))
                        matched_cat = string(cat);
                        break;
                    end
                end
        
                if strlength(matched_cat) == 0
                    continue;
                end
        
                cat = char(matched_cat);
        
                if ~isfield(blocking, cat) || ~isfield(blocking.(cat), 'blocks')
                    continue;
                end
        
                blocks = blocking.(cat).blocks;
                if isempty(blocks)
                    continue;
                end
        
                % global counter
                if ~isfield(cat_counter, cat)
                    cat_counter.(cat) = 0;
                end
                % cat_counter.(cat) = cat_counter.(cat) + 1;
                % n = cat_counter.(cat);
                if ~isfield(cat_counter, cat); cat_counter.(cat) = 0; end
                    cat_counter.(cat) = cat_counter.(cat) + 1;
                    n = cat_counter.(cat);

                    % track found count per category
                    if ~isfield(cat_total_found, cat); cat_total_found.(cat) = 0; end
                    cat_total_found.(cat) = cat_total_found.(cat) + 1;
                    % select matching block
                    cum = 0;
                    new_code = "";
                    for bi = 1:numel(blocks)
                    bi_n = blocks{bi}.n;
                        if isempty(bi_n); continue; end
        
                    cum = cum + double(bi_n);
                        if n <= cum
                        new_code = blocks{bi}.code;
                        break;
                    end
                end
                
                % determine target label for reporting
                if strlength(string(new_code)) > 0
                    target_code = char(string(new_code));
                else
                    target_code = char(current_type);
                end
                
                % track distribution of remap targets per category
                catKey_log = matlab.lang.makeValidName(cat); % 
                targetKey_log = matlab.lang.makeValidName(target_code);
                
                if ~isfield(cat_remap_to, catKey_log)
                    cat_remap_to.(catKey_log) = struct();
                end
                if ~isfield(cat_remap_to.(catKey_log), targetKey_log)
                    cat_remap_to.(catKey_log).(targetKey_log) = 0;
                end
                cat_remap_to.(catKey_log).(targetKey_log) = cat_remap_to.(catKey_log).(targetKey_log) + 1;

                before = helpers.normalize_trigger_type(EEG.event(x).type);
        
                if strlength(string(new_code)) > 0
                    EEG.event(x).type = char(string(new_code));
                else
                    EEG.event(x).type = current_type;
                end
        
            end
        
            % -------- Summary log per category (no phases) --------
            catKeysFound = fieldnames(cat_total_found);
            for ii = 1:numel(catKeysFound)
                cat = catKeysFound{ii};
                nFound = cat_total_found.(cat);
            
                helpers.log_msg_default('Step 02 summary: cat="%s" found=%d', cat, nFound);
            
                catKey_log = matlab.lang.makeValidName(cat);
                if isfield(cat_remap_to, catKey_log)
                    targetKeys = fieldnames(cat_remap_to.(catKey_log));
                    for jj = 1:numel(targetKeys)
                        tKey = targetKeys{jj};
                        nHere = cat_remap_to.(catKey_log).(tKey);
                        helpers.log_msg_default('  -> remap_to="%s" n=%d', tKey, nHere);
                    end
                end
            end
            
            EEG = helpers.append_eeg_comment(EEG, ...
                sprintf('prep02_triggerfix: NO-PHASES -> global category blocking applied for sub-%s', subj_id));
            EEG = eeg_checkset(EEG);

            % SAVE OUTPUT and end Step 02
            out_base = bids_base;
            EEG.setname = sprintf('%s_triggersfixed', out_base);
            fname = sprintf('%s_triggersfixed.set', out_base);
            paths_out_dir = paths.prep_02_out_dir;
            
            EEG = helpers.safe_save_set(EEG, paths_out_dir, fname, helpers, cfg);
            helpers.log_msg_default('Step 02: saved %s', fullfile(paths_out_dir, fname));
            
            out_files(end+1,1) = string(out_set_file_char);
            
            step_out.ok = true;
            step_out.message = sprintf('Processed 1 trigger-fixed set for sub-%s (NO-PHASES fast path).', subj_id);
            helpers.log_msg_default('%s', step_out.message);
            continue;

                    
            % PRIMARY/FALLBACK skip
            do_trigger = false;
            do_block   = false;
            trigger_then_fallback = false;
        end
        
        
        % if ~has_any_phase_marker
        %     do_trigger = false;   % PRIMARY macht eh keinen Sinn ohne Gates
        %     do_block   = true;    % egal was phase_strategy war: global per Kategorie remappen
        % end

        skip_primary_fallback = false;
        if ~has_any_phase_marker
            skip_primary_fallback = true;
        end

        trigger_phase_min_remaps = double(step_cfg.trigger_phase_min_remaps);
        if isempty(trigger_phase_min_remaps) || ~isfinite(trigger_phase_min_remaps)
            trigger_phase_min_remaps = 5;
        end
        
        EEG_primary_backup = EEG;     % backup for fallback
        trigger_primary_ok = false;
        n_remaps_primary_total = 0;
        remap_counts_fallback = containers.Map('KeyType','char','ValueType','double');
        n_remaps_primary_by_phase = struct();
        n_remaps_primary_by_phase_and_cat = struct();
        seen_after_codes_primary = struct();
        remap_counts_primary = containers.Map('KeyType','char','ValueType','double');
        phases_with_remaps_count = 0;
        
        % Primary only meaningful if count_scope is phase and we have phase markers
        %if do_trigger && count_scope == "phase" && has_any_phase_marker
        if do_trigger && has_any_phase_marker
            phase_marker_names = fieldnames(phase_marker_tokens);

            phase_start_seen_counts = struct();
            for kk = 1:numel(phase_marker_names)
                phName = char(phase_marker_names{kk});
                phase_start_seen_counts.(phName) = 0;
            end
            n_remaps_primary_by_phase_only = struct();
            
            for kk = 1:numel(phase_marker_names)
                phName = char(phase_marker_names{kk});
                n_remaps_primary_by_phase_only.(phName) = 0;
            end
            
            if ~isempty(phase_marker_names)
                EEGp = EEG_primary_backup;
                current_phase = "";
        
                cat_counter_phase_primary = struct();
        
                for x = 1:numel(EEGp.event)
                    current_type = helpers.normalize_trigger_type(EEGp.event(x).type);
        
                    % --- phase update from trigger ---
                    hitPhase = false;
                    for kk = 1:numel(phase_marker_names)
                        pName = char(phase_marker_names{kk});
                        if strcmp(current_type, phase_marker_tokens.(pName))
                            current_phase = string(pName);
                            hitPhase = true;
                            break;
                        end
                    end
                    if hitPhase
                        phase_start_seen_counts.(char(current_phase)) = phase_start_seen_counts.(char(current_phase)) + 1;
                        cat_counter_phase_primary.(char(current_phase)) = struct();
                        continue;
                    end
        
                    % find matched category by raw token
                    matched_cat = "";
                    catKeys = fieldnames(cat_raw_tok);
                    for ci = 1:numel(catKeys)
                        cat = catKeys{ci};
                        if strcmp(current_type, cat_raw_tok.(cat))
                            matched_cat = string(cat);
                            break;
                        end
                    end
        
                    if strlength(matched_cat) == 0
                        EEGp.event(x).type = current_type;
                        continue;
                    end
        
                    cat = char(matched_cat);
        
                    blocks = helpers.triggerfix_blocks_for_phase(blocking.(cat), step_cfg, char(current_phase), cat);
                    if isempty(blocks); continue; end
        
                    if strlength(current_phase) == 0
                        continue;
                    end
        
                    phKey = char(current_phase);
                    
        % increment counter within this phase+category
        if ~isfield(cat_counter_phase_primary, phKey)
            cat_counter_phase_primary.(phKey) = struct();
        end
        if ~isfield(cat_counter_phase_primary.(phKey), cat)
            cat_counter_phase_primary.(phKey).(cat) = 0;
        end
        
        cat_counter_phase_primary.(phKey).(cat) = cat_counter_phase_primary.(phKey).(cat) + 1;
        n = cat_counter_phase_primary.(phKey).(cat);

        
        
        cum = 0;
        new_code = "";
        for bi = 1:numel(blocks)
            bi_n = blocks{bi}.n;
            if isempty(bi_n); continue; end
            cum = cum + double(bi_n);
            if n <= cum
                new_code = blocks{bi}.code;
                break;
            end
        end
                    before = helpers.normalize_trigger_type(EEGp.event(x).type);

                    if strlength(string(new_code)) > 0
                        EEGp.event(x).type = char(string(new_code));
                    else
                        EEGp.event(x).type = current_type;
                    end

                   

                after = helpers.normalize_trigger_type(EEGp.event(x).type); 
                    % if strlength(string(new_code)) > 0
                    %     EEGp.event(x).type = char(string(new_code));
                    % else
                    %     EEGp.event(x).type = current_type;
                    % end
        
         

                    % Ensure we know phase & cat for logging
                    phKey_log = phKey;           % phase key from current_phase
                    catKey_log = cat;           % category key (raw category label)
                    
                    % Track only when we really changed something (after != before)
                    if ~strcmp(after, before)
                        % init structs
                        if ~isfield(seen_after_codes_primary, phKey_log)
                            seen_after_codes_primary.(phKey_log) = struct();
                        end
                        if ~isfield(seen_after_codes_primary.(phKey_log), catKey_log)
                            seen_after_codes_primary.(phKey_log).(catKey_log) = {};
                        end
                    
                        % append unique code (string)
                        already = seen_after_codes_primary.(phKey_log).(catKey_log);
                        already_str = string(already(:));
                    
                        if ~any(already_str == string(after))
                            seen_after_codes_primary.(phKey_log).(catKey_log){end+1,1} = char(string(after));
                    
                            if ~step_cfg.log_summary_only
                                helpers.log_msg_default( ...
                                    'Step 02 QA PRIMARY CODEMAP: phase="%s" cat="%s" before="%s" after="%s"', ...
                                    phKey_log, catKey_log, before, after);
                            end
                        end
                    end
                   
                    if ~strcmp(after, before)

                        n_remaps_primary_total = n_remaps_primary_total + 1;

                        % total per phase
                            if ~isfield(n_remaps_primary_by_phase, phKey)
                                n_remaps_primary_by_phase.(phKey) = 0;
                            end
                        n_remaps_primary_by_phase.(phKey) = n_remaps_primary_by_phase.(phKey) + 1;

                        % total per phase+category
                        if count_scope == "phase" && strlength(current_phase) > 0
                            catKey = char(cat);
                            phKey  = char(current_phase);
                    
                            if ~isfield(n_remaps_primary_by_phase_and_cat, phKey)
                                n_remaps_primary_by_phase_and_cat.(phKey) = struct();
                            end
                            if ~isfield(n_remaps_primary_by_phase_and_cat.(phKey), catKey)
                                n_remaps_primary_by_phase_and_cat.(phKey).(catKey) = 0;
                            end
                            n_remaps_primary_by_phase_and_cat.(phKey).(catKey) = ...
                                n_remaps_primary_by_phase_and_cat.(phKey).(catKey) + 1;
                            
                            n_remaps_primary_by_phase_only.(phKey) = ...
                                n_remaps_primary_by_phase_only.(phKey) + 1;
                        end
                        % Count concrete trigger remaps before -> after (PRIMARY)
                        phaseKey_for_count = "";
                        if exist('current_phase','var') && strlength(string(current_phase)) > 0
                            phaseKey_for_count = char(string(current_phase));
                        end
                        
                        key_ba = sprintf('%s|||%s|||%s', phaseKey_for_count, char(before), char(after));
                        if ~isKey(remap_counts_primary, key_ba)
                            remap_counts_primary(key_ba) = 0;
                        end
                        remap_counts_primary(key_ba) = remap_counts_primary(key_ba) + 1;
                                            end
                end
                    start_counts = cell2mat(struct2cell(phase_start_seen_counts));
                    n_start_total = sum(start_counts);
                    min_start_markers = double(step_cfg.trigger_phase_min_start_markers);
                    if isempty(min_start_markers)
                        starts_pass = all(start_counts > 0);
                    else
                        starts_pass = n_start_total >= min_start_markers;
                    end
                    num_phases_with_remaps = numel(fieldnames(n_remaps_primary_by_phase));
                    min_phases_remaps = double(step_cfg.trigger_phase_min_phases_with_remaps);

                    phaseKeysPrim = fieldnames(n_remaps_primary_by_phase_only);
                    for kk = 1:numel(phaseKeysPrim)
                        ph = phaseKeysPrim{kk};
                        if ~step_cfg.log_summary_only
                            helpers.log_msg_default( ...
                                'Step 02 QA PRIMARY: renamed trials by condition(phase)=%s -> n=%d', ...
                                ph, n_remaps_primary_by_phase_only.(ph));
                        end
                    end
                    
                    max_phase_share = 0;
                    if n_remaps_primary_total > 0
                        pk = fieldnames(n_remaps_primary_by_phase_only);
                        for kk = 1:numel(pk)
                            ph = pk{kk};
                            share = n_remaps_primary_by_phase_only.(ph) / n_remaps_primary_total;
                            if share > max_phase_share
                                max_phase_share = share;
                            end
                        end
                    end
                    
                    dominant_share_max = double(step_cfg.trigger_phase_max_phase_share);

                    helpers.log_msg_default('Step 02 QA share-check: n_remaps_total=%d n_start_total=%d num_phases_with_remaps=%d dominant_share_max=%.3f max_phase_share=%.3f', ...
                    n_remaps_primary_total, n_start_total, num_phases_with_remaps, dominant_share_max, max_phase_share);
                    
                    if n_remaps_primary_total >= trigger_phase_min_remaps && ...
                       starts_pass && ...
                       num_phases_with_remaps >= min_phases_remaps && ...
                       max_phase_share <= dominant_share_max
                        trigger_primary_ok = true;
                        EEG = EEGp;
                    end
            end
        end
        
       
        % Optional: Behavior-QC gating for trigger-based phase remapping
        if do_trigger && logical(getfield_default(step_cfg, 'use_behavior_for_trigger_strategy', true)) ...
                && step_cfg.run_raw_order_qc && ~isempty(beh)
        
            if ~qc_ok_beh
                helpers.log_msg_default(['Step 02: WARNING Behavior-QC indicates trigger order mismatch ' ...
                    '-> KEEP trigger-based phase remapping (do not force fallback).']);
            end
        end

        % If trigger_only: do not pretend success when primary checks failed.
if do_trigger && ~do_block && has_any_phase_marker
    if ~trigger_primary_ok
        helpers.log_msg_default( ...
            'Step 02: trigger_only primary did not pass QA -> no remaps committed. Marking step as skipped for %s.', ...
            bids_base);
        continue; % go to next vhdr/run
    end
end

        %if ~trigger_primary_ok
        helpers.log_msg_default('Step 02: has_any_phase_marker=%d, phase_strategy=%s, do_trigger=%d, do_block=%d, trigger_primary_ok=%d, trigger_then_fallback=%d', ...
        logical(has_any_phase_marker), char(phase_strategy), logical(do_trigger), logical(do_block), logical(trigger_primary_ok), logical(trigger_then_fallback));
        
        %if do_block && ( ~trigger_then_fallback || ~trigger_primary_ok )
        if ~skip_primary_fallback && do_block && ( ~trigger_then_fallback || ~trigger_primary_ok )
            % ---------------- Fallback: block-counting logic ----------------
            cat_counter = struct();

            if count_scope == "phase" && has_any_phase_marker
                % Initialize per-phase struct for fallback accounting
                n_remaps_primary_by_phase_only = struct();
                phase_marker_names_FB = fieldnames(phase_marker_tokens);
                for kk = 1:numel(phase_marker_names_FB)
                    phName = char(phase_marker_names_FB{kk});
                    n_remaps_primary_by_phase_only.(phName) = 0;
                end
            end
            cat_counter_phase = struct();
        
            n_remaps_fallback_total = 0;
            n_remaps_fallback_by_phase = struct();
            n_remaps_fallback_by_phase_and_cat = struct();
        
            current_phase = ""; 
        
            for x = 1:numel(EEG.event)
        
                current_type = helpers.normalize_trigger_type(EEG.event(x).type);
        
                % phase update (skip remap for phase markers)
                if has_any_phase_marker
                    hitPhase = false;
                    pFields = fieldnames(phase_marker_tokens);
                    for kk = 1:numel(pFields)
                        pName = pFields{kk};
                        if strcmp(current_type, phase_marker_tokens.(pName))
                            current_phase = string(pName);
                            hitPhase = true;
                            break;
                        end
                    end
                    if hitPhase
                        phase_start_seen_counts.(char(current_phase)) = phase_start_seen_counts.(char(current_phase)) + 1;
                        cat_counter_phase.(char(current_phase)) = struct();
                        continue;
                    end
                end
        
                % find matched category by raw token
                matched_cat = "";
                catKeys = fieldnames(cat_raw_tok);
                for ci = 1:numel(catKeys)
                    cat = catKeys{ci};
                    if strcmp(current_type, cat_raw_tok.(cat))
                        matched_cat = string(cat);
                        break;
                    end
                end
        
                if strlength(matched_cat) == 0
                    EEG.event(x).type = current_type;
                    continue;
                end
        
                cat = char(matched_cat);
        
                blocks = helpers.triggerfix_blocks_for_phase(blocking.(cat), step_cfg, char(current_phase), cat);
                if isempty(blocks); continue; end
        
                % counter
                if count_scope == "phase"
                    if strlength(current_phase) == 0
                        continue;
                    end
                    phKey = char(current_phase);
        
                    if ~isfield(cat_counter_phase, phKey)
                        cat_counter_phase.(phKey) = struct();
                    end
                    if ~isfield(cat_counter_phase.(phKey), cat)
                        cat_counter_phase.(phKey).(cat) = 0;
                    end
        
                    cat_counter_phase.(phKey).(cat) = cat_counter_phase.(phKey).(cat) + 1;
                    n = cat_counter_phase.(phKey).(cat);
                else
                    if ~isfield(cat_counter, cat); cat_counter.(cat) = 0; end
                    cat_counter.(cat) = cat_counter.(cat) + 1;
                    n = cat_counter.(cat);
                end
        
                % select matching block
                % cum = 0;
                % new_code = "";
                % for bi = 1:numel(blocks)
                %     bi_n = blocks{bi}.n;
                %     if isempty(bi_n); continue; end
                %     cum = cum + double(bi_n);
                %     if n <= cum
                %         new_code = blocks{bi}.code;
                %         break;
                %     end
                % end
                % 
                % before = helpers.normalize_trigger_type(EEG.event(x).type);
                % 
                % if strlength(string(new_code)) > 0
                %     EEG.event(x).type = char(string(new_code));
                % else
                %     EEG.event(x).type = current_type;
                % end
        % select matching block
        cum = 0;
        new_code = "";
        for bi = 1:numel(blocks)
            bi_n = blocks{bi}.n;
            if isempty(bi_n); continue; end
            cum = cum + double(bi_n);
            if n <= cum
                new_code = blocks{bi}.code;
                break;
            end
        end
        
        before = helpers.normalize_trigger_type(EEG.event(x).type);
        
        if strlength(string(new_code)) > 0
            EEG.event(x).type = char(string(new_code));
        else
            EEG.event(x).type = current_type;
        end
                after = helpers.normalize_trigger_type(EEG.event(x).type);
        
               if ~strcmp(after, before)

                n_remaps_fallback_total = n_remaps_fallback_total + 1;

                % Count concrete trigger remaps before -> after (FALLBACK)
                key_ba = sprintf('%s|||%s', char(before), char(after));
                if ~isKey(remap_counts_fallback, key_ba)
                    remap_counts_fallback(key_ba) = 0;
                end
                remap_counts_fallback(key_ba) = remap_counts_fallback(key_ba) + 1;
                                % total per phase
                if count_scope == "phase" && strlength(current_phase) > 0
                    phKey = char(current_phase);
                    n_remaps_primary_by_phase_only.(phKey) = ...
                    n_remaps_primary_by_phase_only.(phKey) + 1;
                    if ~isfield(n_remaps_fallback_by_phase, phKey)
                        n_remaps_fallback_by_phase.(phKey) = 0;
                    end
                    n_remaps_fallback_by_phase.(phKey) = n_remaps_fallback_by_phase.(phKey) + 1;
                end
            
                % total per phase+category
                if count_scope == "phase" && strlength(current_phase) > 0
                    catKey = char(cat);
                    phKey  = char(current_phase);
            
                    if ~isfield(n_remaps_fallback_by_phase_and_cat, phKey)
                        n_remaps_fallback_by_phase_and_cat.(phKey) = struct();
                    end
                    if ~isfield(n_remaps_fallback_by_phase_and_cat.(phKey), catKey)
                        n_remaps_fallback_by_phase_and_cat.(phKey).(catKey) = 0;
                    end
                    n_remaps_fallback_by_phase_and_cat.(phKey).(catKey) = ...
                        n_remaps_fallback_by_phase_and_cat.(phKey).(catKey) + 1;
                end
               end
            end
        
            EEG = helpers.append_eeg_comment(EEG, ...
                sprintf('prep02_triggerfix: fallback generic blocking applied for sub-%s', subj_id));
        
           helpers.log_msg_default('Step 02: fallback remaps total=%d', n_remaps_fallback_total);

            if step_cfg.log_summary_only
                % compact summary: Phase + Category + count
                phaseKeysFB2 = fieldnames(n_remaps_fallback_by_phase_and_cat);
                for kk = 1:numel(phaseKeysFB2)
                    ph = phaseKeysFB2{kk};
                    catKeys = fieldnames(n_remaps_fallback_by_phase_and_cat.(ph));
                    for cc = 1:numel(catKeys)
                        catKey = catKeys{cc};
                        nHere  = n_remaps_fallback_by_phase_and_cat.(ph).(catKey);
            
                        helpers.log_msg_default('Step 02 summary fallback: phase="%s" cat="%s" n=%d', ...
                            ph, catKey, nHere);
                    end
                end
            else
                % original verbose QA 
                phaseKeysFB = fieldnames(n_remaps_fallback_by_phase);
                for kk = 1:numel(phaseKeysFB)
                    ph = phaseKeysFB{kk};
                    helpers.log_msg_default('Step 02: fallback remaps in phase "%s" = %d', ph, n_remaps_fallback_by_phase.(ph));
                end
            
                phaseKeysFB2 = fieldnames(n_remaps_fallback_by_phase_and_cat);
                for kk = 1:numel(phaseKeysFB2)
                    ph = phaseKeysFB2{kk};
                    catKeys = fieldnames(n_remaps_fallback_by_phase_and_cat.(ph));
                    for cc = 1:numel(catKeys)
                        catKey = catKeys{cc};
                        helpers.log_msg_default('Step 02: FALLBACK remaps in phase "%s" for category "%s" = %d', ...
                            ph, catKey, n_remaps_fallback_by_phase_and_cat.(ph).(catKey));
                    end
                end
            end 


            EEG = helpers.append_eeg_comment(EEG, ...
                sprintf('prep02_triggerfix: PRIMARY trigger-indicates-phase applied for sub-%s', subj_id));
        end
        
        % =====================================================================
        % TRIGGER REMAP SUMMARY 
        % =====================================================================
        if step_cfg.log_summary_only
            % PRIMARY
            if n_remaps_primary_total > 0
                helpers.log_msg_default('Step 02 SUMMARY PRIMARY trigger remaps (before->after): total=%d', n_remaps_primary_total);
                keys = remap_counts_primary.keys();
                for ii = 1:numel(keys)
                    k = keys{ii};                 % char
                    cnt = remap_counts_primary(k);
                    parts = split(k, '|||');
                    phaseKey = string(parts(1));
                    before   = string(parts(2));
                    after    = string(parts(3));
                    
                    helpers.log_msg_default('  PRIMARY: phase="%s" "%s" -> "%s" : n=%d', ...
                        phaseKey, before, after, cnt);
                end
            else
                helpers.log_msg_default('Step 02 SUMMARY PRIMARY trigger remaps: total=0');
            end
        
            % FALLBACK
            if exist('n_remaps_fallback_total','var') && n_remaps_fallback_total > 0

            fb_keys = remap_counts_fallback.keys;   % correct for containers.Map
        
            % check if we have any non-empty after
            any_nonempty_after = false;
            for ii = 1:numel(fb_keys)
                k = fb_keys{ii};
                parts = split(string(k), '|||');
                if numel(parts) >= 2 && strlength(parts(2)) > 0
                    any_nonempty_after = true;
                    break;
                end
            end
        
            if any_nonempty_after
                helpers.log_msg_default('Step 02 SUMMARY FALLBACK trigger remaps (before->after): total=%d', n_remaps_fallback_total);
        
                for ii = 1:numel(fb_keys)
                    k = fb_keys{ii};
                    cnt = remap_counts_fallback(k);
        
                    parts = split(string(k), '|||');
                    before = "";
                    after  = "";
        
                    if numel(parts) >= 1, before = parts(1); end
                    if numel(parts) >= 2, after  = parts(2); end
        
                    % skip entries with empty after
                    if strlength(after) == 0
                        continue;
                    end
        
                    helpers.log_msg_default('  FALLBACK: "%s" -> "%s" : n=%d', before, after, cnt);
                end
            else
                helpers.log_msg_default('Step 02 SUMMARY FALLBACK suppressed (all after-codes empty). total=%d', n_remaps_fallback_total);
            end
        
        else
            helpers.log_msg_default('Step 02 SUMMARY FALLBACK trigger remaps: total=0');
        end

           
        else
            helpers.log_msg_default('Step 02 trigger remap summary (before->after) detailed mode uses same format.');
            if n_remaps_primary_total > 0
                helpers.log_msg_default('Step 02 SUMMARY PRIMARY trigger remaps (before->after): total=%d', n_remaps_primary_total);
                keys = remap_counts_primary.keys();
                for ii = 1:numel(keys)
                    k = keys{ii};                 % char
                    cnt = remap_counts_primary(k);
                    parts = split(k, '|||');
                    before = string(parts(1));
                    after  = string(parts(2));
                    helpers.log_msg_default('  PRIMARY: "%s" -> "%s" : n=%d', before, after, cnt);
                end
            end
        
            if exist('n_remaps_fallback_total','var') && n_remaps_fallback_total > 0
                helpers.log_msg_default('Step 02 SUMMARY FALLBACK trigger remaps (before->after): total=%d', n_remaps_fallback_total);
                fb_keys = remap_counts_fallback.keys;   % richtig für containers.Map
            for ii = 1:numel(fb_keys)
                k = fb_keys{ii};                    % char key: 'before|||after'
                cnt = remap_counts_fallback(k);    % richtig: map(indexed by key)
            
                parts = split(string(k), '|||');
                before = "";
                after  = "<missing_after_from_key>";
            
                if numel(parts) >= 1
                    before = parts(1);
                end
                if numel(parts) >= 2
                    after = parts(2);
                end
            
                helpers.log_msg_default('  FALLBACK: "%s" -> "%s" : n=%d', before, after, cnt);
            end
                                end
                            end
                
                
        % ---- PASS X: generic first-match replacements ----
        if isfield(step_cfg, 'enable_first_match_replacements')
            run_replacements = logical(step_cfg.enable_first_match_replacements);
        else
            run_replacements = true;
        end

        if run_replacements && isfield(step_cfg, 'first_match_replacements') && ...
                ~isempty(step_cfg.first_match_replacements)

            replacements = step_cfg.first_match_replacements;
            if ~iscell(replacements)
                replacements = {replacements};
            end
            
            n_done = zeros(numel(replacements), 1);

            for x = 1:numel(EEG.event)
                current_type = helpers.normalize_trigger_type(EEG.event(x).type);

                for r = 1:numel(replacements)
                    if n_done(r) >= (getfield_default(replacements{r}, 'max_replacements', 1))
                        continue;
                    end

                    rule = replacements{r};

                    % resolve match_code
                    match_code = "";
                    if isfield(rule, 'match_code') && strlength(string(rule.match_code)) > 0
                        match_code = helpers.normalize_trigger_type(rule.match_code);
                    elseif isfield(rule, 'match_code_key') && strlength(string(rule.match_code_key)) > 0
                        match_code = helpers.get_raw_trigger_from_key(step_cfg.raw_triggers, rule.match_code_key);
                        match_code = helpers.normalize_trigger_type(match_code);
                    end

                    if strlength(match_code) == 0 || ~strcmp(current_type, match_code)
                        continue;
                    end

                    % resolve replace_code
                    replace_code = "";
                    if isfield(rule, 'replace_code') && strlength(string(rule.replace_code)) > 0
                        replace_code = helpers.normalize_trigger_type(rule.replace_code);
                    elseif isfield(rule, 'replace_code_key') && strlength(string(rule.replace_code_key)) > 0
                        replace_code = helpers.get_raw_trigger_from_key(step_cfg.raw_triggers, rule.replace_code_key);
                        replace_code = helpers.normalize_trigger_type(replace_code);
                    end

                    if strlength(replace_code) == 0
                        continue;
                    end

                    EEG.event(x).type = replace_code;
                    n_done(r) = n_done(r) + 1;
                end
            end

            EEG = helpers.append_eeg_comment(EEG, ...
                sprintf('prep02_triggerfix: generic first-match replacements applied for sub-%s', subj_id));
            helpers.log_msg_default('Step 02 LOGBOOK first_match_replacements sub-%s:', subj_id);
            
            for r = 1:numel(replacements)
                rule = replacements{r};
        
                % match_code & replace_code 
                match_code = "";
                if isfield(rule, 'match_code') && strlength(string(rule.match_code)) > 0
                    match_code = helpers.normalize_trigger_type(rule.match_code);
                elseif isfield(rule, 'match_code_key') && strlength(string(rule.match_code_key)) > 0
                    match_code = helpers.get_raw_trigger_from_key(step_cfg.raw_triggers, rule.match_code_key);
                    match_code = helpers.normalize_trigger_type(match_code);
                end
        
                replace_code = "";
                if isfield(rule, 'replace_code') && strlength(string(rule.replace_code)) > 0
                    replace_code = helpers.normalize_trigger_type(rule.replace_code);
                elseif isfield(rule, 'replace_code_key') && strlength(string(rule.replace_code_key)) > 0
                    replace_code = helpers.get_raw_trigger_from_key(step_cfg.raw_triggers, rule.replace_code_key);
                    replace_code = helpers.normalize_trigger_type(replace_code);
                end
        
                if strlength(match_code) == 0
                    match_code = "<missing_match>";
                end
                if strlength(replace_code) == 0
                    replace_code = "<missing_replace>";
                end
        
                helpers.log_msg_default('Step 02 LOGBOOK  - rule %d: "%s" -> "%s" applied_n=%d (max=%d)', ...
                    r, char(match_code), char(replace_code), n_done(r), ...
                    getfield_default(rule, 'max_replacements', 1));
            end
        end

        % -----------------------------------------------------------------
        % SAVE OUTPUT (.set)
        % -----------------------------------------------------------------
        EEG = eeg_checkset(EEG);

        out_base = bids_base; % filename = <bids_base>_triggersfixed.set
        EEG.setname = sprintf('%s_triggersfixed', out_base);

        fname = sprintf('%s_triggersfixed.set', out_base);
        paths_out_dir = paths.prep_02_out_dir;

        EEG = helpers.safe_save_set(EEG, paths_out_dir, fname, helpers, cfg);

        helpers.log_msg_default('Step 02: saved %s', fullfile(paths_out_dir, fname));

        out_files(end+1,1) = string(out_set_file_char); %#ok<AGROW>
    end 

    % =====================================================================
    % FINALIZE
    % =====================================================================
    step_out.ok = true;

    if isempty(out_files)
        step_out.skipped = true;
        step_out.message = 'No outputs written (all skipped or no matching files).';
    elseif ~ran_any
        step_out.skipped = true;
        step_out.out_set_file = char(out_files(1));
        step_out.message = 'All matching outputs already existed and were skipped.';
    else
        step_out.out_set_file = char(out_files(1));
        if numel(out_files) == 1
            step_out.message = sprintf('Processed 1 trigger-fixed set for sub-%s.', subj_id);
        else
            step_out.message = sprintf('Processed %d trigger-fixed sets for sub-%s.', numel(out_files), subj_id);
        end
    end

    helpers.log_msg_default('%s', step_out.message);

catch ME
    step_out.ok = false;
    step_out.skipped = false;
    step_out.message = ME.message;

    helpers.log_msg_default('ERROR in Step 02 for sub-%s: %s', subj_id, ME.message);
    helpers.log_msg_default('%s', getReport(ME, 'extended', 'hyperlinks', 'off'));
end


% =========================================================================
% LOCAL HELPERS
% =========================================================================
function v = getfield_default(s, field, default_val)
if isfield(s, field) && ~isempty(s.(field))
    v = s.(field);
else
    v = default_val;
end
end

function step_cfg = local_default_step_cfg()
step_cfg = struct();

% General behavior
step_cfg.run_raw_order_qc      = true;
step_cfg.allow_multiple_runs   = false;
step_cfg.multiple_vhdr_policy  = "most_recent";
step_cfg.qc_out_dir            = "";
step_cfg.task_label            = "task";
step_cfg.session_label         = "01";
step_cfg.input_vhdr_pattern    = "";
step_cfg.use_explicit_chanlist = false;
step_cfg.explicit_chanlist     = 1:66;
step_cfg.overwrite_mode        = "";
step_cfg.overwrite_if_older_than = "";

% Raw QC settings
step_cfg.raw_qc_keep_tokens      = ["S 20","S 21","S 22","S 23","S 24","S 15","S 5"];
step_cfg.raw_qc_bin_size_s       = 1;
step_cfg.raw_qc_max_rows         = 20000;
step_cfg.raw_qc_write_csv_on_ok  = false;

% RTGMN/CF behavior-log parser settings
step_cfg.behavior_log_column_event_type = 'EventType';
step_cfg.behavior_log_column_code       = 'Code';
step_cfg.behavior_log_column_time       = 'Time';
step_cfg.behavior_log_time_unit         = "ms";
step_cfg.behavior_log_map               = {};

% Phase markers
step_cfg.phase_start_markers = struct();
step_cfg.trigger_phase_min_start_markers = []; % Require all configured start markers.
step_cfg.trigger_phase_min_phases_with_remaps = 2;

% Optional enabling flags / generic defaults
step_cfg.enable_first_match_replacements = true;
step_cfg.use_gating_from_start_markers   = true;

% Blocking default 
step_cfg.blocking = struct();

% First-match replacements default 
step_cfg.first_match_replacements = {};

% fallback to current block-counting if trigger-based remapping seems unreliable.
step_cfg.phase_strategy = "trigger_then_block_fallback";
step_cfg.trigger_phase_min_remaps = 5; 
step_cfg.trigger_phase_max_phase_share = 0.80;

% Logging
step_cfg.log_summary_only = true; % suppress verbose QA lines, print only summary

end
end