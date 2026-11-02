classdef SmokeTest < matlab.unittest.TestCase
    
    methods (Test)
        % Test methods
        function runnerCodeAnalysis(testCase)
            % Test that the runner script pass code analysis
            testFile = mfilename('fullpath');
            repoRoot = fileparts(fileparts(testFile));
            runner_path = fullfile(repoRoot, 'run_eeg_pipeline.m');
            diagnostics = codeIssues(runner_path);
            testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), 'Code Errors in run_eeg_pipeline!');
        end

        function configCodeAnalysis(testCase)
            % Test that the configuration script pass code analysis
            testFile = mfilename('fullpath');
            repoRoot = fileparts(fileparts(testFile));
            config_path = fullfile(repoRoot, 'eeg_pipeline_config.m');
            diagnostics = codeIssues(config_path);
            testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), 'Code Errors in eeg_pipeline_config!');
        end

        function helpersCodeAnalysis(testCase)
            % Test that the helper functions pass code analysis
            testFile = mfilename('fullpath');
            repoRoot = fileparts(fileparts(testFile));
            stepsDir = fullfile(repoRoot, 'steps');
            helpers_path = fullfile(stepsDir, 'eeg_pipeline_helpers.m');
            diagnostics = codeIssues(helpers_path);
            testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), 'Code Errors in pipeline_helpers!');
        end

        function stepsCodeAnalysis(testCase)
            % Test looping over steps, if they pass code analysis
            testFile = mfilename('fullpath');
            repoRoot = fileparts(fileparts(testFile));
            stepsDir = fullfile(repoRoot, 'steps');
            files = dir(fullfile(stepsDir, "eeg_prep*.m"));
            for f = 1:numel(files)
                filePath = fullfile(files(f).folder, files(f).name);
                diagnostics = codeIssues(filePath);
                testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), ...
                    sprintf('Code Errors in %s!', files(f).name));
            end
        end

    end

end