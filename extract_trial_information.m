function extract_trial_information(cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in eyelink or other data, and plot across events.
  %Currently only focused on producing blink distributions.
  %Created 02/12/2017.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/',cfgin.restingfile(2:3));
  cd(dsfile)

  %Identify datasets, and load correct block.
  datasets = dir('*ds');

  cd(dsfile)
  datafile=datasets(1).name;

  %Load data into trial-based format.
  cfg                         = [];
  trldef = 'trialfun_lissajous';
  cfg.dataset                 = datafile;
  cfg.trialfun                = trldef; % this is the default
  cfg.trialdef.eventtype      = 'UPPT001';
  cfg.trialdef.eventvalue     = 10; % self-occlusion trigger value
  %TODO: save preprocessed data occuring before the stimulus onset.
  %Stim or selfocclusion is preprocessed
  cfgin.stim_self='stim';
  if strcmp(cfgin.stim_self,'stim')
    cfg.trialdef.prestim        = -2; % in seconds
    cfg.trialdef.poststim       = 1; % in seconds
  else
    cfg.trialdef.prestim        = 2.25; % in seconds
    cfg.trialdef.poststim       = 2.25; % in seconds
  end
  %Stores all the trial information
  cfg = ft_definetrial(cfg);
  %Load or create a table of all trial-based behavior.
  %Create.

  %Get the eyeblink channel from each participant:

  %Load in raw data.
  cfg.channel    ={'UADC003'};
  cfg.continuous = 'yes';
  data = ft_preprocessing(cfg); %data.time{1}(1),data.time{1}(end)
  cfg2              = [];
  begsample        = 1;
  endsample        = 6*1200+1;
  cfg2.begsample = ones(1,length(data.trial))';
  cfg2.endsample = ones(1,length(data.trial))'*endsample;

  data = ft_redefinetrial(cfg2,data);
  blinks = data.trial;
  savefile = sprintf('%s_eyelink_data.mat',cfgin.restingfile);
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior/blinks/')
  save(savefile,'blinks')
  %trl_info{icfgin}=cfg.trl;



end
