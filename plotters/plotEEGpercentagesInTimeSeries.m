function plotEEGpercentagesInTimeSeries(AlphaEEG)
    % plotEEGpercentageInTimeSeries() - plot EEG & Alpha wave percentage transition
    %
    % Usage:
    %  >> plotEEGpercentageInTimeSeries( AlphaEEG );
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlphaWaves()

    percentages = [];
    pctAlpha = [];
    for component = 1:length(AlphaEEG(1).timeseries_eeg_percentage)
        percentages = [
            percentages;
            AlphaEEG(1).timeseries_eeg_percentage(component).theta...
            AlphaEEG(1).timeseries_eeg_percentage(component).alpha...
            AlphaEEG(1).timeseries_eeg_percentage(component).beta...
            AlphaEEG(1).timeseries_eeg_percentage(component).gamma...
        ];
        pctAlpha = [pctAlpha AlphaEEG(1).timeseries_eeg_percentage(component).alpha];
    end

    figure();
    bar(percentages, 'stacked');
    legend({'theta', 'alpha', 'beta', 'gamma'}, 'location', 'northeast');
    ylim([0 100]);
    xlabel('Time');
    ylabel('Percentage [%]');
    title('EEG percentage in time series');

    figure();
    plot(movmean(pctAlpha, constants.ProjectConstants.SmoothingWindowSize));
    xlabel('Time');
    ylabel('Percentage [%]');
    title('Alpha EEG percentage in time series');
end
