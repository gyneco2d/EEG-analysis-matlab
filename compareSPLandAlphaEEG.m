function compareSPLandAlphaEEG(plotchannel)
    % compareAlphaEEGandSPL() - Plot SPL(sound pressure level) and alpha band power in time series
    %
    % Usage:
    %   >> compareAlphaEEGandSPL()
    %
    % Inputs:
    %   plotchannel - [integer array] electrode number used for plotting

    disp('select EEG data');
    [filename, filepath] = uigetfile('*.mat');
    if ~ischar(filename) || ~ischar(filepath)
        error('no files selected');
    end
    load(strcat(filepath, filename));
    disp(strcat('Read: ', filepath, filename));

    disp('select audio file');
    [filename, filepath] = uigetfile('*.wav');
    if ~ischar(filename) || ~ischar(filepath)
        error('no files selected');
    end
    [audio, Fs] = audioread(strcat(filepath, filename));
    disp(strcat('Read: ', filepath, filename));

    % sampling frequency: 2048Hz
    fs = 2048;
    % electrode channels
    channels = [1:32];
    % fft interval: 2sec
    interval = 2;
    % alpha wave band: 8-13Hz
    alphaBand = [8:13];
    % window size
    windowsize = 30;
    % default channel for plot
    if ~exist('plotchannel', 'var'); plotchannel = [14:18]; end
    
    n = fs * interval;
    f = (0:n-1)*(fs/n);
    totlaTime = size(ALLEEG(1).data, 2) / fs;
    nComponent = fix(totlaTime - 1);
    stepsize = n / 2;
    alphaBandIndex = calcFreqIndex(alphaBand, f);
    timeseries_rootmean = zeros(32, nComponent);
    for channel = channels
        for iComponent = 1:nComponent
            first = (iComponent-1)*stepsize + 1;
            last = first + (n-1);
            x = ALLEEG(1).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;
            timeseries_rootmean(channel, iComponent) = sqrt(mean(power(alphaBandIndex)));
        end
        smoothdata(channel, :) = movmean(timeseries_rootmean(channel, :), windowsize);
    end
    subplot(211);
    hold on;
    for iChannel = plotchannel
        plot(smoothdata(iChannel, :));
    end
    subplot(212);
    plot(abs(audio));
end
