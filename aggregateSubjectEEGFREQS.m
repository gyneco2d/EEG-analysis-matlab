function aggregateSubjectEEGFREQS(subjectList)
    % aggregateSubjectEEGFREQS() - Create EEGFREQS collection of listed subjects
    %
    % Usage:
    %   >> aggregateSubjectEEGFREQS( 'subjectlist.dat' );
    %
    % Inputs:
    %   subjectList - subject list. see subjectlist.dat.example

    % Import constants
    import('constants.ProjectConstants');

    % Load subject list
    if ~exist(subjectList, 'file'), error('subject list does not exist'); end
    list = readsubjectlist(subjectList);

    trials = {'HRtoCD', 'CDtoHR'};
    sections = 4;
    sectionsPerSubject = 8;
    for subject = 1:size(list, 1)
        for iTrial = 1:length(trials)
            subjectId = char(list.SubjectID(subject));
            trial = char(trials(iTrial));
            filename = [subjectId, '_', trial];
            datasetfile = fullfile(getEnvHome(), ProjectConstants.RootDir, ...
                                   'datasets', [filename '.mat'])
            disp(['Read ', datasetfile]);
            load(datasetfile);
            EEGFREQS = fftEEGdata(ALLEEG);

            % Aggregate trial data
            EEGFREQS(1).setname = [subjectId ' - ' trial];
            EEGFREQS_full(...
                length(trials)*subject - double(iTrial == 1)) = EEGFREQS(1);
            % Aggregate second harf of the section
            firstSection = sectionsPerSubject*(subject-1)+1 + sections*(iTrial-1);
            for index = 1:sections
                EEGFREQS_sections(firstSection+index-1) ...
                    = EEGFREQS(ProjectConstants.SecondHalfSectionIndex(index));
            end
        end
    end

    save(fullfile(getEnvHome(), ProjectConstants.RootDir, 'EEGFREQS_datasets.mat'), ...
         'EEGFREQS_full', ...
         '-v7.3');
    save(fullfile(getEnvHome(), ProjectConstants.RootDir, 'EEGFREQS_sections.mat'), ...
         'EEGFREQS_sections', ...
         '-v7.3');
end
