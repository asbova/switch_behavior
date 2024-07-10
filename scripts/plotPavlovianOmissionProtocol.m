function plotPavlovianOmissionProtocol(dlightData, currentMouse, saveDirectory)

    


    % Parameters for figure
    plotLimits = 800 : 1999;    
    blockSize = 6;

    
    plotColorReward = [12 149 113] ./ 255;
    plotColorOmit = [255 153 204] ./ 255;
    plotColorCues = [0 128 255] ./ 255;
    % Create color gradient
    nColors = 2160;
    leftColor = [151 186 177] ./ 255; 
    rightColor = [15 121 93] ./ 255; 
    cmap = interp1([0, 1], [leftColor; rightColor], linspace(0, 1, nColors));


    % Find rewarded vs. omission trials.
    behaviorData = dlightData.TrialAnSt.(currentMouse);
    rewardTrials = find(cellfun(@(x) x == 1, {behaviorData.trialType}));
    omissionTrials = find(cellfun(@(x) x == 0, {behaviorData.trialType}));

    rewardSignal = dlightData.TrialStart(rewardTrials, plotLimits);
    omitSignal = dlightData.TrialStart(omissionTrials, plotLimits);
    
    figure('Units', 'Normalized', 'OuterPosition', [.1, 0.4, .5, 0.65]);
    % Plot the average signal of all trials.    
    averageSignalReward = mean(rewardSignal);
    stdSignalReward = std(rewardSignal, 0, 1) ./ sqrt(length(rewardTrials));
    averageSignalOmit = mean(omitSignal);
    stdSignalOmit = std(omitSignal, 0, 1) ./ sqrt(length(omissionTrials));

    subplot(2,3,1); cla;
    hold on;
    xline([200 200], 'LineStyle', '--');
    xline([900 900], 'LineStyle', '--');
    plotband(1 : length(plotLimits), averageSignalOmit, stdSignalOmit, plotColorOmit);
    plotband(1 : length(plotLimits), averageSignalReward, stdSignalReward, plotColorReward);    
    xlim([0 length(plotLimits)]);
    xticks(0:200:length(plotLimits));
    xticklabels(-2:2:10);
    xlabel('Time from Cues On (s)');
    ylabel('dLight dF/F');
    legend('','','','', '', 'Reward Omitted', '', 'Reward Delivered')



    % Plot signal in blocks over the session.
    subplot(2,3,[2 5]); cla; 
    hold on;
    xline(200, 'LineStyle', '--');
    xline(900, 'LineStyle', '--');
    nTrials = size(rewardSignal, 1);
    blockIndex = 1;
    yJitter = 0;
    colorIndex = 1;
    count = 1;
    maxCuesOn = [];
    maxReward = [];
    while blockIndex + blockSize <= nTrials
        currentTrials = blockIndex : blockIndex + blockSize;
        maxCuesOn(count) = mean(max(rewardSignal(currentTrials, 201:251),[],2));
        maxReward(count) = mean(max(rewardSignal(currentTrials, 901:951),[],2));
    
        averageSignal = mean(rewardSignal(currentTrials, :));
        stdSignal = std(rewardSignal(currentTrials, :), 0, 1) ./ sqrt(size(rewardSignal(currentTrials,:),1));
        plotband(1 : length(averageSignal), averageSignal - yJitter, stdSignal, cmap(colorIndex, :));
        blockIndex = blockIndex + blockSize + 1;
        yJitter = yJitter + 2.5;
        colorIndex = colorIndex + 300;
        count = count + 1;
    end
    h = gca;
    h.YAxis.Visible = 'off';
    xticks(0:200:length(plotLimits));
    xticklabels(-2:2:10);
    xlabel('Time from Cues On (s)');
    text(950, 0.8, 'Early', 'FontSize', 16)
    text(995, -14.3, 'Late', 'FontSize', 16)


    % Plot cues on signal vs. reward signal over blocks.
    subplot(2,3,4); cla;
    hold on;
    plot(1:size(maxCuesOn,2), maxCuesOn, '-o', 'Color', plotColorCues, 'MarkerFaceColor', plotColorCues, 'MarkerEdgeColor', plotColorCues);
    plot(1:size(maxReward,2), maxReward, '-o', 'Color', plotColorReward, 'MarkerFaceColor', plotColorReward, 'MarkerEdgeColor', plotColorReward);
    legend('Cues On', 'Reward')
    xlim([0 size(maxCuesOn,2) + 1]);
    xticks(1 : size(maxCuesOn,2));
    xlabel('Block Number')
    ylim([0 2]);
    yticks(0:0.5:2);
    ylabel('Average Peak dF/F');
    box off;
    hold off;

    subplot(2,3,3); cla;
    hold on;
    postRewardRewardTrials = rewardTrials(find(~ismember(rewardTrials-1, omissionTrials))); % Reward trials where previous trial was omitted.
    averageSignal = mean(dlightData.TrialStart(postRewardRewardTrials, plotLimits));
    stdSignal = std(dlightData.TrialStart(postRewardRewardTrials, plotLimits), 0, 1) ./ sqrt(size(dlightData.TrialStart(postRewardRewardTrials, :),1));
    xline([200 200], 'LineStyle', '--');
    xline([900 900], 'LineStyle', '--');
    plotband(1 : length(plotLimits), averageSignal, stdSignal, plotColorReward);

    postOmitRewardTrials = rewardTrials(find(ismember(rewardTrials-1, omissionTrials))); % Reward trials where previous trial was omitted.
    averageSignal = mean(dlightData.TrialStart(postOmitRewardTrials, plotLimits));
    stdSignal = std(dlightData.TrialStart(postOmitRewardTrials, plotLimits), 0, 1) ./ sqrt(size(dlightData.TrialStart(postOmitRewardTrials, :),1));
    plotband(1 : length(plotLimits), averageSignal, stdSignal, plotColorOmit);
    legend('','','','','','Post-Reward','','Post-Omission')

    
    rewardSignal = NaN(sum([behaviorData.trialType]), 400);
    omitSignal = NaN(size(behaviorData,2) - size(rewardSignal,1), 400);
    rewardCount = 1;
    omitCount = 1;
    for iTrial = 1 : size(behaviorData,2)
        rewardEntries = behaviorData(iTrial).rewardRspTimeTrial;
        if ~isempty(rewardEntries) & behaviorData(iTrial).trialType == 1
            firstRewardEntry = rewardEntries(1);
            if firstRewardEntry*100 + 1199 < 2500
                rewardSignal(rewardCount, :) = dlightData.TrialStart(iTrial, (firstRewardEntry*100) + 800 : (firstRewardEntry*100) + 1199);
            else 
                rewardSignal(rewardCount, 1:length(dlightData.TrialStart(iTrial, (firstRewardEntry*100) + 800 : end))) = dlightData.TrialStart(iTrial, (firstRewardEntry*100) + 800 : end);
            end
            rewardCount = rewardCount + 1;
        elseif ~isempty(rewardEntries) & behaviorData(iTrial).trialType == 0
            firstRewardEntry = rewardEntries(1);
            if firstRewardEntry*100 + 1199 < 2500
                omitSignal(omitCount, :) = dlightData.TrialStart(iTrial, (firstRewardEntry*100) + 800 : (firstRewardEntry*100) + 1199);
            else 
                omitSignal(omitCount, 1:length(dlightData.TrialStart(iTrial, (firstRewardEntry*100) + 800 : end))) = dlightData.TrialStart(iTrial, (firstRewardEntry*100) + 800 : end);
            end
            omitCount = omitCount + 1;
        end
    end

    subplot(2,3,6); cla;
    hold on;
    xline(200, 'LineStyle', '--');
    meanRewardSignal = mean(rewardSignal, 'omitnan');
    meanOmitSignal = mean(omitSignal, 'omitnan');
    stdRewardSignal = std(rewardSignal, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(rewardSignal(:,1)),1));
    stdOmitSignal = std(omitSignal, 0, 1, 'omitnan') ./ sqrt(sum(~isnan(omitSignal(:,1)),1));

    plotband(1:400, meanRewardSignal, stdRewardSignal, 'k');
    plotband(1:400, meanOmitSignal, stdOmitSignal, 'r');
    

    % Save figure;
    saveas(gcf, fullfile(saveDirectory, sprintf('%s_PavlovianOmit.png', currentMouse)))
    close all










