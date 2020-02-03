function plotSubjectsEEGpercentageTransition(EEGFREQS, wave)
    % plotSubjectsEEGpercentageTransition() - plot subject EEG percentage transition
    %
    % Usage:
    %   >> plotSubjectsEEGpercentageTransition( EEGFREQS );
    %
    % Inputs:
    %   EEGFREQS - [structure] structure created by fftEEGdata()

    % Confirm args
    if ~exist('wave', 'var'), wave = 'alpha'; end
    if ~any(strcmp(wave, {'theta', 'alpha', 'beta', 'gamma'}))
        error('Invalid EEG wave name');
    end

    trialHRtoCD = figure();
    hold('on');
    trialCDtoHR = figure();
    hold('on');
    for index = 1:length(EEGFREQS)
        pctWave = [];
        for component = 1:length(EEGFREQS(index).timeseries_percentage)
            pctWave = [pctWave EEGFREQS(index).timeseries_percentage(component).(wave)];
        end
        if mod(index, 2) ~= 0
            figure(trialHRtoCD);
        else
            figure(trialCDtoHR);
        end
        plot(movmean(pctWave, constants.ProjectConstants.SmoothingWindowSize));
    end

    subjects = {};
    for index = 1:length(EEGFREQS)
        if mod(index, 2) ~= 0
            parts = strsplit(EEGFREQS(index).setname, '_');
            subjects = [subjects {char(parts(1))}];
        end
    end
    figure(trialHRtoCD);
    legend(subjects, 'location', 'northeast');
    ylim([0 100]);
    xlabel('Time');
    ylabel('Percentage [%]');
    title(['[Trial HRtoCD] ' upper(wave(1)) wave(2:end) ' EEG percentage transition']);

    figure(trialCDtoHR);
    legend(subjects, 'location', 'northeast');
    ylim([0 100]);
    xlabel('Time');
    ylabel('Percentage [%]');
    title(['[Trial CDtoHR] ' upper(wave(1)) wave(2:end) ' EEG percentage transition']);
end
