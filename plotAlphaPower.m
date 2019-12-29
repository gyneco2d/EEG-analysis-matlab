% Plot frequency distribution

prompt = 'Datasets [default: 1]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = 1;
elseif ~isnumeric(datasets)
    error('Input must be a numeric');
end

prompt = 'Channel numbers [default: 14:18]: ';
channels = input(prompt);
if isempty(channels)
    channels = [14:18];
end

setname = strsplit(AlphaEEG(1).setname, ' - ');

% Plot each channel in each state
for dataset = datasets
    figure('Name', string(setname(1)), 'NumberTitle', 'off');
    hold on;
    for channel = channels
        plot(f, AlphaEEG(dataset).freq_distribution(channel, :));
    end
    legend(strsplit(num2str(channels), ' '), 'Location', 'northeast');
    xlim([6 15]);
    ylim([0 100000]);
    xlabel('Frequency[Hz]');
    ylabel('Power[uV]');
    title(ALLEEG(dataset).setname);
end

% Plot the channel average for each state
setname = strsplit(AlphaEEG(1).setname, ' - ');
figure('Name', string(setname(1)), 'NumberTitle', 'off');
hold on;
for dataset = datasets
    avgOfChannels = zeros(32, length(AlphaEEG(dataset).freq_distribution(1, :)));
    for channel = channels
        avgOfChannels = avgOfChannels + AlphaEEG(dataset).freq_distribution(channel, :);
    end
    avgOfChannels = avgOfChannels / length(channels);
    plot(f, avgOfChannels);
end
status = [];
for dataset = datasets
    name = strsplit(AlphaEEG(dataset).setname, ' - ');
    status = horzcat(status, name(end));
end
legend(status, 'Location', 'northeast');
xlim([6 15]);
ylim([0 100000]);
xlabel('Frequency[Hz]');
ylabel('Power[uV]');
title(append('Compare [', string(setname(1)), '] for each state'));
