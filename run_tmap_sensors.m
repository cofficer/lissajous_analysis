function output = run_tmap_sensors(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Plot and show sensors maximially activated by
  %rotation onset.
  %Created 05/01/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %How to create tmaps?
  %Alternative i) use non-baselined data from
  %pre-cue period and test against stimulus onset
  %
  %Alternative ii) use baseline data from baseline
  %period and test against baselined stimulus onset
  %
  %The end we should have two matrices. Participant by sensors.
  %And run ttest to get 1 tvalue per sensor, on the difference of baseline vs.
  %stimulus onset.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  clear all

  blocktype = 'continuous';%continuous or trial

  mainDir = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/stim/';
  cd(mainDir)

  %Store all the seperate data files
  stim_paths = dir('*stim_high*'); %or freqavgs_high.
  load(stim_paths(1).name)
  cfg =[];
  cfg.avgoverrpt = 'yes';
  freq = ft_selectdata(cfg,freq);

  %Create matrix for all participants.
  dims = size(freq.powspctrm);
  all_stim = zeros(29,dims(1),dims(2),dims(3));

  %Load all participants
  for ifiles = 1:length(stim_paths)-1
    all_stim(ifiles,:,:,:) = freq.powspctrm;
    disp((stim_paths(ifiles+1).name))
    load(stim_paths(ifiles+1).name)
    cfg =[];
    cfg.avgoverrpt = 'yes';
    freq = ft_selectdata(cfg,freq);
  end

  %Average over time period and over frequency. Does it matter which order?
  %First freq average
  all_stim=squeeze(nanmean(all_stim(:,:,13:28,:),3));
  %Second time average
  all_stim=squeeze(nanmean(all_stim(:,:,13:19,:),3));



  %Load the baseline freq data.
  mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/baseline/';
  cd(mainDir)

  %Store all the seperate data files
  cue_paths = dir('*baseline_high*'); %or freqavgs_high.
  load(cue_paths(1).name)
  cfg =[];
  cfg.avgoverrpt = 'yes';
  freq = ft_selectdata(cfg,freq);

  %new_powspctrm=zeros(29,274,38,61);
  %Loop all data files into seperate jobs
  %Create matrix for all participants.
  dims = size(freq.powspctrm);
  all_cue = zeros(29,dims(1),dims(2),dims(3));

  %Load all participants
  for ifiles = 1:length(cue_paths)-1
    all_cue(ifiles,:,:,:) = freq.powspctrm;
    disp((cue_paths(ifiles+1).name))
    load(cue_paths(ifiles+1).name)
    cfg =[];
    cfg.avgoverrpt = 'yes';
    freq = ft_selectdata(cfg,freq);
  end

  %Average over freq
  all_cue=squeeze(nanmean(all_cue(:,:,13:28,:),3));

  %Average over time
  all_cue=squeeze(nanmean(all_cue(:,:,:),3));




  %Find the timepoints of stim_freq of interest
  %Also define the freq of interest, and average over both?

  stim_time = [stim_freq.time(13),stim_freq.time(19)];

  [H,P,CI,STATS]=ttest(all_stim,all_cue,'dim',1);

  STATS.tstat


  tavalue = STATS.tstat';

  %Plot the topo.
  %Make freq a vector
  cfg =[];
  cfg.avgoverfreq = 'yes';
  cfg.avgovertime = 'yes'
  freq = ft_selectdata(cfg,freq);

  freq.powspctrm = tavalue;

  hf=figure(1),clf
  ax2=subplot(1,1,1)
  % freq.powspctrm = switchTrial;
  cfg=[];
  cfg.zlim         = [-5 5];
  % cfg.ylim         = [20 35];%7 12
  % cfg.ylim         = [10 20];
  cfg.layout       = 'CTF275_helmet.lay';
  % cfg.xlim         = [0.3 0.6];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  % cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  cfg.highlight          = 'on'
  cfg.highlightchannel=freq.label(tavalue>4);
  cfg.colorbar           = 'yes'
  cfg.highlightcolor =[0 0 0];
  cfg.highlightsize=12;
  cfg.title='TOPO all participants gamma';
  cfg.colorbar           = 'yes'
  % ft_singleplotTFR(cfg,freq);
  %ft_multiplotTFR(cfg,freq)
  ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(ax2,flipud(brewermap(64,'RdBu')))

  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('prelim16_high_tmap_baseCue-stimon_sens_select');%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  set(hf,'PaperpositionMode','Auto')
  saveas(hf,figurefreqname,'png')


  %Visual sensors to save;
  visual_sensors = freq.label(tavalue>4);
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial')
  namefigure='visual_sensors'
  visname = sprintf('%s_%s.mat',todaystr,namefigure)
  save(visname,'visual_sensors')



end
