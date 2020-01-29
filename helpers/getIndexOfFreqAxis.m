function indexOfAxis = getIndexOfFreqAxis(targetFreq, freqaxis)
    % getIndexOfFreqAxis() - Returns the frequency axis index corresponding to
    %                        the target frequency.
    %
    % Usage:
    %   >> getIndexOfFreqAxis( [8:0.5:13], [0, 0.5, 1.0, ... 2047] );
    %
    % Inputs:
    %   targetFreq - [array] frequency for which to find the index
    %   freqaxis   - [array] frequency axis
    %
    % Outputs:
    %   indexOfAxis - [array] index of frequency axis

    for index = 1:length(freqaxis)
        if freqaxis(index) == targetFreq(1)
            first = index;
        end
        if freqaxis(index) == targetFreq(end)
            last = index;
        end
    end
    if ~exist('first', 'var') || ~exist('last', 'var')
        error('The specified frequency does not exist in axis');
    end
    indexOfAxis = [first:last];
end
