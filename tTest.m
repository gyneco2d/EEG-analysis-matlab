prompt = 'Select the datasets to compare [default: 1, 2]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = [1, 2];
end
if length(datasets) ~= 2
    disp('Select 2 datasets')
    return
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

prompt = 'Channel numbers [default: all]: ';
channels = input(prompt);
if isempty(channels)
    channels = [1:32];
end

prompt = 'Target frequency [default: 10]: ';
targetFreqs = input(prompt);
if isempty(targetFreqs)
    targetFreqs = 10;
end

% Collect data by fft
for dataset = datasets
    n = fs * interval;
    f = (0:n-1)*(fs/n);
    totalTime = length(ALLEEG(dataset).data(channels(1), :)) / fs;
    components = totalTime / interval;

    % Collect target frequency indexes.
    targetFreqIndex = [];
    for index = 1:length(f)
        for freq = targetFreqs
            if f(index) == freq
                targetFreqIndex = horzcat(targetFreqIndex, index);
            end
        end
    end

    targetPower(dataset).name = ALLEEG(dataset).setname;

    for channel = channels
        % Initialize structure array
        channelname = ['channel', num2str(channel)];
        for index = targetFreqs
            frequency = ['freq', num2str(index), 'hz'];
            targetPower(dataset).(channelname).(frequency) = [];
        end

        for index = 1:components
            last = index * n;
            first = last - (n - 1);
            x = ALLEEG(dataset).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;

            for freqIndex = targetFreqIndex
                frequency = ['freq', num2str(f(freqIndex)), 'hz'];
                targetPower(dataset).(channelname).(frequency) = horzcat(targetPower(dataset).(channelname).(frequency), power(freqIndex));
            end
        end
    end
end

% Test for each frequency
figure;
pValues = [];
for freq = targetFreqs
    frequency = ['freq', num2str(freq), 'hz'];
    set1 = [];
    set2 = [];
    for channel = channels
        channelname = ['channel', num2str(channel)];
        set1 = horzcat(set1, targetPower(datasets(1)).(channelname).(frequency));
        set2 = horzcat(set2, targetPower(datasets(2)).(channelname).(frequency));
    end
    [h, p] = ttest2(set1, set2);
    pValues = horzcat(pValues, p);
    disp([newline, num2str(freq), 'Hz']);
    disp(['  h = ', num2str(h)]);
    disp(['  p = ', num2str(p)]);
end
plot(targetFreqs, pValues);
xlabel('Frequency[Hz]');
ylabel('P-value');
title('P-value for each frequency');
