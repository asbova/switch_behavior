% script_analyzeOptoSwitchBehavior


cd /Users/asbova/Documents/MATLAB

% Identify key directories
codePathway = './switch_behavior/scripts';                            % code
medpcDataPathway = './switch_behavior/data/medpc';                    % medpc files
resultsPathway = './switch_behavior/results/Opto'; % folder to save results
if ~exist(resultsPathway, 'dir')
    mkdir(resultsPathway)
else
    % Directory already exists.
end
addpath(genpath('./switch_behavior'))
addpath('./switch_behavior/util')

% Identify the sessions to be analyzed using the getAnProfile function or manually specify.
[protocols, group] = getOptoSessions();

% Parse out medPC data into a structure trialData.
if isempty(group)
    mpcParsed = getDataIntr(medpcDataPathway, protocols, mouseIDs, dateRange);
else
    mpcParsed = getDataIntr(medpcDataPathway, protocols, group);
end
trialDataStructure = getTrialData(mpcParsed);

plotColors = {[204 0 102] ./ 255, [0 0 0] ./ 255};
plotSummaryOptoCDF(trialDataStructure, plotColors);
