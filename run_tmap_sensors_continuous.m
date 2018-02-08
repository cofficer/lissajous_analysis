function output = run_tmap_sensors_continuous(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Plot and show activity maximially activated by
  %perceptual switch.
  %Created 15/01/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  clear all

  blocktype = 'continuous';%continuous or trial

  mainDir = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/self',blocktype);
  cd(mainDir)

  %Store all the seperate data files
  stim_paths = dir('freqavgs_switch_low*'); %or freqavgs_high.
  load(stim_paths(1).name)


  %Create matrix for all participants.
  dims = size(freq.powspctrm);
  all_stim = zeros(29,dims(1),dims(2),dims(3));
  all_base = zeros(29,dims(1),dims(2),dims(3));

  %Load all participants
  for ifiles = 1:length(stim_paths)

    disp((stim_paths(ifiles).name))
    load(stim_paths(ifiles).name)
    all_stim(ifiles,:,:,:) = switchTrial.powspctrm;
    all_base(ifiles,:,:,:) = stableTrial.powspctrm;

  end

  %Load the sensors of interest
  load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-01-05_visual_sensors.mat')

  idx_trialsens = ismember(freq.label,visual_sensors);

  %Average data to make a TFR plot.
  %Average over the sensors.
  %Average over time period and over frequency. Does it matter which order?
  %First freq average
  % all_stim=squeeze(nanmean(all_stim(:,idx_trialsens,:,:),2));
  all_stim=squeeze(nanmean(all_stim(:,:,5:10,:),3));
  all_stim=squeeze(nanmean(all_stim(:,:,38:48),3));
  %Second time average
  % all_base=squeeze(nanmean(all_base(:,idx_trialsens,:,:),2));
  all_base=squeeze(nanmean(all_base(:,:,5:10,:),3));
  all_base=squeeze(nanmean(all_base(:,:,38:48),3));
  all_freq = squeeze(nanmean(all_stim,1))-squeeze(nanmean(all_base,1));

  %Find the timepoints of stim_freq of interest
  %Also define the freq of interest, and average over both?

  % stim_time = [stim_freq.time(13),stim_freq.time(19)];

  [H,P,CI,STATS]=ttest(all_stim,all_base,'dim',1);

  STATS.tstat


  tavalue = (STATS.tstat); %tavalue(1,:,:)=all_freq; %tavalue(1,:,:)=nanmean(all_stim,1);

  %Plot the topo.
  %Make freq a vector
  cfg =[];
  cfg.avgoverfreq = 'yes';
  freq = ft_selectdata(cfg,freq);

  cfg =[];
  cfg.avgovertime = 'yes';
  freq = ft_selectdata(cfg,freq);

  freq.powspctrm = tavalue';


  hf=figure(1),clf
  ax2=subplot(1,1,1)
  % freq.powspctrm = switchTrial;
  cfg=[];
  cfg.zlim         = [-3 3];
  %cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = %[-0.25 0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  cfg.interactive = 'no';
  cfg.colorbar           = 'yes'
  cfg.title='Topo all participants lowAlpha freq';
  % ft_singleplotTFR(cfg,freq)
  %ft_multiplotTFR(cfg,freq)
  ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(ax2,flipud(brewermap(64,'RdBu')))


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('prelim5_tmap_low-Alpha_TOPO_switchvsnoswitch_-05-0s_baselined_within_selfo');%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  set(hf,'PaperpositionMode','Auto')
  saveas(hf,figurefreqname,'png')

end
