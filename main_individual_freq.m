function main_individual_freq(cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Main script for handling creation of individual plots per participant
  %Created, 15/09/2017
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  d_average = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/',cfgin.blocktype);
  cd(d_average)

  %Loop over correct participants to plot or save the trials switch no switch sep.


  if cfgin.load_avg
    cd(d_average)
    freqpath   = dir(sprintf('*%s_%s.mat',cfgin.freqrange,num2str(cfgin.part_ID)));
    load(freqpath.name);
  else
    [freq,switchTrial,stableTrial]=freq_average_individual(cfgin);
  end

  plot_average_individual(cfgin.part_ID,freq,switchTrial,stableTrial);




end
