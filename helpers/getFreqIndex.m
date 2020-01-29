function freqIndex = getFreqIndex(target, f)
    % Returns index of f indicating the target frequency.

    for index = 1:length(f)
        if f(index) == target(1)
            first = index;
        end
        if f(index) == target(end)
            last = index;
        end
    end
    freqIndex = [first:last];
end
