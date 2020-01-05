function compareSPLandAlphaEEG(plotchannel)
    % compareAlphaEEGandSPL() - Plot SPL(sound pressure level) and alpha band power in time series
    %
    % Usage:
    %   >> compareSPLandAlphaEEG()
    %
    % Inputs:
    %   plotchannel - [integer array] electrode number used for plotting

    import constants.BioSemiConstants;
    import constants.ProjectConstants;

    % Confirm args
    if ~exist('plotchannel', 'var'); plotchannel = [14:18]; end
    
    % Source file select
    disp('Select EEG data');
    [filename, filepath] = uigetfile('*.mat');
    if ~ischar(filename) || ~ischar(filepath)
        error('no files selected');
    end
    disp(strcat('Read: ', filepath, filename));
    load(strcat(filepath, filename));

    disp('Select audio file');
    [filename, filepath] = uigetfile('*.wav');
    if ~ischar(filename) || ~ischar(filepath)
        error('no files selected');
    end
    disp(strcat('Read: ', filepath, filename));
    [audio, Fs] = audioread(strcat(filepath, filename));

    n = BioSemiConstants.Fs * ProjectConstants.FFTInterval;
    f = (0:n-1)*(BioSemiConstants.Fs/n);
    totlaTime = size(ALLEEG(1).data, 2) / BioSemiConstants.Fs;
    nComponent = fix(totlaTime - 1);
    stepsize = n / 2;
    alphaBandIndex = calcFreqIndex(ProjectConstants.AlphaBand, f);
    timeseries_rootmean = zeros(32, nComponent);
    for channel = BioSemiConstants.Electrodes
        for iComponent = 1:nComponent
            first = (iComponent-1)*stepsize + 1;
            last = first + (n-1);
            x = ALLEEG(1).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;
            timeseries_rootmean(channel, iComponent) = sqrt(mean(power(alphaBandIndex)));
        end
        smoothdata(channel, :) = movmean(timeseries_rootmean(channel, :), ProjectConstants.SmoothingWindowSize);
    end
    subplot(211);
    hold on;
    for iChannel = plotchannel
        plot(smoothdata(iChannel, :));
    end
    subplot(212);
    plot(abs(audio));
end
