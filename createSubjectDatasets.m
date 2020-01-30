function createSubjectDatasets(subjectList, overwrite)
    % createSubjectDatasets() - Export analysis results of listed subjects to mat files
    %
    % Usage:
    %   >> createSubjectDatasets( 'subjectlist.dat', 'overwrite' );
    %   >> % Generate only BDF for which no mat file exists
    %
    % Inputs:
    %   subjectList - subject list. see subjectlist.dat.example
    %   overwrite   - [string] overwrite : overwrite even if mat file already exists
    %                        skip      : return control if mat file already exists

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if ~exist(subjectList, 'file'), error('subject list does not exist'); end
    if ~exist('overwrite', 'var'), overwrite = 'skip'; end
    if ~strcmp(overwrite, 'overwrite') && ~strcmp(overwrite, 'skip')
        error('Invalid input for "overwrite"');
    end

    % Load subject list
    list = readsubjectlist(subjectList);

    for index = 1:size(list, 1)
        subject = list(index, :);

        subjectdir = fullfile( ...
                        ProjectConstants.ProjectRoot, 'BDF', ...
                        [char(subject.ExperimentDate), '_', char(subject.Name)]);

        trial1 = fullfile(subjectdir, [char(lower(subject.Name)), 'HRtoCD.bdf']);
        trial2 = fullfile(subjectdir, [char(lower(subject.Name)), 'CDtoHR.bdf']);
        if ~exist(trial1, 'file')
            error(strcat(string(trial1), " does not exist"));
        end
        if ~exist(trial2, 'file')
            error(strcat(string(trial2), " does not exist"));
        end

        loadBDF(char(subject.SubjectID), trial1, overwrite);
        loadBDF(char(subject.SubjectID), trial2, overwrite);
    end
end
