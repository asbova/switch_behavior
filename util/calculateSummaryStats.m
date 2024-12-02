function SummaryStatsTable = calculateSummaryStats(data)

    Avg = mean(data); 
    STD = std(data); 
    N = size(data,2); 
    SEM = STD/(sqrt(N));
    Median = median(data); 
    Q1 = quantile(data, 0.25); 
    Q2 = quantile(data, 0.75); 
    IntQRange = Q2 - Q1; 
    Limen = IntQRange/2; 
    WR = Limen/Median;
    CV = (STD/Avg)*100;

    SummaryStatsTable = array2table([Avg, STD, N, SEM, Median, Q1, Q2, IntQRange, Limen, WR, CV]);
    SummaryStatsTable.Properties.VariableNames = {'Average', 'STD', 'N', 'SEM', 'Median', 'Q1', 'Q2', 'IntQRange', 'Limen', 'WR', 'CV'};

end