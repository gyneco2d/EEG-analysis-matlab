function plotFreqDistribution(EEGFREQS, channels)
    % plotFreqDistribution() - Plot frequency distribution
    %
    % Usage:
    %   >> plotFreqDistribution( EEGFREQS, [14:18] );
    %
    % Inputs:
    %   EEGFREQS - [structure] structure created by fftEEGdata()
    %   channels - [integer array] electrode number used for plotting

    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('channels', 'var')
        channels = ProjectConstants.OccipitalElectrodes;
    end
    
    % Create figure labels
    labels = {};
    for index = 1:length(channels)
        labels = [labels ['channel' num2str(channels(index))]];
    end
    xlimit = [6 15];
    ylimit = [0 100000];
    sectionNames = {};
    for section = 1:length(EEGFREQS)
        nameparts = strsplit(EEGFREQS(section).setname, ' - ');
        sectionNames{length(sectionNames)+1} ...
            = [char(nameparts(1)), ' - ', char(nameparts(2))];
    end

    % Plot each channel in each section
    for section = 1:length(EEGFREQS)
        nameparts = strsplit(EEGFREQS(section).setname, ' - ');
        figure('Name', string(sectionNames(section)), 'NumberTitle', 'off');
        hold('on');
        for channel = channels
            plot(EEGFREQS(section).axis, EEGFREQS(section).distribution(channel, :));
        end
        legend(labels, 'Location', 'northeast');
        xlim(xlimit);
        ylim(ylimit);
        xlabel('Frequency[Hz]');
        ylabel('Power[uV]');
        title(nameparts(2));
    end

    % Plot the channel average for each datasets
    subjects = {};
    for section = 1:length(EEGFREQS)
        sectionName = strsplit(EEGFREQS(section).setname, ' - ');
        if length(subjects) == 0 || ~strcmp(subjects(end), sectionName(1))
            subjects{length(subjects)+1} = cell2mat(sectionName(1));
        end
    end
    figure('Name', cell2mat(join(subjects, ' - ')), 'NumberTitle', 'off');
    hold('on');
    for section = 1:length(EEGFREQS)
        avgOfChannels = zeros(32, length(EEGFREQS(section).distribution(1, :)));
        for channel = channels
            avgOfChannels = avgOfChannels + EEGFREQS(section).distribution(channel, :);
        end
        avgOfChannels = avgOfChannels / length(channels);
        plot(EEGFREQS(section).axis, avgOfChannels);
    end
    legend(sectionNames, 'Location', 'northeast');
    xlim(xlimit);
    ylim(ylimit);
    xlabel('Frequency[Hz]');
    ylabel('Power[uV]');
    title(append('Compare [', join(subjects, ' - '), '] for each section'));
end
