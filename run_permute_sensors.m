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

  blocktype = 'continuous';

  sw_vs_no = 1;

  topo_or_tfr = 'topo';

  freqspan = 'low';

  mainDir = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/self/',blocktype);
  cd(mainDir)

  if sw_vs_no
    %Store all the seperate data files
    stim_paths = dir(sprintf('*switch_%s*',freqspan)); %or freqavgs_high.
  else
    stim_paths = dir(sprintf('*all_%s*',freqspan));
  end
  % load(stim_paths(1).name)
  % cfg =[];
  % cfg.avgoverrpt = 'yes';
  % freq = ft_selectdata(cfg,freq);
  %
  % %Create matrix for all participants.
  % dims = size(freq.powspctrm);
  % all_stim = zeros(29,dims(1),dims(2),dims(3));

  %exclude 8 and 19.
  % stim_paths(28)=[];
  % stim_paths(11)=[];

  %Load all participants
  for ifiles = 1:length(stim_paths)
    disp((stim_paths(ifiles).name))
    load(stim_paths(ifiles).name)
    % cfg =[];
    % cfg.avgoverrpt = 'yes';
    % freq = ft_selectdata(cfg,freq);
    % all_stim(ifiles,:,:,:) = freq.powspctrm;
    if ~sw_vs_no
      allsubjStim{ifiles}=freq;
    else
      allsubjStim{ifiles}=switchTrial;
      allsubjCue{ifiles}=stableTrial;
    end
  end

  %load instead the completed combined_low_freq_self_stim.mat
  % load('combined_low_freq_self_stim.mat')

  %Decide on which frequency to use:
  %Start with beta, alpha, theta, etc.
  % freq_ind1=13;
  % freq_ind2=33;

  % all_stim=squeeze(nanmean(all_stim(:,:,13:18,:),3));
  %Second time average
  % all_stim=squeeze(nanmean(all_stim(:,:,13:19),3));

  if ~sw_vs_no
    %Load the baseline freq data.
    mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/average/stimoff/';
    cd(mainDir)

    %Store all the seperate data files
    cue_paths = dir('*all_high*');

    %Load all participants
    for ifiles = 1:length(stim_paths)
      disp((cue_paths(ifiles).name))
      load(cue_paths(ifiles).name)
      % cfg =[];
      % cfg.avgoverrpt = 'yes';
      % freq = ft_selectdata(cfg,freq);
      % all_stim(ifiles,:,:,:) = freq.powspctrm;
      allsubjCue{ifiles}=freq;
    end
  end

  %load instead the completed combined_low_freq_stimoff_cue.mat
  % load('combined_low_freq_stimoff_cue.mat')

  %Average over freq
  % all_cue=squeeze(nanmean(all_cue(:,:,13:18,:),3));

  %Average over time
  % all_cue=squeeze(nanmean(all_cue(:,:,15:23),3));


  %Insert new data in freq struct.
  % freq.powspctrm=new_powspctrm;
  % freq.dimord = 'rpt_chan_freq_time';

  if strcmp(blocktype,'trial')
    idx_start = [8,12,18,24,30,36,42,48,54]; %idx_start=18
    idx_end = [12,18,24,30,36,42,48,54,60]; %idx_end=24
  else
    idx_start = [8,12,18,24,30,36,42,48,54]; %idx_start=18
    idx_end = [12,18,24,30,36,42,48,54,60]; %idx_end=24
  end

  for iplot = 1:length(idx_start)
    % Select data for time of interest.
    time0 = [allsubjStim{1}.time(idx_start(iplot)) allsubjStim{1}.time(idx_end(iplot))]; %13, 19,   41 51

    if strcmp(topo_or_tfr,'tfr')
      time1 = [allsubjCue{1}.time(33) allsubjCue{1}.time(41)];
    elseif strcmp(topo_or_tfr,'topo')
      time1 = [allsubjStim{1}.time(idx_start(iplot)) allsubjStim{1}.time(idx_end(iplot))];
    end

    %Trying the orginal baseline comparison...
    % time0 = [freq.time(1) freq.time(11)];
    % time1 = [freq.time(37) freq.time(43)];

    cfg = [];
    cfg.keepindividual = 'yes';
    if strcmp(topo_or_tfr,'topo')
      cfg.toilim =time0;
    else
      load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-03-04_visual_sensors_alpha.mat')
      cfg.channel=visual_sensors;
    end
    dat_time0= ft_freqgrandaverage(cfg,allsubjStim{:})

    if strcmp(topo_or_tfr,'topo')
      cfg.toilim =time1;
    else
      cfg.channel=visual_sensors;
    end
    dat_time1= ft_freqgrandaverage(cfg,allsubjCue{:})

    % dat_time0.time = dat_time1.time;


    cfg = []
    if strcmp(topo_or_tfr,'topo')
      cfg.latency = [dat_time0.time(1), dat_time0.time(end)];
      cfg.avgovertime ='yes';
      cfg.avgoverfreq ='yes';
      cfg.frequency =[15 30];
    else
      cfg.avgoverchan ='yes';
    end
    dat_time0 = ft_selectdata(cfg,dat_time0);


    cfg = []
    if strcmp(topo_or_tfr,'topo')
      cfg.latency = [dat_time1.time(1), dat_time1.time(end)];
      cfg.avgovertime ='yes';
      cfg.avgoverfreq ='yes';
      cfg.frequency =[15 30];
    else
      cfg.avgoverchan ='yes';
    end
    dat_time1 = ft_selectdata(cfg,dat_time1);

    dat_time0.time = dat_time1.time;

    % dat_time1.powspctrm = squeeze(dat_time1.powspctrm);
    % dat_time0.powspctrm = squeeze(dat_time0.powspctrm);
    % dat_time1.dimord = 'subj_freq_time';
    % dat_time0.dimord = 'subj_freq_time';
    % %% visual_sensors = freq.label(stat.mask)
    % %% ab=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-03-04_visual_sensors_alpha.mat')
    % %Try doing TFR cluster stats.
    % ab=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-01-05_visual_sensors.mat')


    cfg = [];
    if strcmp(topo_or_tfr,'topo')
      cfg.latency          = 'all';%[0.3 0.7];
    else
      cfg.channel          =  {'MEG'}; % visual_sensors; %
    end

    cfg.method           = 'montecarlo';
    % cfg.frequency        = 75;
    cfg.statistic        = 'ft_statfun_depsamplesT';
    cfg.correctm         = 'cluster';
    cfg.clusteralpha     = 0.05; %Normal 0.05
    cfg.clusterstatistic = 'maxsum';
    cfg.minnbchan        = 2;
    cfg.tail             = 0;
    cfg.clustertail      = 0;
    cfg.alpha            = 0.05;
    cfg.numrandomization = 500;
    % prepare_neighbours determines what sensors may form clusters
    cfg_neighb.method    = 'distance';
    cfg.neighbours       = ft_prepare_neighbours(cfg_neighb, freq);
    cfg.channel           = dat_time0.label;

    subj = size(dat_time0.powspctrm,1);
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


    cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',blocktype))
    %New naming file standard. Apply to all projects.
    formatOut = 'yyyy-mm-dd';
    todaystr = datestr(now,formatOut);
    namefigure = sprintf('prelim13_15-30Hz_switchvsno_%s_wholwbaseline_self-locked%s-%ss',blocktype(1:4),num2str(time0(1)),num2str(time0(2)));%Stage of analysis, frequencies, type plot, baselinewindow

    figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
    % set(gca,'PaperpositionMode','Auto')
    saveas(gca,figurefreqname,'png')

  end



  hf=figure(1),clf
  %ax1=subplot(2,2,1)
  cfg=[];
  cfg.zlim         = [-3 3];
  %cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  % cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  cfg.title='Cluster Channels';
  %freq.powspctrm=dat_time1.powspctrm;

  %ft_multiplotTFR(cfg,freq)
  cfg.highlight          = 'on'
  cfg.highlightchannel=freq.label(stat.mask);
  cfg.colorbar           = 'yes'
  cfg.highlightcolor =[0 0 0];
  cfg.highlightsize=12;
  cfg.parameter     = 'stat';
  % ft_topoplotTFR(cfg,freq)
  ft_singleplotTFR(cfg,stat);
  %ft_hastoolbox('brewermap', 1);
  colormap(hf,flipud(brewermap(64,'RdBu')))


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('prelim11_TFR_highFreq_clusterstatistics_switchvsnoswitch_wholetrialbaseline_sensorsAlphatrl');%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  % set(gca,'PaperpositionMode','Auto')
  saveas(gca,figurefreqname,'png')


  end
