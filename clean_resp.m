function [freq,freqsamples] = clean_resp(trlTA_1,freq,model_dat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extract model predictions per self-occlusion
%based on the active inference framework.
%TODO: good idea to do for every block.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


trl_info = freq.cfg.previous.previous.previous.previous.previous.previous.trl;

trial_end.freq = trl_info(:,2)-3600;
if trlTA_1.participant(1)==1
  trial_end.freq=trial_end.freq-2700;
end
trial_end.respfreq = trl_info(:,8);
trial_end.model = trlTA_1.SelfOcclusionSample;

% indexes of the current block.
% finds the samples in the freq data that exists as samples in the model data.
% this should get rid of all non-response trials already.
trial_end.index = (ismember(trial_end.freq,trial_end.model));

% remove bad trials. Add to trial_end.index?
% removes all non-existant trials, this probably changes nothing over the above one.
resp = trial_end.respfreq;
add_index=(resp>0);
trial_end.index = and(trial_end.index,add_index);

cfg = [];
cfg.trials = trial_end.index;
cfg.latency   = [-0.5,0.5];
freq = ft_selectdata(cfg, freq);


freqsamples=trial_end.freq(trial_end.index);
end
