function [eeg] = loadBdf(exportname, displayname, pattern)
    % loadBdf() - Read bdf file, apply 0.5-90Hz band pass filter,
    %             and split into '.mat' files for each state based on 'EEG.event'
    %
    % Usage:
    %   >> loadBdf( ito, '伊藤', 0 );
    %
    % Inputs:
    %   exportname  - [string] subject name
    %   displayname - [string] subject name for display
    %   pattern     - [0/1] order of sound source to be presented
    %                    0: baseline1, HR, CD, baseline2
    %                    1: baseline1, CD, HR, baseline2

    % Confirm args
    clearvars -except exportname displayname pattern;
    if ~ischar(exportname); error('exportname must be char'); end
    if ~isnumeric(pattern); error('pattern must be numeric'); end
    % Initialize
    fs = 2048;
    if pattern == 0
        status = {'baseline1', 'HR', 'CD', 'baseline2'};
    else
        status = {'baseline1', 'CD', 'HR', 'baseline2'};
    end
    if pattern == 0
        exportname = strcat(exportname, 'HRtoCD');
    else
        exportname = strcat(exportname, 'CDtoHR');
    end

    % Load bdf file
    [filename, filepath] = uigetfile('*.bdf');
    if ~ischar(filename) || ~ischar(filepath)
        error('no files selected');
    end
    [ALLEEG EEG CURRENTSET ALLCOM] = eeglab;
    EEG = pop_biosig(strcat(filepath, filename), 'channels', [1:32], 'ref', 32);
    EEG = pop_reref(EEG, []);
    EEG.setname = displayname;
    EEG = eeg_checkset(EEG);

    % Apply a 0.5-90Hz bandpass filter to the data
    EEG = pop_eegfiltnew(EEG, 0.5, 90);
    EEG = eeg_checkset(EEG);

    % Remove invalid events due to chattering
    previous = EEG.event(1).latency;
    invalids = [];
    for index = 2:length(EEG.event)
        if EEG.event(index).latency - previous < fs
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
    save(strcat(filepath, exportname, '', '.mat'));
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
        last = (first-1) + fs*200;
        EEG = pop_select(REFERENCE_EEG, 'point', [first last]);
        EEG.setname = strcat(displayname, ' - ', status{index});
        EEG.subjectname = exportname;
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'gui', 'off');
    end
    
    % Export separated by state
    save(strcat(filepath, exportname, 'separated', '.mat'));
end