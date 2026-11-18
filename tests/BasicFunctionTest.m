classdef BasicFunctionTest < matlab.unittest.TestCase

    properties
        RepoRoot
        OutputDir
        Config
    end
    
    methods (TestClassSetup)
        % Shared setup for the entire test class
        function setupPaths(testCase)
            testFile = mfilename('fullpath');
            testCase.RepoRoot = fileparts(fileparts(testFile));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(testCase.RepoRoot, 'steps')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture( ...
                fullfile(testCase.RepoRoot, 'tests')));

            outputFixture = testCase.applyFixture( ...
                matlab.unittest.fixtures.TemporaryFolderFixture);
            testCase.OutputDir = outputFixture.Folder;
        end

        function setupConfig(testCase)
            testCase.Config = eeg_pipeline_config();
        end
    end

    methods (TestMethodSetup)
        % Setup for each test
    end

    methods (Test)
        % Test methods


        % function checkConfigStruct(testCase) % check that the config
        % comes out right
        %     config_struct = eeg_pipeline_config();
        % 
        % end
        function unimplementedTest(testCase)
            testCase.verifyFail("Unimplemented test");
        end
    end

end