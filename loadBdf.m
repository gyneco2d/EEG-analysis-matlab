function loadBdf(exportname, displayname, pattern)
    % loadBdf() - Read bdf file, apply 0.5-90Hz band pass filter,
    %             and split into '.mat' files for each state based on 'EEG.event'
    %
    % Usage:
    %   >> loadBdf( 'ito', '伊藤', 0 );  % Open dialog to generate '.mat' file based on selected file
    %
    % Inputs:
    %   exportname  - [string] subject name
    %   displayname - [string] subject name for display
    %   pattern     - [0/1] order of sound source to be presented
    %                    0: baseline1, HR, CD, baseline2
    %                    1: baseline1, CD, HR, baseline2
    %
    % See also:
    %   >> help eeg_checkset           % the EEG dataset structure

    % Confirm args
    clearvars -except exportname displayname pattern;
    if ~ischar(exportname); error('exportname must be char'); end
    if ~isnumeric(pattern); error('pattern must be numeric'); end
    if pattern == 0
        status = {'baseline1', 'HR', 'CD', 'baseline2'};
        exportname = strcat(exportname, 'HRtoCD');
    else
        status = {'baseline1', 'CD', 'HR', 'baseline2'};
        exportname = strcat(exportname, 'CDtoHR');
    end

    % Load bdf file
    [filename, filepath] = uigetfile('*.bdf');
    if ~ischar(filename) || ~ischar(filepath)
        error('no files selected');
    end
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_biosig(strcat(filepath, filename), 'channels', constants.BioSemiConstants.Electrodes, 'ref', 32);
    EEG = pop_reref(EEG, []);
    EEG.setname = displayname;
    EEG.filename = filename;
    EEG.filepath = filepath;
    EEG = eeg_checkset(EEG);

    % Apply a 0.5-90Hz bandpass filter to the data
    EEG = pop_eegfiltnew(EEG, 0.5, 90);
    EEG = eeg_checkset(EEG);

    % Remove invalid events due to chattering
    previous = EEG.event(1).latency;
    invalids = [];
    for index = 2:length(EEG.event)
        if EEG.event(index).latency - previous < constants.BioSemiConstants.Fs
            invalids = [invalids index];
        else
            previous = EEG.event(index).latency;
        end
    end
    for index = invalids
        EEG = pop_editeventvals(EEG, 'delete', index);
    end
    EEG = eeg_checkset(EEG);

    % Export data before separation
    [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'gui', 'off');
    save(strcat(filepath, exportname, '', '.mat'), 'ALLEEG', 'EEG', 'CURRENTSET', 'status');
    ALLEEG(1) = [];

    % Separate data for each state
    event = EEG.event;
    for index = 1:length(event)
        EEG = pop_editeventvals(EEG, 'delete', 1);
    end
    EEG = eeg_checkset(EEG);
    REFERENCE_EEG = EEG;
    for index = 1:length(status)
        first = event(index).latency;
        last = (first-1) + constants.BioSemiConstants.Fs*200;
        EEG = pop_select(REFERENCE_EEG, 'point', [first last]);
        EEG.setname = char(strcat(displayname, " - ", status{index}));
        EEG.subjectname = exportname;
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'gui', 'off');
    end

    % Create datasets for latter half (100sec) of each state
    for index = 1:size(ALLEEG, 2)
        EEG = pop_select(ALLEEG(index), 'time', [100 200]);
        EEG.setname = char(strcat(displayname, " - ", status{index}, " - latter 100sec"));
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'gui', 'off');
    end

    % Export data separated by state
    save(strcat(filepath, exportname, 'separated', '.mat'), 'ALLEEG', 'EEG', 'CURRENTSET', 'status');
end
