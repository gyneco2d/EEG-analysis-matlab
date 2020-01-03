% Calculate index for dataset split.

% Initialize sampling frequency
fs = 2048;

prompt = '`ALLEEG.event(any).latency` value here: ';
firstIndex = input(prompt);
if isempty(firstIndex)
    error('Input is required');
elseif ~isnumeric(firstIndex)
    error('Input must be a numeric');
end

prompt = 'How many seconds later [default: 200sec]: ';
interval = input(prompt);
if isempty(interval)
    interval = 200;
elseif ~isnumeric(interval)
    error('Input must be a numeric');
end

lastIndex = (firstIndex - 1) + fs * interval;
disp(['Last index is ', num2str(lastIndex)]);
