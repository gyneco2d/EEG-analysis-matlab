% Plot the detrended transition of alpha band power

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

rawAlpha = [];
for channel = channels
    channelAlpha = [];
    for dataset = datasets
        channelAlpha = horzcat(channelAlpha, AlphaEEG(dataset).rootmean(channel, 1));
    end
    rawAlpha = vertcat(rawAlpha, channelAlpha);
end

detrendedAlpha = [];
for iChannel = 1:length(channels)
    detrendedAlpha = vertcat(detrendedAlpha, detrend(rawAlpha(iChannel, :)) + mean(rawAlpha(iChannel, :)));
end

% Adjacent raw data and detrended data
forPlot = [];
for iChannel = 1:length(channels)
    channelset = vertcat(rawAlpha(iChannel, :), detrendedAlpha(iChannel, :));
    forPlot = vertcat(forPlot, channelset);
end

figure;
bar([1:length(channels)*2], forPlot);
