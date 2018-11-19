function output = run_switch_behaviour(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Correlate switch-related activity with
  %upcoming perceptual duration.
  %Created 20/09/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  %Get the stat.mask
  % load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/2018-06-04_statistics_switchvsnoswitch.mat')
  %Get the most recent stat.mask and plot it to check....
  load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
  %Load to get one freq.
  load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/both_self_freqavg/freqavgs_switch_continuous_low_7.mat')

  % %Sum over time, and freq.
  data_comp = statout.stat;
  data_comp(~statout.mask)=NaN;
  %sum over channels...
  %time
  data_comp=nansum(data_comp(:,:,:),3);
  %freq
  data_comp=nansum(data_comp(:,:,:),2);
  %only take the most negative sensors in the cluster
  data_comp_sensors=data_comp<-80;

  %I need to extract the more precise cluster in all three dimensions and then after that
  %I can run the behavioural correlations.
  %Maybe it is possible to only reduce the number of sensors in the cluster and
  %See the other dimensions within those sensors. Essentially, I can plot
  %The effect in the TFR using only the reduced number of sensors...


  data_comp = statout.stat;
  %MOST IMPORTANT line. This states we only take the sensors which show
  %the strongest effect.
  %if not mask=1, then insert NaNs for all positions exluding the
  %sensors we have predefined as of interest.
  data_comp(~statout.mask(data_comp_sensors,:,:))=NaN;
  %sum over channels...
  data_comp=nansum(data_comp(data_comp_sensors,:,:),1);

  %Loop for every datafile...
  %Temporary example
  load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/continous_self_freq/06freq_low_selfocclBlock2.mat')
  %Always 272 self-occlusions:
  %Step 1. Figure out which are the switches.
  %Step 2. Assign each of the self-occlusions with the number of sOs until next switch.
  %Caution. Make sure that the missing triggers are not treated as switches or
  %inferred to mean that there was no switch there. Only use the trial sequences
  %that have correctly reported behaviour.

  idx_switch  = freq.trialinfo(:,end);

  %Add an additional column in the freq.trialinfo for the percept duration.
  %The only thing is that this will be confounded by effect of continually pressing
  %the same button. There may be spectral leakage into the visual sensors.
  freq=find_continuous_stay_duration(freq);

  bp_types = unique(freq.trialinfo(:,5));



  %After we have both the switches and the associated upcoming trial duration
  %Step 1. ft_selectdata only the time points of interest -0.5 to 0.5s.
  %Step 2. Use the defined mask of the sensors by freqs by time and sum over all
  %dimensions for a singular switch-modulated magnetic field value.
  %Step 3. Store the switch-modulated value and the upcoming trial duration in a matrix
  %Step 4. Store these two quantities for all the continuous low freq data.
  %Step 5. Store these two quantities for all the trial-based low freq data.

  %Potential problems with the researchers degrees of freedom:
  %I can change baseline, I can use only trial or only continuous or both.
  %I can be more or less stringent about trial rejection and participants to include.


end
