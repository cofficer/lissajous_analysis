function plot_average_all(runplot,freq,avg_freq_stable,avg_freq_switch)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Main script for handling creation of individual plots per participant
  %Taken from, main_individual_freq
  %Standalone script to produce average plots TFRs and TOPOs
  %Need to be easy to create all relevant plots:
  %Across defined frequencies, types, sensors, timewindow
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %Insert the freq data averaged over participants.
  switch runplot.data
  case 'stable'
    freq.powspctrm=avg_freq_stable;
  case 'switch'
    freq.powspctrm=avg_freq_switch;
  case 'SvsN'
    freq.powspctrm=avg_freq_switch-avg_freq_stable;
  end

  %define frequency ranges
  switch runplot.freqrange
  case 'theta'
    freqrange = [4 7];
  case 'alpha'
    freqrange = [7 13];
  case 'beta'
    freqrange = [12 35];
  end

  %timewindow as str
  timewindow=num2str(runplot.timewindow);
  expression = '[\-\d]';
  idx_timewindow = regexp(timewindow,expression);
  timewindow = timewindow(idx_timewindow);


  switch runplot.type
  case 'topo'

    if runplot.multi
      %plot the topoplot
      figure(1),clf
      cfg=[];
      cfg.zlim         = runplot.zlim ;
      cfg.ylim         = freqrange;
      cfg.layout       = 'CTF275_helmet.lay';
      cfg.xlim         = runplot.timewindow;%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
      %cfg.channel      = freq.label(idx_occ);
      cfg.interactive = 'no';
      cfg.title='Stable';
      %cfg.marker = 'labels';
      %ft_singleplotTFR(cfg,freq);
      %ft_multiplotTFR(cfg,freq)
      ft_topoplotTFR(cfg,freq)
      %ft_hastoolbox('brewermap', 1);
      colormap(flipud(brewermap(64,'RdBu')))
      namefigure = sprintf('prelim3_%s_%s_%s_multiTOPO',runplot.data,runplot.freqrange,timewindow);
    else
      figure(1),clf
      cfg=[];
      cfg.zlim         = runplot.zlim ;
      cfg.ylim         = freqrange;
      cfg.layout       = 'CTF275_helmet.lay';
      cfg.xlim         = runplot.timewindow;%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
      %cfg.channel      = freq.label(idx_occ);
      cfg.interactive = 'no';
      cfg.title='Stable';
      %cfg.marker = 'labels';
      %ft_singleplotTFR(cfg,freq);
      %ft_multiplotTFR(cfg,freq)
      ft_topoplotTFR(cfg,freq)
      %ft_hastoolbox('brewermap', 1);
      colormap(flipud(brewermap(64,'RdBu')))
      namefigure = sprintf('prelim3_%s_%s_%s_TOPO',runplot.data,runplot.freqrange,timewindow);
    end

  case 'tfr'
  case 'tmap'
  end

  %save figure
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
  %New naming file standard. Apply to all projects.
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%
  saveas(gca,figurefreqname,'png')



  %
  %
  % plot_mean = 0;
  % if plot_mean
  %
  %
  %   %plot the topoplot
  %   figure(2),clf
  %   cfg=[];
  %   cfg.zlim         = [-4 4];
  %   cfg.ylim         = [7 13];
  %   cfg.layout       = 'CTF275_helmet.lay';
  %   cfg.xlim         = [1.3:0.2:2.3];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  %   %cfg.channel      = freq.label(idx_occ);
  %   cfg.interactive = 'no';
  %   cfg.title='Stable';
  %   %cfg.marker = 'labels';
  %   %ft_singleplotTFR(cfg,freq);
  %   %ft_multiplotTFR(cfg,freq)
  %   ft_topoplotTFR(cfg,freq)
  %   %ft_hastoolbox('brewermap', 1);
  %   colormap(flipud(brewermap(64,'RdBu')))
  %
  %
  %   cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
  %   %New naming file standard. Apply to all projects.
  %   formatOut = 'yyyy-mm-dd';
  %   todaystr = datestr(now,formatOut);
  %   namefigure = sprintf('prelim2_Stable_realalphaAverage_1323_multiTOPO');%Stage of analysis, frequencies, type plot, baselinewindow
  %
  %   figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  %
  %   saveas(gca,figurefreqname,'png')
  %
  %
  %
  %   idx_occ=strfind(freq.label,'O');
  %   idx_occ=find(~cellfun(@isempty,idx_occ));
  %   figure(1),clf
  %   cfg=[];
  %   cfg.zlim         = [-4 4];
  %   %cfg.ylim         = [3 35];
  %   cfg.layout       = 'CTF275_helmet.lay';
  %   %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  %   %    cfg.channel      = freq.label(idx_occ);
  %   cfg.interactive = 'no';
  %   cfg.title='Switch vs Stable';
  %   ft_singleplotTFR(cfg,freq);
  %   %ft_multiplotTFR(cfg,freq)
  %   %ft_topoplotTFR(cfg,freq)
  %   %ft_hastoolbox('brewermap', 1);
  %   colormap(flipud(brewermap(64,'RdBu')))
  %
  %
  %   %Save figure active.
  %   cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
  %   %New naming file standard. Apply to all projects.
  %   formatOut = 'yyyy-mm-dd';
  %   todaystr = datestr(now,formatOut);
  %   namefigure = sprintf('prelim2_Stable_LowAverage_10zlim_TFR');%Stage of analysis, frequencies, type plot, baselinewindow
  %
  %   figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  %
  %   saveas(gca,figurefreqname,'png')
  %
  %
  %   %create a tmap...
  %
  %   %Create tmaps. If across dim 1, testing sig across channels
  %   %between switch and no switch averages.
  %   [h,p]=ttest2(avg_freq_switch(idx_occ,:,9:93),...
  %   avg_freq_stable(idx_occ,:,9:93),'Dim',1);
  %   hf=figure(1),clf
  %   colormap(cbrewer('seq', 'YlOrBr', 200))
  %   set(hf, 'Position', [0 0 500 500])
  %   imagesc(squeeze(p))
  %   %change the x values displayed
  %   xticklabels = freq.time(9:21:93);
  %   xticks = linspace(1, find(freq.time==xticklabels(end)),numel(xticklabels));
  %   set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
  %   %change the y values displayed
  %   yticklabels = freq.freq(3:10:end);
  %   yticks = linspace(3,find(freq.freq==yticklabels(end)),numel(freq.freq(3:10:end)));
  %   set(gca, 'YTick', yticks, 'YTickLabel', yticklabels)
  %   set(gca,'YDir','normal')
  %   caxis([0 0.1])
  %   colorbar
  %   title('P values for ttest2')
  %
  %
  %   %Save figure active.
  %   cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
  %   %New naming file standard. Apply to all projects.
  %   formatOut = 'yyyy-mm-dd';
  %   todaystr = datestr(now,formatOut);
  %   namefigure = sprintf('prelim2_SwitchvsNoSwitch_lowfreq_TMAP2');%Stage of analysis, frequencies, type plot, baselinewindow
  %
  %   figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
  %
  %   saveas(gca,figurefreqname,'png')
  % end
end
