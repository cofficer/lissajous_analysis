function [avgFreq] = freq_average_individual(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and average across
%Created 15/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


clear all;close all
cfgin.blocktype='continuous';
filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype)

cd(filepath)

freqrange  = 'high';
doplot     = 0;
compSwitch = 0;
freqpath   = dir(sprintf('*%s*-26-26*',freqrange));

%Remove participant nr 10, super weird artifacts.
namecell = {freqpath.name};

partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

partnum = cellfun(@str2num,partnum,'UniformOutput',false);


part_ID = 5;

blocks_ID = find(ismember([partnum{:}],part_ID));

suplot = 0;
%Loop over participants
for ipart = 1:length(blocks_ID)
  suplot=suplot+1;

  %Load the freq data
  load(freqpath(blocks_ID(ipart)).name)
  disp(freqpath(blocks_ID(ipart)).name)

  %store details about each freq.
  partInfo(ipart).trialinfo = freq.trialinfo;


  %Change the button press to the same values.
  if sum(freq.trialinfo(:,5)==226)>0
    freq.trialinfo(freq.trialinfo(:,5)==226,5)=225;
    freq.trialinfo(freq.trialinfo(:,5)==228,5)=232;
  elseif sum(freq.trialinfo(:,5)==228)>0
    freq.trialinfo(freq.trialinfo(:,5)==228,5)=232;
    freq.trialinfo(freq.trialinfo(:,5)==226,5)=225;
  end

  %Find the indices of switches and non switches.
  idx_switch   = (abs(diff(freq.trialinfo(:,5)))==7);
  nopress      = freq.trialinfo(:,5)==0;
  idx_noswitch = diff(freq.trialinfo(:,5))==0;

  %Remove the trials where there is no buttonpress.
  idx_noswitch(nopress(length(idx_noswitch)))=0;
  idx_switch(nopress(length(idx_switch)))=0;

  currNum = partnum(ipart);

  %select trials,
  cfg   = [];
  cfg.trials = logical([idx_switch;0]); %add a 0 for the last trial.
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
  freq=[];

end

%How to do the within trial baseline?


%Save figure active.
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim2_SwitchvsNoswitch_highfreq26-26_TFR');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,figurefreqname,'png')
