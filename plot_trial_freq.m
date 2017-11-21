

function plot_trial_freq(frequencies,cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Created 2017-11-21
  %TODO: plot trial-based freq data.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype))


  %The question is how this has been averaged and baselined.
  %Pretty sure it is not trustworthy
  load('averageGammaBand.mat')

  %Plot gamma at the time of rotation.
  %Want to look at the topoplots, and identify the
  %sensors most activated.
  %Will need to do a different baselinewindow then.
  %And actually therefore need to redo the freq analysis to include
  %further back in time. 



  end
