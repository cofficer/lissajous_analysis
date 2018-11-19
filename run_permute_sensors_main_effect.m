function output = run_permute_sensors_main_effect(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Select sensors maximially activated by
  %rotation onset.
  %Created 17/01/2018.
  %Change to compare the cue-period with interest.
  %Edited 17/11/2018
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % Load all the average data, make subj into trls.


  % mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/average/';
  % cd(mainDir)
  %
  % %Store all the seperate data files
  % freq_paths = dir('*freqavgs_all_high*'); %or freqavgs_high.

  clear all

  %The next step... is it possible to combine the trial and the continuous...
  blocktype = 'both';

  sw_vs_no = 1;

  topo_or_tfr = 'topo';

  freqspan = 'low';

  stim_self='self'

  mainDir = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/%s/',blocktype,stim_self);
  mainDir = sprintf('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/%s_self_freqavg/',blocktype);

  cd(mainDir)

  if strcmp(blocktype,'both')
    stim_paths = dir(sprintf('*switch_*'));
  else
    if sw_vs_no
      %Store all the seperate data files
      stim_paths = dir(sprintf('*switch_%s*',freqspan)); %or freqavgs_high.
    else
      stim_paths = dir(sprintf('*all_%s*',freqspan));
    end
  end

  % Define the ID's.
  % Not sure exactly how to.
  namecell = {stim_paths.name};
  partnum = cellfun(@(x) x(end-5:end-4),namecell,'UniformOutput',false);
  if strcmp(blocktype,'both')
    partnum = cellfun(@strtok, partnum,repmat({'_'},1,58),'UniformOutput',false);
  else
    partnum = cellfun(@strtok, partnum,repmat({'_'},1,29),'UniformOutput',false);
  end

  %Find the number of self-occlusions for the trial vs. continuous blocks per
  %participant
  %For this to be done properly I need to probably look into the code that makes
  %the average plots... Maybe even run on cluster and save only that info...
  % cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  cd('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/behaviour')
  nr_cont=load('trialNrCont_StableSwitch.mat');
  nr_trial=load('trialNrTrial_StableSwitch.mat');
  cd(mainDir)
  %consider excluding participant 5 due to only having 7 stable trial trials.
  %really think this must be a trigger issue...
  % load('Table_continfo.mat') %seems good. Which folder??
  % load('all_trialinfo.mat') %also usable. Very different though.

  %Load all participants
  i_load = 1;
  for ifiles = 1:29%length(stim_paths)


    blocks_ID = find(ismember([partnum],{num2str(ifiles)}));

    %First try to average trial and continuous together
    for iblock_ID =  1:length(blocks_ID)

      %What about the NaNs in the trial blocks.. I will need to shorten that
      %here by extracting the time-points of interest.
      %Otherwise averaging is not possible.
      %ac = load(stim_paths(blocks_ID(2)).name)
      disp(stim_paths(blocks_ID(iblock_ID)).name)
      load(stim_paths(blocks_ID(iblock_ID)).name);

      if strcmp(stim_paths(blocks_ID(iblock_ID)).name(17:21),'trial')
        time1 = [switchTrial.time(61) switchTrial.time(end)];
        time0 = [switchTrial.time(61) switchTrial.time(end)];
      else
        time1 = [switchTrial.time(41) switchTrial.time(61)];
        time0 = [switchTrial.time(41) switchTrial.time(61)];
      end

      cfg = []
      cfg.latency = time1;
      cfg.spmversion = 'spm12';

      %
      if iblock_ID==1
        %_1 is the continuous blocks and _2 is the trial blocks.
        switchTrial_1=ft_selectdata(cfg,switchTrial);
        stableTrial_1=ft_selectdata(cfg,stableTrial);
      else
        switchTrial_2=ft_selectdata(cfg,switchTrial);
        stableTrial_2=ft_selectdata(cfg,stableTrial);

        %Calculate the amount of trials
        %Average together the switchTrial & the stableTrial 816, 240
        nr_cont_stable_ratio=nr_cont.stable_nr(ifiles)/(nr_cont.stable_nr(ifiles)+nr_trial.stable_nr(ifiles));
        nr_cont_switch_ratio=nr_cont.switch_nr(ifiles)/(nr_cont.switch_nr(ifiles)+nr_trial.switch_nr(ifiles));
        nr_trial_stable_ratio=nr_trial.stable_nr(ifiles)/(nr_trial.stable_nr(ifiles)+nr_cont.stable_nr(ifiles));
        nr_trial_switch_ratio=nr_trial.switch_nr(ifiles)/(nr_cont.switch_nr(ifiles)+nr_trial.switch_nr(ifiles));

        switchTrial_2.powspctrm = (switchTrial_1.powspctrm.*nr_cont_switch_ratio+switchTrial_2.powspctrm.*nr_trial_switch_ratio);
        stableTrial_2.powspctrm = (stableTrial_1.powspctrm.*nr_cont_stable_ratio+stableTrial_2.powspctrm.*nr_trial_stable_ratio);
        switchTrial=switchTrial_2;
        stableTrial=stableTrial_2;
      end


    end
    %sum(isnan(ab.powspctrm(:))) ab.powspctrm(1,5,:)

    % sum(isnan(freq.powspctrm(:)))>1

    % if strcmp(stim_paths(ifiles).name(18:19),'8.')
    % disp((stim_paths(blocks_ID(iblock_ID)).name))
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

  %%
  %Combine the data from all participants from cell to data matrix.
  cfg = [];
  cfg.keepindividual = 'yes';
  dat_time0= ft_freqgrandaverage(cfg,allsubjStim{:})
  dat_time1= ft_freqgrandaverage(cfg,allsubjCue{:})

  %Run cluster-based permutation test
  cfg = [];
  cfg.latency          = 'all';%[0.3 0.7];
  cfg.method           = 'montecarlo';
  % cfg.frequency        = 75;
  cfg.statistic        = 'ft_statfun_depsamplesT';
  cfg.correctm         = 'cluster';
  cfg.clusteralpha     = 0.025; %Normal 0.05 0.02 for 1 cluster
  cfg.clusterstatistic = 'maxsum';
  cfg.minnbchan        = 2;  %orig 2, 5 for one cluster
  cfg.tail             = 0;
  cfg.clustertail      = 0;
  cfg.alpha            = 0.025;
  cfg.numrandomization = 1000;
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
  cfg.spmversion = 'spm12'
  statout = ft_freqstatistics(cfg, dat_time0, dat_time1);
  sum(statout.mask(:))


  % %Sum over time, and freq.
  data_comp = statout.stat;
  data_comp(~statout.mask)=NaN;
  %sum over channels...
  %time
  data_comp=nansum(data_comp(:,:,:),3);
  %freq
  data_comp=nansum(data_comp(:,:,:),2);
  min(data_comp(:))
  max(data_comp(:))

  %Plotting
  freq2=freq;
  cfg =[];
  cfg.avgoverfreq = 'yes';
  freq2 = ft_selectdata(cfg,freq2);
  cfg =[];
  cfg.avgovertime = 'yes';
  cfg.latency = [time1(1), time1(end)];
  freq2 = ft_selectdata(cfg,freq2);
  freq2.powspctrm=data_comp;



  hf=figure(1),clf
  %ax1=subplot(2,2,1)
  cfg=[];
  cfg.zlim         = [min(data_comp(:))+40 -min(data_comp(:))-40];
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
  cfg.colorbar           = 'yes'
  % cfg.parameter     = 'stat';
  % ft_singleplotTFR(cfg,freq);
  %ft_multiplotTFR(cfg,freq)

  % cfg.highlightchannel=freq2.label(statout.mask);
  % cfg.highlightchannel=high22;
  cfg.highlight='off';
  cfg.highlightcolor =[0 0 0];
  cfg.highlightsize=12;
  ft_topoplotTFR(cfg,freq2)
  %ft_hastoolbox('brewermap', 1);
  colormap(hf,flipud(brewermap(64,'RdBu')))


  % cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',blocktype))

  cd('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/results_plots')
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure='TOPO_cont-trl-comb_switch-activity_025clus_1000perm'
  % namefigure = sprintf('prelim22_12-30Hz_%s_stimoff_preOnsetbaseline_self-locked%s-%ss',blocktype(1:4),num2str(time0(1)),num2str(time0(2)));%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  % set(gca,'PaperpositionMode','Auto')
  saveas(gca,figurefreqname,'png')


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % Compute the TFR for the significant cluster.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  freq2=freq;
  cfg =[];
  cfg.latency = [time1(1), time1(end)];
  cfg.avgoverchan = 'yes';
  freq2 = ft_selectdata(cfg,freq2);

  data_comp = statout.stat;
  data_comp(~statout.mask)=NaN;
  %sum over channels...
  %channels
  data_comp=nansum(data_comp(:,:,:),1);
  freq2.powspctrm=data_comp;
  %freq

  hf=figure(1),clf
  %ax1=subplot(2,2,1)
  cfg=[];
  cfg.zlim         = [-140 140];
  %cfg.ylim         = [3 35];
  % cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  % cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  cfg.title='Cluster Channels';
  freq.dimord='freq_time';
  ft_singleplotTFR(cfg,freq2)
  %ft_hastoolbox('brewermap', 1);
  colormap(hf,flipud(brewermap(64,'RdBu')))

  namefigure='TFR_CONT-TRL_lowghz_self-locked_nobaseline'

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  % set(gca,'PaperpositionMode','Auto')
  % cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',blocktype))
  saveas(hf,figurefreqname,'png')

  %also save the statout which contains the statistical mask.
  statoutname=sprintf('%s_statistics_switchvsnoswitch.mat',todaystr)
  save(statoutname,'statout')

end
