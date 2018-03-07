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
  %plot the TFR
  %idx_occ = tavalue<-2; idx_lissajous=freq.label(idx_occ);
  %TODO: find the IDX of all motor sensors, and use those to plot TFR.
  idx_occ=strfind(freq.label,'O');
  idx_occ=find(~cellfun(@isempty,idx_occ));
  idx_lissajous = visual_sensors;
  idx_motor = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
              'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
              'MRF54','MRF55','MRF56','MRF66','MRF46'...
              'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
              'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
              'MLF54','MLF55','MLF56','MLF66','MLF46'};

  idx_trialsens = ismember(freq.label,visual_sensors);

  %Average data to make a TFR plot.
  %Average over the sensors.
  %Average over time period and over frequency. Does it matter which order?
  %First freq average all_stimA= all_stim; all_baseA=all_base;
  %all_stim=all_stimA; all_base=all_baseA; idx_lissajous=freq.label(stat.mask)
  % all_stim=squeeze(nanmean(all_stim(:,idx_trialsens,:,:),2));
  all_stim=squeeze(nanmean(all_stim(:,:,13:28,:),3));
  all_stim=squeeze(nanmean(all_stim(:,:,41:51),3));
  %Second time average
  % all_base=squeeze(nanmean(all_base(:,idx_trialsens,:,:),2));
  all_base=squeeze(nanmean(all_base(:,:,13:28,:),3));
  all_base=squeeze(nanmean(all_base(:,:,41:51),3));
  all_freq = squeeze(nanmean(all_stim,1))-squeeze(nanmean(all_base,1));

  %Find the timepoints of stim_freq of interest
  %Also define the freq of interest, and average over both?

  % stim_time = [stim_freq.time(13),stim_freq.time(19)];

  [H,P,CI,STATS]=ttest(all_stim,all_base,'dim',1);

  STATS.tstat;


  tavalue = squeeze(STATS.tstat); %tavalue(1,:,:)=all_freq; %tavalue(1,:,:)=nanmean(all_stim,1);
  %tavalue = squeeze(STATS.tstat);
  %Plot the topo.
  %Make freq a vector
  cfg =[];
  cfg.avgoverfreq = 'yes';
  freq = ft_selectdata(cfg,freq);

  cfg =[];
  cfg.avgovertime = 'yes';
  freq = ft_selectdata(cfg,freq);

  freq.powspctrm = squeeze(tavalue);


  hf=figure(1),clf
  ax2=subplot(1,1,1)
  % freq.powspctrm = switchTrial;
  cfg=[];
  cfg.zlim         = [-3 3];
  %cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.mat';
  %cfg.xlim         = %[-0.25 0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  cfg.interactive = 'no';
  cfg.colorbar           = 'yes'
  cfg.title='Topo all participants high freq';
  % ft_singleplotTFR(cfg,freq)
  %ft_multiplotTFR(cfg,freq)
  ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(ax2,flipud(brewermap(64,'RdBu')))


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('prelim10_tmap_60-90Hz_TOPO_switchvsnoswitch_-05-0s_nobaseline');%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  set(hf,'PaperpositionMode','Auto')
  saveas(hf,figurefreqname,'png')


  hf=figure(1),clf
  set(hf, 'Position', [0 0 800 800])

  ax2=subplot(2,1,2)
  % freq.powspctrm = switchTrial;
  cfg=[];
  cfg.zlim         = [-10 10];
  %cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = %[-0.25 0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  cfg.interactive = 'no';
  cfg.channel      = idx_lissajous;%freq.label(idx_occ);%idx_motor';%
  cfg.colorbar           = 'yes'
  cfg.title='Topo all participants low freq';
  ft_singleplotTFR(cfg,freq)
  %ft_multiplotTFR(cfg,freq)
  % ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(ax2,flipud(brewermap(64,'RdBu')))


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('prelim15_freqmap_lowandhighfreq_TFR_avg_CONT_allVisual');%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  set(hf,'PaperpositionMode','Auto')
  saveas(hf,figurefreqname,'png')


  hf = figure(1),clf;
  %set(hf,'DefaultFigureColormap',cbrewer('qual', 'YlOrBr', 400))
  colormap(cbrewer('seq', 'YlOrBr', 200))
  set(hf, 'Position', [0 0 500 500])
  imagesc(squeeze(tavalue))
  %change the x values displayed
  xticklabels = freq.time(1:10:end);
  xticks = linspace(1, numel(freq.time),numel(xticklabels));
  set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
  set(gca,'YDir','normal')
  % caxis([0 0.005])
  colorbar
  title('P values for ttest2')
  ylabel('Frequencies')
  xlabel('time (s)')

  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures'))
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = 'low_freqTmap_TFR_switchvsnoswitch';
  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure);
  saveas(gca,figurefreqname,'png')

end
