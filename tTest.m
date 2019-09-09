disp('Select the dataset to compare');
prompt = 'Datasets1 [default: 1]: ';
dataset1 = input(prompt);
if isempty(dataset1)
    dataset1 = 1;
end
prompt = 'Datasets2 [default: 2]: ';
dataset2 = input(prompt);
if isempty(dataset2)
    dataset2 = 2;
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
targetFreq = input(prompt);
if isempty(targetFreq)
    targetFreq = 10;
end

for dataset = datasets
    n = fs * interval;
    f = (0:n-1)*(fs/n);
    totalTime = length(ALLEEG(dataset).data(channels(1), :)) / fs;
    components = totalTime / interval;

    targetFreqIndex = 0;
    for index = 1:length(f)
        if f(index) == targetFreq
            targetFreqIndex = index;
        end
    end

    targetPower(dataset).name = ALLEEG(dataset).setname;
    targetPower(dataset).power = [];

    for channel = channels
        for index = 1:components
            last = index * n;
            first = last - (n - 1);
            x = ALLEEG(dataset).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;
            
            targetPower(dataset).power = horzcat(targetPower(dataset).power, power(targetFreqIndex));
        end
    end
end

[h, p, ci, stats] = ttest2(targetPower(dataset1).power, targetPower(dataset2).power);
disp([newline, ALLEEG(dataset1).setname, ' and ', ALLEEG(dataset2).setname, ' compared']);
disp(['Check the following variables', newline, '  h, p, ci, stats']);
