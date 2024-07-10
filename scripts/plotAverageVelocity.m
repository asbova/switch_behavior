function glmStructure = plotAverageVelocity(fpData)
%
% Plot average velocity (across mice) over multiple trials.
%
% Input: 
%       fpData:             structure with dlight data and dlc data for each session
%
% Output: 
%       figure


    intervalLimit = [-4 22];

    nMice = length(fpData);
    for iMouse = 1 : nMice
        velocityData = fpData(iMouse).dlc.velocity.LongTrials;
        if fpData(iMouse).dlc.frameRate == 30
            averageVelocity(iMouse,:) = mean(velocityData, 'omitnan');
        else
            binnedVelocity = [];
            for jTrial = 1 : size(velocityData,1)
                binnedVelocity(jTrial, 1:779) = arrayfun(@(x) mean(velocityData(jTrial, x:x+1)), 1:2:length(velocityData)-2);
            end
            averageVelocity(iMouse,:) = mean(binnedVelocity, 'omitnan');
        end
    end

    acrossMouseAverage = mean(averageVelocity);
    acrossMouseSTD = std(averageVelocity, 0, 1) ./ sqrt(nMice);

    x = intervalLimit(1) + 1/30 : 1/30 : intervalLimit(2);
    xline(0, '--');
    plotband(x(1:end-1), acrossMouseAverage, acrossMouseSTD, [228/255 67/255 95/255]);
    xlim(intervalLimit);
    xticks([-4 0 6 12 18 22]);
    ylabel('Velocity (mm/s)');
    xlabel('Time from Trial Start (s)');
    set(gca, 'FontSize', 14)

end