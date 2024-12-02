function plotIndividualOptoSwitchSession(trialData, saveDirectory, groupName)

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
        plotOptoSessionCDFs(trialData, currentMouse);
        saveas(gcf, fullfile(saveDirectory, sprintf('%s_%s.png', currentMouse, groupName)));
        close all
    end

end


function plotOptoSessionCDFs(trialData, mouseID)

% 
% 
% INPUTS:
%   trialData:          data structure with behavioral data for each trial, each session, each mouse
%   mouseID:            string of the mouse ID
%
% OUTPUTS:              
%   figure:             CDF plots (switch departure and switch arrival) and PDF plots (short and long responses) for all sesssions for one mouse 
%


    % Get number of sessions for current mouse.
    rowsWithData = find(~cellfun('isempty', {trialData.(mouseID)}));
    nSessions = numel(rowsWithData);

    % Set up figure;
    figure('Units', 'Normalized', 'OuterPosition', [0, 0.04, 1, 0.96]);
    nSubplotsY = ceil(sqrt(nSessions));
    nSubplotsX = ceil(nSessions/nSubplotsY)*2;

    colors = {([64 64 64] ./ 255) ([243 195 0] ./ 255)};

    idxSubplot = 1;
    for iSession = 1 : nSessions

        currentSessionData = trialData(rowsWithData(iSession)).(mouseID);

        % Identify trials that are 18s trials and contain a switch response. Identify opto trials.
        laserOnTrials = find(cellfun(@(x) x == 0, {currentSessionData.opto}));
        laserOffTrials = find(cellfun(@(x) x == 1, {currentSessionData.opto}));
        longTrials = find(cellfun(@(x) x == 18000, {currentSessionData.programmedDuration}));
        trialsWithSwitch = find(cellfun(@(x) ~isempty(x), {currentSessionData.SwitchDepart}));
        actualSwitchTrials = intersect(longTrials, trialsWithSwitch);
        laserOnSwitchTrials = ismember(actualSwitchTrials, laserOnTrials);
        laserOffSwitchTrials = ismember(actualSwitchTrials, laserOffTrials);
        switchDepartureTimes = [currentSessionData(actualSwitchTrials).SwitchDepart];
        laserOnDepartureTimes = switchDepartureTimes(laserOnSwitchTrials);
        laserOffDepartureTimes = switchDepartureTimes(laserOffSwitchTrials);

        if ~isempty(laserOnDepartureTimes) & ~isempty(laserOffDepartureTimes)
            % Plot CDF
            subplot(nSubplotsX, nSubplotsY, idxSubplot);
            hold on;
            ecdf(laserOffDepartureTimes);
            ecdf(laserOnDepartureTimes);

            % Figure Properties
            title(sprintf('%s %s', mouseID, currentSessionData(1).mpc.StartDate))
            legend('laser off', 'laser on', 'Location', 'northwest');
            legend('boxoff');
            text(13, 0.35, sprintf('OFF: n = %d', length(laserOffDepartureTimes)))
            text(13, 0.2, sprintf('ON: n = %d', length(laserOnDepartureTimes)))
            yticks(0:0.25:1);
            xticks(0:6:18);
            xlim([0 20]);
            ylabel('Cumulative Probability of a Switch');
            xlabel('Trial Duration (s)');
            box off

            % Jitter plot of all switch times for laser off and on.
            subplot(nSubplotsX, nSubplotsY, idxSubplot + 1);
            hold on;
            switchData = cell(2,1);
            switchData{1} = laserOffDepartureTimes;
            switchData{2} = laserOnDepartureTimes;
            jitterPlot(switchData, 1, colors);

            % Figure Properties
            title(sprintf('%s %s', mouseID, currentSessionData(1).mpc.StartDate))
            xticks([1 2]);
            xticklabels({'Laser Off', 'Laser On'})
            ylabel('Switch Time');
            box off

            idxSubplot = idxSubplot + 2;
        else
            % Nothing to plot
        end
    end
end


