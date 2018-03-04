function freq_filter(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First high-pass filter frequency data.
%Second, insert nan values in freq where blinks.
%Third, nanmean the data.
%Created 2018-02-16.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%resources:
%1. https://de.mathworks.com/help/signal/ref/designfilt.html
%2. https://de.mathworks.com/help/signal/ref/filtfilt.html?requestedDomain=true

%Make sure to pad the data before and after real data. And then index out post
%filtering.

%Make sure to visualize the filtering process as to be sure it works.
%It might also be worth it to first mirror the signal.

%performs zero-phase digital filtering by processing the input data, x, in both
%the forward and reverse directions. After filtering the data in the forward
%direction, filtfilt reverses the filtered sequence and runs it back through
%the filter. The result has the following characteristics:
%Zero phase distortion.
%A filter transfer function equal to the squared magnitude of the original
%filter transfer function.
%A filter order that is double the order of the filter specified by b and a.

filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/%s/',cfgin.blocktype,cfgin.stim_self)
cd(filepath)

doplot     = 0;
compSwitch = 0;
if strcmp(cfgin.blocktype,'continuous')
  freqpath   = dir(sprintf('*%s*.mat',cfgin.freqrange));
else
  freqpath   = dir(sprintf('*stim_%s*',cfgin.freqrange));
end

namecell = {freqpath.name};

partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

partnum = cellfun(@str2num,partnum,'UniformOutput',false);

blocks_ID = find(ismember([partnum{:}],cfgin.part_ID));

%Decide to plot the power spectrum before and after filterering.
doplot_freq_filt = 0;
doplot_freq_timecourse = 1;
%Loop over participant 3 seperate blocks
for ipart = 1:length(blocks_ID)
  cd(filepath)
  %Load the freq data
  load(freqpath(blocks_ID(ipart)).name)
  disp(freqpath(blocks_ID(ipart)).name)

  %store details about each freq.
  partInfo(ipart).trialinfo = freq.trialinfo;


  %The only way to highpass might be to do so continuously...
  t_start = 1;
  t_stop  = 91;
  for itrl = 1:size(freq.powspctrm,1)

    freq_concat(:,:,t_start:t_stop) = squeeze(freq.powspctrm(itrl,:,:,6:96));
    % time_concat(1,appropriate time indices) = data.time{itrl}(:);
    t_start = t_start+91;
    t_stop  = t_stop+91;
  end

  if doplot_freq_timecourse
    %Plot the figure
    figure(1),clf
    subplot(2,1,1) % unfilt=freq_concat;
    % loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on; 22=1s.
    ab1 = squeeze(unfilt(100,10,1000:1400));
    % ab(500:600)=NaN;
    plot(ab1, 'k', 'linewidth', 1);
    ntitle('Unfiltered freq powspctrm','location','northeast','fontsize',10,'edgecolor','k')

  end

  %Loop over each chan and each freq, and run the defined filtering. 1.2497e-26
  for ichan = 1:length(freq.label)
    disp(ichan)
    for ifreq = 1:length(freq.freq)
      %Run filter sequence
      x = [squeeze(freq_concat(ichan,ifreq,:))',squeeze(freq_concat(ichan,ifreq,:))',...
      squeeze(freq_concat(ichan,ifreq,:))'];

      x=nbt_filter_firHp(x,0.2,20,10);
      x=x';
      % y = filtfilt(d,x);

      freq_concat(ichan,ifreq,:)=x((size(x,2)/3)+1:end-(size(x,2)/3));
    end
  end

  if doplot_freq_timecourse
    %Plot the 2nd filtered figure
    subplot(2,1,2) %filt = freq_concat;
    % loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on;
    ab2 = squeeze(filt(100,10,1100:1500));
    % ab(500:600)=NaN;
    plot(ab2, 'k', 'linewidth', 1);
    ntitle('Filtered freq powspctrm','location','northeast','fontsize',10,'edgecolor','k')
    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
    saveas(gca,'testing_diff_timecource_filt_freq_continuous.png')

    [acor,lag]=xcorr(squeeze(filt(100,10,:)),squeeze(unfilt(100,10,:)));
    [~,I] = max(abs(acor));
    lagDiff = lag(I)
    figure
    plot(lag,acor)
    xlim([-500 500])
    saveas(gca,'testing_diff_timecource_filt_freq_continuous_error.png')

  end

  %Now the question is how we re-assemble the data where it belongs:
  %Into the original trials... The question is also if all trials are
  %still present. Looks like some trials are indeed missing.
  %and its not due to no resp. Its 10 in total.

  if doplot_freq_filt
      %Plot the figure
      figure(1),clf
      subplot(1,2,1)
      % loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on;
      loglog(freq.freq, squeeze(mean(mean(mean(freq.powspctrm,1),4),2)), 'k', 'linewidth', 1);
      xlim([1 33])
      ntitle('Unfiltered freq powspctrm','location','northeast','fontsize',10,'edgecolor','k')


  end

  freq.powspctrm = zeros(size(freq.powspctrm,1),size(freq.powspctrm,2),...
                    size(freq.powspctrm,3),91);

  t_start = 1;
  t_stop  = 91;
  for itrial = 1:size(freq.powspctrm,1)
    disp(itrial)
    freq.powspctrm(itrial,:,:,:)=freq_concat(:,:,t_start:t_stop);
    t_start = t_start+91;
    t_stop  = t_stop+91;

  end

  if doplot_freq_filt
      %Plot the figure
      subplot(1,2,2)
      % loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on;
      loglog(freq.freq, squeeze(mean(mean(mean(freq.powspctrm,1),4),2))', 'k', 'linewidth', 1);
      xlim([1 33])
      ntitle('Filtered freq powspctrm','location','northeast','fontsize',10,'edgecolor','k')
      cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
      saveas(gca,'testing_diff_filt_freq_continuous.png')
  end

  freq.time=freq.time(6):0.05:freq.time(97);

  %Save, average switch and no switch and save as switch trials.
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/filtered')

  %Divide trials into the switch and stable trials

    %Change the button press to the same values.
    if ~strcmp(cfgin.blocktype,'trial')
      if sum(freq.trialinfo(:,5)==226)>0
        freq.trialinfo(freq.trialinfo(:,5)==226,5)=225;
        freq.trialinfo(freq.trialinfo(:,5)==228,5)=232;
      elseif sum(freq.trialinfo(:,5)==228)>0
        freq.trialinfo(freq.trialinfo(:,5)==228,5)=232;
        freq.trialinfo(freq.trialinfo(:,5)==226,5)=225;
      end
    end

    %Find the indices of switches and non switches.
    if strcmp(cfgin.blocktype,'trial')
      idx_switch   = zeros(1,length(freq.trialinfo(:,6)))';
      idx_switch(freq.trialinfo(:,6)==42)   = 1;
      idx_switch(freq.trialinfo(:,6)==45)   = 1;
      nopress      = freq.trialinfo(:,6)==43;
      idx_noswitch   = zeros(1,length(freq.trialinfo(:,6)))';
      idx_noswitch(freq.trialinfo(:,6)==41)   = 1;
      idx_noswitch(freq.trialinfo(:,6)==46)   = 1;
    else
      idx_switch   = (abs(diff(freq.trialinfo(:,5)))==7);
      nopress      = freq.trialinfo(:,5)==0;
      idx_noswitch = diff(freq.trialinfo(:,5))==0;
    end



    %Remove the trials where there is no buttonpress.
    idx_noswitch(nopress)=0;
    idx_switch(nopress)=0;
    currNum = partnum(ipart);

    %Remove the trials where there are artifacts.
    %Call function for all artifacts.
    %inputs: participant nr, and iblock, freq.
    %outputs: full freq, but with nans. and idx of
    %trials to remove.
    [idx_artifacts, freq]         = freq_artifact_remove(freq,cfgin,ipart);
    idx_noswitch(idx_artifacts)   = 0;
    idx_switch(idx_artifacts)     = 0;


    %select trials,
    cfg.avgoverrpt = 'no';
    cfg.trials = logical([idx_switch;0]);
    if ipart>1
      freqtmp = ft_selectdata(cfg,freq);
      %new function for appending data.
      switchTrial = append_trialfreq([],switchTrial,freqtmp);
      freqtmp=[];
    else
      switchTrial  = ft_selectdata(cfg,freq);
    end
    %select trials
    cfg   = [];
    cfg.trials = logical([idx_noswitch;0]); %add a 0 for the last trial.
    cfg.avgoverrpt = 'no';
    if ipart>1
      freqtmp = ft_selectdata(cfg,freq);
      %new function for appending data.
      stableTrial = append_trialfreq([],stableTrial,freqtmp);
      freqtmp=[];
    else
      stableTrial  = ft_selectdata(cfg,freq);
    end

    cfg =[];
    cfg.avgoverrpt = 'yes';
    freq = ft_selectdata(cfg,freq);



end

%Remove blinks and muscle and jumps then average the filtered freq data.





%Make the freq the trial average
cfg =[];
cfg.avgoverrpt = 'yes';
switchTrial = ft_selectdata(cfg,switchTrial);

%Make the freq the trial average
cfg =[];
cfg.avgoverrpt = 'yes';
stableTrial = ft_selectdata(cfg,stableTrial);

%Save the freq in new folder
freqtosave = sprintf('freqs_%s_%d.mat',cfgin.freqrange,cfgin.part_ID);
save(freqtosave,'freq','switchTrial','stableTrial')

%Procedures:
%1. Identify blinks and insert nans in freq data.
%2. Highpass filter the freq data.
%3. Nanmean freq data into averages. No baseline
