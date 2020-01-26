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
    %   AlphaEEG setname                  - dataset name
    %            axis                     - frequency axis
    %            freq_distribution        - EEG power for each frequency 
    %            timeseries_power         - square root of the averaged alpha waves for each fft window
    %            raw                      - alpha waves in all fft windows
    %            section_power            - square root of the averaged alpha waves in the section
    %            normalized               - normalized alpha waves (respect to raw average)
    %            normalized_section_power - normalized section_power (respect to raw average)

    % Load EEG data from .mat file
    if ~ischar(filepath)
        error('specify an existing file');
    end
    load(filepath);

    import('constants.BioSemiConstants');
    import('constants.ProjectConstants');

    n = BioSemiConstants.Fs * ProjectConstants.FFTInterval;
    f = (0:n-1)*(BioSemiConstants.Fs/n);
    for iState = 1:size(ALLEEG, 2)
        totalTime = length(ALLEEG(iState).data(1, :)) / BioSemiConstants.Fs;
        nComponent = fix(totalTime - 1);
        stepsize = n / 2;
        alphaIndex = calcFreqIndex(ProjectConstants.AlphaWaves, f);
        AlphaEEG(iState).setname = ALLEEG(iState).setname;
        AlphaEEG(iState).axis = f;
        AlphaEEG(iState).freq_distribution = zeros(32, n);
        AlphaEEG(iState).eeg_percentage = struct();
        AlphaEEG(iState).timeseries_power = zeros(32, nComponent);
        AlphaEEG(iState).raw = zeros(32, length(alphaIndex)*nComponent);
        AlphaEEG(iState).section_power = zeros(32, 1);

        for channel = BioSemiConstants.Electrodes
            for iComponent = 1:nComponent
                first = (iComponent-1)*stepsize + 1;
                last = first + (n-1);
                x = ALLEEG(iState).data(channel, first:last);
                y = fft(x);
                power = abs(y).^2/n;

                AlphaEEG(iState).freq_distribution(channel, :) = AlphaEEG(iState).freq_distribution(channel, :) + power;
                for iAlpha = 1:length(alphaIndex)
                    AlphaEEG(iState).raw(channel, iAlpha + (iComponent-1)*length(alphaIndex)) = power(alphaIndex(iAlpha));
                end
                AlphaEEG(iState).timeseries_power(channel, iComponent) = sqrt(mean(power(alphaIndex)));
            end
            AlphaEEG(iState).freq_distribution(channel, :) = AlphaEEG(iState).freq_distribution(channel, :) / nComponent;
            AlphaEEG(iState).section_power(channel, 1) = sqrt(mean(AlphaEEG(iState).raw(channel, :)));
        end
        fftpower = AlphaEEG(iState).freq_distribution;
        freqaxis = AlphaEEG(iState).axis;
        [AlphaEEG(iState).eeg_percentage.theta, AlphaEEG(iState).eeg_percentage.alpha,...
            AlphaEEG(iState).eeg_percentage.beta, AlphaEEG(iState).eeg_percentage.gamma] = calcEEGpercentage(fftpower, freqaxis);
        standard = mean(AlphaEEG(iState).raw, 'all');
        AlphaEEG(iState).normalized = AlphaEEG(iState).raw / standard;
        for channel = BioSemiConstants.Electrodes
            AlphaEEG(iState).normalized_section_power(channel, 1) = sqrt(mean(AlphaEEG(iState).normalized(channel, :)));
        end
    end
end
