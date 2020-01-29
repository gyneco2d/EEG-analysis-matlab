function [pctTheta, pctAlpha, pctBeta, pctGamma] = calcEEGpercentage(fftpower, freqaxis)
    % calcEEGratio() - Calculate the percentage of each of theta, alpha and beta waves
    %                  in the analysis frequency band of the five occipital electrodes
    %
    % Inputs:
    %   fftpower - result of fft()
    %   freqaxis - frequency axis corresponding to fftpower

    % Import constants
    import('constants.ProjectConstants');

    % Confirm args
    if length(fftpower) ~= length(freqaxis)
        error('Vectors must be the same length.');
    end

    % Target 5 occipital electrodes
    occipital = mean(fftpower(ProjectConstants.OccipitalElectrodes, :));

    % Total power of all bands (theta, alpha, beta)
    analysisFreqIndex = getFreqIndex(ProjectConstants.AnalysisFreqRange, freqaxis);
    allband = sum(occipital(analysisFreqIndex));

    % Calc each EEG percentage
    thetabandIndex = getFreqIndex(ProjectConstants.ThetaWaves, freqaxis);
    thetaband = sum(occipital(thetabandIndex));

    alphabandIndex = getFreqIndex(ProjectConstants.AlphaWaves, freqaxis);
    alphaband = sum(occipital(alphabandIndex));

    betabandIndex = getFreqIndex(ProjectConstants.BetaWaves, freqaxis);
    betaband = sum(occipital(betabandIndex));

    gammabandIndex = getFreqIndex(ProjectConstants.GammaWaves, freqaxis);
    gammaband = sum(occipital(gammabandIndex));

    % Percentage expression
    pctTheta = thetaband / allband * 100;
    pctAlpha = alphaband / allband * 100;
    pctBeta = betaband / allband * 100;
    pctGamma = gammaband / allband * 100;
end
