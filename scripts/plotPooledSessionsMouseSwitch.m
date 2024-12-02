function PooledData = plotPooledSessionsMouseSwitch(trialData, saveDirectory)

% 
% 
% INPUTS:
%   trialData:          data structure with behavioral data for each trial, each session, each mouse
%   saveDirectory:      directory pathway where figures will be saved
%
% OUTPUTS:
%

    % Constants
    PooledData = struct;
    centersCDF = 0:0.1:18;
    centersPDF = 0:0.1:24;
    cmap = lines(2);

    mouseIDs = fieldnames(trialData);
    switchCDF = NaN(numel(centersCDF) - 1, length(mouseIDs));
    switchPDF = NaN(numel(centersPDF) - 1, length(mouseIDs));

    for iMouse = 1 : length(mouseIDs)
        currentMouse = char(mouseIDs(iMouse));
        nSessions = sum(~cellfun('isempty', {trialData.(currentMouse)}));

        % Collect switch responses, short responses, and long responses from all sessions.
        allSwitchDeparture = [];
        allSwitchArrival = [];
        allShortResponses = [];
        allLongResponses = [];
        for jSession = 1 : nSessions
            currentData = trialData(jSession).(currentMouse);
            longTrials = find(cellfun(@(x) x == 18000, {currentData.programmedDuration}));

            allSwitchDeparture = [allSwitchDeparture, currentData(longTrials).SwitchDepart];
            allSwitchArrival = [allSwitchArrival, currentData(longTrials).SwitchArrival];
            allShortResponses = [allShortResponses, currentData.ShortRsp];
            allLongResponses = [allLongResponses, currentData.LongRsp];
        end

        % Calculate the CDFs and PDFs for each mouse.
        [switchCDF(:,iMouse), ~] = histcounts(allSwitchDeparture, centersCDF, 'Normalization', 'cdf');
        [switchPDF(:,iMouse), ~] = ksdensity(allSwitchArrival, centersPDF(2:end), 'Bandwidth', 0.6);

        % Add data to structure.
        PooledData.(currentMouse).switchCDF = switchCDF(:,iMouse);
        PooledData.(currentMouse).switchPDF = switchPDF(:,iMouse);
        PooledData.(currentMouse).switchDepartures = allSwitchDeparture;
        PooledData.(currentMouse).switchArrivals = allSwitchArrival;
        PooledData.(currentMouse).shortResponses = allShortResponses;
        PooledData.(currentMouse).longResponses = allLongResponses;
        PooledData.(currentMouse).Stats = calculateSummaryStats(allSwitchDeparture);

        % Plot CDF of switch departures and switch arrivals
        figure(1); 
        subplot(1,2,1); cla;
        hold on;
        ecdf(allSwitchDeparture);
        ecdf(allSwitchArrival);

        xlim([0 20]);
        xticks(0:6:18);
        xlabel('Trial Durations (s)');
        ylim([0 1]);
        yticks(0:0.25:1);
        ylabel('Cumulative Probability of a Switch');
        legend('Switch Depart', 'Switch Arrive', 'Location', 'southeast')
        title(currentMouse);
        text(1, 0.9, sprintf(' %d Sessions\n N = %d\n Median = %0.2f\n Average = %0.2f\n CV = %0.2f', nSessions, PooledData.(currentMouse).Stats.N,...
            PooledData.(currentMouse).Stats.Median, PooledData.(currentMouse).Stats.Average, PooledData.(currentMouse).Stats.CV))
        hold off;

        % Plot PDF of short and long responses
        [shortResponsePDF, ~] = ksdensity(allShortResponses, centersPDF(2:end), 'Bandwidth', 0.6); 
        [longResponsePDF, ~] = ksdensity(allLongResponses, centersPDF(2:end), 'Bandwidth', 0.6);

        subplot(1,2,2); cla;
        hold on;
        histogram(allShortResponses, 0:0.5:24, 'Normalization', 'probability', 'LineStyle', 'none', 'FaceColor', cmap(1,:));
        histogram(allLongResponses, 0:0.5:24, 'Normalization', 'probability', 'LineStyle', 'none', 'FaceColor', cmap(2,:));
        plot(centersPDF(2:end), shortResponsePDF, 'Color', cmap(1,:));
        plot(centersPDF(2:end), longResponsePDF, 'Color', cmap(2,:));

        xlim([0 24]);
        xticks(0:6:24);
        xlabel('Trial Duration (s)');
        ylabel('PDF of Short and Long Responses');
        legend('Short Response', 'Long Response', '', '')
        hold off;

        % Save figure
        saveas(gcf, fullfile(saveDirectory, sprintf('%s_Pooled.png', currentMouse)))
        close all
    end

end