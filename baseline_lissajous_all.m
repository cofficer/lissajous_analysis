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

%Compute the average signal for combined baseline
if strcmp(cfg.subtractmode,'within')
  cfg2      = [];
  cfg2.avgoverrpt = 'yes';
  freq12    = ft_selectdata(cfg2,freq);
  freq12 = nanmean(freq12.powspctrm(:,:,toi1:toi2),3);
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
  base_name = dir(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/baseline/%s*',cfgin.restingfile(2:3)))
  base_trl  = load(sprintf('%s/%s',base_name.folder,base_name.name));
  base_trl  = base_trl.freq;
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
