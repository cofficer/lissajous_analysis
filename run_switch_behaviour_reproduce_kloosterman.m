function output = run_switch_behaviour_reproduce_kloosterman(nPart)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Correlate switch-related activity with
  %upcoming perceptual duration.
  %In order to replicate the correlation:
  %1. Piecewise linear detrending of the scalar MEG/trial. -STRANGE.
  %2. Group the resulting scalar trial values into 10 equal valued bins.
  %2. normalize by the median percept duration. Or don't.
  %Created 20/09/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  % Get the stat.mask
  % load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/2018-06-04_statistics_switchvsnoswitch.mat')
  % Get the most recent stat.mask and plot it to check....
  % load('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
  load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/2018-11-17_statistics_switchvsnoswitch.mat')

  % Load to get one freq.
  % load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/both_self_freqavg/freqavgs_switch_continuous_low_7.mat')
  % load('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/continous_self_freq/06freq_low_selfocclBlock2.mat')
  % cd('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/continous_self_freq/')

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


  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/self')

  % Extract the participant number.
  % Necessary to store the data in the proper format per participant.
  % nPart='06';
  nFiles = dir(sprintf('%s*low*',nPart));

  for ifile = 1:length(nFiles)

    % Needs to load every relevant file...
    load(nFiles(ifile).name)

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

    meg_cluster_all=horzcat(meg_cluster_all,meg_cluster);
    size(meg_cluster_all)
  end

  % Do linear Piecewise-Detrending.
  % How does the linear detrending make sense if the data is not continuous?
  meg_detrend=detrend(meg_cluster_all(1,:),'linear');

  % Replace the MEG value with a bin number 1-10.
  linspace(min(meg_detrend),max(meg_detrend),10)

  quantize_data=quantile(meg_detrend,linspace(0,1,10));

  % Create a matrix for all the divisions of MEG trials.
  meg_quantiles_bool = nan(10,length(meg_detrend));

  % Loop over the quantiles and create correct indexing.
  for iquant = 1:10
    if iquant == 10
      meg_quantiles_bool(iquant,:)=meg_detrend>quantize_data(iquant-1);
    else
      meg_quantiles_bool(iquant,:)=meg_detrend<quantize_data(iquant+1);
      meg_quantiles_bool(iquant,:)=and(meg_quantiles_bool(iquant,:), meg_detrend>=quantize_data(iquant));
    end
  end

  % Figure out which quantile each MEG scalar belongs to.
  % Each scalar should be replaced  with 1:10.
  % find(meg_quantiles_bool)
  % meg_cluster_all(1,:)
  % total_quant=sum(meg_quantiles_bool,2)

  % use test_meg_change instead of changing meg_cluster_all for now
  % this loop removes the MEG scalar and inserts the quartile divisions instead.
  meg_cluster_bins=meg_cluster_all;
  for iscalar = 1:length(meg_detrend)
    pos_scalar = find(meg_quantiles_bool(:,iscalar));
    meg_cluster_bins(1,iscalar)=pos_scalar(1);

  end

  % final step is to normalise the stay duration by the median stay duration.
  % need to consider if this is different from the post switch-related stay dur.
  meg_cluster_bins(2,:)=meg_cluster_all(2,:)./median(meg_cluster_all(2,:),'omitnan');


  % meg_cluster_bins_collapsed will contain the norm. average percept duration per bin
  meg_cluster_bins_collapsed=nan(1,10);

  for ibins =1:10
    meg_cluster_bins_collapsed(ibins)=nanmean(meg_cluster_bins(2,meg_cluster_bins(1,:)==ibins));
  end

  % save the data meg_cluster_bins_collapsed per participant.
  % cd('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/beta_cluster_self_switch')
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/cluster_freq/')
  save(sprintf('%s_meg_cluster_bins.mat',nPart),'meg_cluster_bins_collapsed')
  %
  % figure(1),clf
  % plot(meg_cluster_bins_collapsed)
  % hold on
  % plot(quantize_data)


  %
  % discretize(meg_cluster_all(1,1:end-20),10)
  % x = rand(10,1);
  % bins = discretize(x,0:0.25:1)
  % % Save the meg_cluster_all matrix, one per participant.
  % cd('/home/chrisgahn/Documents/MATLAB/Lissajous/continuous/cluster_freq')
  %
  % filename=sprintf('%s_meg_cluster.mat',cfgin.restingfile)
  % save('meg_cluster_all.mat','meg_cluster_all')
  %
  % figure(1),clf
  % stay_durs   = meg_cluster_all(2,:);
  % meg_act     = meg_cluster_all(1,:);
  % stay_durs   = stay_durs(meg_act<1e-19);
  % meg_act     = meg_act(meg_act<1e-19);
  % meg_act(isnan(stay_durs))=[];
  % stay_durs(isnan(stay_durs))=[];
  %
  % scatter(stay_durs,meg_act,'*')
  %
  % xlabel('bin MEG percentile')
  % ylabel('normalized stay duration')
  % cd('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/results_plots')
  %
  % saveas(gca,'norm_stay_duration_MEG_bins.png','png')

  % [aa,bb]=corr(stay_durs',meg_act')

end
