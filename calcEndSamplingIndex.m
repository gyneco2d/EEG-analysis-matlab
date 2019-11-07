prompt = '`ALLEEG.event(any).latency` value here: ';
firstIndex = input(prompt);
if isempty(firstIndex)
    disp('Invalid input');
end

prompt = 'Sampling frequency [default: 2048]: ';
fs = input(prompt);
if isempty(fs)
    fs = 2048;
end

prompt = 'How many seconds later [default: 200sec]: ';
interval = input(prompt);
if isempty(interval)
    interval = 200;
end

lastIndex = (firstIndex - 1) + fs * interval;
disp(['Last index is ', num2str(lastIndex)]);
