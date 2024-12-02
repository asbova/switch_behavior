function plotSummaryOptoCDF(behaviorData, plotColors)
%
%   Plots a cumulative distribution function (CDF) of switch response times with laser off vs. laser on.
%
%   Inputs:
%       sessionData:        structure with behavioral data and processed neuronal data for each session 
%       plotColors:         cell with RGB color values for plotting
%
%   Outputs:
%       figure


    centers = 0 : 0.1 : 20;
    mice = fieldnames(behaviorData);
    nMice = size(mice, 1);
    nSession = size(behaviorData, 2);

    % Set up figure;
    figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 0.6, 0.8]);
    nSubplotsY = ceil(sqrt(nMice));
    nSubplotsX = ceil(nMice/nSubplotsY)*2;

    idxSubplot = 1;
    for iMouse = 1 : nMice

        cdfOff = NaN(length(centers) - 1, nSession);
        cdfOn = NaN(length(centers) - 1, nSession);
        meanResponseTime = NaN(nSession, 2);
        nTrials = NaN(nSession, 2);
        for jSession = 1 : nSession
            if isempty(behaviorData(jSession).(mice{iMouse}))
                continue;
            end
            sessionData = behaviorData(jSession).(mice{iMouse});
                   
            % Find switch trials.
            longTrials = find(cellfun(@(x) x == 18000, {sessionData.programmedDuration}));
            longTrialsWithSwitch = intersect(longTrials, find(cellfun(@(x) ~isempty(x), {sessionData.SwitchDepart})));
    
            % Identify switch trials with laser off vs. laser on.
            offTrials = find(cellfun(@(x) x == 1, {sessionData.opto}));
            onTrials = find(cellfun(@(x) x == 0, {sessionData.opto}));
            offSwitchTrials = intersect(offTrials, longTrialsWithSwitch);
            onSwitchTrials = intersect(onTrials, longTrialsWithSwitch);
    
            [cdfOff(:, jSession), ~] = histcounts([sessionData(offSwitchTrials).SwitchDepart], centers, 'Normalization', 'cdf');
            [cdfOn(:, jSession), ~] = histcounts([sessionData(onSwitchTrials).SwitchDepart], centers, 'Normalization', 'cdf');
    
            % Calculate average switch response time for laser off vs. laser on.
            meanResponseTime(jSession, 1) = mean([sessionData(offSwitchTrials).SwitchDepart]);
            meanResponseTime(jSession, 2) = mean([sessionData(onSwitchTrials).SwitchDepart]);

            nTrials(jSession, 1) = length(offSwitchTrials);
            nTrials(jSession, 2) = length(onSwitchTrials);
        end
    
        % Plot average CDF with SEM.
        meanOff = mean(cdfOff, 2, 'omitnan');
        stdOff = std(cdfOff, 0, 2, 'omitnan') ./ sqrt(size(cdfOff, 2));
        meanOn = mean(cdfOn, 2, 'omitnan');
        stdOn = std(cdfOn, 0, 2, 'omitnan') ./ sqrt(size(cdfOn, 2));
    
        % Plot CDF
        subplot(nSubplotsX, nSubplotsY, idxSubplot); cla;
        plotband(centers(2 : end), meanOff, stdOff, plotColors{2});
        plotband(centers(2 : end), meanOn, stdOn, plotColors{1});
    
        % Figure properties
        ylim([0 1]);
        xlim([0 18]);
        xticks([0 6 18]);
        ylabel('Cumulative Distribution Function')
        xlabel('Time from Trial Start (s)')
        text(0.5, 0.9, sprintf('%d Trials Off', sum(nTrials(:, 1), 'omitnan')))
        text(0.5, 0.8, sprintf('%d Trials On', sum(nTrials(:, 2), 'omitnan')))
        title(char(mice(iMouse)))

        % Plot average switch response time
        subplot(nSubplotsX, nSubplotsY, idxSubplot + 1); cla; hold on;
        plot(1:2, meanResponseTime, 'Color', [160 160 160]./255)
        scatter(ones(length(meanResponseTime), 1), meanResponseTime(:,1), 'MarkerEdgeColor', plotColors{2}, 'MarkerFaceColor', plotColors{2});
        scatter(ones(length(meanResponseTime), 1)*2, meanResponseTime(:,2), 'MarkerEdgeColor', plotColors{1}, 'MarkerFaceColor', plotColors{1});
        line([0.85 1.15], [mean(meanResponseTime(:,1), 'omitnan') mean(meanResponseTime(:,1), 'omitnan')], 'Color', plotColors{2}, 'LineWidth', 3);
        line([1.85 2.15], [mean(meanResponseTime(:,2), 'omitnan') mean(meanResponseTime(:,2), 'omitnan')], 'Color', plotColors{1}, 'LineWidth', 3);
    
        % Figure properties
        %ylim([6 12]);
        xlim([0.75 2.25]);
        xticks([1 2]);
        xticklabels({'Laser Off', 'Laser On'})
        ylabel('Mean Switch Response Time (s)')

        idxSubplot = idxSubplot + 2;
    end
 
