% Plot alpha band power in time series

prompt = 'Datasets [default: 1:4]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = [1:4];
elseif ~isnumeric(datasets)
    error('Input must be a numeric');
end

prompt = 'Channel numbers [default: 14:18]: ';
channels = input(prompt);
if isempty(channels)
    channels = [14:18];
elseif ~isnumeric(channels)
    error('Input must be a numeric');
end

prompt = 'Window size [default: 10sec]: ';
windowsize = input(prompt);
if isempty(windowsize)
    windowsize = 10;
elseif ~isnumeric(windowsize)
    error('Input must be a numeric');
end

% smoothing
for dataset = datasets
    for channel = channels
        AlphaEEG(dataset).smoothdata(channel, :) = movmean(AlphaEEG(dataset).timeseries_rootmean(channel, :), windowsize);
    end
end

for channel = channels
    continuous = [];
    for dataset = datasets
        continuous = horzcat(continuous, AlphaEEG(dataset).smoothdata(channel, :));
    end
    plot(1:length(continuous), continuous);
end
legend(strsplit(num2str(channels), ' '), 'Location', 'northeast');
xlabel('Time');
ylabel('Power');
status = [];
for dataset = datasets
    name = strsplit(ALLEEG(dataset).setname, ' - ');
    status = horzcat(status, name(end));
end
title(append('Alpha band power transition (', join(status, '-'), ')'));
