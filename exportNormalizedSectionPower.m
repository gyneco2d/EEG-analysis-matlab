function exportNormalizedSectionPower(EEGFREQS, wave)

    import('constants.ProjectConstants');

    if ~exist('wave', 'var'), wave = 'alpha'; end
    if ~any(strcmp(wave, {'theta', 'alpha', 'beta', 'gamma'}))
        error('Invalid EEG wave name');
   end

    subjectsEEG.baseline1 = [];
    subjectsEEG.HR = [];
    subjectsEEG.CD = [];
    subjectsEEG.baseline2 = [];

    channel = ProjectConstants.OccipitalElectrodes;
    status = {'baseline1', 'HR', 'CD', 'baseline2'};

    for section = 1:size(EEGFREQS, 2)
        nameparts = strsplit(EEGFREQS(section).setname, ' - ');
        secStatus = cell2mat(nameparts(2));
        subjectsEEG.(secStatus) ...
            = [subjectsEEG.(secStatus);
               mean(EEGFREQS(section).(['normalized_section_', wave])(channel))];
    end

    trialNum = length(subjectsEEG.baseline1);
    tableIndex = reshape([1:trialNum], [trialNum, 1]);
    trialName = {};
    for i = 1:trialNum
        trialName{size(trialName, 1)+1, 1} = {['Trial-' num2str(i)]};
    end
    result = table(...
                tableIndex, ...
                trialName, ...
                subjectsEEG.baseline1, subjectsEEG.HR, subjectsEEG.CD, subjectsEEG.baseline2);
    result.Properties.VariableNames ...
        = {'Index', 'Trial', 'Baseline1', 'HR', 'CD', 'Baseline2'};

    % Export
    writetable(result, ...
               fullfile(ProjectConstants.ProjectRoot, 'Sectionset_unordered.csv'), ...
               'Delimiter', ',');
end
