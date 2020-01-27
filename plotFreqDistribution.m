function plotFreqDistribution(AlphaEEG, channels)
    % plotFreqDistribution() - Plot frequency distribution
    %
    % Usage:
    %   >> plotFreqDistribution()
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlpha()
    %   channels - [integer array] electrode number used for plotting

    % Confirm args
    if ~exist('channels', 'var'); channels = [14:18]; end

    import constants.ProjectConstants;

    setname = strsplit(AlphaEEG(1).setname, ' - ');
    % Plot each channel in each state
    for section = ProjectConstants.SecondHalfSectionIndex
        figure('Name', string(setname(1)), 'NumberTitle', 'off');
        hold on;
        for channel = channels
            plot(AlphaEEG(section).axis, AlphaEEG(section).freq_distribution(channel, :));
        end
        legend(strsplit(num2str(channels), ' '), 'Location', 'northeast');
        xlim([6 15]);
        ylim([0 100000]);
        xlabel('Frequency[Hz]');
        ylabel('Power[uV]');
        title(AlphaEEG(section).setname);
    end

    % Plot the channel average for each state
    figure('Name', string(setname(1)), 'NumberTitle', 'off');
    hold on;
    for section = ProjectConstants.SecondHalfSectionIndex
        avgOfChannels = zeros(32, length(AlphaEEG(section).freq_distribution(1, :)));
        for channel = channels
            avgOfChannels = avgOfChannels + AlphaEEG(section).freq_distribution(channel, :);
        end
        avgOfChannels = avgOfChannels / length(channels);
        plot(AlphaEEG(section).axis, avgOfChannels);
    end
    status = [];
    for section = ProjectConstants.SecondHalfSectionIndex
        name = strsplit(AlphaEEG(section).setname, ' - ');
        status = horzcat(status, name(2));
    end
    legend(status, 'Location', 'northeast');
    xlim([6 15]);
    ylim([0 100000]);
    xlabel('Frequency[Hz]');
    ylabel('Power[uV]');
    title(append('Compare [', string(setname(1)), '] for each state'));
end
