

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Main script for handling creation of individual plots per participant
  %Taken from, main_individual_freq
  %Standalone script to produce average plots TFRs and TOPOs
  %Need to be easy to create all relevant plots:
  %Across defined frequencies, types, sensors, timewindow
  %Created: 2017-10-12
  %TODO: Make same distinctions for the trial-based data.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Low or high frequencies
  frequencies = 'high';
  cfgin.blocktype ='trial'; %continuous, trial.
  %load averaged data
  [freq,avg_freq_stable,avg_freq_switch]=load_averaged_freq(frequencies,cfgin);

  %Define plot type
  runplot.multi       = 0;
  runplot.zlim        = [-3 3];
  runplot.freqrange   = 'gamma'; %theta, alpha, beta, gamma
  runplot.type        = 'tfr'; %topo, tfr, tmap
  runplot.timewindow  = [-0.8:0.2:0.4]; %make 1 too many, always
  runplot.sensors     = 'all'; %all, occipital
  runplot.data        = 'SvsN'; %SvsN, stable, switch, combined


  plot_average_all(runplot,freq,avg_freq_stable,avg_freq_switch)
