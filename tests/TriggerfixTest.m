classdef TriggerfixTest < matlab.unittest.TestCase
    methods (Test)
        function remapsPhaseBlocksAfterMissingTrial(testCase)
            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, 'steps')));
            folder = testCase.applyFixture(matlab.unittest.fixtures.TemporaryFolderFixture);
            paths.bids_ses_dir = folder.Folder;
            paths.prep_02_out_dir = fullfile(folder.Folder, 'output');

            % Stub the EEGLAB check and use a placeholder header for input discovery.
            writelines(["function EEG = eeg_checkset(EEG)", "end"], ...
                fullfile(folder.Folder, 'eeg_checkset.m'));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(folder.Folder));
            eegDir = fullfile(paths.bids_ses_dir, 'eeg');
            mkdir(eegDir);
            fclose(fopen(fullfile(eegDir, 'sub-001_ses-01_task-task_eeg.vhdr'), 'w'));

            helpers = eeg_pipeline_helpers('');
            helpers.log_msg_default = @(varargin) [];
            helpers.safe_save_set = @TriggerfixTest.saveSet;
            cfg.io.overwrite_mode = "delete";

            cfg.paradigms.myParadigm.triggerfix.run_raw_order_qc = false;
            cfg.paradigms.myParadigm.triggerfix.gates.start_markers = struct('practice', "S 81", 'test', "S 82");
            cfg.paradigms.myParadigm.triggerfix.raw_triggers = struct('cue', "S 31", 'probe', "S 32");
            cfg.paradigms.myParadigm.triggerfix.blocking.cue.raw_key = "cue";
            cfg.paradigms.myParadigm.triggerfix.blocking.probe.raw_key = "probe";
            cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming = true;
            cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.practice.cue.blocks = { ...
                struct('n', 2, 'code', "S 311"), struct('n', Inf, 'code', "S 312")};
            cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.test.cue.blocks = { ...
                struct('n', 1, 'code', "S 313"), struct('n', 1, 'code', "S 314"), ...
                struct('n', Inf, 'code', "S 315")};
            cfg.paradigms.myParadigm.triggerfix.phase_specific_trigger_renaming_rules.test.probe.code = "S 321";
            cfg.paradigms.myParadigm.triggerfix.first_match_replacements = {struct('match_code', "S 311", 'replace_code', "S 319")};

            % Repeat the practice marker at the end to check that its count resets.
            raw = {'S 81', 'S 31', 'S 31', 'S 31', ...
                'S 82', 'S 31', 'S 32', 'S 31', 'S 31', 'S 31', 'S 81', 'S 31'};
            expected = {'S 81', 'S 319', 'S 311', 'S 312', ...
                'S 82', 'S 313', 'S 321', 'S 314', 'S 315', 'S 315', 'S 81', 'S 311'};

            for strategy = ["trigger_only", "block_only"]
                cfg.paradigms.myParadigm.triggerfix.phase_strategy = strategy;
                % The second recording is missing the third practice trial.
                for kept = {1:numel(raw), [1:3, 5:numel(raw)]}
                    indices = kept{1};
                    EEG.event = struct('type', raw(indices), 'latency', num2cell(100 * indices));
                    helpers.safe_load_bv = @(varargin) EEG;
                    result = eeg_prep02_triggerfix('001', cfg, paths, helpers);
                    testCase.assertTrue(result.ok && ~result.skipped, result.message);
                    saved = load(result.out_set_file, 'EEG', '-mat');
                    testCase.verifyEqual({saved.EEG.event.type}, expected(indices));
                    testCase.verifyEqual([saved.EEG.event.latency], 100 * indices);
                end
            end
        end
    end

    methods (Static, Access = private)
        function EEG = saveSet(EEG, outDir, filename, varargin)
            save(fullfile(outDir, filename), 'EEG', '-mat');
        end
    end
end
