% Plot comparison of alpha band power for each electrode

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

meanValue = [];
for dataset = datasets
    meanPerDataset = [];
    for channel = channels
        alphaBandPower = sqrt(mean(AlphaEEG(dataset).raw(channel, :)));
        meanPerDataset = vertcat(meanPerDataset, alphaBandPower);
    end
    meanValue = horzcat(meanValue, meanPerDataset);
end
figure;
bar(channels, meanValue);
setnames = {};
for dataset = datasets
    setnames = horzcat(setnames, ALLEEG(dataset).setname);
end
legend(setnames, 'Location', 'northeast');
xlabel('Channel');
ylabel('Power[uV]');
title('alpha-band power per channel');
