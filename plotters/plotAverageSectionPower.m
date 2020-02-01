function plotAverageSectionPower(subjectlist, AlphaEEGcollection)
    % plotAverageSectionPower() - 

    import('constants.ProjectConstants');
    list = readsubjectlist(subjectlist);

    baseline1 = [];
    hires = [];
    cdda = [];
    baseline2 = [];

    channel = [14:18];
    sectionsPerSubject = 8;
    sectionsPerTrial = 4;
    trials = {'HRtoCD', 'CDtoHR'};
    for subject = 1:size(list, 1)
        for trial = 1:length(trials)
            collectionIndex = sectionsPerSubject*(subject-1)+1 + sectionsPerTrial*(trial-1);
            baseline1 = [baseline1; mean(AlphaEEGcollection(collectionIndex).normalized_section_power(channel))];
            baseline2 = [baseline2; mean(AlphaEEGcollection(collectionIndex+3).normalized_section_power(channel))];
            if trial == 1
                hiresIndex = collectionIndex + 1;
                cddaIndex = collectionIndex + 2;
            else
                cddaIndex = collectionIndex + 1;
                hiresIndex = collectionIndex + 2;
            end
            hires = [hires; mean(AlphaEEGcollection(hiresIndex).normalized_section_power(channel))];
            cdda = [cdda; mean(AlphaEEGcollection(cddaIndex).normalized_section_power(channel))];
        end
    end
    sections = [baseline1 hires cdda baseline2];
    sections = detrend(sections) + mean(sections);
    subjectAvg = mean(sections);
    figure;
    bar([1:4], subjectAvg);
    xticks([1:4]);
    xticklabels({'Baseline1', 'HR', 'CD', 'Baseline2'});
    xlabel('Section');
    ylabel('Normalized Power');
    title('Average AlphaEEG power for all subjects');
end
