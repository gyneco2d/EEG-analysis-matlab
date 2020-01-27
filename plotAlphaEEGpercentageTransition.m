function plotAlphaEEGpercentageTransition(AlphaEEG)
    % plotAlphaEEGpercentageTransition() - plot subject Alpha EEG percentage transition
    %
    % Usage:
    %   >> plotAlphaEEGpercentageTransition( AlphaEEG );
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by aggregateSubjectAlphaEEG()

    trialHRtoCD = figure();
    hold('on');
    trialCDtoHR = figure();
    hold('on');
    for index = 1:length(AlphaEEG)
        pctAlpha = [];
        for component = 1:length(AlphaEEG(index).timeseries_eeg_percentage)
            pctAlpha = [pctAlpha AlphaEEG(index).timeseries_eeg_percentage(component).alpha];
        end
        if mod(index, 2) ~= 0
            figure(trialHRtoCD);
        else
            figure(trialCDtoHR);
        end
        plot(movmean(pctAlpha, constants.ProjectConstants.SmoothingWindowSize));
    end

    subjects = {};
    for index = 1:length(AlphaEEG)
        if mod(index, 2) ~= 0
            parts = strsplit(AlphaEEG(index).setname, '_');
            subjects = [subjects {char(parts(1))}];
        end
    end
    figure(trialHRtoCD);
    legend(subjects, 'location', 'northeast');
    ylim([0 100]);
    xlabel('Time');
    ylabel('Percentage [%]');
    title('[Trial HRtoCD] Alpha EEG percentage transition');

    figure(trialCDtoHR);
    legend(subjects, 'location', 'northeast');
    ylim([0 100]);
    xlabel('Time');
    ylabel('Percentage [%]');
    title('[Trial CDtoHR] Alpha EEG percentage transition');
end
