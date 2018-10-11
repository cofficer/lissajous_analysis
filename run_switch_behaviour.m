function output = run_switch_behaviour(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Correlate switch-related activity with
  %upcoming perceptual duration.
  %Created 20/09/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %Get the stat.mask
  load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/2018-06-04_statistics_switchvsnoswitch.mat')

  %Use the mask to extract the cluster on each trial. The cluster should be
  %the signal change in power, or simply the power...
  %%Potential difficuly is definately the absence of baseline.
  %%I would think the effect is still there even if we baseline, it should not
  %%really matter.
  %%Use the baseline to see if the effect is still there.

  %Correlate with the average




end
