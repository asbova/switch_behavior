% script_analyzeSwitchBehavior

cd /Users/asbova/Documents/MATLAB

% Identify key directories
codePathway = './switch_behavior/scripts';                            % code
medpcDataPathway = './switch_behavior/data/medpc';                    % medpc files
resultsPathway = './switch_behavior/results/training_behavior/SITI'; % folder to save results
if ~exist(resultsPathway, 'dir')
    mkdir(resultsPathway)
else
    % Directory already exists.
end
addpath(genpath('./switch_behavior'))
addpath('./switch_behavior/util')

% Identify the sessions to be analyzed using the getAnProfile function or manually specify.
if exist(fullfile(codePathway, 'getAnProfile.m'), 'file') == 2
    [protocols, group] = getAnProfile();
else
    protocols = {'Switch_6L18R_viITI', 'Switch_18L6R_viITI'}; % Specify the medpc protocols or leave empty.
    mouseIDs = {'ASB15', 'ASB16', 'ASB17', 'ASB18'};          % Specify the mouse ids or leave empty.
    dateRange = {'2024-06-11', '2024-06-13'};                 % Specify the start date or start and end dates or leave empty.
    group = [];
end

% Parse out medPC data into a structure trialData.
if isempty(group)
    mpcParsed = getDataIntr(medpcDataPathway, protocols, mouseIDs, dateRange);
else
    mpcParsed = getDataIntr(medpcDataPathway, protocols, group);
end
trialDataStructure = getTrialData(mpcParsed);

% Plot each session for each mouse individually (CDF switch responses, PDF nosepokes, rasters all responses)
plotIndividualSwitchSession(trialDataStructure, resultsPathway)

% Plot across all sessions for each mouse.
pooledData = plotPooledSessionsMouseSwitch(trialDataStructure, resultsPathway);

% Plot data across all mice in a group.
GroupData = plotGroupSwitch(trialDataStructure, group, resultsPathway);






 length(find(cellfun(@(x) x == 18000, {trialDataStructure(6).MEW6.programmedDuration}) & cellfun(@(x) ~isempty(x), {trialDataStructure(6).MEW6.reward})))