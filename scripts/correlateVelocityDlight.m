function glmStructure = correlateVelocityDlight(fpData)
%
% Make a scatter plot of velocity vs dlight signal and calculate an R2 value.
%
% Input: 
%       fpData:             structure with dlight data and dlc data for each session
%
% Output: 
%       figure


    binSize = 0.25;     % seconds
    scatterColors = {[67/255 72/255 228/255], [228/255 67/255 95/255], [65/255 152/255 38/255]};

    fpData = get_norm_values(fpData); % get normalization values

    nMice = length(fpData);
    allVelocity = [];
    allDlight = [];
    for iMouse = 1 : nMice
        
        normalizationValue = fpData(iMouse).normValue;
        dlightData = fpData(iMouse).switchTrial / normalizationValue;

        % Bin average velocity 
        velocityData = fpData(iMouse).dlc.velocity.LongTrials;
        frameRate = fpData(iMouse).dlc.frameRate;
        framesPerBin = frameRate * binSize;       
        nBins = round(size(velocityData,2)/framesPerBin);
        binnedVelocity = NaN(nBins-1, size(velocityData,1));
        for iTrial = 1 : size(velocityData, 1)
            binnedVelocity(1:nBins-1, iTrial) = arrayfun(@(x) mean(velocityData(iTrial, x:x+framesPerBin-1)), 1:framesPerBin:length(velocityData)-framesPerBin+1)';
        end
        binnedVelocity = reshape(binnedVelocity, [], 1);
        allVelocity = [allVelocity; binnedVelocity];
    
        % Bin average dLight data.
        dLightData = fpData(iMouse).switchTrial(:, 1100 : 3700); 
        nBins = round(size(dLightData,2)/(binSize*100));
        binnedDlight = NaN(nBins-1, size(dLightData, 1));
        for iTrial = 1 : size(dLightData, 1)
            binnedDlight(1:nBins-1, iTrial) = arrayfun(@(x) mean(dLightData(iTrial, x:x+(binSize*100 - 1)), 'omitnan'), 1:(binSize*100):(length(dLightData) - (binSize*100 + 1)))';
        end
        binnedDlight = reshape(binnedDlight, [], 1);
        allDlight = [allDlight; binnedDlight];

        scatter(binnedVelocity, binnedDlight, 'MarkerFaceColor', scatterColors{iMouse}, 'MarkerEdgeColor', scatterColors{iMouse}, 'MarkerFaceAlpha', 0.2);
    end

    xlabel('Velocity (mm/s)')
    ylabel('dLight (normalized)')
    xlim([0 250]);
    ylim([-5 10]);
    set(gca, 'FontSize', 14)

    allDlight(isnan(allVelocity)) = [];
    allVelocity(isnan(allVelocity)) = [];
    
    [r, p] = corr(allVelocity, allDlight);

    % Get coefficients of a line fit through the data.
    coefficients = polyfit(allVelocity, allDlight, 1);
    % Create a new x axis with exactly 1000 points (or whatever you want).
    xFit = linspace(min(allVelocity), max(allVelocity), 1000);
    % Get the estimated yFit value for each of those 1000 new x locations.
    yFit = polyval(coefficients , xFit);
    % Plot everything.
    plot(xFit, yFit, 'k-', 'LineWidth', 2); % Plot fitted line.


    text(210, 8, sprintf('r^2 = %.2e', r.*r), 'FontSize', 14)