classdef ProjectConstants
    properties (Constant)
        ThetaWaves = [4:0.5:7.5];
        AlphaWaves = [8:0.5:13];
        BetaWaves = [13.5:0.5:29.5];
        GammaWaves = [30:0.5:90];
        AnalysisFreqRange = [4:0.5:90];
        OccipitalElectrodes = [14:18];
        FFTInterval = 2;
        SmoothingWindowSize = 30;
        SectionIndex = [2:5];
        SecondHalfSectionIndex = [6:9];
        ProjectRoot = fullfile(getenv('HOME'), '/Documents/MATLAB/HSE2019_EEG/');
    end
end
