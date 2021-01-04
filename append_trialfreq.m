function [switchTrial] = append_trialfreq(cfg,switchTrial,freqtmp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and append across trials
%Created 15/09/2017.
%switchTrial = freqAll 
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Append powspctrm, cumtapcnt, trialinfo...
switchTrial.powspctrm = [switchTrial.powspctrm;freqtmp.powspctrm];
switchTrial.cumtapcnt = [switchTrial.cumtapcnt;freqtmp.cumtapcnt];
switchTrial.trialinfo = [switchTrial.trialinfo(:,1:7);freqtmp.trialinfo(:,1:7)];


% use freq.cfg.trials to remove the trails that were removed in
% clean_resp function. 


switchTrial.sampletrials = [switchTrial.sampletrials;freqtmp.cfg.previous.previous.previous.previous.previous.previous.previous.trl(freqtmp.cfg.trials,1:2)];

end
