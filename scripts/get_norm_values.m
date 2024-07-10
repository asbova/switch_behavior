function dataSt = get_norm_values(dataSt)

num_sess = size(dataSt,2);
for i_sess = 1 : num_sess
    
    mouse_id = char(dataSt(i_sess).animalID);
    beh_data = dataSt(i_sess).TrialAnSt.(mouse_id);
    
    % find short correct trials to extract reward signal
    all_correct_trials = find(cellfun(@(x) ~isempty(x), {beh_data.reward}));
    short_trials = find(cellfun(@(x) x == 6000, {beh_data.programmedDuration}));
    short_reward_trials = ismember(all_correct_trials, short_trials);
    
    fp_short_reward = dataSt(i_sess).RewardDisp(short_reward_trials,:);
    
    % get max peak in the 1s after reward delivery
    rew_pks = NaN(size(fp_short_reward,1),1);
    for i_trial = 1 : size(fp_short_reward,1)       
        %plot(fp_short_reward(i_trial,:)); hold on;
        pks = findpeaks(fp_short_reward(i_trial,500:600));
        if isempty(pks)
            rew_pks(i_trial) = NaN;
        else
            rew_pks(i_trial) = max(pks);
        end
    end   
    
    avg_pks = mean(rew_pks,'omitnan');
    dataSt(i_sess).normValue = avg_pks;
end