function plotEEGpercentagesBySection(AlphaEEG)
    % plotEEGpercentage() - plot EEG percentages by section
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlphaWaves()

    % Import constants
    import('constants.ProjectConstants');

    percentage = [];
    sectionName = [];
    for section = ProjectConstants.SecondHalfSectionIndex
        percentage = vertcat(...
            percentage,...
            [...
                AlphaEEG(section).eeg_percentage.theta,...
                AlphaEEG(section).eeg_percentage.alpha,...
                AlphaEEG(section).eeg_percentage.beta,...
                AlphaEEG(section).eeg_percentage.gamma...
            ]...
        );
        setnames = strsplit(AlphaEEG(section).setname, ' - ');
        sectionName = [sectionName, setnames(2)];
    end

    figure();
    bar(percentage, 'stacked');
    legend({'theta', 'alpha', 'beta', 'gamma'}, 'Location', 'northeast');
    xticks([1:length(sectionName)]);
    xticklabels(sectionName);
    xlabel('Section')
    ylabel('Percentage [%]');
    title('EEG percentage per section');
end
