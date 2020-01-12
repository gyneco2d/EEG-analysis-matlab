function [AlphaEEG] = collectAlphaWaves(filepath)
    % collectAlphaWaves() - Collect alpha waves (8-13Hz) into structure 'AlphaEEG'
    %
    % Usage:
    %   >> collectAlphaWaves();
    %
    % Inputs:
    %   filepath - [string] source file path
    %
    % structure array:
    %   AlphaEEG setname             - dataset name
    %            axis                - frequency axis
    %            freq_distribution   - EEG power for each frequency 
    %            timeseries_rootmean - rootmean of alpha waves for each fft section
    %            raw                 - alpha waves in all sections
    %            rootmean            - rootmean of alpha waves in all sections

    % Load EEG data from .mat file
    if ~ischar(filepath)
        error('specify an existing file');
    end
    load(filepath);

    import constants.BioSemiConstants;
    import constants.ProjectConstants;

    n = BioSemiConstants.Fs * ProjectConstants.FFTInterval;
    f = (0:n-1)*(BioSemiConstants.Fs/n);
    for iState = 1:size(ALLEEG, 2)
        totalTime = length(ALLEEG(iState).data(1, :)) / BioSemiConstants.Fs;
        nComponent = fix(totalTime - 1);
        stepsize = n / 2;
        alphaBandIndex = calcFreqIndex(ProjectConstants.AlphaBand, f);
        AlphaEEG(iState).setname = ALLEEG(iState).setname;
        AlphaEEG(iState).axis = f;
        AlphaEEG(iState).freq_distribution = zeros(32, n);
        AlphaEEG(iState).timeseries_rootmean = zeros(32, nComponent);
        AlphaEEG(iState).raw = zeros(32, length(alphaBandIndex)*nComponent);
        AlphaEEG(iState).rootmean = zeros(32, 1);

        for channel = BioSemiConstants.Electrodes
            for iComponent = 1:nComponent
                first = (iComponent-1)*stepsize + 1;
                last = first + (n-1);
                x = ALLEEG(iState).data(channel, first:last);
                y = fft(x);
                power = abs(y).^2/n;

                AlphaEEG(iState).freq_distribution(channel, :) = AlphaEEG(iState).freq_distribution(channel, :) + power;
                for iAlpha = 1:length(alphaBandIndex)
                    AlphaEEG(iState).raw(channel, iAlpha + (iComponent-1)*length(alphaBandIndex)) = power(alphaBandIndex(iAlpha));
                end
                AlphaEEG(iState).timeseries_rootmean(channel, iComponent) = sqrt(mean(power(alphaBandIndex)));
            end
            AlphaEEG(iState).freq_distribution(channel, :) = AlphaEEG(iState).freq_distribution(channel, :) / nComponent;
            AlphaEEG(iState).rootmean(channel, 1) = sqrt(mean(AlphaEEG(iState).raw(channel, :)));
        end
    end
end
