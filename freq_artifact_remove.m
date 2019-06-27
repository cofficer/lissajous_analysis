function [idx_artifacts, freq] = freq_artifact_remove(freq,cfgin,ipart,iblock)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Remove all trials with artifact,
  %Insert NaN for blinks into freq. Add freq xtra wdw.
  %Created 02/03/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  % TODO: make function more general, call for any analysis.
  %preproc path
  % cd(sprintf('%s%s/preprocessed/%s/%s/',cfgin.fullpath(1:56),...
  % cfgin.blocktype,cfgin.restingfile,cfgin.stim_self))
  cd(cfgin.preproc)
  if strcmp(cfgin.blocktype,'trial')
    preproc_path = dir(sprintf('*noMEG*%s*block1.mat',cfgin.restingfile));
    load(preproc_path.name) %dataNoMEG

    arfct_path = dir(sprintf('artifacts*block1.mat'));
    load(arfct_path.name)

    cfg = [];
    cfg.toilim = [freq.time(1) freq.time(end)];
    dataNoMEG = ft_redefinetrial(cfg,dataNoMEG);

    cfg = [];
    cfg.trials = ismember(dataNoMEG.trialinfo(:,12),freq.trialinfo(:,12));
    dataNoMEG = ft_selectdata(cfg,dataNoMEG);
    % idx_artifacts=[];
    sampleinfo = dataNoMEG.cfg.previous.previous.previous.previous.trl(:,1:2);

  else
    preproc_path = dir(sprintf('*noMEG*%s*%d.mat',ipart,iblock+1));
    load(preproc_path.name) %dataNoMEG

    arfct_path = dir(sprintf('artifacts*%s*%d.mat',ipart,iblock+1));

    load(arfct_path.name) % artifact_Jump/Muscle/idx_jump
    if isfield(dataNoMEG.cfg.previous.previous,'trl')
      sampleinfo = dataNoMEG.cfg.previous.previous.trl(:,1:2);
    else
      sampleinfo = dataNoMEG.cfg.previous.previous.previous.trl(:,1:2);
    end
    %Identify blinks and insert nans.

    % Not sure if it should be 2.5 instead.
    cfg = [];
    cfg.toilim = [-2.25 2.25];
    dataNoMEG = ft_redefinetrial(cfg,dataNoMEG)

  end

  %Find muscle trials
  for iart = 1:size(artifact_Muscle,1)

    idx_trl_mscle_start = find(artifact_Muscle(iart,1)<sampleinfo(:,2));
    idx_trl_mscle_start = idx_trl_mscle_start(1);

    idx_trl_mscle_end = find(artifact_Muscle(iart,2)<sampleinfo(:,2));
    idx_trl_mscle_end = idx_trl_mscle_end(1);

    idx_mscle{iart} = unique([idx_trl_mscle_start,idx_trl_mscle_end]);

  end

  if length(artifact_Muscle)==0
    idx_artifacts=idx_jump;
  else
    %Muscle and jump trials to remove.
    idx_artifacts = unique([idx_mscle{:},idx_jump]);
  end


  %Eye artifact detection.
  cfg                              = [];
  cfg.continuous                   = 'no'; % data has been epoched

  % channel selection, cutoff and padding
  cfg.artfctdef.zvalue.channel     = {'UADC003'};

  % 001, 006, 0012 and 0018 are the vertical and horizontal eog chans
  cfg.artfctdef.zvalue.trlpadding  = 0; % avoid filter edge artefacts by setting to negative
  cfg.artfctdef.zvalue.fltpadding  = 0;
  cfg.artfctdef.zvalue.artpadding  = 0.05; % go a bit to the sides of blinks
  % cfg.artfctdef.zvalue.feedback    = 'yes';

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
    trl_start   = ceil(start_blink(iblinks)/length(dataNoMEG.time{1}));
    trl_stop    = ceil(end_blink(iblinks)/length(dataNoMEG.time{1}));


    %How do find the affect tbins?
    %How many samples in each tbin? 25. 1 sample = 0.002s. 1 bin = 0.05.
    %This might be wrong, if the samples are considered in terms of original Hz.
    sample_from_start(iblinks)       = mod(start_blink(iblinks),length(dataNoMEG.time{1}));
    sample_from_stop(iblinks)        = mod(end_blink(iblinks),length(dataNoMEG.time{1}));

    %Correction for the cases where blinks extend across more than one trial.
    %If the end trial is one larger than the start trial, then remove from
    %sample 1 on the end trial.
    %The samples which extend into the previous trial will be ignored since
    %The data is not continuous.
    if trl_stop>trl_start;
      trl_start=trl_stop;
      sample_from_start(iblinks)=1;
    end
    %convert num samples to num bins. 25samples = 1 bin
    %1 bin=50ms, 1 sample = 1/1200ms. 20 freq bins per second.
    %1 freq bins = 50ms = 24 original samples.
    %assuming basing all samples on the new sample rate.... does not make sense.
    %1200*0.05 = 60. The convertion rate for orig samples to freq time bins.
    num_bins_start(iblinks)          = ceil(sample_from_start(iblinks)/60);
    num_bins_stop(iblinks)           = ceil(sample_from_stop(iblinks)/60);

    % 2422/1200 sec from start. = 2.01, how many freq bins? one every 50ms.

    if num_bins_start(iblinks)<1;
      num_bins_start(iblinks)=1;
    end

    %the num_bins_start, until num_bins_stop
    freq_nan(trl_start,:,:,num_bins_start(iblinks):num_bins_stop(iblinks))=NaN;

  end

  freq.powspctrm = freq_nan;

  perc_blink = sum(isnan(freq.powspctrm(:)))/numel(freq.powspctrm);

  disp(sprintf('The frequency data has %3f percent inserted NaNs',perc_blink))

end
