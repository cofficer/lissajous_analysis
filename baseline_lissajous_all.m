function [freq_base]=baseline_lissajous_all(freq,cfg)
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
    freq_base1(itrl1,:,:,:) = ((squeeze(freq.powspctrm(itrl1,:,:,:)) - base_trl)./base_trl)*100;
  end

  %Average over trials
  freq_base = squeeze(nanmean(freq_base1,1));
end


end
