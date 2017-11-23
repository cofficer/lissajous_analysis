function plot_trial_behavior
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in behavioral data, and plot across events.
  %Created 23/11/2017.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  %Load or create a table of all trial-based behavior.
  %Create.


  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/')

  freqfiles= dir('*all_high*');
  load(freqfiles(1).name)


  %Create matrix for all participants.
  dims = size(freq.powspctrm);
  all_freq = zeros(29,dims(1),dims(2),dims(3));

  %Load all participants
  for ifiles = 1:length(freqfiles)-1
    all_freq(ifiles,:,:,:) = freq.powspctrm;
    load(freqfiles(ifiles+1).name)
  end








end
