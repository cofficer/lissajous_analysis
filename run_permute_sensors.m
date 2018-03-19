function output = run_permute_sensors(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Select sensors maximially activated by
  %rotation onset.
  %Created 29/11/2017.
  %Change to compare the cue-period with interest.
  %Edited 05/01/2018
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % Load all the average data, make subj into trls.


  % mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/average/';
  % cd(mainDir)
  %
  % %Store all the seperate data files
  % freq_paths = dir('*freqavgs_all_high*'); %or freqavgs_high.

  clear all

  blocktype = 'trial';

  sw_vs_no = 1;

  topo_or_tfr = 'topo';

  freqspan = 'high';

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
  i_load = 1;
  for ifiles = 1:length(stim_paths)

    load(stim_paths(ifiles).name)

    % if strcmp(stim_paths(ifiles).name(18:19),'8.')
    disp((stim_paths(ifiles).name))
    % else
      if ~sw_vs_no
        allsubjStim{i_load}=freq;
      else
        allsubjStim{i_load}=switchTrial;
        allsubjCue{i_load}=stableTrial;
      end
      i_load=i_load+1;
    % end
    % cfg =[];
    % cfg.avgoverrpt = 'yes';
    % freq = ft_selectdata(cfg,freq);
    % all_stim(ifiles,:,:,:) = freq.powspctrm;

  end

  %The the average of switch and stable trials. No longer need to have this
  %separately. Only load switch vs no switch.
  for ifiles = 1:length(stim_paths)
    disp(ifiles)
    allsubjStim{ifiles}.powspctrm=(allsubjStim{ifiles}.powspctrm+allsubjCue{ifiles}.powspctrm)./2;

  end

  %cfg  = [];
  %freq = ft_freqgrandaverage(cfg,allsubjStim{:})

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
    mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/average/self/';
    cd(mainDir)

    %Store all the seperate data files
    cue_paths = dir(sprintf('*all_%s*',freqspan));

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
    idx_start = [8,12,18,24,30,36,42,48,54,60,68,75]; %idx_start=18
    idx_end = [12,18,24,30,36,42,48,54,60,66,74,81]; %idx_end=24
  else
    idx_start = [8,12,18,24,30,36,42,48,54]; %idx_start=18
    idx_end = [12,18,24,30,36,42,48,54,60]; %idx_end=24
  end

  for iplot = 1:length(idx_start)
    % Select data for time of interest. time1= [allsubjStim{1}.time(18) allsubjStim{1}.time(26)];
    %time1= [allsubjStim{1}.time(41) allsubjStim{1}.time(end)];
    time0 = [allsubjStim{1}.time(idx_start(iplot)) allsubjStim{1}.time(idx_end(iplot))];
    % time0 = [allsubjStim{1}.time(18) allsubjStim{1}.time(21)]; %13, 19,   41 51
    % time1 = [allsubjCue{1}.time(33) allsubjCue{1}.time(41)];
    if strcmp(topo_or_tfr,'tfr')
      if strcmp(blocktype,'trial')
        time1 = [allsubjCue{1}.time(61) allsubjCue{1}.time(end)];
        time0 = [allsubjCue{1}.time(61) allsubjCue{1}.time(end)];
      elseif strcmp(blocktype,'continuous')
        time1 = [allsubjCue{1}.time(41) allsubjCue{1}.time(61)];
        time0 = [allsubjCue{1}.time(41) allsubjCue{1}.time(61)];
      end

    elseif strcmp(topo_or_tfr,'topo')
      % time1 = [allsubjStim{1}.time(idx_start(iplot)) allsubjStim{1}.time(idx_end(iplot))];
      time1 = [allsubjStim{1}.time(21) allsubjStim{1}.time(21)];
    end

    %Trying the orginal baseline comparison...
    % time0 = [freq.time(1) freq.time(11)];
    % time1 = [freq.time(37) freq.time(43)];

    cfg = [];
    cfg.keepindividual = 'yes';
    if strcmp(topo_or_tfr,'topo')
      cfg.toilim =time0;
    else
      load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-03-14_visual_sensors_gamma.mat')
      cfg.channel=visual_sensors;
      % cfg.foilim = [36 110];
    end
    dat_time0= ft_freqgrandaverage(cfg,allsubjStim{:})

    if strcmp(topo_or_tfr,'topo')
      cfg.toilim =time1;
    else
      cfg.channel=visual_sensors;
    end
    dat_time1= ft_freqgrandaverage(cfg,allsubjStim{:})

    % dat_time0.time = dat_time1.time;


    cfg = []
    if strcmp(topo_or_tfr,'topo')
      % cfg.latency = [time1(1), time1(end)];
      cfg.avgovertime ='yes';
      cfg.avgoverfreq ='yes';
      cfg.frequency =[60 90];
    else
      cfg.avgoverchan ='yes';
      cfg.latency = [time1(1), time1(end)];
    end
    dat_time0 = ft_selectdata(cfg,dat_time0);


    cfg = []
    if strcmp(topo_or_tfr,'topo')
      % cfg.latency = [dat_time1.time(1), dat_time1.time(end)];
      cfg.avgovertime ='yes';
      cfg.avgoverfreq ='yes';
      cfg.frequency =[60 90];
    else
      cfg.latency = [time1(1), time1(end)];
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
    %save('2018-03-17_3Dstats_TRIAL_lowfreq_switchvsno.mat','stat')
    %cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/')
    %stat2=load('2018-03-15_stats_TRIAL_lowfreq_switchvsno.mat')
    % %Try doing TFR cluster stats.
    % ab=load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-01-05_visual_sensors.mat')


    %Run cluster-based permutation test
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
    sum(stat.mask(:))
    %
    % %Sum over channels
    % data_comp = stat.stat;
    % data_comp(~stat.mask)=NaN;
    % %sum over channels...
    % data_comp=nansum(data_comp(:,:,:),1);
    % % size(data_comp)
    % %realstat.mask()
    %
    % %Sum over time, and freq.
    % data_comp = stat.stat;
    % data_comp(~stat.mask)=NaN;
    % %sum over channels...
    % %time
    % data_comp=nansum(data_comp(:,:,1:7),3);
    % %freq
    % data_comp=nansum(data_comp(:,4:8,:),2);
    %min(data_comp(:))
    %max(dat_time0.powspctrm(:))

    % %Plotting
    % cfg =[];
    % cfg.avgoverfreq = 'yes';
    % freq = ft_selectdata(cfg,freq);
    % cfg =[];
    % cfg.avgovertime = 'yes';
    % cfg.latency = [time1(1), time1(end)];
    % freq = ft_selectdata(cfg,freq);
    %
    % if ~strcmp(topo_or_tfr,'topo')
    %   cfg =[];
    %   cfg.avgoverchan = 'yes';
    %   freq = ft_selectdata(cfg,freq);
    % end
    % % freq.powspctrm=data_comp;
    % freq.powspctrm=dat_time0.powspctrm;


    hf=figure(1),clf
    %ax1=subplot(2,2,1)
    cfg=[];
    cfg.zlim         = [-4 4];
    %cfg.ylim         = [3 35];
    cfg.layout       = 'CTF275_helmet.lay';
    %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
    % cfg.channel      = freq.label(idx_occ);
    cfg.interactive = 'no';
    cfg.title='Cluster Channels';
    %freq.powspctrm=dat_time1.powspctrm;
    %high22=ones(1,33,21);
    %high2=high22;
    %freq.high22=high22;
    % cfg.maskstyle     = 'saturation';
    % cfg.maskparameter = 'mask'
    % cfg.maskalpha     = 0.5
    % cfg.colorbar           = 'yes'
    cfg.parameter     = 'stat';
    % ft_singleplotTFR(cfg,freq);
    %ft_multiplotTFR(cfg,freq)

    cfg.highlightchannel=freq.label(stat.mask);
    % cfg.highlightchannel=high22;
    cfg.highlight='on';
    cfg.highlightcolor =[0 0 0];
    cfg.highlightsize=12;
    ft_topoplotTFR(cfg,stat)
    %ft_hastoolbox('brewermap', 1);
    colormap(hf,flipud(brewermap(64,'RdBu')))


    cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',blocktype))
    %New naming file standard. Apply to all projects.
    formatOut = 'yyyy-mm-dd';
    todaystr = datestr(now,formatOut);
    namefigure='prelim19_TOPO_TRIAL_12Hz_self-locked_-15-05s'
    namefigure = sprintf('prelim20_60-90Hz_%s_preOnsetbaseline_self-locked%s-%ss',blocktype(1:4),num2str(time0(1)),num2str(time0(2)));%Stage of analysis, frequencies, type plot, baselinewindow

    figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
    % set(gca,'PaperpositionMode','Auto')
    saveas(gca,figurefreqname,'png')

  end



  hf=figure(1),clf
  set(hf, 'Position', [0 0 800 800])

  ax1=subplot(1,1,1)
  cfg=[];
  cfg.zlim         = [-4 4];
  %cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  % cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  cfg.title='Cluster Channels';
  %freq.powspctrm=dat_time1.powspctrm;
  cfg.maskstyle     = 'outline';
  cfg.maskparameter = 'mask'
  cfg.maskalpha     = 0.5
  %ft_multiplotTFR(cfg,freq)
  cfg.highlight          = 'on'
  % high2 = squeeze(mean(stat2.stat.mask(idx_sens,:,:),1));
  % high2=high2>0.3; stat.mask=logical(stat.mask);
  % cfg.highlightchannel=high2;
  cfg.colorbar           = 'yes'
  cfg.highlightcolor =[0 0 0];
  cfg.highlightsize=12;
  cfg.parameter     = 'stat';
  % ft_topoplotTFR(cfg,freq)
  % stat2=squeeze(mean(stat.stat(idx_sens,:,:),1));
  % stat.stat=stat2;

  ft_singleplotTFR(cfg,stat);
  %ft_hastoolbox('brewermap', 1);
  colormap(hf,flipud(brewermap(64,'RdBu')))


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/figures'))
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('prelim15_tmap_lowfreq_TFR_switchvsno_TRIAL_allGammaVisual_-0505s');%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  % set(gca,'PaperpositionMode','Auto')
  saveas(gca,figurefreqname,'png')




  %%
  %Following fieldtrip plotting permutation test:

  neg = stat.negclusterslabelmat == 1;

  timestep = 0.05;		% timestep between time windows for each subplot (in seconds)
  sampling_rate = dataFC_LP.fsample;	% Data has a temporal resolution of 300 Hz
  sample_count = length(stat.time);
  % number of temporal samples in the statistics object
  j = [0:timestep:1];   % Temporal endpoints (in seconds) of the ERP average computed in each subplot
  m = [1:timestep*sampling_rate:sample_count];  % temporal endpoints in MEEG samples


  % First ensure the channels to have the same order in the average and in the statistical output.
% This might not be the case, because ft_math might shuffle the order
  [i1,i2] = match_str(raweffectFICvsFC.label, stat.label);

  for k = 1:20;
       subplot(4,5,k);
       cfg = [];
       cfg.xlim=[j(k) j(k+1)];   % time interval of the subplot
       cfg.zlim = [-2.5e-13 2.5e-13];
     % If a channel reaches this significance, then
     % the element of pos_int with an index equal to that channel
     % number will be set to 1 (otherwise 0).

     % Next, check which channels are significant over the
     % entire time interval of interest.
       pos_int = zeros(numel(raweffectFICvsFC.label),1);
       neg_int = zeros(numel(raweffectFICvsFC.label),1);
       pos_int(i1) = all(pos(i2, m(k):m(k+1)), 2);
       neg_int(i1) = all(neg(i2, m(k):m(k+1)), 2);

       cfg.highlight = 'on';
     % Get the index of each significant channel
       cfg.highlightchannel = find(pos_int | neg_int);
       cfg.comment = 'xlim';
       cfg.commentpos = 'title';
       cfg.layout = 'CTF151.lay';
       cfg.interactive = 'no';
       ft_topoplotER(cfg, raweffectFICvsFC);
  end


  end
