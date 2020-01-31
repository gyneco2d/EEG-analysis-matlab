function plotEEGpercentagesBySection(EEGFREQS)
    % plotEEGpercentage() - plot EEG percentages by section
    %
    % Inputs:
    %   EEGFREQS - [structure] structure created by fftEEGdata()

    % Import constants
    import('constants.ProjectConstants');

    percentage = [];
    for section = 1:length(EEGFREQS)
        percentage = vertcat(...
            percentage,...
            [...
                EEGFREQS(section).percentage.theta,...
                EEGFREQS(section).percentage.alpha,...
                EEGFREQS(section).percentage.beta,...
                EEGFREQS(section).percentage.gamma...
            ]...
        );
    end

    sectionNames = {};
    for section = 1:length(EEGFREQS)
        nameparts = strsplit(EEGFREQS(section).setname, ' - ');
        sectionNames{length(sectionNames)+1} = char(nameparts(2));
    end
    figure();
    bar(percentage, 'stacked');
    legend({'theta', 'alpha', 'beta', 'gamma'}, 'Location', 'northeast');
    ylim([0 100]);
    xticks([1:length(sectionNames)]);
    xticklabels(sectionNames);
    xlabel('Section')
    ylabel('Percentage [%]');
    title('EEG percentage for each section');
end
