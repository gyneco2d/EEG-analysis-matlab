function compareByState(AlphaEEG, channel)
    % compareByState() - Plot original AlphaEEG & detrended AlphaEEG power for each state
    %
    % Usage:
    %   >> compareByState( AlphaEEG, [14:18] );
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlphaWaves()
    %   channel  - [integer array] electrode number used for calculation & plotting

    % Confirm args
    if ~exist('channel', 'var'); channel = [14:18]; end

    import constants.ProjectConstants;

    sessions = [];
    for iState = ProjectConstants.LatterHalfDataIndex
        sessions = [sessions mean(AlphaEEG(iState).normalized_rootmean(channel))];
    end
    detrended = detrend(sessions) + mean(sessions);

    % Create label for plotting
    label = [];
    for iState = ProjectConstants.LatterHalfDataIndex
        name = strsplit(AlphaEEG(iState).setname, ' - ');
        label = [label name(2)];
    end

    % Plot the data before detrend
    figure;
    bar(ProjectConstants.LatterHalfDataIndex, sessions, 'b');
    xticks(ProjectConstants.LatterHalfDataIndex);
    xticklabels(label);
    xlabel('State');
    ylabel('Power');
    title('AlphaEEG power per state');

    % Plot detrended data
    figure;
    bar(ProjectConstants.LatterHalfDataIndex, detrended, 'g');
    xticks(ProjectConstants.LatterHalfDataIndex);
    xticklabels(label);
    xlabel('State');
    ylabel('Power');
    title('AlphaEEG power per state (detrended)');
end
