classdef SmokeTest < matlab.unittest.TestCase
    
    properties (Access = private)
        RepoRoot
    end
    methods (TestClassSetup)
        function setupRoot(testCase)
            testFile = mfilename('fullpath');
            testCase.RepoRoot = fileparts(fileparts(testFile));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(testCase.RepoRoot, 'steps')));
        end
    end

    methods (Test)
        % Test methods
        function runnerCodeAnalysis(testCase)
            % Test that the runner script pass code analysis
            runner_path = fullfile(testCase.RepoRoot, 'run_eeg_pipeline.m');
            diagnostics = codeIssues(runner_path);
            testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), 'Code Errors in run_eeg_pipeline!');
        end

        function configCodeAnalysis(testCase)
            % Test that the configuration script pass code analysis
            config_path = fullfile(testCase.RepoRoot, 'eeg_pipeline_config.m');
            diagnostics = codeIssues(config_path);
            testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), 'Code Errors in eeg_pipeline_config!');
        end

        function helpersCodeAnalysis(testCase)
            % Test that the helper functions pass code analysis
            helpers_path = fullfile(testCase.RepoRoot, 'steps', 'eeg_pipeline_helpers.m');
            diagnostics = codeIssues(helpers_path);
            testCase.verifyFalse(any(diagnostics.Issues.('Severity')== 'error'), 'Code Errors in pipeline_helpers!');
        end

        function stepsCodeAnalysis(testCase)
            % Test looping over steps, if they pass code analysis
            stepsDir = fullfile(testCase.RepoRoot, 'steps');
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