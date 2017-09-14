function [switchTrial] = append_trialfreq([],switchTrial,freqtmp)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and append across trials
%Created 15/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Append powspctrm, cumtapcnt, trialinfo...
switchTrial.powspctrm = [switchTrial.powspctrm;freqtmp.powspctrm];
switchTrial.cumtapcnt = [switchTrial.cumtapcnt;freqtmp.cumtapcnt];
switchTrial.trialinfo = [switchTrial.trialinfo;freqtmp.trialinfo];

end
