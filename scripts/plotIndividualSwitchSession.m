function plotIndividualSwitchSession(trialData, saveDirectory)

% 
% 
% INPUTS:
%   trialData:          data structure with behavioral data for each trial, each session, each mouse
%   saveDirectory:      directory pathway where figures will be saved
%
% OUTPUTS:
%

    
    mouseIDs = fieldnames(trialData);

    for iMouse = 1 : length(mouseIDs)
        currentMouse = char(mouseIDs(iMouse));

        % Plot cumulative distribution functions of switch response times for each session.
        plotSessionCDFs(trialData, currentMouse);
        saveas(gcf, fullfile(saveDirectory, sprintf('%s_CDF.png', currentMouse)));
        close all

        % Plot raster plots of nosepoke responses for each session.
        plotSessionRasters(trialData, currentMouse);
        saveas(gcf, fullfile(saveDirectory, sprintf('%s_raster.png', currentMouse)));
        close all
    end

end


function plotSessionCDFs(trialData, mouseID)

% 
% 
% INPUTS:
%   trialData:          data structure with behavioral data for each trial, each session, each mouse
%   mouseID:            string of the mouse ID
%
% OUTPUTS:              
%   figure:             CDF plots (switch departure and switch arrival) and PDF plots (short and long responses) for all sesssions for one mouse 
%

    centers = 0: 0.1: 24;
    cmap = lines(2);

    % Get number of sessions for current mouse.
    rowsWithData = find(~cellfun('isempty', {trialData.(mouseID)}));
    nSessions = numel(rowsWithData);

    % Set up figure;
    figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    nSubplotsY = ceil(sqrt(nSessions));
    nSubplotsX = ceil(nSessions/nSubplotsY)*2;

    idxSubplot = 1;
    for iSession = 1 : nSessions

        currentSessionData = trialData(rowsWithData(iSession)).(mouseID);

        % Identify trials that are 18s trials and contain a switch response.
        longTrials = find(cellfun(@(x) x == 18000, {currentSessionData.programmedDuration}));
        trialsWithSwitch = find(cellfun(@(x) ~isempty(x), {currentSessionData.SwitchDepart}));
        actualSwitchTrials = intersect(longTrials, trialsWithSwitch);
        switchDepartureTimes = [currentSessionData(actualSwitchTrials).SwitchDepart];
        switchArrivalTimes = [currentSessionData(actualSwitchTrials).SwitchArrival];

        shortResponses = [currentSessionData.ShortRsp];
        longResponses = [currentSessionData.LongRsp];

        if ~isempty(actualSwitchTrials)
            % Plot CDF
            subplot(nSubplotsX, nSubplotsY, idxSubplot);
            hold on;
            ecdf(switchDepartureTimes);
            ecdf(switchArrivalTimes);

            % Figure Properties
            title(sprintf('%s %s', mouseID, currentSessionData(1).mpc.StartDate))
            legend('Switch Depart', 'Switch Arrival', 'Location', 'southwest');
            legend('boxoff');
            yticks(0:0.25:1);
            xticks(0:6:18);
            xlim([0 20]);
            ylabel('Cumulative Probability of a Switch');
            xlabel('Trial Duration (s)');
            box off

            % Add text
            text(1, 0.9, ['N = ' num2str(length(switchDepartureTimes))]);
            text(1, 0.8, ['Median = ' num2str(median(switchDepartureTimes))])
            text(1, 0.7, ['Average = ' num2str(mean(switchDepartureTimes))])
            
            hold off;

            % Plot PDF of short and long nosepokes (for all trials - not just switch trials).
            subplot(nSubplotsX, nSubplotsY, idxSubplot + 1);
            hold on;
            [pdfShortResponses, ~] = ksdensity(shortResponses, centers(2:end), 'Bandwidth', 0.6);
            [pdfLongResponses, ~] = ksdensity(longResponses, centers(2:end), 'Bandwidth', 0.6);
            histogram(shortResponses, 0:0.5:24, 'Normalization', 'probability', 'LineStyle', 'none', 'FaceColor', cmap(1,:));
            plot(centers(2:end), pdfShortResponses, 'Color', cmap(1,:), 'LineWidth', 1);
            histogram(longResponses, 0:0.5:24, 'Normalization', 'probability', 'LineStyle', 'none', 'FaceColor', cmap(2,:));
            plot(centers(2:end), pdfLongResponses, 'Color', cmap(2,:), 'LineWidth', 1);

            % Figure Properties
            title(sprintf('%s %s', mouseID, currentSessionData(1).mpc.StartDate))
            legend('Short Responses', '', 'Long Responses', '', 'Location', 'northwest');
            legend('boxoff');
            xticks(0:6:18);
            xlim([0 24]);
            xlabel('Trial Duration (s)');
            ylabel('PDF of Short and Long Responses');
            box off

            idxSubplot = idxSubplot + 2;
        else
            % Nothing to plot
        end
    end
end



function plotSessionRasters(trialData, mouseID)

% 
% 
% INPUTS:
%   trialData:          data structure with behavioral data for each trial, each session, each mouse
%   mouseID:            string of the mouse ID
%
% OUTPUTS:              
%   figure:             CDF plots (switch departure and switch arrival) and PDF plots (short and long responses) for all sesssions for one mouse 
%

    colors = {[0, 0.447, 0.741]; [0.85, 0.325, 0.098]; [0.298 0 0.6]; [0.8 0 0]};
    lineWidth = [1 1 2 2];
    responseTypes = {'ShortRsp', 'LongRsp', 'SwitchDepart', 'SwitchArrival'};

    % Get number of sessions for current mouse.
    rowsWithData = find(~cellfun('isempty', {trialData.(mouseID)}));
    nSessions = length(rowsWithData);

    % Set up figure;
    figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    nSubplotsX = ceil(sqrt(nSessions));
    nSubplotsY = ceil(nSessions/nSubplotsX);
    idxSubplot = [1 3];

    for iSession = 1 : nSessions

        currentSessionData = trialData(rowsWithData(iSession)).(mouseID);

        for jTrialType = 1 : 2
            if jTrialType == 1
                currentTrials = find(cellfun(@(x) x == 18000, {currentSessionData.programmedDuration}));
                subplot(nSubplotsX, nSubplotsY*3, idxSubplot(1):idxSubplot(1)+1); hold on;
                xlim([0 20]);
                title(sprintf('%s %s Long Trials', mouseID, currentSessionData(1).mpc.StartDate))
            else
                currentTrials = find(cellfun(@(x) x == 6000, {currentSessionData.programmedDuration}));
                subplot(nSubplotsX, nSubplotsY*3, idxSubplot(2)); hold on;
                xlim([0 10]);
                title('Short Trials')
            end

            for kResponseType = 1 : length(responseTypes)
                [xRasterValues, yRasterValues] = getRasterData(currentSessionData, responseTypes{kResponseType}, currentTrials);
                plot(xRasterValues, yRasterValues, 'Color', colors{kResponseType}, 'LineWidth', lineWidth(kResponseType));
            end % response type

            xline(6, 'Color', [0.8 0.8 0.8], 'LineWidth', 1);
            xline(18, 'Color', [0.8 0.8 0.8], 'LineWidth', 1);
            xlabel('Trial time (s)');
            ylabel('Trial Number');
            box off;
            hold off;

        end     % trial type

        idxSubplot = idxSubplot + 3;
    end         % session
end



function [xRasterValues, yRasterValues] = getRasterData(sessionData, responseType, trialNumbers)

% 
% INPUTS:
%   sessionData:        data structure with behavioral data for each trial in one session
%   responseType:       the type of response that will be plotted
%   trialNumbers:       the trials that are being plotted (short or long trials)
%
% OUTPUTS:              
%   
    
    % Get response times for each trial into an array responseData (rows = responses, columns = trials);
    numResponsesPerTrial = cellfun(@numel, {sessionData.(responseType)});
    responseData = zeros(max(numResponsesPerTrial), length(sessionData));
    for iTrial = 1 : length(sessionData)
       responseData(1 : numResponsesPerTrial(iTrial), iTrial) = sessionData(iTrial).(responseType);
    end
    responseData(responseData == 0) = NaN;
    responseData = responseData(:, trialNumbers);
    
    startValue = -0.1;
    xRasterValues = NaN(3 * size(responseData,1), size(responseData,2));
    yRasterValues = xRasterValues;
    xRasterValues(1:3:3*size(responseData,1), :) = responseData;
    xRasterValues(2:3:3*size(responseData,1), :) = responseData;
    yRasterValues(1:3:3*size(responseData,1), :) = repmat((1:size(responseData,2)) + 1 + startValue, size(responseData,1), 1);
    yRasterValues(2:3:3*size(responseData,1), :) = yRasterValues(1:3:end, :) + 1 - 0.1;

end