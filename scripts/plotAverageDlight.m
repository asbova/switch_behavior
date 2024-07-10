function glmStructure = plotAverageDlight(fpData)
%
% Plot average dlight signal (across mice) over multiple trials.
%
% Input: 
%       fpData:             structure with dlight data and dlc data for each session
%
% Output: 
%       figure


    intervalLimit = [-4 22];

    fpData = get_norm_values(fpData); % get normalization values

    nMice = length(fpData);
    for iMouse = 1 : nMice
        normalizationValue = fpData(iMouse).normValue;
        dlightData = fpData(iMouse).switchTrial / normalizationValue;
        averageDlight(iMouse,:) = mean(dlightData, 'omitnan');
    end

    acrossMouseAverage = mean(averageDlight);
    acrossMouseSTD = std(averageDlight, 0, 1) ./ sqrt(nMice);

    x = intervalLimit(1) + 1/100 : 1/100 : intervalLimit(2);
    xline(0, '--');
    plotband(x(1:end), acrossMouseAverage(:, 1100:3699), acrossMouseSTD(:, 1100:3699), [67/255 72/255 228/255]);
    xlim(intervalLimit);
    ylim([-0.3 0.5]);
    xticks([-4 0 6 12 18 22]);
    ylabel('dLight (normalized)');
    xlabel('Time from Trial Start (s)');
    set(gca, 'FontSize', 14)


end