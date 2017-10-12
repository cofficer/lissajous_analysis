

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
  runplot.zlim        = [-10 10];
  runplot.freqrange   = 'theta'; %theta, alpha, beta
  runplot.type        = 'topo'; %topo, tfr, tmap
  runplot.timewindow  = [-0.8:0.2:0.4]; %make 1 too many, always
  runplot.sensors     = 'all'; %all, occipital
  runplot.data        = 'switch'; %SvsN, stable, switch, combined


  plot_average_all(runplot,freq,avg_freq_stable,avg_freq_switch)
