function [EEGFREQS] = fftEEGdata(ALLEEG)
    % fftEEGdata() - FFT EEGLAB datasets into structure 'EEGFREQS'
    %
    % Usage:
    %   >> fftEEGdata( ALLEEG );
    %
    % Inputs:
    %   ALLEEG - [structure] EEGLAB dataset structure
    %
    % structure array:
    %   EEGFREQS setname                      - dataset name
    %            axis                         - frequency axis
    %            distribution                 - EEG power for each frequency 
    %            timeseries_distribution      - time series EEG power for each frequency
    %            percentage                   - EEG percentages
    %            timeseries_percentage        - timeseries EEG percentages
    %            raw                          - alpha waves in all fft windows
    %            section_power                - square root of the averaged alpha waves in the section
    %            timeseries_power             - square root of the averaged alpha waves for each fft window
    %            normalized                   - normalized alpha waves (respect to raw average)
    %            normalized_section_power     - normalized section_power (respect to raw average)

    % Import constants
    import('constants.ProjectConstants');

    n = ProjectConstants.BioSemiSamplingRate * ProjectConstants.FFTwindowSize;
    f = (0:n-1)*(ProjectConstants.BioSemiSamplingRate/n);
    for section = 1:size(ALLEEG, 2)
        totalTime = length(ALLEEG(section).data(1, :)) / ...
                    ProjectConstants.BioSemiSamplingRate;
        nComponent = fix(totalTime - 1);
        stepsize = n / 2;
        alphaIndex = calcFreqIndex(ProjectConstants.AlphaWaves, f);

        % Initialize EEGFREQS structure
        EEGFREQS(section).setname = ALLEEG(section).setname;
        EEGFREQS(section).axis = f;
        EEGFREQS(section).distribution = zeros(32, n);
        EEGFREQS(section).timeseries_distribution(nComponent) = {[]};
        EEGFREQS(section).percentage = struct();
        EEGFREQS(section).timeseries_percentage = struct();
        EEGFREQS(section).raw = zeros(32, length(alphaIndex)*nComponent);
        EEGFREQS(section).section_power = zeros(32, 1);
        EEGFREQS(section).timeseries_power = zeros(32, nComponent);

        for channel = ProjectConstants.AllElectrodes
            for iComponent = 1:nComponent
                % FFT EEG data in window
                first = (iComponent-1)*stepsize + 1;
                last = first + (n-1);
                x = ALLEEG(section).data(channel, first:last);
                y = fft(x);
                power = abs(y).^2/n;

                % Sum to find the average frequency distribution
                EEGFREQS(section).distribution(channel, :) = ...
                    EEGFREQS(section).distribution(channel, :) + power;
                % Collect frequency distribution for each fft window
                EEGFREQS(section).timeseries_distribution(iComponent) = ...
                    {...
                        [cell2mat(EEGFREQS(section).timeseries_distribution(iComponent));
                        power]...
                    };

                % Save unprocessed Alpha wave power
                for index = 1:length(alphaIndex)
                    EEGFREQS(section).raw(channel, index + (iComponent-1)*length(alphaIndex)) = ...
                        power(alphaIndex(index));
                end
                % Collect alpha wave power for each fft window
                EEGFREQS(section).timeseries_power(channel, iComponent) = ...
                    sqrt(mean(power(alphaIndex)));
            end
            % Calculate the average frequency distribution between fft window
            EEGFREQS(section).distribution(channel, :) = ...
                EEGFREQS(section).distribution(channel, :) / nComponent;
            EEGFREQS(section).section_power(channel, 1) = ...
                sqrt(mean(EEGFREQS(section).raw(channel, :)));
        end

        % Calculate the percentage of each EEG
        fftpower = EEGFREQS(section).distribution;
        freqaxis = EEGFREQS(section).axis;
        [...
            EEGFREQS(section).percentage.theta, ...
            EEGFREQS(section).percentage.alpha,...
            EEGFREQS(section).percentage.beta, ...
            EEGFREQS(section).percentage.gamma ...
        ] = calcEEGpercentage(fftpower, freqaxis);

        % Collect the percentage of each EEG for each fft window
        for iComponent = 1:nComponent
            [...
                EEGFREQS(section).timeseries_percentage(iComponent).theta,...
                EEGFREQS(section).timeseries_percentage(iComponent).alpha,...
                EEGFREQS(section).timeseries_percentage(iComponent).beta,...
                EEGFREQS(section).timeseries_percentage(iComponent).gamma...
            ] = calcEEGpercentage(...
                    cell2mat(EEGFREQS(section).timeseries_distribution(iComponent)), ...
                    EEGFREQS(section).axis);
        end

        % Create normalized data
        standard = mean(EEGFREQS(section).raw, 'all');
        EEGFREQS(section).normalized = EEGFREQS(section).raw / standard;
        for channel = ProjectConstants.AllElectrodes
            EEGFREQS(section).normalized_section_power(channel, 1) = ...
                sqrt(mean(EEGFREQS(section).normalized(channel, :)));
        end
    end
end
