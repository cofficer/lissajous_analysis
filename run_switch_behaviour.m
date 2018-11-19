function output = run_switch_behaviour(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Correlate switch-related activity with
  %upcoming perceptual duration.
  %Created 20/09/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % Get the stat.mask
  % load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/2018-06-04_statistics_switchvsnoswitch.mat')
  % Get the most recent stat.mask and plot it to check....
  load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')

  % Load to get one freq.
  % load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/both_self_freqavg/freqavgs_switch_continuous_low_7.mat')

  %%
  % Sum over time, and freq.
  data_comp = statout.stat;
  data_comp(~statout.mask)=NaN;
  data_comp=nansum(data_comp(:,:,:),3);
  data_comp=nansum(data_comp(:,:,:),2);

  %only take the most negative sensors in the cluster
  data_comp_sensors=data_comp<-80;

  % Reset the data_comp variable.
  data_comp = statout.stat;

  %MOST IMPORTANT line. This states we only take the sensors which show
  %the strongest effect.
  %if not mask=1, then insert NaNs for all positions exluding the
  %sensors we have predefined as of interest.
  data_comp(~statout.mask(data_comp_sensors,:,:))=NaN;

  % Initialize loop variables.
  nFiles=1;
  meg_cluster_all=[];

  for ifile = 1:nFiles

    load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/continous_self_freq/06freq_low_selfocclBlock2.mat')

    %Always 272 self-occlusions:
    %Step 1. Figure out which are the switches.
    %Step 2. Assign each of the self-occlusions with the number of sOs until next switch.
    %Caution. Make sure that the missing triggers are not treated as switches or
    %inferred to mean that there was no switch there. Only use the trial sequences
    %that have correctly reported behaviour.

    freq=find_continuous_stay_duration(freq);

    %After we have both the switches and the associated upcoming trial duration
    %Step 1. ft_selectdata only the time points of interest -0.5 to 0.5s.
    %Step 2. Use the defined mask of the sensors by freqs by time and sum over all
    %dimensions for a singular switch-modulated magnetic field value.
    %Step 3. Store the switch-modulated value and the upcoming trial duration in a matrix
    %Step 4. Store these two quantities for all the continuous low freq data.
    %Step 5. Store these two quantities for all the trial-based low freq data.

    cluster_mask=~isnan(data_comp);
    meg_cluster=correlate_stay_duration_switches(freq,cluster_mask);

    meg_cluster_all=[meg_cluster_all;meg_cluster];

  end

  % Save the meg_cluster_all matrix, one per participant.



end
