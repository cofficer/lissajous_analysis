function [idx_artifacts, freq] = freq_artifact_remove(freq,cfgin,ipart)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Remove all trials with artifact,
  %Insert NaN for blinks into freq. Add freq xtra wdw.
  %Created 02/03/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %preproc path
  cd(sprintf('%s%s/preprocessed/%s/%s/',cfgin.fullpath(1:56),...
  cfgin.blocktype,cfgin.restingfile,cfgin.stim_self))
  preproc_path = dir(sprintf('*noMEG*%d.mat',ipart+1));

  load(preproc_path.name) %dataNoMEG

  arfct_path = dir(sprintf('artifacts*%d.mat',ipart+1));

  load(arfct_path.name) % artifact_Jump/Muscle/idx_jump

  sampleinfo = dataNoMEG.cfg.previous.previous.trl(:,1:2);

  %Find muscle trials
  for iart = 1:length(artifact_Muscle)

    idx_trl_mscle_start = find(artifact_Muscle(iart,1)<sampleinfo(:,2));
    idx_trl_mscle_start = idx_trl_mscle_start(1);

    idx_trl_mscle_end = find(artifact_Muscle(iart,2)<sampleinfo(:,2));
    idx_trl_mscle_end = idx_trl_mscle_end(1);

    idx_mscle{iart} = unique([idx_trl_mscle_start,idx_trl_mscle_end]);

  end

  %Muscle and jump trials to remove.
  idx_artifacts = unique([idx_mscle{:},idx_jump]);

  %Identify blinks and insert nans.

  cfg = [];
  cfg.toilim = [-2.25 2.25];
  dataNoMEG = ft_redefinetrial(cfg,dataNoMEG)

  %Remove trials that are not present in the freq data.
  cfg = [];
  cfg.trials = zeros(1,length(dataNoMEG.time));
  cfg.trials(freq.trialinfo(:,6))=1;
  cfg.trials=logical(cfg.trials);
  dataNoMEG = ft_selectdata(cfg,dataNoMEG);

  %Eye artifact detection.
  cfg                              = [];
  cfg.continuous                   = 'no'; % data has been epoched

  % channel selection, cutoff and padding
  cfg.artfctdef.zvalue.channel     = {'UADC003'};

  % 001, 006, 0012 and 0018 are the vertical and horizontal eog chans
  cfg.artfctdef.zvalue.trlpadding  = 0; % avoid filter edge artefacts by setting to negative
  cfg.artfctdef.zvalue.fltpadding  = 0;
  cfg.artfctdef.zvalue.artpadding  = 0.05; % go a bit to the sides of blinks

  % algorithmic parameters
  cfg.artfctdef.zvalue.bpfilter   = 'yes';
  cfg.artfctdef.zvalue.bpfilttype = 'but';
  cfg.artfctdef.zvalue.bpfreq     = [1 15];
  cfg.artfctdef.zvalue.bpfiltord  = 4;
  cfg.artfctdef.zvalue.hilbert    = 'yes';

  % set cutoff
  cfg.artfctdef.zvalue.cutoff     = 1; % to detect all blinks, be strict
  % cfg.artfctdef.zvalue.interactive = 'yes';
  % I think I need the downsampled samplinfo which is not present currently.
  [~, artifact_eog]               = ft_artifact_zvalue(cfg, dataNoMEG); %816272

  %in artifact_eog trials are appended. So samples = sample_trial * num_trials
  %would like the output in the form of which trial and time-window is contaminated by blinks.
  %I should first extend the blink time window by +/- half time-window, which is freq dependant.
  %but 250ms (500/4 samples) for low.

  start_blink = artifact_eog(:,1)-125;
  start_blink(start_blink<1)=1;
  end_blink   = artifact_eog(:,2)+125;


  freq_nan = freq.powspctrm;

  %predefine variables
  sample_from_start   = zeros(1,length(start_blink));
  sample_from_stop    = zeros(1,length(start_blink));
  num_bins_start      = zeros(1,length(start_blink));
  num_bins_stop       = zeros(1,length(start_blink));


  %I need to figure out which time-bins are affected in which trials.
  %Perhaps a for-look for mod(3001) would work
  for iblinks = 1:length(start_blink)
    %find trial of the blink.
    %insert nan at the time-freq been affected.
    trl=ceil(start_blink(iblinks)/length(dataNoMEG.time{1}));

    %How do find the affect tbins?
    %How many samples in each tbin? 25. 1 sample = 0.002s. 1 bin = 0.05.
    sample_from_start(iblinks)       = mod(start_blink(iblinks),length(dataNoMEG.time{1}));
    sample_from_stop(iblinks)        = mod(end_blink(iblinks),length(dataNoMEG.time{1}));

    %convert num samples to num bins. 25samples = 1 bin
    num_bins_start(iblinks)          = ceil(sample_from_start(iblinks)/25);
    num_bins_stop(iblinks)           = ceil(sample_from_stop(iblinks)/25);

    if num_bins_start(iblinks)<1;num_bins_start(iblinks)=1;end

    %the num_bins_start, until num_bins_stop
    freq_nan(trl,:,:,num_bins_start(iblinks):num_bins_stop(iblinks))=NaN;

  end

  freq.powspctrm = freq_nan;

end
