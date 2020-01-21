function createMATfiles(subjectList, overwrite)
    % createMATfiles() - Generate mat files based on subject list
    %
    % Usage:
    %   >> createMATfiles( 'subjectList.dat', 0 ) % Generate only BDF for which no mat file exists
    %
    % Inputs:
    %   subjectList - subject list. see subjectList.dat.example
    %   overwrite   - [0/1] 0: skip generate if mat file already exists
    %                     1: regenerate & overwrite even if mat file already exists

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if ~exist('overwrite', 'var'); overwrite = 0; end
    if overwrite ~= 0 && overwrite ~= 1; error('invalid input'); end

    % Load subject list
    list = readtable(subjectList, 'Format', '%d %s %{dd MMMM yyyy}D %s');
    list.ExperimentDate.Format = 'yyyyMMdd';

    for index = 1:size(list, 1)
        subject = list(index, :);
        BDFdir = ['BDF/', char(subject.ExperimentDate), '_', char(subject.Name)];
        trial1 = fullfile(ProjectConstants.ProjectRoot, BDFdir, [char(lower(subject.Name)), 'HRtoCD.bdf']);
        trial2 = fullfile(ProjectConstants.ProjectRoot, BDFdir, [char(lower(subject.Name)), 'CDtoHR.bdf']);
        if ~exist(trial1, 'file')
            error(strcat(string(trial1), " does not exist"));
        end
        if ~exist(trial2, 'file')
            error(strcat(string(trial2), " does not exist"));
        end

        loadBdf(char(subject.SubjectID), trial1, overwrite);
        loadBdf(char(subject.SubjectID), trial2, overwrite);
    end
end
