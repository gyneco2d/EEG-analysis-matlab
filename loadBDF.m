function loadBDF(subjectid, bdf, overwrite)
    % loadBDF() - Read bdf file, apply 0.5-90Hz band pass filter,
    %             and split into MAT files for each state based on 'EEG.event'
    %
    % Usage:
    %   >> loadBDF( 'subject01', ...
    %               '/User/gyneco2d/Documents/MATLAB/subjectnameHRtoCD.bdf' );
    %
    % Inputs:
    %   subjectid - [string] subject identifier
    %   bdf       - [string] bdf file path
    %   overwrite - [string] overwrite : overwrite even if mat file already exists
    %                        skip      : return control if mat file already exists
    %
    % Expected bdf file name:
    %   [subjectname][trial_pattern].bdf
    %     subjectname   - subject name
    %     trial_pattern - ['HRtoCD' / 'CDtoHR'] pattern of the measurment
    %                       HRtoCD - baseline1, HR, CD, baseline2
    %                       CDtoHR - baseline1, CD, HR, baseline2
    %
    % See also:
    %   >> help eeg_checkset           % the EEG dataset structure

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if ~ischar(subjectid), error('subjectid must be char'); end
    if ~exist(bdf, 'file'), error('bdf file does not exist'); end
    [filepath, name, ext] = fileparts(bdf);
    filename = [name ext];
    if ~exist('overwrite', 'var'), overwrite = 'skip'; end
    if ~strcmp(overwrite, 'overwrite') && ~strcmp(overwrite, 'skip')
        error('Invalid input for "overwrite"');
    end

    % Read filename
    filenameparts = strsplit(filename, {'HRtoCD', 'CDtoHR'});
    subjectname = filenameparts(1);
    if contains(filename, 'HRtoCD')
        section = {'baseline1', 'HR', 'CD', 'baseline2'};
        trial = 'HRtoCD';
    elseif contains(filename, 'CDtoHR')
        section = {'baseline1', 'CD', 'HR', 'baseline2'};
        trial = 'CDtoHR';
    else
        error('Not the expected file name');
    end

    % Confirm overwrite
    exportfile = fullfile(ProjectConstants.ProjectRoot, 'datasets', ...
                          strcat(subjectid, '_', trial, '.mat'));
    if exist(exportfile, 'file') && strcmp(overwrite, 'skip')
        disp(strcat(exportfile, ' already exists'));
        return
    end
    
    % Load bdf file
    ALLEEG = [];
    CURRENTSET = 0;
    EEG = pop_biosig(fullfile(filepath, filename), 'channels', ...
                     ProjectConstants.AllElectrodes, 'ref', 32);
    EEG = pop_reref(EEG, []);
    EEG.setname = subjectid;
    EEG.subjectname = subjectname;
    EEG.trial = trial;
    EEG = eeg_checkset(EEG);

    % Apply a 0.5-90Hz bandpass filter to the data
    EEG = pop_eegfiltnew(EEG, 0.5, 90);
    EEG = eeg_checkset(EEG);

    % Remove invalid events due to chattering
    previous = EEG.event(1).latency;
    invalidEvents = [];
    for index = 2:length(EEG.event)
        if EEG.event(index).latency - previous < EEG.srate
            invalidEvents = [invalidEvents index];
        else
            previous = EEG.event(index).latency;
        end
    end
    EEG = pop_editeventvals(EEG, 'delete', invalidEvents);
    EEG = eeg_checkset(EEG);

    % Trim dataset and save the original before separation
    FULLEEG = pop_select(EEG, 'point', [1 EEG.srate*830]);
    FULLEEG.setname = char(strcat(subjectid, " - full"));
    FULLEEG = eeg_checkset(FULLEEG);
    [ALLEEG] = pop_newset(ALLEEG, FULLEEG, 0, 'gui', 'off');

    % Separate data for each state
    event = EEG.event;
    for index = 1:length(event)
        EEG = pop_editeventvals(EEG, 'delete', 1);
    end
    EEG = eeg_checkset(EEG);
    REFERENCE_EEG = EEG;
    for index = 1:length(section)
        first = event(index).latency;
        last = (first-1) + REFERENCE_EEG.srate*200;
        EEG = pop_select(REFERENCE_EEG, 'point', [first last]);
        EEG.setname = char(strcat(subjectid, " - ", section{index}));
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'gui', 'off');
    end

    % Create datasets for latter half (100sec) of each state
    for index = 1:length(section)
        EEG = pop_select(ALLEEG(ProjectConstants.SectionIndex(index)), ...
                         'time', [100 200]);
        EEG.setname = char(...
            strcat(subjectid, " - ", section{index}, " - second half"));
        EEG = eeg_checkset(EEG);
        [ALLEEG EEG CURRENTSET] = pop_newset(ALLEEG, EEG, 0, 'gui', 'off');
    end

    % Export data to mat file
    save(exportfile, 'ALLEEG', 'EEG', 'CURRENTSET');
end
