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
    baselineSection = [];
    hrSection = [];
    cdSection = [];

    for index = 1:size(list, 1)
        sectionIndex = ProjectConstants.SecondHalfSectionIndex;
        % === HRtoCD trial ===
        trial1 = [char(list.SubjectID(index)), '_HRtoCD'];
        filename = fullfile(ProjectConstants.ProjectRoot, [trial1 '.mat']);
        disp(['Read ', filename]);
        AlphaEEG_HRtoCD = collectAlphaWaves(filename);

        % baseline section
        baseline = mean([AlphaEEG_HRtoCD(sectionIndex(1)).normalized_section_power([14:18]);
                   AlphaEEG_HRtoCD(sectionIndex(end)).normalized_section_power([14:18])]);
        % HR section
        hr = mean(AlphaEEG_HRtoCD(sectionIndex(2)).normalized_section_power([14:18]));
        % CD section
        cd = mean(AlphaEEG_HRtoCD(sectionIndex(3)).normalized_section_power([14:18]));

        trial(length(trial)+1, 1) = {trial1};
        baselineSection = [baselineSection; baseline];
        hrSection = [hrSection; hr];
        cdSection = [cdSection; cd];

        % === CDtoHR trial ===
        trial2 = [char(list.SubjectID(index)), '_CDtoHR'];
        filename = fullfile(ProjectConstants.ProjectRoot, [trial2 '.mat']);
        disp(['Read ', filename]);
        AlphaEEG_CDtoHR = collectAlphaWaves(filename);

        % baseline section
        baseline = mean([AlphaEEG_CDtoHR(sectionIndex(1)).normalized_section_power([14:18]);
                   AlphaEEG_CDtoHR(sectionIndex(end)).normalized_section_power([14:18])]);
        % CD section
        cd = mean(AlphaEEG_CDtoHR(sectionIndex(2)).normalized_section_power([14:18]));
        % HR section
        hr = mean(AlphaEEG_CDtoHR(sectionIndex(3)).normalized_section_power([14:18]));

        trial(length(trial)+1, 1) = {trial2};
        baselineSection = [baselineSection; baseline];
        cdSection = [cdSection; cd];
        hrSection = [hrSection; hr];
    end

    listlength = size(list, 1)*2;
    tableindex = reshape([1:listlength], [listlength, 1]);
    result = table(tableindex, trial, baselineSection, cdSection, hrSection);
    result.Properties.VariableNames = {'Index', 'Trial', 'Baseline', 'CD', 'HR'};
    writetable(result, fullfile(ProjectConstants.ProjectRoot, 'result.txt'), 'Delimiter', ',');
end
