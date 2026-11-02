% =========================================================================
% TEST: Count bad-channel flags across epoched EEG datasets
% =========================================================================
% Copyright (C) 2025–2026 Saskia Wilken and contributors
%
clear; clc;

base_dir = 'Z:\pb\KLPSY1\KLPSY1-RTG\MATRICS\derivatives\preprocessed_eeg\06_epoched_runica';
out_dir  = fileparts(mfilename('fullpath'));

if isempty(out_dir)
    out_dir = pwd;
end

if exist('eeglab', 'file') ~= 2
    error('EEGLAB is not on the MATLAB path.');
end

eeglab('nogui');

set_files = dir(fullfile(base_dir, '*', '*_epoched_final.set'));

if isempty(set_files)
    warning('No *_epoched_final.set files found. Falling back to any *.set files.');
    set_files = dir(fullfile(base_dir, '*', '*.set'));
end

if isempty(set_files)
    error('No .set files found under: %s', base_dir);
end

n_files = numel(set_files);

subject        = strings(n_files, 1);
set_file       = strings(n_files, 1);
n_bad_channels = zeros(n_files, 1);
bad_channels   = strings(n_files, 1);

all_bad_channels = strings(0, 1);

for i = 1:n_files

    set_path = fullfile(set_files(i).folder, set_files(i).name);
    [~, subj_id] = fileparts(set_files(i).folder);

    fprintf('[%03d/%03d] Loading %s\n', i, n_files, set_path);

    EEG = pop_loadset('filename', set_files(i).name, ...
                      'filepath', set_files(i).folder);

    bad_raw = {};

    if isfield(EEG, 'chaninfo') && ...
       isfield(EEG.chaninfo, 'bad') && ...
       ~isempty(EEG.chaninfo.bad)

        bad_raw = EEG.chaninfo.bad;
    end

    if isempty(bad_raw)
        bad = strings(1, 0);
    elseif isstring(bad_raw)
        bad = bad_raw(:)';
    elseif ischar(bad_raw)
        bad = string({bad_raw});
    elseif iscell(bad_raw)
        bad = string(bad_raw(:)');
    else
        warning('Unsupported EEG.chaninfo.bad format in %s. Skipping bad-channel list.', set_files(i).name);
        bad = strings(1, 0);
    end

    bad = strtrim(bad);
    bad = bad(strlength(bad) > 0);

    subject(i)        = string(subj_id);
    set_file(i)       = string(set_files(i).name);
    n_bad_channels(i) = numel(bad);

    if isempty(bad)
        bad_channels(i) = "";
    else
        bad_channels(i) = strjoin(bad, ", ");
        all_bad_channels = [all_bad_channels; bad(:)];
    end

end

per_subject = table( ...
    subject, ...
    set_file, ...
    n_bad_channels, ...
    bad_channels, ...
    'VariableNames', {'subject', 'set_file', 'n_bad_channels', 'bad_channels'} ...
);

if isempty(all_bad_channels)

    freq_table = table( ...
        strings(0, 1), ...
        zeros(0, 1), ...
        zeros(0, 1), ...
        'VariableNames', {'channel', 'n_flagged', 'percent_subjects'} ...
    );

else

    [channels, ~, idx] = unique(all_bad_channels);
    counts = accumarray(idx, 1);

    freq_table = table( ...
        channels, ...
        counts, ...
        100 * counts / height(per_subject), ...
        'VariableNames', {'channel', 'n_flagged', 'percent_subjects'} ...
    );

    freq_table = sortrows(freq_table, 'n_flagged', 'descend');

end

fprintf('\n========================================\n');
fprintf('Subjects/files checked: %d\n', height(per_subject));
fprintf('Total bad-channel flags: %d\n', numel(all_bad_channels));
fprintf('Unique channels flagged: %d\n', height(freq_table));
fprintf('========================================\n\n');

disp(freq_table);
disp(per_subject);

freq_out = fullfile(out_dir, 'bad_channel_frequency.csv');
subj_out = fullfile(out_dir, 'bad_channel_per_subject.csv');

writetable(freq_table, freq_out);
writetable(per_subject, subj_out);

fprintf('\nSaved:\n');
fprintf('  %s\n', freq_out);
fprintf('  %s\n', subj_out);