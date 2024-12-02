function GroupData = plotGroupSwitch(trialData, group, saveDirectory)

% 
% 
% INPUTS:
%   trialData:          data structure with behavioral data for each trial, each session, each mouse
%   group:              group name
%   saveDirectory:      directory pathway where figures will be saved
%
% OUTPUTS:
%

    % Constants
    GroupData = struct;
    centers = 0:0.1:20;
   
    % Identify the correct data in trialData for each session within groups.
    groupNames = fieldnames(group);
    nGroups = size(groupNames,1);
    structureIndex = [];
    for iGroup = 1 : nGroups
        currentGroup = group.(groupNames{iGroup});

        for jSession = 1 : size(currentGroup,2)
            currentDate = currentGroup{jSession}{1};
            currentMouse = currentGroup{jSession}{2};
            structureIndex{jSession, iGroup} = {currentMouse, date2TableNum(currentMouse, currentDate, trialData)}; % Find the matching data in trialData.
        end
    end

    % Calculate CDFs and PDFs for switch response, short responses, and long responses for each group.
    for iGroup = 1 : nGroups
        % Find unique mouse IDs within group.
        currentGroupRows = cellfun(@(x) ~isempty(x), structureIndex(:, iGroup));
        currentGroupIDs = cellfun(@(x) x{1}, structureIndex(currentGroupRows, iGroup), 'UniformOutput', false);
        uniqueIDs = unique(currentGroupIDs);

        % Pre-allocate arrays.
        switchDepartCDF = zeros(numel(centers) - 1, size(uniqueIDs, 1));
        switchDepartPDF = zeros(numel(centers) - 1, size(uniqueIDs, 1));
        shortResponsePDF = zeros(numel(centers) - 1, size(uniqueIDs, 1));
        longResponsePDF = zeros(numel(centers) - 1, size(uniqueIDs, 1));

        for jMouse = 1 : length(uniqueIDs)
            currentMouseIndex = find(strcmp(uniqueIDs{jMouse}, currentGroupIDs));

            % Collect response data from all sessions for one mouse.
            allSwitchDeparts = [];
            allSwitchArrivals = [];
            allShortResponses = [];
            allLongResponses = [];
            for kSession = 1 : length(currentMouseIndex)
                currentData = trialData(structureIndex{currentMouseIndex(kSession), iGroup}{2}).(structureIndex{currentMouseIndex(kSession), iGroup}{1});
                longTrials = find(cellfun(@(x) x == 18000, {currentData.programmedDuration}));
                allSwitchDeparts = [allSwitchDeparts, currentData(longTrials).SwitchDepart];
                allSwitchArrivals = [allSwitchArrivals, currentData(longTrials).SwitchArrival];
                allShortResponses = [allShortResponses, currentData.ShortRsp];
                allLongResponses = [allLongResponses, currentData.LongRsp];
            end

            % Calculate CDF and PDF of switch responses, and PDFs for short and long responses.
            [switchDepartCDF(:, jMouse), ~] = histcounts(allSwitchDeparts, centers, 'Normalization', 'cdf');
            [switchDepartPDF(:, jMouse), ~] = ksdensity(allSwitchDeparts, centers(2:end), 'Bandwidth', 0.6);
            [shortResponsePDF(:, jMouse), ~] = ksdensity(allShortResponses, centers(2:end), 'Bandwidth', 0.6);
            [longResponsePDF(:, jMouse), ~] = ksdensity(allLongResponses, centers(2:end), 'Bandwidth', 0.6);

            % Add pooled mouse data to the group data structure (GroupData).
            GroupData.(groupNames{iGroup}).switchDepartures{jMouse} = allSwitchDeparts;
            GroupData.(groupNames{iGroup}).switchArrivals{jMouse} = allSwitchArrivals;
            GroupData.(groupNames{iGroup}).shortResponses{jMouse} = allShortResponses;
            GroupData.(groupNames{iGroup}).longResponses{jMouse} = allLongResponses;
        end
        % Add CDF/PDF data to GroupData.
        GroupData.(groupNames{iGroup}).switchDepartCDF = switchDepartCDF;
        GroupData.(groupNames{iGroup}).switchDepartPDF = switchDepartPDF;
        GroupData.(groupNames{iGroup}).shortResponsePDF = shortResponsePDF;
        GroupData.(groupNames{iGroup}).longResponsePDF = longResponsePDF;
    end

    % Plot the average CDF of switch responses for each group.

    cmap = lines(2);
    centersPDF = centers(2:end);
    
    for iGroup = 1 : nGroups
        cdfGroupData = GroupData.(groupNames{iGroup}).switchDepartCDF;

        % Calculate CDF 50 for each mouse and the group average.
        cdfFifty = NaN(size(cdfGroupData, 2), 1);
        for jMouse = 1 : size(cdfGroupData, 2)
            fiftyIndex1 = find(cdfGroupData(:, jMouse) < 0.5, 1, 'last');
            fiftyIndex2 = find(cdfGroupData(:, jMouse) >= 0.5, 1, 'first');
            cdfFifty(jMouse, 1) = interp1(cdfGroupData([fiftyIndex1, fiftyIndex2], jMouse), centersPDF([fiftyIndex1, fiftyIndex2]), 0.5);
        end
        GroupData.(groupNames{iGroup}).cdfFifty = cdfFifty;

        averageCDF = mean(cdfGroupData, 2, 'omitnan');
        fiftyMeanIndex1 = find(averageCDF < 0.5, 1, 'last');
        fiftyMeanIndex2 = find(averageCDF >= 0.5, 1, 'first');
        cdfFiftyMean = interp1(averageCDF([fiftyMeanIndex1, fiftyMeanIndex2]), centersPDF([fiftyMeanIndex1, fiftyMeanIndex2]), 0.5);

        % Plot CDF
        figure('Units', 'Normalized', 'OuterPosition', [.1, 0.4, .65, 0.5]);
        sgtitle(groupNames{iGroup})
        subplot(1,3,1); cla;
        hold on;
        plotband(centersPDF, averageCDF, std(cdfGroupData, [], 2)/sqrt(size(cdfGroupData,2)), cmap(iGroup,:));
        plot([0 cdfFiftyMean cdfFiftyMean], [0.5 0.5 0], 'Color', cmap(iGroup,:));

        xlim([0 20]);
        xticks(0:6:18);
        xlabel('Trial Duration (s)');
        ylabel('Cumulative Probability of a Switch');
        hold off;

        % Plot PDF
        pdfGroupData = GroupData.(groupNames{iGroup}).switchDepartPDF;        
        subplot(1,3,2); cla;
        hold on;
        plotband(centersPDF, mean(pdfGroupData, 2, 'omitnan'), std(pdfGroupData, [], 2)/sqrt(size(pdfGroupData,2)), cmap(iGroup,:));
        xlim([0 20]);
        xticks(0:6:18);
        xlabel('Trial Duration (s)');
        ylabel('PDF of Switch Departure');
        hold off;

        % Plot short and long responses
        shortResponseData = GroupData.(groupNames{iGroup}).shortResponsePDF;
        longResponseData = GroupData.(groupNames{iGroup}).longResponsePDF;
        subplot(1,3,3); cla;
        hold on;
        plotband(centersPDF, mean(shortResponseData, 2, 'omitnan'), std(shortResponseData, [], 2)/sqrt(size(shortResponseData,2)), cmap(1,:));
        plotband(centersPDF, mean(longResponseData, 2, 'omitnan'), std(longResponseData, [], 2)/sqrt(size(longResponseData,2)), cmap(2,:));
        xlim([0 20]);
        xticks(0:6:18);
        xlabel('Trial Duration (s)');
        ylabel('PDF of Short and Long Responses');
        hold off;

        % Save figure
        saveas(gcf, fullfile(saveDirectory, sprintf('%s_Averaged.png', groupNames{iGroup})))
        close all
    end

end