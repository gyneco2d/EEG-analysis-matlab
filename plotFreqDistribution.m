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

    setname = strsplit(AlphaEEG(1).setname, ' - ');
    % Plot each channel in each state
    for iState = 1:size(AlphaEEG, 2)
        figure('Name', string(setname(1)), 'NumberTitle', 'off');
        hold on;
        for channel = channels
            plot(AlphaEEG(iState).axis, AlphaEEG(iState).freq_distribution(channel, :));
        end
        legend(strsplit(num2str(channels), ' '), 'Location', 'northeast');
        xlim([6 15]);
        ylim([0 100000]);
        xlabel('Frequency[Hz]');
        ylabel('Power[uV]');
        title(AlphaEEG(iState).setname);
    end

    % Plot the channel average for each state
    figure('Name', string(setname(1)), 'NumberTitle', 'off');
    hold on;
    for iState = 1:size(AlphaEEG, 2)
        avgOfChannels = zeros(32, length(AlphaEEG(iState).freq_distribution(1, :)));
        for channel = channels
            avgOfChannels = avgOfChannels + AlphaEEG(iState).freq_distribution(channel, :);
        end
        avgOfChannels = avgOfChannels / length(channels);
        plot(AlphaEEG(iState).axis, avgOfChannels);
    end
    status = [];
    for iState = 1:size(AlphaEEG, 2)
        name = strsplit(AlphaEEG(iState).setname, ' - ');
        status = horzcat(status, name(end));
    end
    legend(status, 'Location', 'northeast');
    xlim([6 15]);
    ylim([0 100000]);
    xlabel('Frequency[Hz]');
    ylabel('Power[uV]');
    title(append('Compare [', string(setname(1)), '] for each state'));
end
