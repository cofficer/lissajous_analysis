function [data,cnt]=preproc_eye_artifact(data,cnt,blinkchannel)
  % ==================================================================
  % 26-09-2017. CG.
  % 3. Identify blinks (only during beginning of trial)
  % Remove trials with (horizontal) saccades (EOGH). Use the same settings as
  % for the EOGV-based blinks detection. The z-threshold can be set a bit higher
  % (z = [4 6]). Reject all trials that contain saccades before going further.
  % ==================================================================



  %find pupil index.
  idx_blink = find(ismember(data.label,{blinkchannel})==1);
  %idx_sacc  = find(ismember(data.label,{'EEG058'})==1); %Vertical

  %Take the absolute of the blinks to make identification easier with zscoring.
  for itrials = 1:length(data.trial)
    data.trial{itrials}(idx_blink,:) = abs(data.trial{itrials}(idx_blink,:));
  end

  cfg                              = [];
  cfg.continuous                   = 'yes'; % data has been epoched

  % channel selection, cutoff and padding
  cfg.artfctdef.zvalue.channel     = {blinkchannel}; %UADC003 UADC004s
  if strcmp(blinkchannel,'UADC003')
    % 001, 006, 0012 and 0018 are the vertical and horizontal eog chans
    cfg.artfctdef.zvalue.trlpadding  = 0; % padding doesnt work for data thats already on disk
    cfg.artfctdef.zvalue.fltpadding  = 0; % 0.2; this crashes the artifact func!
    cfg.artfctdef.zvalue.artpadding  = 0.1; % go a bit to the sides of blinks

    % algorithmic parameters
    cfg.artfctdef.zvalue.bpfilter   = 'no';

    % set cutoff
    cfg.artfctdef.zvalue.cutoff     = 2.5;
    cfg.artfctdef.zvalue.interactive = 'no';
  elseif strcmp(blinkchannel,'EEG058')

    cfg.artfctdef.zvalue.cutoff      = 0.2;
    cfg.artfctdef.zvalue.trlpadding  = 0;
    cfg.artfctdef.zvalue.artpadding  = 0.1;
    cfg.artfctdef.zvalue.fltpadding  = 0.2;

    % algorithmic parameters
    cfg.artfctdef.zvalue.bpfilter   = 'yes';
    cfg.artfctdef.zvalue.bpfilttype = 'but';
    cfg.artfctdef.zvalue.bpfreq     = [1 15];
    cfg.artfctdef.zvalue.bpfiltord  = 4;
    cfg.artfctdef.zvalue.hilbert    = 'yes';
  end

  [cfgart, artifact_eog]               = ft_artifact_zvalue(cfg, data);

  artifact_eogHorizontal = artifact_eog;
  %plot the blink rate horizontal??
  cfg=[];
  cfg.channel = blinkchannel; %UADC003 UADC004 if eyelink is present
  blinks = ft_selectdata(cfg,data);

  %%
  %Remove the eye artifacts
  cfg                              = [];
  cfg.artfctdef.reject             = 'complete';
  cfg.artfctdef.eog.artifact       = artifact_eogHorizontal;
  data                             = ft_rejectartifact(cfg,data);

  %Only plot the first time around.
  if strcmp(blinkchannel,'UADC003')
    %Save the blinks before removal.
    artifactTrl=zeros(size(cfgart.artfctdef.zvalue.artifact,2),size(cfgart.artfctdef.zvalue.artifact,1))';
    for iart = 1:size(cfgart.artfctdef.zvalue.artifact,1)

      %Compare the samples identified by the artifact detection and the
      %samples of each trial to identify the trial with artifact.
      %TODO: Check this error which occurs for blocks = 4, Part = 21.
      %Why add one to the floor? Because there is no trl = 0.
      artifactTrl(iart,1) = floor(cfgart.artfctdef.zvalue.artifact(iart,1)/length(data.time{1}))+1;
      artifactTrl(iart,2) = floor(cfgart.artfctdef.zvalue.artifact(iart,2)/length(data.time{1}))+1;
      %There should be some kind of modulus to use here to find in which interval of 2250
      %the artifact sample is contained within
      avgBlinks(iart,:) = blinks.trial{artifactTrl(iart)};

    end
    %Add the samples info to the trial numbers.
    %artifactTrl(:,3:4) = cfgart.artfctdef.zvalue.artifact;
    if length(cfgart.artfctdef.zvalue.artifact)>0
      %Remove the blinks but inserting NaNs
      artfctdef.eog.artifact=zeros(size(cfgart.artfctdef.zvalue.artifact));
      artfctdef.eog.artifact=cfgart.artfctdef.zvalue.artifact;


      subplot(2,3,cnt); cnt = cnt + 1;
      %figure(1),clf
      plot(mean(avgBlinks,1))
      %plot(avgBlinks(:,:)')
      axis tight; axis square; box off;
      title('Blink rate 3')
    end
  end


end
