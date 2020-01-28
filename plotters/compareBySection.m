function compareBySection(AlphaEEG, channel)
    % compareBySection() - Plot original AlphaEEG & detrended AlphaEEG power for each state
    %
    % Usage:
    %   >> compareBySection( AlphaEEG, [14:18] );
    %
    % Inputs:
    %   AlphaEEG - [structure] structure created by collectAlphaWaves()
    %              Requires an AlphaEEG of length 4
    %   channel  - [integer array] electrode number used for calculation & plotting

    % Confirm args
    if length(AlphaEEG) ~= 4; error('an AlphaEEG of length 4 required'); end
    if ~exist('channel', 'var'); channel = [14:18]; end

    sections = [];
    for section = 1:4
        sections = [sections mean(AlphaEEG(section).normalized_section_power(channel))];
    end
    detrended = detrend(sections) + mean(sections);

    % Create label for plotting
    sectionName = [];
    for section = 1:4
        setnames = strsplit(AlphaEEG(section).setname, ' - ');
        sectionName = [sectionName setnames(2)];
    end

    % Plot the data before detrend
    figure;
    bar([1:4], sections, 'b');
    xticks([1:4]);
    xticklabels(sectionName);
    xlabel('State');
    ylabel('Power');
    title('AlphaEEG power per state');

    % Plot detrended data
    figure;
    bar([1:4], detrended, 'g');
    xticks([1:4]);
    xticklabels(sectionName);
    xlabel('State');
    ylabel('Power');
    title('AlphaEEG power per state (detrended)');
end
