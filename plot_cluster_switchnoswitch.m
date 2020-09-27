function output = plot_cluster_switchnoswitch(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Correlate switch-related activity with
  %upcoming perceptual duration.
  %Created 17/11/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
  %Get the stat.mask
  % load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/2018-06-04_statistics_switchvsnoswitch.mat')
  %Get the most recent stat.mask and plot it to check....
%   load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
  load('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')

  % %Sum over time, and freq.
  data_comp = statout.stat;
  data_comp(~statout.mask)=NaN
  %sum over channels...
  %time
  data_comp=nansum(data_comp(:,:,:),3);
  %freq
  data_comp=nansum(data_comp(:,:,:),2);
  
  for in = 10:29
      load(sprintf('/home/chris/Documents/lissajous/data/continous_self_freq/%dfreq_low_selfocclBlock4.mat',in))
      
      figure(in-9),clf
      freq2=freq;
      cfg = [];
      cfg.trials=logical(zeros(1,size(freq.powspctrm,1)));
      indexsameresp = freq.trialinfo(:,5)==225; %225 232
      cfg.trials(indexsameresp)=1;
      cfg.avgoverrpt  = 'yes'
      freq2 = ft_selectdata(cfg,freq);
      
      cfg=[];
      cfg.ylim         = [15 30];
      cfg.xlim = [-0.4:0.4:2.5];
      cfg.baseline = [-1 -0.5];
      cfg.layout       = 'CTF275_helmet.lay';
      %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
      % cfg.channel      = freq.label(idx_occ);
      cfg.interactive = 'no';
      %   cfg.highlightchannel=freq2.label(data_comp<-80);
      %   cfg.highlight='on';
      cfg.highlightcolor =[0.5 0.5 0.5];
      cfg.highlightsize=22;
      %   freq2.powspctrm=zeros(size(freq2.powspctrm));
      ft_topoplotTFR(cfg,freq2)
      
      
  end

  cd('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/results_plots')
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure='TOPO_cluster_selected_behaviour'
  % namefigure = sprintf('prelim22_12-30Hz_%s_stimoff_preOnsetbaseline_self-locked%s-%ss',blocktype(1:4),num2str(time0(1)),num2str(time0(2)));%Stage of analysis, frequencies, type plot, baselinewindow

  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  % set(gca,'PaperpositionMode','Auto')
  saveas(gca,figurefreqname,'png')
  %Use the mask to extract the cluster on each trial. The cluster should be
  %the signal change in power, or simply the power...
  %%Potential difficuly is definately the absence of baseline.
  %%I would think the effect is still there even if we baseline, it should not
  %%really matter.
  %%Use the baseline to see if the effect is still there.

  %Correlate with the average




end
