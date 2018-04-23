function [freq,switchTrial,stableTrial]=freq_average_individual(cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in freq data, and average across
  %Created 15/09/2017.
  %Edited 22/11/2017. Accomodate trial-based/stim
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/%s/',cfgin.blocktype,cfgin.stim_self)

  cd(filepath)

  doplot     = 0;
  compSwitch = 0;
  if strcmp(cfgin.blocktype,'continuous')
    freqpath   = dir(sprintf('*%s*',cfgin.freqrange));
  else
    freqpath   = dir(sprintf('*%s*',cfgin.freqrange));
  end

  namecell = {freqpath.name};

  partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

  partnum = cellfun(@str2num,partnum,'UniformOutput',false);


  %part_ID = 5;

  blocks_ID = find(ismember([partnum{:}],cfgin.part_ID));

  suplot = 0;
  %Loop over participant 3 seperate blocks
  for ipart = 1:length(blocks_ID)
    suplot=suplot+1;
    cd(filepath)
    %Load the freq data
    load(freqpath(blocks_ID(ipart)).name)
    disp(freqpath(blocks_ID(ipart)).name)

    %store details about each freq.
    partInfo(ipart).trialinfo = freq.trialinfo;


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
      idx_switch   = zeros(1,length(freq.trialinfo(:,8)))';
      idx_switch(freq.trialinfo(:,8)==42)   = 1;
      idx_switch(freq.trialinfo(:,8)==45)   = 1;
      nopress      = freq.trialinfo(:,8)==43;
      idx_noswitch   = zeros(1,length(freq.trialinfo(:,8)))';
      idx_noswitch(freq.trialinfo(:,8)==41)   = 1;
      idx_noswitch(freq.trialinfo(:,8)==46)   = 1;
    else
      idx_switch   = (abs(diff(freq.trialinfo(:,5)))==7);
      nopress      = freq.trialinfo(:,5)==0;
      idx_noswitch = diff(freq.trialinfo(:,5))==0;
    end


    %Remove the trials where there is no buttonpress.
    idx_noswitch(nopress(length(idx_noswitch)))=0;
    idx_switch(nopress(length(idx_switch)))=0;

    currNum = partnum(ipart);

    if strcmp(cfgin.blocktype,'continuous')
      %Remove the trials where there are artifacts.
      %Call function for all artifacts.
      %inputs: participant nr, and iblock, freq.
      %outputs: full freq, but with nans. and idx of
      %trials to remove.
      [idx_artifacts, freq]         = freq_artifact_remove(freq,cfgin,ipart);
      idx_noswitch(idx_artifacts)   = 0;
      idx_switch(idx_artifacts)     = 0;
    else
      [~,freq] = freq_artifact_remove(freq,cfgin,[]);
    end

    %select trials,
    cfg   = [];
    if strcmp(cfgin.blocktype,'trial')
      cfg.trials = logical([idx_switch]); %add a 0 for the last trial.
    else
      cfg.trials = logical([idx_switch;0]); %add a 0 for the last trial.
    end
    %cfg.trial = ~nopress;
    %cfg.frequency = [12 35];
    cfg.avgoverrpt = 'no';
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


  end

  %Remove all trials occuring to close to stimulus onset.
  if strcmp(cfgin.stim_self,'self') && strcmp(cfgin.blocktype,'trial')

    diff_resp_self_stable= stableTrial.trialinfo(:,11)-stableTrial.trialinfo(:,9);
    diff_resp_self_switch= switchTrial.trialinfo(:,11)-switchTrial.trialinfo(:,9);

    %threshold for removing trials, 500ms?
    % sum(diff_resp_self<600)
    %remove trials
    cfg4 =[];
    cfg4.trials = diff_resp_self_stable>900;
    stableTrial = ft_selectdata(cfg4,stableTrial);
    cfg4.trials = diff_resp_self_switch>900;
    switchTrial = ft_selectdata(cfg4,switchTrial);

  end

  %Run within trial baseline
  cfg2                       = [];
  cfg2.subtractmode          = 'no'; %what are the options? %no within within_norm
  %Find first nonnan timepoint in data, and use that before and after self-O
  %What if there are no nans at all...
  if strcmp(cfgin.blocktype,'continuous')
    % idx_nan = ~isnan(switchTrial.powspctrm(1,1,1,:));
    % idx_time=find(diff(idx_nan)==-1);
    % switchTrial.time(idx_time)
    % cfg.baselinewindow        = [-2.25 -1.85];%[-switchTrial.time(idx_time) switchTrial.time(idx_time)];
    cfg2.baselinewindow        = [freq.time(1) freq.time(11)];
  else
    if strcmp(cfgin.baseline,'cue')
      cfg2.baselinewindow=[-0.7 -0.3];
    elseif strcmp(cfgin.baseline,'stimoff')
      cfg2.baselinewindow=[0.1 0.5];
    elseif strcmp(cfgin.baseline,'self')
      cfg2.baselinewindow=[-2.5 -2.5];
    end
  end

  if ~strcmp(cfg2.subtractmode,'no')
    % CG commented out the baseline for now. 2018-01-15.
    [freq1,freq2] = baseline_lissajous(switchTrial,stableTrial,cfg2,cfgin);
  end

  %save the number of switch trials and stable trials left.
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/')
  fid=fopen('stat_summary_trials','a+');
  c=clock;
  fprintf(fid,sprintf('\n\n\n\nNew entry for %s at %i/%i/%i %i:%i\n',cfgin.restingfile,fix(c(1)),fix(c(2)),fix(c(3)),fix(c(4)),fix(c(5))))
  fprintf(fid,sprintf('Switch trials: %s \nStable trials: %s \n',num2str(size(switchTrial.powspctrm,1)),num2str(size(stableTrial.powspctrm,1))))

  fclose(fid)


  %Make the freq the trial average
  cfg =[];
  cfg.avgoverrpt = 'yes';
  cfg.nanmean    = 'yes';
  freq = ft_selectdata(cfg,freq);

  %Make the freq the trial average
  cfg =[];
  cfg.avgoverrpt = 'yes';
  cfg.nanmean    = 'yes';
  switchTrial = ft_selectdata(cfg,switchTrial);

  %Make the freq the trial average
  cfg =[];
  cfg.avgoverrpt = 'yes';
  cfg.nanmean    = 'yes';
  stableTrial = ft_selectdata(cfg,stableTrial);
  %sum(isnan(stableTrial.powspctrm(:)))

  if ~strcmp(cfg2.subtractmode,'no')
    switchTrial.powspctrm = freq1;
    stableTrial.powspctrm = freq2;
  end
  %substitute powspctrm with own baselined data
  freq.powspctrm=squeeze(switchTrial.powspctrm)-squeeze(stableTrial.powspctrm);

  %Save the freq in new folder
  d_average = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/%s/',cfgin.blocktype,cfgin.stim_self);
  cd(d_average)
  freqtosave = sprintf('freqavgs_switch_%s_%d',cfgin.freqrange,cfgin.part_ID);
  save(freqtosave,'freq','switchTrial','stableTrial')

end
