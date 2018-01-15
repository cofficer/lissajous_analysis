function [freq,switchTrial,stableTrial]=freq_average_individual(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and average across
%Created 15/09/2017.
%Edited 22/11/2017. Accomodate trial-based/stim
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

namecell = {freqpath.name};

partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

partnum = cellfun(@str2num,partnum,'UniformOutput',false);


%part_ID = 5;

blocks_ID = find(ismember([partnum{:}],cfgin.part_ID));

suplot = 0;
%Loop over participant 3 seperate blocks
for ipart = 1:length(blocks_ID)
  suplot=suplot+1;

  %Load the freq data
  load(freqpath(blocks_ID(ipart)).name)
  disp(freqpath(blocks_ID(ipart)).name)

  %store details about each freq.
  partInfo(ipart).trialinfo = freq.trialinfo;


  %Change the button press to the same values.
  if ~strcmp(cfgin.blocktype,'trial')
    if sum(freq.trialinfo(:,5)==226)>0
      freq.trialinfo(freq.trialinfo(:,5)==226,5)=225;
      freq.trialinfo(freq.trialinfo(:,5)==228,5)=232;
    elseif sum(freq.trialinfo(:,5)==228)>0
      freq.trialinfo(freq.trialinfo(:,5)==228,5)=232;
      freq.trialinfo(freq.trialinfo(:,5)==226,5)=225;
    end
  end

  %Find the indices of switches and non switches.
  if strcmp(cfgin.blocktype,'trial')
    idx_switch   = zeros(1,length(freq.trialinfo(:,6)))';
    idx_switch(freq.trialinfo(:,6)==42)   = 1;
    idx_switch(freq.trialinfo(:,6)==45)   = 1;
    nopress      = freq.trialinfo(:,6)==43;
    idx_noswitch   = zeros(1,length(freq.trialinfo(:,6)))';
    idx_noswitch(freq.trialinfo(:,6)==41)   = 1;
    idx_noswitch(freq.trialinfo(:,6)==46)   = 1;
  else
    idx_switch   = (abs(diff(freq.trialinfo(:,5)))==7);
    nopress      = freq.trialinfo(:,5)==0;
    idx_noswitch = diff(freq.trialinfo(:,5))==0;
  end



  %Remove the trials where there is no buttonpress.
  idx_noswitch(nopress(length(idx_noswitch)))=0;
  idx_switch(nopress(length(idx_switch)))=0;

  currNum = partnum(ipart);

  %select trials,
  cfg   = [];
  if strcmp(cfgin.blocktype,'trial')
    cfg.trials = logical([idx_switch]); %add a 0 for the last trial.
  else
    cfg.trials = logical([idx_switch;0]); %add a 0 for the last trial.
  end
  %cfg.trial = ~nopress;
  %cfg.frequency = [12 35];
  cfg.avgoverrpt = 'no';
  if ipart>1
    freqtmp = ft_selectdata(cfg,freq);
    %new function for appending data.
    switchTrial = append_trialfreq([],switchTrial,freqtmp);
    freqtmp=[];
  else
    switchTrial  = ft_selectdata(cfg,freq);
  end
  %select trials
  cfg   = [];
  cfg.trials = logical([idx_noswitch;0]); %add a 0 for the last trial.
  cfg.avgoverrpt = 'no';
  if ipart>1
    freqtmp = ft_selectdata(cfg,freq);
    %new function for appending data.
    stableTrial = append_trialfreq([],stableTrial,freqtmp);
    freqtmp=[];
  else
    stableTrial  = ft_selectdata(cfg,freq);
  end


end

%Run within trial baseline
cfg                       = [];
cfg.subtractmode          = 'within'; %what are the options?
%Find first nonnan timepoint in data, and use that before and after self-O
%What if there are no nans at all...
if strcmp(cfgin.blocktype,'continuous')
idx_nan = ~isnan(switchTrial.powspctrm(1,1,1,:));
idx_time=find(diff(idx_nan)==-1);
switchTrial.time(idx_time)
cfg.baselinewindow        = [-switchTrial.time(idx_time) switchTrial.time(idx_time)];

else
  cfg.baselinewindow        = [switchTrial.time(1) switchTrial.time(11)];
end

% CG commented out the baseline for now. 2018-01-15.
% [switchTrial,stableTrial] = baseline_lissajous(switchTrial,stableTrial,cfg);


%Make the freq the trial average
cfg =[];
cfg.avgoverrpt = 'yes';
freq = ft_selectdata(cfg,freq);

%Make the freq the trial average
cfg =[];
cfg.avgoverrpt = 'yes';
switchTrial = ft_selectdata(cfg,switchTrial);

%Make the freq the trial average
cfg =[];
cfg.avgoverrpt = 'yes';
stableTrial = ft_selectdata(cfg,stableTrial);

%substitute powspctrm with own baselined data
freq.powspctrm=squeeze(switchTrial.powspctrm)-squeeze(stableTrial.powspctrm);

%Save the freq in new folder
d_average = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/',cfgin.blocktype);
cd(d_average)
freqtosave = sprintf('freqavgs_%s_%d',cfgin.freqrange,cfgin.part_ID);
save(freqtosave,'freq','switchTrial','stableTrial')

end
