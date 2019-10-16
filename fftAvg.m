prompt = 'Datasets [default: 1]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = 1;
end

% prompt = 'Sampling frequency(Hz) [default: 2048]: ';
% fs = input(prompt);
% if isempty(fs)
%     fs = 2048;
% end
fs = 2048;

prompt = 'Interval(sec) [default: 1]: ';
interval = input(prompt);
if isempty(interval)
    interval = 1;
end

prompt = 'Channel numbers: ';
channels = input(prompt);
if isempty(channels)
    disp('Invalid');
    return;
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
        
        for index = 1:components
            last = index * n;
            first = last - (n - 1);
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
%     figure;
%     plot(f, channelAvg);
%     xlim([0 15]);
%     ylim([0 30000]);
%     xlabel('Frequency[Hz]');
%     ylabel('Power');
%     title([ALLEEG(dataset).setname, ' average']);
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
