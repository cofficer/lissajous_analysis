function [freq,freqsamples,idx_artifacts] = clean_resp(trlTA_1,freq,ipart,iblock,latency)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Extract model predictions per self-occlusion
%based on the active inference framework.
%TODO: good idea to do for every block.
%This funciton is meant to remove all previously
%Identified artifacts. Could possible be found in trl_info.
%TODO: look into how the freq analysis was made to begin with.

%TODO: also clean up according to [idx_artifacts, freq] = freq_artifact_remove(freq,cfgin,ipart)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


% load('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/continous_self_freq/29freq_low_selfocclBlock4.mat')

% Path to the preprocessed information.
cfgin.preproc = '/home/chris/Dropbox/PhD/Projects/Lissajous/preproc_continuous_self_freq/';
cfgin.blocktype = 'continuous';

[idx_artifacts, freq] = freq_artifact_remove(freq,cfgin,ipart,iblock)

% remove trials with musle artifcats from freq.
% cfg = [];
% cfg.trials = ones(1,length(freq.trialinfo))';
% cfg.trials(idx_artifacts) = 0;
% cfg.trials = logical(cfg.trials)';
% freq = ft_selectdata(cfg,freq);


% Get original trial info
trl_info = freq.cfg.previous.previous.previous.previous.previous.previous.trl;

% Not sure why remove the samples. Probably to get the timestamp of the self-occlusions.
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
cfg.trials = logical(ones(1,size(freq.powspctrm,1)))';
% remove muscle artifacts.
cfg.trials(idx_artifacts) = 0;
cfg.latency   = latency;
freq = ft_selectdata(cfg, freq);

trial_end.index(idx_artifacts) = [];
trial_end.freq(idx_artifacts) = [];
trial_end.respfreq(idx_artifacts) = [];

freqsamples=trial_end.freq(trial_end.index);

idx_artifacts=cfg.trials;
end
