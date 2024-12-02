

% Find the sessions for each mouse with best effects on switch timing


cd /Users/asbova/Documents/MATLAB

% Identify key directories
codePathway = './switch_behavior/scripts';                            % code
medpcDataPathway = './switch_behavior/data/medpc';                    % medpc files
resultsPathway = './switch_behavior/results/opto'; % folder to save results
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
mpcParsed = getDataIntr(medpcDataPathway, protocols, group);
trialDataStructure = getTrialData(mpcParsed);

plotIndividualOptoSwitchSession(trialDataStructure, resultsPathway, char(fieldnames(group)))
