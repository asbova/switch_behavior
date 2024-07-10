% scriptDlightMovementGLM

addpath(genpath('./striatal_dlight'))
cd './striatal_dlight'

resultsFolder = './results/kumarGrant';

load './data/kumarGrant/dlightData.mat';  % dlight data
load './data/kumarGrant/dlcData.mat';          % dlc data

% Add deeplabcut data to the dlight data structure.
for iSession = 1 : length(fpData)
    sessionRow = find(contains({dlcStructure.mouseID}, fpData(iSession).animalID) &...
        contains({dlcStructure.date}, fpData(iSession).date));
    if isempty(sessionRow)
        continue
    else
        fpData(iSession).dlc = dlcStructure(sessionRow);
    end
end

% Run a generalized linear model on trial by trial firing rates and behavior.
% Currently run GLM on all long trials.
for iSession = 1 : length(fpData)
    fpData(iSession).GLM = runGLM(fpData(iSession));
end


% Plot the velocity vs dlight.
figure(1);
subplot(3,1,1); cla;
hold on;
plotAverageVelocity(fpData);

subplot(3,1,2); cla;
hold on;
plotAverageDlight(fpData);

subplot(3,1,3); cla;
hold on;
correlateVelocityDlight(fpData);

saveas(gcf, fullfile(resultsFolder, 'dLightVelocity.png'));