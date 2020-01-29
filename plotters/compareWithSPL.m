function compareWithSPL(AlphaEEG, audiofile, plotchannel)
    % compareWithSPL() - Plot SPL(sound pressure level) and alpha band power in time series
    %
    % Usage:
    %   >> compareWithSPL()
    %
    % Inputs:
    %   plotchannel - [integer array] electrode number used for plotting
    %
    % Required files:
    %   [mat] - continuous data of listening state
    %   [wav] - continuous sound record of listening state

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('plotchannel', 'var'); plotchannel = [14:18]; end

    % Read audio file
    [audio, Fs] = audioread(audiofile);

    % Smoothing
    smoothspl = movmean(abs(audio), Fs * ProjectConstants.SmoothingWindowSize);
    for channel = plotchannel
        smoothpower(channel, :) = movmean(AlphaEEG(1).timeseries_power(channel, :), ProjectConstants.SmoothingWindowSize);
    end

    % Plot
    figure;
    subplot(211);
    hold on;
    for channel = plotchannel
        plot(smoothpower(channel, :));
    end
    subplot(212);
    plot(smoothspl);
end
