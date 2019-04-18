function [freq,model_dat_block] = clean_resp(trlTA_1,freq,model_dat)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extract model predictions per self-occlusion
%based on the active inference framework.
%TODO: good idea to do for every block.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


trl_info = freq.cfg.previous.previous.previous.previous.previous.previous.trl;

% model_info should always be larger. So we use find for all the samples.
figure(1),clf
plot((trl_info(1:end,2)-3600)-(trlTA_1.SelfOcclusionSample(1:length(trl_info(1:end,2)))))


trial_end.freq = trl_info(1:end,2)-3600;
trial_end.model = trlTA_1.SelfOcclusionSample;

trial_end.index = (ismember(trial_end.freq,trial_end.model));

model_dat_block=model_dat(trial_end.index);


cfg = [];
cfg.trials = trial_end.index;
freq = ft_selectdata(cfg, freq);

% TODO: index mask for data
% TODO: output freq after masking. 
freq.powspctrm = freq.powspctrm();

resp = trl_info(:,end-2)
resp=resp(resp>0);
freq=
resp(resp==225)=0;
resp(resp==232)=1;
resp(resp==226)=0;
resp(resp==228)=1;
resp=resp(~isnan(resp));



end
