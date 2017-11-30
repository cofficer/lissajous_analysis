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
  freqpath   = dir(sprintf('*%s*-26-26*',cfgin.freqrange));
else
  freqpath   = dir(sprintf('*stim_%s*',cfgin.freqrange));
end

%Load the freq data
load(freqpath(cfgin.part_ID).name)
disp(freqpath(cfgin.part_ID).name)


%Run within trial baseline
cfg                       = [];
cfg.subtractmode          = 'within_norm'; %what are the options? within_norm, within
%Find first nonnan timepoint in data, and use that before and after self-O
%What if there are no nans at all...
if strcmp(cfgin.blocktype,'continuous')
  idx_nan = ~isnan(switchTrial.powspctrm(1,1,1,:));
  idx_time=find(diff(idx_nan)==-1);
  switchTrial.time(idx_time)
  cfg.baselinewindow        = [-switchTrial.time(idx_time) switchTrial.time(idx_time)];

else
  cfg.baselinewindow        = [freq.time(22) freq.time(29)];
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
