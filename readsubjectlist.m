function [subjectlist] = readsubjectlist('subjectlistpath')
    % readsubjectlist() - Read subject list file and return created subject table
    %
    % Usage:
    %   >> readsubjectlist( 'subjectlist.dat' );
    %
    % Inputs:
    %   subjectlistpath - [string] path to subjectlist.dat

    subjectlist = readtable(subjectlistpath, 'Format', '%d %s %{dd MMMM yyyy}D %s');
    subjectlist.ExperimentDate.Format = 'yyyyMMdd';
end
