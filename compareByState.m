function compareByState(AlphaEEG, channel)
    % compareByState() - Detrend through state & plot AlphaEEG power for each state
    %
    % Usage:
    %   >> compareByState( AlphaEEG, [14:18] );
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlpha()
    %   channel  - [integer array] electrode number used for calc & plotting

    % Confirm args
    if ~exist('channel', 'var'); channel = [14:18]; end

    import constants.ProjectConstants;

    rootmean = [];
    for iState = ProjectConstants.LatterHalfDataIndex
        rootmean = [rootmean mean(AlphaEEG(iState).rootmean(channel))];
    end

    figure;
    state = [];
    for iState = ProjectConstants.LatterHalfDataIndex
        name = strsplit(AlphaEEG(iState).setname, ' - ');
        state = [state name(2)];
    end
    bar(ProjectConstants.LatterHalfDataIndex, detrend(rootmean) + mean(rootmean));
    xticks(ProjectConstants.LatterHalfDataIndex);
    xticklabels(state);
    xlabel('State');
    ylabel('Power[uV]');
    title('AlphaEEG power per state');
end
