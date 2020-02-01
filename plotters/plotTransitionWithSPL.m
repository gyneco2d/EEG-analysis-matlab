function plotTransitionWithSPL(EEGFREQS, audiofile, wave, channel)
    % plotTransitionWithSPL() - Plot SPL(sound pressure level) and EEG transition
    %
    % Usage:
    %   >> plotTransitionWithSPL( EEGFREQS, '/User/gyneco2d/Documents/MATLAB/audio.wav',
    %                           channel );
    %
    % Inputs:
    %   EEGFREQS  - [structure] structure created by fftEEGdata()
    %   audiofile - [string] audio file path
    %   wave      - [string: 'all' / 'theta' / 'alpha' / 'beta' / 'gamma'] specify EEG wave to plot
    %   channel   - [integer array] electrode number used for plot
    %
    % Required files:
    %   [wav] - continuous sound record of listening section

    % Import constants
    import('constants.ProjectConstants');

    waves = {'theta', 'alpha', 'beta', 'gamma'};

    % Confirm args
    if length(EEGFREQS) ~= 1, error('Required 1 EEGFREQS'); end
    if ~exist(audiofile, 'file'), error('Audio file does not exist'); end
    if ~exist('wave', 'var'), wave = 'alpha'; end
    if ~any(strcmp(wave, {'all', 'theta', 'alpha', 'beta', 'gamma'}))
        error('Invalid EEG wave name');
    end
    if ~exist('channel', 'var')
        channel = ProjectConstants.OccipitalElectrodes;
    end

    % Read audio file
    [audio, Fs] = audioread(audiofile);

    waveTrans = [];
    for iWave = waves
        waveTrans = [waveTrans; mean(EEGFREQS.(['timeseries_', char(iWave)])(channel, :))];
    end
    smoothspl = movmean(abs(audio), Fs * ProjectConstants.SmoothingWindowSize);

    % Plot
    figure;
    subplot(211);
    hold('on');
    if strcmp(wave, 'all')
        for index = 1:length(waves)
            plot(movmean(waveTrans(index, :), ProjectConstants.SmoothingWindowSize));
        end
        title('EEG transition');
        legend();
    else
        index = find(strncmp(wave, waves, length(wave)));
        plot(movmean(waveTrans(index, :), ProjectConstants.SmoothingWindowSize));
        title([upper(wave(1)) wave(2:end) ' EEG transition']);
    end
    xlabel('Time');
    ylabel('Power [uV]');
    subplot(212);
    plot(smoothspl);
end
