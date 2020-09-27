function [switchTrial] = append_trialfreq(cfg,switchTrial,freqtmp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and append across trials
%Created 15/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Append powspctrm, cumtapcnt, trialinfo...
switchTrial.powspctrm = [switchTrial.powspctrm;freqtmp.powspctrm];
switchTrial.cumtapcnt = [switchTrial.cumtapcnt;freqtmp.cumtapcnt];
switchTrial.trialinfo = [switchTrial.trialinfo(:,1:7);freqtmp.trialinfo(:,1:7)];

end
