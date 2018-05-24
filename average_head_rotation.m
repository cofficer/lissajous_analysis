

function mm_move = average_head_rotation(cfgin)


  % Compute head movement


  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/',cfgin.restingfile(2:3));
  cd(dsfile)

  %Identify datasets, and load correct block.
  datasets = dir('*ds');

  if strcmp(cfgin.blocktype,'continuous')
    %Choosing the second dataset is arbitrary.
    %dsfile=datasets(2).name;
    nblocks=4;
    startblock=2;
    if strcmp(cfgin.restingfile(2:3),'19')
      nblocks=6;
    elseif strcmp(cfgin.restingfile(2:3),'8')

    end
    if strcmp(cfgin.stim_self,'resp')
      trldef = 'trialfun_lissajous_CONT_resp';
    elseif strcmp(cfgin.stim_self,'cue')
      trldef = 'trialfun_lissajous_CONT_cue';
    else
      trldef = 'trialfun_lissajous_CONT';
    end
  end

  for iblock = startblock:nblocks
    cd(dsfile)
    datafile=datasets(iblock).name;

    %Hard coding P08 issues.
    % if iblock==3 && strcmp(cfgin.restingfile(2:3),'08')
    %   continue
    % end
    % %Hard codgin P19 issues.
    % if iblock==3 && strcmp(cfgin.restingfile(2:3),'19')
    %   continue
    % elseif iblock==4 && strcmp(cfgin.restingfile(2:3),'19')
    %   continue
    % end
    %%
    %Load data into trial-based format.
    cfg                         = [];
    cfg.dataset                 = datafile;
    cfg.trialfun                = trldef; % this is the default
    cfg.trialdef.eventtype      = 'UPPT001';
    cfg.trialdef.eventvalue     = 10; % self-occlusion trigger value
    %TODO: save preprocessed data occuring before the stimulus onset.
    %Stim or selfocclusion is preprocessed

    if ~strcmp(cfgin.blocktype,'continuous')
      if strcmp(cfgin.stim_self,'stim')
        cfg.trialdef.prestim        = 4; % -2in seconds
        cfg.trialdef.poststim       = -1; % 1in seconds
      elseif strcmp(cfgin.stim_self,'cue')
        cfg.trialdef.prestim        = 2; %200ms bf stimoff. Negative means after self-occlusion
        cfg.trialdef.poststim       = 1;  %800ms after stimoff.
      elseif strcmp(cfgin.stim_self,'self')
        cfg.trialdef.prestim          = 4
        cfg.trialdef.poststim         = 1
      elseif strcmp(cfgin.stim_self,'stimoff')
        cfg.trialdef.prestim          = 3
        cfg.trialdef.poststim         = 2

      else
        cfg.trialdef.prestim        = cfgin.prestim%1;%5.5; % 2.25in seconds
        cfg.trialdef.poststim       = cfgin.poststim%7;%5; % 4.25in seconds
      end
    elseif strcmp(cfgin.stim_self,'resp')
      cfg.trialdef.prestim          = 3
      cfg.trialdef.poststim         = 1
    elseif strcmp(cfgin.stim_self,'cue')
      cfg.trialdef.prestim          = 3
      cfg.trialdef.poststim         = 1
    elseif strcmp(cfgin.stim_self,'self')
      cfg.trialdef.prestim          = 3
      cfg.trialdef.poststim         = 1
    elseif strcmp(cfgin.stim_self,'stim')
      cfg.trialdef.prestim          = 4
      cfg.trialdef.poststim         = -1
    else
      cfg.trialdef.prestim          = 2.6
      cfg.trialdef.poststim         = 2.6
    end
    %Stores all the trial information
    cfg = ft_definetrial(cfg);

    %add trial information about perceptual switches.

    %Change the button press to the same values.
    if sum(cfg.trl(:,8)==226)>0
      cfg.trl(cfg.trl(:,8)==226,8)=225;
      cfg.trl(cfg.trl(:,8)==228,8)=232;
    elseif sum(cfg.trl(:,8)==228)>0
      cfg.trl(cfg.trl(:,8)==228,8)=232;
      cfg.trl(cfg.trl(:,8)==226,8)=225;
    end

    %Find the indices of switches and non switches.
    idx_switch   = [(abs(diff(cfg.trl(:,8)))==7);0];

    %add the idx_switch to trl structure
    cfg.trl(:,end+1) = idx_switch;

    %Hard coded to deal with bad recording.
    if startblock==2 && strcmp(cfgin.restingfile(2:3),'04')
      cfg.trl=cfg.trl(2:end,:);
    end

    %remove all trials that are missing sammpleinfo.
    cfg.trl(cfg.trl(:,1)<1,:)=[];


    %Load in raw data.
    % cfg.channel    ={'all'};
    cfg.channel = {'HLC0011','HLC0012','HLC0013', ...
    'HLC0021','HLC0022','HLC0023', ...
    'HLC0031','HLC0032','HLC0033'};
    cfg.continuous = 'yes';
    data = ft_preprocessing(cfg); %data1=data;

    %Resample raw data
    cfg3=[];
    cfg3.resample = 'yes';
    cfg3.fsample = 1200;
    cfg3.resamplefs = 500;
    cfg3.detrend = 'no'; %Why not detrend? Might destort eyelink?
    data = ft_resampledata(cfg3,data);

    % compute head rotation wrt first trial
    cc_rel = computeHeadRotation(data);

    mm_move(iblock) = max(cc_rel(:));
  end

end
