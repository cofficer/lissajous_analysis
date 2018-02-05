function [freq_base1,freq_base2]=baseline_lissajous(freq1,freq2,cfg,cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in already computed freq data
%Compute the baseline according to cfg.
%Created 8/09/2017.
%Can also handle within trial baseline
%Updated 15/09/2017.
%Update 12/10/2017:
%If I only want to do within trial subtraction and normal
%then freq12 needs to also be within trial...
%Outputting NaNs, because of the timewindow probably.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%toi-index
toi1 = find(round(freq1.time,2)==round(cfg.baselinewindow(1),2));
toi2 = find(round(freq1.time,2)==round(cfg.baselinewindow(2),2));


%Compute the average signal for combined baseline
if strcmp(cfg.subtractmode,'within')
  freq12    = append_trialfreq([],freq1,freq2);
  %instead of using the average of the two inputs, one could load
  %cue-locked data.
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/cue')
  freqpath   = dir(sprintf('*%s*-26-26*',cfgin.freqrange));

  namecell = {freqpath.name};
  partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);
  partnum = cellfun(@str2num,partnum,'UniformOutput',false);
  blocks_ID = find(ismember([partnum{:}],cfgin.part_ID));

  for ipart = 1:length(blocks_ID)
    load(freqpath(blocks_ID(ipart)).name)
    if ipart>1
      cfg=[];
      cfg.trials=freq.trialinfo(:,5)>0;
      freqtmp = ft_selectdata(cfg,freq);
      %new function for appending data.
      freq12 = append_trialfreq([],freq12,freqtmp);
      freqtmp=[];
    else
      cfg=[];
      cfg.trials=freq.trialinfo(:,5)>0;
      freq12 = ft_selectdata(cfg,freq);
    end
  end

  %Average the loaded cue data.
  cfg2      = [];
  cfg2.avgoverrpt = 'yes';
  freq12    = ft_selectdata(cfg2,freq12);
  freq12 = nanmean(freq12.powspctrm(:,:,41:51),3);

elseif strcmp(cfg.subtractmode,'combine') %not sure about the combine.

  freq1  = freq1.powspctrm;
  freq2  = freq2.powspctrm;
  freq12 = freq1(:,:,toi1:toi2)+freq2(:,:,toi1:toi2)./2;
  freq12 = mean(freq12,3);
end

%Compute baseline, subtracting using freq of interest
if strcmp(cfg.subtractmode,'same')
  freq_base1 = ((freq1-mean(freq1(:,:,toi1:toi2),3))./freq12)*100;
  freq_base2 = ((freq2-mean(freq2(:,:,toi1:toi2),3))./freq12)*100;
%Compute baseline, subtracting using combined freq of interest
elseif strcmp(cfg.subtractmode,'combine')
  freq_base1 = ((freq1-freq12)./freq12)*100;
  freq_base2 = ((freq2-freq12)./freq12)*100;
elseif strcmp(cfg.subtractmode,'within')

  %loop over all trials for each switch and stable trials
  for itrl1 = 1:size(freq1.powspctrm,1)
    freq_base1(itrl1,:,:,:) = ((squeeze(freq1.powspctrm(itrl1,:,:,:)) - freq12)./freq12)*100;
  end
  for itrl2 = 1:size(freq2.powspctrm,1)
    freq_base2(itrl2,:,:,:) = ((squeeze(freq2.powspctrm(itrl2,:,:,:)) - freq12)./freq12)*100;
  end

  %Average over trials
  freq_base1 = squeeze(nanmean(freq_base1,1));
  freq_base2 = squeeze(nanmean(freq_base2,1));

%within_norm means doing single-trial normalization
%and compute within trial percent change.
elseif strcmp(cfg.subtractmode,'within_norm')
  %loop over all trials for each switch and stable trials
  for itrl1 = 1:size(freq1.powspctrm,1)
    base_trl = squeeze(mean(freq1.powspctrm(itrl1,:,:,toi1:toi2),4));
    freq_base1(itrl1,:,:,:) = ((squeeze(freq1.powspctrm(itrl1,:,:,:)) - base_trl)./base_trl)*100;
  end
  for itrl2 = 1:size(freq2.powspctrm,1)
    base_trl = squeeze(mean(freq2.powspctrm(itrl2,:,:,toi1:toi2),4));
    freq_base2(itrl2,:,:,:) = ((squeeze(freq2.powspctrm(itrl2,:,:,:)) - base_trl)./base_trl)*100;
  end

  %Average over trials
  freq_base1 = squeeze(nanmean(freq_base1,1));
  freq_base2 = squeeze(nanmean(freq_base2,1));
end


end
