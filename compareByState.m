function compareByState(AlphaEEG, channel)
    % compareByState() - Plot original AlphaEEG & detrended AlphaEEG power for each state
    %
    % Usage:
    %   >> compareByState( AlphaEEG, [14:18] );
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlphaWaves()
    %   channel  - [integer array] electrode number used for calculation & plotting

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('channel', 'var'); channel = [14:18]; end

    sessions = [];
    for iState = ProjectConstants.SecondHalfSectionIndex
        sessions = [sessions mean(AlphaEEG(iState).normalized_section_power(channel))];
    end
    detrended = detrend(sessions) + mean(sessions);

    % Create label for plotting
    label = [];
    for iState = ProjectConstants.SecondHalfSectionIndex
        name = strsplit(AlphaEEG(iState).setname, ' - ');
        label = [label name(2)];
    end

    % Plot the data before detrend
    figure;
    bar(ProjectConstants.SecondHalfSectionIndex, sessions, 'b');
    xticks(ProjectConstants.SecondHalfSectionIndex);
    xticklabels(label);
    xlabel('State');
    ylabel('Power');
    title('AlphaEEG power per state');

    % Plot detrended data
    figure;
    bar(ProjectConstants.SecondHalfSectionIndex, detrended, 'g');
    xticks(ProjectConstants.SecondHalfSectionIndex);
    xticklabels(label);
    xlabel('State');
    ylabel('Power');
    title('AlphaEEG power per state (detrended)');
end
