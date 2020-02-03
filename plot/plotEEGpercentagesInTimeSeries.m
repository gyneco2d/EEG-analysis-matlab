function plotEEGpercentagesInTimeSeries(EEGFREQS, wave)
    % plotEEGpercentageInTimeSeries() - plot EEG percentage & each wave transition
    %
    % Usage:
    %  >> plotEEGpercentageInTimeSeries( EEGFREQS );
    %
    % Inputs:
    %   EEGFREQS - [structure] structure created by fftEEGdata()
    %   wave     - [string: 'all' / 'theta' / 'alpha' / 'beta' / 'gamma']
    %              specify EEG wave to plot

    import('constants.ProjectConstants');

    % Confirm args
    if length(EEGFREQS) ~= 1, error('Required 1 EEGFREQS'); end
    if ~exist('wave', 'var'), wave = 'all'; end
    if ~any(strcmp(wave, {'all', 'theta', 'alpha', 'beta', 'gamma'}))
        error('Invalid EEG wave name');
    end

    waves = {'theta', 'alpha', 'beta', 'gamma'};
    percentages = [];
    pctWaves = zeros(length(waves), 0);
    for component = 1:length(EEGFREQS.timeseries_percentage)
        percentages = [
            percentages;
            EEGFREQS(1).timeseries_percentage(component).theta...
            EEGFREQS(1).timeseries_percentage(component).alpha...
            EEGFREQS(1).timeseries_percentage(component).beta...
            EEGFREQS(1).timeseries_percentage(component).gamma...
        ];
        for index = 1:length(waves)
            pctWaves(index, component) = EEGFREQS.timeseries_percentage(component).(char(waves(index)));
        end
    end

    figure();
    bar(percentages, 'stacked');
    legend({'Theta', 'Alpha', 'Beta', 'Gamma'}, 'location', 'northeast');
    ylim([0 100]);
    xlabel('Time');
    ylabel('Percentage [%]');
    title('EEG percentage transition');

    figure();
    hold('on');
    if strcmp(wave, 'all')
        for index = 1:size(pctWaves, 1)
            plot(movmean(pctWaves(index, :), ProjectConstants.SmoothingWindowSize));
        end
        title('EEG percentage transition');
    else
        index = find(strncmp(wave, waves, length(wave)));
        plot(movmean(pctWaves(index, :), ProjectConstants.SmoothingWindowSize));
        title([upper(wave(1)) wave(2:end) ' EEG percentage transition']);
    end
    xlabel('Time');
    ylabel('Percentage [%]');
end
