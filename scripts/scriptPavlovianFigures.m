% scriptPalovianFigures

load '/Users/asbova/Documents/ID_pavlovianomitnew.mat';
saveDirectory = '/Users/asbova/Documents/Hannah/PavlovianDlight';

nMice = size(dlightData,2);
for iMouse = 1 : nMice
    currentMouse = char(dlightData(iMouse).animalID);
    currentData = dlightData(iMouse).dlData;
    nSession = size(currentData,2);

    for jSession = 1 : nSession
        if isempty(currentData(jSession).TrialStart)
            continue;
        end
    
        behaviorData = currentData(jSession).TrialAnSt.(currentMouse);
        if any([behaviorData.trialType] == 0)   
            plotPavlovianOmissionProtocol(currentData(jSession), currentMouse, saveDirectory) % Omission protocol
        else
            plotPavlovianStandardProtocol(currentData(jSession), currentMouse, saveDirectory) % Standard Pavlovian protocol
        end
        
    end
end

%% plotPavlovianOmissionProtocol is a work in progress!