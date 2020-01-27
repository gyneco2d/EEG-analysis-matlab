function [AlphaEEGcollection] = aggregateSubjectAlphaEEG(subjectList)
    % aggregateSubjectAlphaEEG() - Create AlphaEEG collection of listed subjects
    %
    % Usage:
    %   >> aggregateSubjectAlphaEEG( 'subjectList.dat' );
    %
    % Inputs:
    %   subjectList - subject list. see subjectList.dat.example

    % Import constants
    import('constants.ProjectConstants');

    % Load subject list
    list = readtable(subjectList, 'Format', '%d %s %{dd MMMM yyyy}D %s');

    trials = {'HRtoCD', 'CDtoHR'};
    sections = 4;
    sectionsPerSubject = 8;
    for subject = 1:size(list, 1)
        for iTrial = 1:length(trials)
            trial = [char(list.SubjectID(subject)), '_', char(trials(iTrial))];
            filename = fullfile(ProjectConstants.ProjectRoot, [trial '.mat']);
            disp(['Read ', filename]);
            AlphaEEG = collectAlphaWaves(filename);

            firstSection =  sectionsPerSubject * (subject-1) + 1 + sections*(iTrial-1);
            for index = 1:sections
                AlphaEEGcollection(firstSection+index-1) = AlphaEEG(ProjectConstants.SecondHalfSectionIndex(index));
            end
        end
    end

    save(fullfile(ProjectConstants.ProjectRoot, 'AlphaEEG_collection.mat'), 'AlphaEEGcollection', '-v7.3');
end
