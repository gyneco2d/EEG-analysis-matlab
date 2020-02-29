classdef ProjectConstants
    properties (Constant)
        % Define the frequency band of each EEG wave
        ThetaWaves = [4:0.5:7.5];
        AlphaWaves = [8:0.5:13];
        BetaWaves = [13.5:0.5:29.5];
        GammaWaves = [30:0.5:90];
        AnalysisFreqRange = [4:0.5:90];
        % Electrodes hardware settings
        AllElectrodes = [1:32];
        OccipitalElectrodes = [14:18];
        BioSemiSamplingRate = 2048;
        % Aanlysis settings
        FFTwindowSize = 2;        % [seconds] - unit of window size
        SmoothingWindowSize = 30; % [seconds]
        SectionIndex = [2:5];
        SecondHalfSectionIndex = [6:9];
        RootDir = fullfile('Documents/MATLAB/HSE2019');
    end
end
