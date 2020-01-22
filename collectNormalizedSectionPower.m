function collectNormalizedSectionPower(subjectList)
    % collectNormalizedSectionPower() - Generate CSV file that summarizes 
    %                                   normalized section power of listed subjects
    %
    % Usage:
    %   >> collectNormalizedSectionPower( 'subjectList.dat' );
    %
    % Inputs:
    %   subjectList - subject list. see subjectList.dat.example

    % Import constants
    import('constants.ProjectConstants');

    % Load subject list
    list = readtable(subjectList, 'Format', '%d %s %{dd MMMM yyyy}D %s');

    trial = {};
    baseline1Section = [];
    hrSection = [];
    cdSection = [];
    baseline2Section = [];

    for index = 1:size(list, 1)
        sectionIndex = ProjectConstants.SecondHalfSectionIndex;
        % === HRtoCD trial ===
        trial1 = [char(list.SubjectID(index)), '_HRtoCD'];
        filename = fullfile(ProjectConstants.ProjectRoot, [trial1 '.mat']);
        disp(['Read ', filename]);
        AlphaEEG_HRtoCD = collectAlphaWaves(filename);

        % baseline1 section
        baseline1 = mean(AlphaEEG_HRtoCD(sectionIndex(1)).normalized_section_power([14:18]));
        % HR section
        hr = mean(AlphaEEG_HRtoCD(sectionIndex(2)).normalized_section_power([14:18]));
        % CD section
        cd = mean(AlphaEEG_HRtoCD(sectionIndex(3)).normalized_section_power([14:18]));
        % baseline2 section
        baseline2 = mean(AlphaEEG_HRtoCD(sectionIndex(end)).normalized_section_power([14:18]));

        trial(length(trial)+1, 1) = {trial1};
        baseline1Section = [baseline1Section; baseline1];
        hrSection = [hrSection; hr];
        cdSection = [cdSection; cd];
        baseline2Section = [baseline2Section; baseline2];

        % === CDtoHR trial ===
        trial2 = [char(list.SubjectID(index)), '_CDtoHR'];
        filename = fullfile(ProjectConstants.ProjectRoot, [trial2 '.mat']);
        disp(['Read ', filename]);
        AlphaEEG_CDtoHR = collectAlphaWaves(filename);

        % baseline1 section
        baseline1 = mean(AlphaEEG_CDtoHR(sectionIndex(1)).normalized_section_power([14:18]));
        % CD section
        cd = mean(AlphaEEG_CDtoHR(sectionIndex(2)).normalized_section_power([14:18]));
        % HR section
        hr = mean(AlphaEEG_CDtoHR(sectionIndex(3)).normalized_section_power([14:18]));
        % baseline2 section
        baseline2 = mean(AlphaEEG_CDtoHR(sectionIndex(end)).normalized_section_power([14:18]));

        trial(length(trial)+1, 1) = {trial2};
        baseline1Section = [baseline1Section; baseline1];
        cdSection = [cdSection; cd];
        hrSection = [hrSection; hr];
        baseline2Section = [baseline2Section; baseline2];
    end

    listlength = size(list, 1)*2;
    tableindex = reshape([1:listlength], [listlength, 1]);
    result = table(tableindex, trial, baseline1Section, cdSection, hrSection, baseline2Section);
    result.Properties.VariableNames = {'Index', 'Trial', 'Baseline1', 'CD', 'HR', 'Baseline2'};
    writetable(result, fullfile(ProjectConstants.ProjectRoot, 'result.txt'), 'Delimiter', ',');
end
