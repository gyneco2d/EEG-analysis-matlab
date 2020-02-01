function plotTransitionWithSPL(EEGFREQS, audiofile, channel)
    % plotTransitionWithSPL() - Plot SPL(sound pressure level) and EEG transition
    %
    % Usage:
    %   >> plotTransitionWithSPL( EEGFREQS, audiofile, channel );
    %
    % Inputs:
    %   channel - [integer array] electrode number used for plot
    %
    % Required files:
    %   [mat] - continuous data of listening state
    %   [wav] - continuous sound record of listening state

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('plotchannel', 'var')
        channel = ProjectConstants.OccipitalElectrodes;
    end

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
