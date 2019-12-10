% Plot frequency distribution

% -- Initialize --
% sampling frequency : 2048Hz
fs = 2048;

prompt = 'Datasets [default: 1]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = 1;
elseif ~isnumeric(datasets)
    error('Input must be a numeric');
end

prompt = 'Interval(sec) [default: 2]: ';
interval = input(prompt);
if isempty(interval)
    interval = 2;
end

prompt = 'Channel numbers [default: 14:18]: ';
channels = input(prompt);
if isempty(channels)
    channels = [14:18];
end

datasetAvgs = containers.Map('KeyType', 'char', 'ValueType', 'any');

for dataset = datasets
    n = fs * interval;
    f = (0:n-1)*(fs/n);
    totalTime = length(ALLEEG(dataset).data(channels(1), :)) / fs;
    components = totalTime / interval;
    sumOfChannels = zeros(1, n, 'single');

    figure;
    for channel = channels
        sum = zeros(1, n, 'single');
        
        for component = 1:components
            first = (component-1)*n + 1;
            last = first + (n-1);
            x = ALLEEG(dataset).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;
            sum = sum + power;
        end
        
        componentAvg = sum / components;
        sumOfChannels = sumOfChannels + componentAvg;
        
        hold on;
        plot(f, componentAvg);
    end
    legend(strsplit(num2str(channels), ' '), 'Location', 'northeast');
    xlim([0 15]);
    ylim([0 100000]);
    xlabel('Frequency[Hz]');
    ylabel('Power[uV]');
    title(ALLEEG(dataset).setname);
    
    channelAvg = sumOfChannels / length(channels);
    datasetAvgs(ALLEEG(dataset).setname) = channelAvg;
end

figure;
for key = keys(datasetAvgs)
    hold on;
    plot(f, datasetAvgs(char(key)));
end
legend(keys(datasetAvgs), 'Location', 'northeast');
xlim([0 15]);
ylim([0 100000]);
xlabel('Frequency[Hz]');
ylabel('Power[uV]');
title('average per dataset');
