% Plot alpha band power in time series with 1 second overlap

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
elseif ~isnumeric(channels)
    error('Input must be a numeric');
end

figure;
hold on;
for channel = channels
    continuous = [];
    for dataset = datasets
        continuous = horzcat(continuous, AlphaEEG(dataset).smoothing(channel, :));
    end
    plot(continuous);
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
