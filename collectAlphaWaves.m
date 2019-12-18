% Collect alpha waves (8-13Hz) into structure 'AlphaEEG'

% -- Initialize --
% sampling frequency : 2048Hz
fs = 2048;
% number of channels
channels = [1:32];
% fft interval : 2sec
interval = 2;
% alpha wave band : 8-13Hz
alphaBand = [8:13];
% number of components to average for smoothing
componentInSet = 20;

prompt = 'Datasets [default: 1:4]: ';
datasets = input(prompt);
if isempty(datasets)
    datasets = [1:4];
elseif ~isnumeric(datasets)
    error('Input must be a numeric');
end

prompt = 'Calculate overlap? (y/n) [default: y]: ';
overlap = input(prompt);
if isempty(overlap)
    overlap = 'y';
elseif ~(strcmp(overlap, 'y') || strcmp(overlap, 'n'))
    error('Input must be (y/n)');
end

n = fs * interval;
f = (0:n-1)*(fs/n);
for dataset = datasets
    totalTime = length(ALLEEG(dataset).data(channels(1), :)) / fs;
    if strcmp(overlap, 'y')
        components = fix(totalTime - 1);
        stepsize = n / 2;
    else
        components = fix(totalTime / interval);
        stepsize = n;
    end
    alphaBandIndex = calcFreqIndex(alphaBand, f);
    sets = fix(components / componentInSet);
    AlphaEEG(dataset).setname = ALLEEG(dataset).setname;
    AlphaEEG(dataset).avgOfComponents = zeros(32, n);
    AlphaEEG(dataset).timeseries_rootmean = zeros(32, components);
    AlphaEEG(dataset).smoothing = zeros(32, sets);
    AlphaEEG(dataset).raw = zeros(32, length(alphaBandIndex)*components);
    AlphaEEG(dataset).rootmean = zeros(32, 1);

    for channel = channels
        for component = 1:components
            first = (component-1)*stepsize + 1;
            last = first + (n-1);
            x = ALLEEG(dataset).data(channel, first:last);
            y = fft(x);
            power = abs(y).^2/n;

            AlphaEEG(dataset).avgOfComponents(channel, :) = AlphaEEG(dataset).avgOfComponents(channel, :) + power;
            for index = 1:length(alphaBandIndex)
                AlphaEEG(dataset).raw(channel, index + (component-1)*length(alphaBandIndex)) = power(alphaBandIndex(index));
            end
            AlphaEEG(dataset).timeseries_rootmean(channel, component) = sqrt(mean(power(alphaBandIndex)));
        end
        AlphaEEG(dataset).avgOfComponents(channel, :) = AlphaEEG(dataset).avgOfComponents(channel, :) / components;
        for index = 1:sets
            first = (index-1)*componentInSet + 1;
            last = first + (componentInSet-1);
            AlphaEEG(dataset).smoothing(channel, index) = mean(AlphaEEG(dataset).timeseries_rootmean(channel, first:last));
        end
        AlphaEEG(dataset).rootmean(channel, 1) = sqrt(mean(AlphaEEG(dataset).raw(channel, :)));
    end
end
