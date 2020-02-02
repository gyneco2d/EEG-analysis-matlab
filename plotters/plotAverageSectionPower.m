function statusEEG = plotAverageSectionPower(EEGFREQS, wave)
    % plotAverageSectionPower() - Plot section power average between trials
    %
    % Usage:
    %  >> plotAverageSectionPower( EEGFREQS, 'alpha' );
    %
    % Inputs:
    %   EEGFREQS  - [structure] structure created by fftEEGdata()
    %   wave      - [string: 'theta' / 'alpha' / 'beta' / 'gamma'] specify EEG wave to plot

    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('wave', 'var'), wave = 'alpha'; end
    if ~any(strcmp(wave, {'theta', 'alpha', 'beta', 'gamma'}))
        error('Invalid EEG wave name');
    end

    % Initialize
    subjectNames = {};
    channel = ProjectConstants.OccipitalElectrodes;
    status = {'baseline1', 'HR', 'CD', 'baseline2'};
    statusEEG.baseline1 = [];
    statusEEG.HR = [];
    statusEEG.CD = [];
    statusEEG.baseline2 = [];

    for section = 1:size(EEGFREQS, 2)
        nameparts = strsplit(EEGFREQS(section).setname, ' - ');
        % Collect subject names
        if length(subjectNames) == 0 || ~strcmp(subjectNames(end), nameparts(1))
            subjectNames{length(subjectNames)+1} = cell2mat(nameparts(1));
        end
        % Determine section status
        secStatus = cell2mat(nameparts(2));
        statusEEG.(secStatus) = [statusEEG.(secStatus) mean(EEGFREQS(section).(['normalized_section_', wave])(channel))];
    end
    % Average subject section
    for s = status
        statusEEG.(cell2mat(s)) = mean(statusEEG.(cell2mat(s)));
    end

    % Plot
    figure();
    bar([1:length(status)], [statusEEG.baseline1 statusEEG.HR statusEEG.CD statusEEG.baseline2]);
    xticks([1:length(status)]);
    xticklabels({'Baseline1', 'HR', 'CD', 'Baseline2'});
    xlabel('Section');
    ylabel('Normalized Power');
    title(['Average ' upper(wave(1)) wave(2:end) ' EEG power for all subjects']);
end
