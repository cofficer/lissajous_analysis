function [freq_base]=baseline_lissajous_all(freq,cfg,cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in already computed freq data
%Compute the baseline according to cfg.
%Created 22/1/2017.
%modified version of baseline_lissajous
%the goal is to baseline within all trials.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%toi-index
toi1 = find(round(freq.time,2)==round(cfg.baselinewindow(1),2));
toi2 = find(round(freq.time,2)==round(cfg.baselinewindow(2),2));

%Compute the percent change using the average cue-locked baseline
if strcmp(cfg.subtractmode,'within')
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/cue')
  freqpath   = dir(sprintf('*%s*',cfgin.freqrange));
  baseline = load(freqpath(cfgin.part_ID).name);

  cfg2      = [];
  cfg2.avgoverrpt = 'yes';
  freq12    = ft_selectdata(cfg2,baseline.freq);
  toi1 = find(round(freq12.time,2)==round(cfg.baselinewindow(1),2));
  toi2 = find(round(freq12.time,2)==round(cfg.baselinewindow(2),2));
  freq12 = nanmean(freq12.powspctrm(:,:,toi1:toi2),3);
%Compute baseline, subtracting using freq of interest
end

%Compute the percent change using the average within trial baseline
if strcmp(cfg.subtractmode,'within_trial')

  baseline = freq;

  cfg2      = [];
  cfg2.avgoverrpt = 'yes';
  freq12    = ft_selectdata(cfg2,baseline);
  freq12 = nanmean(freq12.powspctrm(:,:,:),3);
  %loop over all trials for each switch and stable trials
  for itrl1 = 1:size(freq.powspctrm,1)
    freq_base(itrl1,:,:,:) = ((squeeze(freq.powspctrm(itrl1,:,:,:)) - freq12)./freq12)*100;
  end

  %Average over trials
  freq_base = squeeze(nanmean(freq_base,1));

%Compute baseline, subtracting using freq of interest
end

if strcmp(cfg.subtractmode,'within')

  %loop over all trials for each switch and stable trials
  for itrl1 = 1:size(freq.powspctrm,1)
    freq_base(itrl1,:,:,:) = ((squeeze(freq.powspctrm(itrl1,:,:,:)) - freq12)./freq12)*100;
  end


  %Average over trials
  freq_base = squeeze(nanmean(freq_base,1));

%within_norm means doing single-trial normalization
%and compute within trial percent change.
elseif strcmp(cfg.subtractmode,'within_norm')
  %loop over all trials for each switch and stable trials
  for itrl1 = 1:size(freq.powspctrm,1)
    base_trl = squeeze(mean(freq.powspctrm(itrl1,:,:,toi1:toi2),4));
    freq_base(itrl1,:,:,:) = ((squeeze(freq.powspctrm(itrl1,:,:,:)) - base_trl)./base_trl)*100;
  end

  %Average over trials
  freq_base = squeeze(nanmean(freq_base,1));
elseif strcmp(cfg.subtractmode,'norm_avg')

  %use an average normalization instead of within each trial.
  base_name = dir(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/%s/%s*%s*',...
                  cfgin.stim_self,cfgin.restingfile(2:3),cfgin.freqrange));
  base_trl  = load(sprintf('%s/%s',base_name.folder,base_name.name));
  base_trl  = base_trl.freq;

  %index trials present in both base and trial
  freq_trl_idx = ismember(freq.trialinfo(:,12),base_trl.trialinfo(:,12));
  base_trl_idx = ismember(base_trl.trialinfo(:,12),freq.trialinfo(:,12));

  %redefine trials after index
  cfg = [];
  cfg.trials = freq_trl_idx;
  freq = ft_selectdata(cfg,freq);
  cfg = [];
  cfg.trials = base_trl_idx;
  base_trl = ft_selectdata(cfg,base_trl);

  %Average over time.
  base_trl  = squeeze(mean(base_trl.powspctrm(:,:,:,:),4));
  %Average over trials.
  base_trl  = squeeze(mean(base_trl,1));

  %Loop over each trial and each frequency band.
  for itrl1 = 1:size(freq.powspctrm,1)
    for ifreq = 1:size(freq.powspctrm,3)
      freq_base(itrl1,:,ifreq,:) = ((squeeze(freq.powspctrm(itrl1,:,ifreq,:)) - base_trl(:,ifreq))./base_trl(:,ifreq))*100;
    end
  end

  %Average over trials
  freq_base = squeeze(nanmean(freq_base,1));

end


end
