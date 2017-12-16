function [freq,switchTrial,stableTrial]=freq_average_individual_all(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and average across
%Based on freq_average_individual
%But to output the average response of all trials.
%Created 22/11/2017. Accomodate trial-based/stim
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype)

cd(filepath)

doplot     = 0;
compSwitch = 0;
if strcmp(cfgin.blocktype,'continuous')
  freqpath   = dir(sprintf('*freq_%s*-26-26*',cfgin.freqrange));
else
  freqpath   = dir(sprintf('*freq_%s_stim_off*',cfgin.freqrange));
end


%Load the freq data
disp(freqpath(cfgin.part_ID).name)
load(freqpath(cfgin.part_ID).name)

% %Remove trials with response too close to stimulus onset.
% idx_trl = ((freq.trialinfo(:,9)-freq.trialinfo(:,7))./1200)>-0.2;
% sum(idx_trl)
%
% cfg = [];
% cfg.trials = ~idx_trl;
% freq = ft_selectdata(cfg,freq);


%Run within trial baseline
cfg                       = [];
cfg.subtractmode          = 'norm_avg'; % norm_avg within_norm, within
%Find first nonnan timepoint in data, and use that before and after self-O
%What if there are no nans at all...
if strcmp(cfgin.blocktype,'continuous')
  idx_nan = ~isnan(switchTrial.powspctrm(1,1,1,:));
  idx_time=find(diff(idx_nan)==-1);
  switchTrial.time(idx_time)
  cfg.baselinewindow        = [-switchTrial.time(idx_time) switchTrial.time(idx_time)];

else
  %4.5=stim_off.
  cfg.baselinewindow        = [cfgin.baseline(1) cfgin.baseline(2)]; %-0.4 -0.1
end

[freq_base] = baseline_lissajous_all(freq,cfg);


%Make the freq the trial average
cfg =[];
cfg.avgoverrpt = 'yes';
freq = ft_selectdata(cfg,freq);

%substitute powspctrm with own baselined data
freq.powspctrm=freq_base;

%Save the freq in new folder
d_average = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/',cfgin.blocktype);
cd(d_average)
freqtosave = sprintf('freqavgs_all_%s_%d',cfgin.freqrange,cfgin.part_ID);
save(freqtosave,'freq')

end
