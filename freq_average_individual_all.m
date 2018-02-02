function [freq,switchTrial,stableTrial]=freq_average_individual_all(cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in freq data, and average across
  %Based on freq_average_individual
  %But to output the average response of all trials.
  %Created 22/11/2017. Accomodate trial-based/stim
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/%s',cfgin.blocktype,cfgin.stim_self)

  cd(filepath)

  doplot     = 0;
  compSwitch = 0;
  if strcmp(cfgin.blocktype,'continuous')
    freqpath   = dir(sprintf('*freq_%s*-26-26*',cfgin.freqrange));
  else
    if strcmp(cfgin.stim_self,'stim')
      freqpath   = dir(sprintf('*freq_stim_%s*',cfgin.freqrange));
    else
      freqpath   = dir(sprintf('*freq_%s_stim_off*',cfgin.freqrange));
    end
  end


  namecell = {freqpath.name};

  partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

  partnum = cellfun(@str2num,partnum,'UniformOutput',false);

  blocks_ID = find(ismember([partnum{:}],cfgin.part_ID));


  for iblocks = 1:length(blocks_ID)

    %Load the freq data
    disp(freqpath(blocks_ID(iblocks)).name)
    load(freqpath(blocks_ID(iblocks)).name)

    %Append all the data
    if iblocks>1
      [freqAll] = append_trialfreq([],freqAll,freq);
    else
      freqAll=freq;
    end
  end

  % %Remove trials with response too close to stimulus onset.
  % idx_trl = ((freq.trialinfo(:,9)-freq.trialinfo(:,7))./1200)<1;
  % sum(idx_trl)
  % cfg = [];
  % cfg.trials = idx_trl;
  % freq = ft_selectdata(cfg,freq);


  %Run within trial baseline
  cfg                       = [];
  cfg.subtractmode          = 'within'; % norm_avg within_norm, within
  %Find first nonnan timepoint in data, and use that before and after self-O
  %What if there are no nans at all...
  if strcmp(cfgin.blocktype,'continuous')
    idx_nan = ~isnan(freq.powspctrm(1,1,1,:));
    % idx_time=find(diff(idx_nan)==-1);
    % switchTrial.time(idx_time)
    cfg.baselinewindow        = [freq.time(21) freq.time(31)];

  else
    %4.5=stim_off.
    if strcmp(cfgin.baseline,'cue')
      cfg.baselinewindow=[2.35 2.85];
    else
      cfg.baselinewindow        = [cfgin.baseline(1) cfgin.baseline(2)]; %-0.4 -0.1
    end
  end

  [freq_base] = baseline_lissajous_all(freqAll,cfg,cfgin);


  %Append data, by taking the average
  %Make the freq the trial average
  cfg =[];
  cfg.avgoverrpt = 'yes';
  freq = ft_selectdata(cfg,freq);

  %substitute powspctrm with own baselined data
  freq.powspctrm=freq_base;





  %Save the freq in new folder
  d_average = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/%s/',cfgin.blocktype,cfgin.stim_self);
  cd(d_average)
  freqtosave = sprintf('freqavgs_all_%s_%d',cfgin.freqrange,cfgin.part_ID);
  save(freqtosave,'freq')
end
