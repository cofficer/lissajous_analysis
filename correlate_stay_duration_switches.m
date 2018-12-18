function meg_cluster=correlate_stay_duration_switches(freq,cluster_mask)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Execute correlation switch-related activity with
  %upcoming perceptual duration.
  %Return the summed cluster values of switches
  %on a trial-by-trial basis, along with stay durations.
  %Created 19/11/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%



  % How should the result output be stored?
  % One possibility would be to have an expanding matrix with 2-by-trialN size.
  % expanding matrix is bad. Better to store .mat per participant every, only
  % loop over the number of datafiles.


  meg_cluster = zeros(2,size(freq.powspctrm,1));

  for itrl = 1:size(freq.powspctrm,1)
    comp_clust=squeeze(freq.powspctrm(itrl,:,:,:)).*cluster_mask;
    meg_cluster(1,itrl) = sum(comp_clust(:));
    meg_cluster(2,itrl) = freq.trialinfo(itrl,end);
  end




end
