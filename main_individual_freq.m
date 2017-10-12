function main_individual_freq(cfg)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Main script for handling creation of individual plots per participant
  %Created, 15/09/2017
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  d_average = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/average/';
  cd(d_average)
  freqrange  = 'low';
  load_avg   = 0 ;
  %Loop over correct participants to plot or save the trials switch no switch sep.


  if load_avg
    cd(d_average)
    freqpath   = dir(sprintf('*%s_%s.mat',freqrange,num2str(cfg.part_ID)));
    load(freqpath.name);
  else
    [freq,switchTrial,stableTrial]=freq_average_individual(cfg.part_ID);
  end

  plot_average_individual(cfg.part_ID,freq,switchTrial,stableTrial);




end
