function plotSectionPower(EEGFREQS, wave, channel)
    % plotSectionPower() - Plot original & detrended EEG power by section
    %
    % Usage:
    %   >> plotSectionPower( EEGFREQS, 'alpha', [14:18] );
    %
    % Inputs:
    %   EEGFREQS - [structure] structure created by fftEEGdata()
    %   wave     - [string: 'theta' / 'alpha' / 'beta' / 'gamma'] specify EEG wave to plot
    %   channel  - [integer array] electrode number used for calculation & plotting

    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('channel', 'var')
        channel = ProjectConstants.OccipitalElectrodes;
    end
    if ~exist('wave', 'var'), wave = 'alpha'; end
    if ~any(strcmp(wave, {'theta', 'alpha', 'beta', 'gamma'}))
        error('Invalid EEG wave name');
    end
    
    sections = [];
    for section = 1:length(EEGFREQS)
        sections = [sections mean(EEGFREQS(section).(['normalized_section_' wave])(channel))];
    end
    detrended = detrend(sections) + mean(sections);

    % Create label for plotting
    sectionNames = {};
    for section = 1:length(EEGFREQS)
        nameparts = strsplit(EEGFREQS(section).setname, ' - ');
        sectionNames{length(sectionNames)+1} ...
            = [char(nameparts(1)), ' - ', char(nameparts(2))];
    end

    % Plot the data before detrend
    figure;
    bar([1:length(EEGFREQS)], sections, 'b');
    xticks([1:length(EEGFREQS)]);
    xticklabels(sectionNames);
    xlabel('State');
    ylabel('Power');
    title([wave ' EEG wave power per state']);

    % Plot detrended data
    figure;
    bar([1:length(EEGFREQS)], detrended, 'g');
    xticks([1:length(EEGFREQS)]);
    xticklabels(sectionNames);
    xlabel('State');
    ylabel('Power');
    title([wave ' EEG power per state (detrended)']);
end
