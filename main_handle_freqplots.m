

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Main script for handling creation of individual plots per participant
  %Taken from, main_individual_freq
  %Standalone script to produce average plots TFRs and TOPOs
  %Need to be easy to create all relevant plots:
  %Across defined frequencies, types, sensors, timewindow
  %Created: 2017-10-11
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %load averaged data
  [freq,avg_freq_stable,avg_freq_switch]=load_averaged_freq;

  %Define plot type
  runplot.multi       = 1;
  runplot.zlim        = [-4 4];
  runplot.freqrange   = 'alpha'; %theta, alpha, beta
  runplot.type        = 'topo'; %topo, tfr, tmap
  runplot.timewindow  = [-2.0:0.2:-0.8];
  runplot.sensors     = 'all'; %all, occipital
  runplot.data        = 'SvsN'; %SvsN, stable, switch, combined


  plot_average_all(runplot,freq,avg_freq_stable,avg_freq_switch)
