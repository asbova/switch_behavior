function plotPavlovianStandardProtocol(dlightData, currentMouse, saveDirectory)


    % Parameters for figure
    plotLimits = 800 : 1999;    
    blockSize = 6;

    plotColorCues = [0 128 255] ./ 255;
    plotColorReward = [12 149 113] ./ 255;
    % Create color gradient
    nColors = 2160;
    leftColor = [151 186 177] ./ 255; 
    rightColor = [15 121 93] ./ 255; 
    cmap = interp1([0, 1], [leftColor; rightColor], linspace(0, 1, nColors));

    % Figure
    figure('Units', 'Normalized', 'OuterPosition', [.1, 0.4, .45, 0.75]);
    
    % Plot the average signal of all trials.
    subplot(2,2,1); cla;
    averageSignal = mean(dlightData.TrialStart(:, plotLimits));
    stdSignal = std(dlightData.TrialStart(:, plotLimits), 0, 1) ./ sqrt(size(dlightData.TrialStart,1));
    hold on;
    xline([200 200], 'LineStyle', '--');
    xline([900 900], 'LineStyle', '--');
    plotband(1 : length(plotLimits), averageSignal, stdSignal, plotColorReward);
    xlim([0 length(plotLimits)]);
    xticks(0:200:length(plotLimits));
    xticklabels(-2:2:10);
    xlabel('Time from Cues On (s)');
    ylabel('dLight dF/F');
    
    % Plot signal in blocks over the session.
    subplot(2,2,[2 4]); cla; 
    hold on;
    xline(200, 'LineStyle', '--');
    xline(900, 'LineStyle', '--');
    nTrials = size(dlightData.TrialStart, 1);
    blockIndex = 1;
    yJitter = 0;
    colorIndex = 1;
    count = 1;
    maxCuesOn = [];
    maxReward = [];
    while blockIndex + blockSize <= nTrials
        currentTrials = blockIndex : blockIndex + blockSize;
        maxCuesOn(count) = mean(max(dlightData.TrialStart(currentTrials, plotLimits(201:251)),[],2));
        maxReward(count) = mean(max(dlightData.TrialStart(currentTrials, plotLimits(901:951)),[],2));
    
        averageSignal = mean(dlightData.TrialStart(currentTrials, plotLimits));
        stdSignal = std(dlightData.TrialStart(currentTrials, plotLimits), 0, 1) ./ sqrt(size(dlightData.TrialStart(currentTrials,:),1));
        plotband(1 : length(plotLimits), averageSignal - yJitter, stdSignal, cmap(colorIndex, :));
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
    text(990, 0.8, 'Early', 'FontSize', 16)
    text(995, -14.3, 'Late', 'FontSize', 16)
    
    % Plot cues on signal vs. reward signal over blocks.
    subplot(2,2,3); cla;
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
    
    % Save figure;
    saveas(gcf, fullfile(saveDirectory, sprintf('%s_PavlovianStandard.png', currentMouse)))
    close all