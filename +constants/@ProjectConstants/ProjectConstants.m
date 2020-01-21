classdef ProjectConstants
    properties (Constant)
        AlphaBand = [8:13];
        FFTInterval = 2;
        SmoothingWindowSize = 30;
        SectionIndex = [2:5];
        SecondHalfSectionIndex = [6:9];
        ProjectRoot = [getenv('HOME') '/Documents/MATLAB/HSE2019_EEG/'];
    end
end
