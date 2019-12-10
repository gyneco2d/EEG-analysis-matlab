% Plot comparison of alpha wave band power for each electrode

% -- Initialize --
% sampling frequency : 2048Hz
fs = 2048;
% fft interval : 2sec
interval = 2;
% alpha wave band : 8 - 13Hz
alphaBand = [8:13];

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

for dataset = datasets
    n = fs * interval;
    f = (0:n-1)*(fs/n);
    totalTime = length(ALLEEG(dataset).data(channels(1), :)) / fs;
    components = totalTime / interval;
    alphaBandIndex = calcFreqIndex(alphaBand, f);
    alphaPower(dataset).name = ALLEEG(dataset).setname;
    alphaPower(dataset).raw = zeros(32, length(alphaBandIndex)*components, 'single');

    for channel = channels
        for index = 1:components
            last = index * n;
            first = last - (n - 1);
            x = ALLEEG(dataset).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;

            for i = 1:length(alphaBandIndex)
                alphaPower(dataset).raw(channel, i + (index-1)*length(alphaBandIndex)) = power(alphaBandIndex(i));
            end
        end
    end
end

meanValue = [];
for dataset = datasets
    meanPerDataset = [];
    for channel = channels
        meanPerDataset = vertcat(meanPerDataset, mean(alphaPower(dataset).raw(channel, :)));
    end
    meanValue = horzcat(meanValue, meanPerDataset);
end
bar(channels, meanValue);
setnames = {};
for dataset = datasets
    setnames = horzcat(setnames, ALLEEG(dataset).setname);
end
legend(setnames, 'Location', 'northeast');
xlabel('Channel');
ylabel('Power[uV]');
title('alpha-band power per channel');
