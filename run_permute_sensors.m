function output = run_permute_sensors(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Select sensors maximially activated by
  %rotation onset.
  %Created 29/11/2017.
  %Change to compare the cue-period with interest.
  %Edited 05/01/2018
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %Load all the average data, make subj into trls.


  % mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/average/';
  % cd(mainDir)
  %
  % %Store all the seperate data files
  % freq_paths = dir('*freqavgs_all_high*'); %or freqavgs_high.

  clear all
  mainDir = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/stim/');
  cd(mainDir)

  %Store all the seperate data files
  stim_paths = dir('*stim_low*'); %or freqavgs_high.
  % load(stim_paths(1).name)
  % cfg =[];
  % cfg.avgoverrpt = 'yes';
  % freq = ft_selectdata(cfg,freq);
  %
  % %Create matrix for all participants.
  % dims = size(freq.powspctrm);
  % all_stim = zeros(29,dims(1),dims(2),dims(3));

  %Load all participants
  for ifiles = 1:length(stim_paths)
    disp((stim_paths(ifiles).name))
    load(stim_paths(ifiles).name)
    cfg =[];
    cfg.avgoverrpt = 'yes';
    freq = ft_selectdata(cfg,freq);
    % all_stim(ifiles,:,:,:) = freq.powspctrm;
    allsubjStim{ifiles}=freq;
  end

  %Decide on which frequency to use:
  %Start with beta, alpha, theta, etc.
  freq_ind1=13;
  freq_ind2=33;

  % all_stim=squeeze(nanmean(all_stim(:,:,13:28,:),3));
  %Second time average
  % all_stim=squeeze(nanmean(all_stim(:,:,13:19,:),3));

  %Load the baseline freq data.
  mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/baseline/';
  cd(mainDir)

  %Store all the seperate data files
  cue_paths = dir('*baseline_low*');

  %Load all participants
  for ifiles = 1:length(stim_paths)
    disp((cue_paths(ifiles).name))
    load(cue_paths(ifiles).name)
    cfg =[];
    cfg.avgoverrpt = 'yes';
    freq = ft_selectdata(cfg,freq);
    % all_stim(ifiles,:,:,:) = freq.powspctrm;
    allsubjCue{ifiles}=freq;
  end

  %Average over freq
  % all_cue=squeeze(nanmean(all_cue(:,:,13:28,:),3));

  %Average over time
  % all_cue=squeeze(nanmean(all_cue(:,:,:),3));


  %Insert new data in freq struct.
  % freq.powspctrm=new_powspctrm;
  % freq.dimord = 'rpt_chan_freq_time';

  % Select data for time of interest.
  time0 = [allsubjStim{ifiles}.time(27) allsubjStim{ifiles}.time(33)]; %13, 19
  time1 = [allsubjCue{ifiles}.time(1) allsubjCue{ifiles}.time(end-2)];

  %Trying the orginal baseline comparison...
  % time0 = [freq.time(1) freq.time(11)];
  % time1 = [freq.time(37) freq.time(43)];

  cfg = [];
  cfg.keepindividual = 'yes';
  cfg.toilim =time0;
  dat_time0= ft_freqgrandaverage(cfg,allsubjStim{:})

  cfg = [];
  cfg.keepindividual = 'yes';
  cfg.toilim =time1;
  dat_time1= ft_freqgrandaverage(cfg,allsubjCue{:})

  % dat_time0.time = dat_time1.time;


  cfg = []
  cfg.latency = [dat_time0.time(1), dat_time0.time(end)];
  cfg.avgovertime ='yes';
  cfg.avgoverfreq ='yes';
  cfg.frequency =[15 35];
  dat_time0 = ft_selectdata(cfg,dat_time0);


  cfg = []
  cfg.latency = [dat_time1.time(1), dat_time1.time(end)];
  cfg.avgovertime ='yes';
  cfg.avgoverfreq ='yes';
  cfg.frequency =[15 35];
  cfg.latency = time1;
  dat_time1 = ft_selectdata(cfg,dat_time1);

  dat_time0.time = dat_time1.time;

  cfg = [];
  cfg.channel          = {'MEG'};
  % cfg.latency          = [0.3 0.7];
  cfg.method           = 'montecarlo';
  % cfg.frequency        = 75;
  cfg.statistic        = 'ft_statfun_depsamplesT';
  cfg.correctm         = 'cluster';
  cfg.clusteralpha     = 0.05; %Normal 0.05
  cfg.clusterstatistic = 'maxsum';
  cfg.minnbchan        = 2;
  cfg.tail             = 0;
  cfg.clustertail      = 0;
  cfg.alpha            = 0.025;
  cfg.numrandomization = 500;
  % prepare_neighbours determines what sensors may form clusters
  cfg_neighb.method    = 'distance';
  cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, freq);

  subj = 29;
  design = zeros(2,2*subj);
  for i = 1:subj
    design(1,i) = i;
  end
  for i = 1:subj
    design(1,subj+i) = i;
  end
  design(2,1:subj)        = 1;
  design(2,subj+1:2*subj) = 2;

  cfg.design   = design;
  cfg.uvar     = 1;
  cfg.ivar     = 2;
  [stat] = ft_freqstatistics(cfg, dat_time0, dat_time1);
  sum(stat.mask)




  %Plotting
  cfg =[];
  cfg.avgoverfreq = 'yes';
  freq = ft_selectdata(cfg,freq);
  cfg =[];
  cfg.avgovertime = 'yes';
  freq = ft_selectdata(cfg,freq);

  freq.powspctrm=stat.stat;

  hf=figure(1),clf
  %ax1=subplot(2,2,1)
  cfg=[];
  cfg.zlim         = [-5 5];
  %cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  % cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  cfg.title='Cluster Channels';
  %freq.powspctrm=dat_time1.powspctrm;
  % ft_singleplotTFR(cfg,freq);
  %ft_multiplotTFR(cfg,freq)
  cfg.highlight          = 'on'
  cfg.highlightchannel=freq.label(stat.mask);
  cfg.colorbar           = 'yes'
  cfg.highlightcolor =[0 0 0];
  cfg.highlightsize=12;
  ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(hf,flipud(brewermap(64,'RdBu')))


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
    todaystr = datestr(now,formatOut);
    namefigure = sprintf('prelim16_cuebaseline_permutation_stimonset_15-35Hz');%Stage of analysis, frequencies, type plot, baselinewindow

    figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
    % set(gca,'PaperpositionMode','Auto')
    saveas(gca,figurefreqname,'png')


  end
