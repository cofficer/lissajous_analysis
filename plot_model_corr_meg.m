function plot_model_corr_meg


  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Plot and show activity maximally activated by
  %computational model.
  %Created 27/09/2020.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  
  for ifiles = 1:29
      
      cd('/home/chris/Dropbox/PhD/Projects/Lissajous/analysis')
      files = dir('*muhat2*.mat')';
      
      load(files(ifiles).name)
      
      allsubjModel{ifiles}=freq_corrmap;
      
  end
  


  cfg = [];
  cfg.keepindividual = 'no';
  freqavg = ft_freqgrandaverage(cfg,allsubjModel{:});
  
  figure('Position',[10 10 1800 1200])%
  cfg = [];
  cfg.xlim = [-2.5:0.2:2.5];
  cfg.ylim         = [10 15];
  cfg.zlim = [-0.02 0.02];
  cfg.layout       = 'CTF275_helmet.lay';
  ft_topoplotTFR(cfg,freqavg)
  
  cd('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/modelcorr')
  %New naming file standard. Apply to all projects.
  namefigure = 'modeltraj_muhat2';
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  figurefreqname = sprintf('%s_freqgrandavg_%s_nobaselinetest.png',todaystr,namefigure);
  saveas(gca,figurefreqname,'png')

end