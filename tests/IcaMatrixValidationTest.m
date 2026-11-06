classdef IcaMatrixValidationTest < matlab.unittest.TestCase
    properties (Access = private)
        Helpers
    end

    methods (TestClassSetup)
        function loadHelpers(testCase)
            repoRoot = fileparts(fileparts(mfilename('fullpath')));
            testCase.applyFixture(matlab.unittest.fixtures.PathFixture(fullfile(repoRoot, 'steps')));
            testCase.Helpers = eeg_pipeline_helpers('');
        end
    end

    methods (Test)
        function acceptsAutomaticallyReducedRunicaOutput(testCase)
            sphere = eye(62);
            weights = sphere(1:61, :);

            componentCount = testCase.Helpers.validate_ica_matrices(weights, sphere, [], 62, 'runica');

            testCase.verifyEqual(componentCount, 61);
        end

        function rejectsMismatchWithExplicitPcaDimension(testCase)
            sphere = eye(62);
            weights = sphere(1:61, :);

            testCase.verifyError(@() testCase.Helpers.validate_ica_matrices( ...
                weights, sphere, 62, 62, 'runica'), ?MException);
        end

        function rejectsMoreComponentsThanChannels(testCase)
            sphere = eye(62);
            weights = [sphere; sphere(1, :)];

            testCase.verifyError(@() testCase.Helpers.validate_ica_matrices( ...
                weights, sphere, [], 62, 'runica'), ?MException);
        end
    end
end
