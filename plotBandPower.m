prompt = 'Datasets [default: 1]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = 1;
end

fs = 2048;

prompt = 'Interval(sec) [default: 2]: ';
interval = input(prompt);
if isempty(interval)
    interval = 2;
end

prompt = 'Channel numbers [default: 13:18]: ';
channels = input(prompt);
if isempty(channels)
    channels = [13:18];
end

prompt = 'Target frequency band [default: 8:13]: ';
targetFreqs = input(prompt);
if isempty(targetFreqs)
    targetFreqs = [8:13];
end

datasetAvgs = containers.Map('KeyType', 'char', 'ValueType', 'any');

figure;
means = [];
for dataset = datasets
    n = fs * interval;
    f = (0:n-1)*(fs/n);
    totalTime = length(ALLEEG(dataset).data(channels(1), :)) / fs;
    components = totalTime / interval;
    sumOfChannels = zeros(1, n, 'single');

    targetFreqIndex = calcFreqIndex(targetFreqs, f);

    % Initialize structure array
    targetBandPower(dataset).name = ALLEEG(dataset).setname;

    d_means = [];
    for channel = channels
        channelname = ['channel', num2str(channel)];
        targetBandPower(dataset).(channelname) = [];

        for index = 1:components
            last = index * n;
            first = last - (n - 1);
            x = ALLEEG(dataset).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;

            targetBandPower(dataset).(channelname) = horzcat(targetBandPower(dataset).(channelname), power(targetFreqIndex));
        end
        d_means = vertcat(d_means, mean(targetBandPower(dataset).(channelname)));
    end
    means = horzcat(means, d_means);
end

bar(channels, means);
setnames = {};
for index = datasets
    setnames = horzcat(setnames, ALLEEG(index).setname);
end
legend(setnames, 'Location', 'northeast');
xlabel('Channel');
ylabel('Power[uV]');
title('alpha-band power per channel');
