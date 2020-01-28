function [AlphaEEG] = collectAlphaWaves(filepath)
    % collectAlphaWaves() - Collect alpha waves (8-13Hz) into structure 'AlphaEEG'
    %
    % Usage:
    %   >> collectAlphaWaves( '/Users/gyneco2d/Documents/MATLAB/subject01_HRtoCD.mat' );
    %
    % Inputs:
    %   filepath - [string] source file path
    %
    % structure array:
    %   AlphaEEG setname                      - dataset name
    %            axis                         - frequency axis
    %            freq_distribution            - EEG power for each frequency 
    %            timeseries_freq_distribution - time series EEG power for each frequency
    %            eeg_percentage               - EEG percentages
    %            timeseries_eeg_percentage    - timeseries EEG percentages
    %            raw                          - alpha waves in all fft windows
    %            section_power                - square root of the averaged alpha waves in the section
    %            timeseries_power             - square root of the averaged alpha waves for each fft window
    %            normalized                   - normalized alpha waves (respect to raw average)
    %            normalized_section_power     - normalized section_power (respect to raw average)

    % Load EEG data from .mat file
    if ~ischar(filepath)
        error('specify an existing file');
    end
    load(filepath);

    % Import constants
    import('constants.BioSemiConstants');
    import('constants.ProjectConstants');

    n = BioSemiConstants.Fs * ProjectConstants.FFTInterval;
    f = (0:n-1)*(BioSemiConstants.Fs/n);
    for section = 1:size(ALLEEG, 2)
        totalTime = length(ALLEEG(section).data(1, :)) / BioSemiConstants.Fs;
        nComponent = fix(totalTime - 1);
        stepsize = n / 2;
        alphaIndex = calcFreqIndex(ProjectConstants.AlphaWaves, f);

        % Initialize AlphaEEG structure
        AlphaEEG(section).setname = ALLEEG(section).setname;
        AlphaEEG(section).axis = f;
        AlphaEEG(section).freq_distribution = zeros(32, n);
        AlphaEEG(section).timeseries_freq_distribution(nComponent) = {[]};
        AlphaEEG(section).eeg_percentage = struct();
        AlphaEEG(section).timeseries_eeg_percentage = struct();
        AlphaEEG(section).raw = zeros(32, length(alphaIndex)*nComponent);
        AlphaEEG(section).section_power = zeros(32, 1);
        AlphaEEG(section).timeseries_power = zeros(32, nComponent);

        for channel = BioSemiConstants.Electrodes
            for iComponent = 1:nComponent
                % Main FFT processing
                first = (iComponent-1)*stepsize + 1;
                last = first + (n-1);
                x = ALLEEG(section).data(channel, first:last);
                y = fft(x);
                power = abs(y).^2/n;

                % Summation of frequency distribution for calculation average
                AlphaEEG(section).freq_distribution(channel, :) = ...
                    AlphaEEG(section).freq_distribution(channel, :) + power;
                % Save time series frequency distribution
                AlphaEEG(section).timeseries_freq_distribution(iComponent) = ...
                    {...
                        [cell2mat(AlphaEEG(section).timeseries_freq_distribution(iComponent));
                        power]...
                    };

                % Save unprocessed Alpha wave power
                for index = 1:length(alphaIndex)
                    AlphaEEG(section).raw(channel, index + (iComponent-1)*length(alphaIndex)) = power(alphaIndex(index));
                end
                % Save time series fft window power
                AlphaEEG(section).timeseries_power(channel, iComponent) = sqrt(mean(power(alphaIndex)));
            end
            % Save the average frequency distribution
            AlphaEEG(section).freq_distribution(channel, :) = ...
                AlphaEEG(section).freq_distribution(channel, :) / nComponent;
            AlphaEEG(section).section_power(channel, 1) = ...
                sqrt(mean(AlphaEEG(section).raw(channel, :)));
        end
        % Calculate the overall EEG percentage
        fftpower = AlphaEEG(section).freq_distribution;
        freqaxis = AlphaEEG(section).axis;
        [...
            AlphaEEG(section).eeg_percentage.theta, ...
            AlphaEEG(section).eeg_percentage.alpha,...
            AlphaEEG(section).eeg_percentage.beta, ...
            AlphaEEG(section).eeg_percentage.gamma ...
        ] = calcEEGpercentage(fftpower, freqaxis);

        % Save frequency distribution for each time series
        for iComponent = 1:nComponent
            [...
                AlphaEEG(section).timeseries_eeg_percentage(iComponent).theta,...
                AlphaEEG(section).timeseries_eeg_percentage(iComponent).alpha,...
                AlphaEEG(section).timeseries_eeg_percentage(iComponent).beta,...
                AlphaEEG(section).timeseries_eeg_percentage(iComponent).gamma...
            ] = calcEEGpercentage(...
                    cell2mat(AlphaEEG(section).timeseries_freq_distribution(iComponent)), ...
                    AlphaEEG(section).axis);
        end

        % Create normalized data
        standard = mean(AlphaEEG(section).raw, 'all');
        AlphaEEG(section).normalized = AlphaEEG(section).raw / standard;
        for channel = BioSemiConstants.Electrodes
            AlphaEEG(section).normalized_section_power(channel, 1) = ...
                sqrt(mean(AlphaEEG(section).normalized(channel, :)));
        end
    end
end
