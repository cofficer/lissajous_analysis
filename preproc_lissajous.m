
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preprocessing trl-based data - Lissajous project%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = preproc_lissajous(cfgin)
  %The key here is to use the already defined tables for samples when calling
  %trialfun function which I should define next.

  %Inclose the whole function to catch potential error.
  try
    %define ds file, this is actually from the trial-based data
    dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/',cfgin.restingfile(2:3));
    cd(dsfile)

    %Identify datasets, and load correct block.
    datasets = dir('*ds');

    %TODO: Define how to loop over blocks.
    if strcmp(cfgin.blocktype,'trial')
      %dsfile=datasets(1).name;
      nblocks=1;
      startblock=1;
      %if continuous then there will be several datasets to analyze
      if strcmp(cfgin.stim_self,'cue')
        trldef = 'trialfun_lissajous_TRIAL_cue';
      elseif strcmp(cfgin.stim_self,'self')
        trldef = 'trialfun_lissajous_TRIAL_self';
      elseif strcmp(cfgin.stim_self,'stimoff')
        trldef = 'trialfun_lissajous_TRIAL_stimoff';
      else
        trldef = 'trialfun_lissajous';
      end

    elseif strcmp(cfgin.blocktype,'continuous')
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
          cfg.trialdef.prestim          = 2
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
      cfg.channel = {'M*','UADC001',...
      'UADC002','UADC003',...
      'UADC004','EEG058','EEG059',...
      'HLC0011','HLC0012','HLC0013', ...
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

      %Get all data except for the MEG.
      cfg          = [];
      cfg.channel  = {'all','-MEG'};
      dataNoMEG    = ft_selectdata(cfg,data);


      % plot a quick power spectrum
      % save those cfgs for later plotting
      cfgfreq             = [];
      cfgfreq.method      = 'mtmfft';
      cfgfreq.output      = 'pow';
      cfgfreq.taper       = 'hanning';
      cfgfreq.channel     = 'MEG';
      cfgfreq.foi         = 1:130;
      % cfgfreq.fsample     = 800;
      cfgfreq.keeptrials  = 'no';
      freq                = ft_freqanalysis(cfgfreq, data); %Should only be done on MEG channels.

      %plot those data and save for visual inspection
      figure('vis','off'),clf
      cnt                   = 1;
      subplot(2,3,cnt); cnt = cnt + 1;

      loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on;
      loglog(freq.freq, mean(freq.powspctrm), 'k', 'linewidth', 1);
      axis tight; axis square; box off;
      set(gca, 'xtick', [10 50 100], 'tickdir', 'out', 'xticklabel', []);

      % compute head rotation wrt first trial
      cc_rel = computeHeadRotation(dataNoMEG);
      % plot the rotation of the head
      subplot(2,3,cnt); cnt = cnt + 1;
      plot(cc_rel); ylabel('HeadM');
      axis tight; box off;

      %%
      % ==================================================================
      % 4. REMOVE TRIALS WITH JUMPS
      % Compute the power spectrum of all trials and a linear line on the loglog-
      % transformed power spectrum. Jumps cause broad range increase in the power
      % spectrum so trials containing jumps can be selected by detecting outliers
      % in the intercepts of the fitted lines (using Grubb?s test for outliers).
      % ==================================================================

      %call function which calculates all jumps. Instead of only the channel I also need the
      %trial...
      [channelJump,trialnum]=findSquidJumpsLissajous(data,datafile(1:3));
      artifact_Jump = channelJump;
      subplot(2,3,cnt); cnt = cnt + 1;

      %If there are jumps, plot them.
      if ~isempty(channelJump)
        %subplot...
        for ijump = 1:length(channelJump)
          plot(data.trial{trialnum(ijump)}( ismember(data.label,channelJump{ijump}),:))
          hold on
        end

        %Remove trials with jumps
        idx_jump   = unique(trialnum);
        cfg        = [];
        idx_trials = ones(1,length(data.trial));
        idx_trials(idx_jump) = 0;
        cfg.trials = find(idx_trials');
        data       = ft_selectdata(cfg,data);
      else
        idx_jump=[];
        title('No jumps')
      end

      % ==================================================================
      % 5. REMOVE DATA WITH EYE ARTIFACTS.
      % ==================================================================
      % if ~strcmp(cfgin.blocktype,'continuous')
      %   blinkchannel = 'UADC003';%EEG058	+        blinkchannel = 'UADC003';%EEG058
      %   [data,cnt]=preproc_eye_artifact(data,cnt,blinkchannel);	+        [data,cnt]=preproc_eye_artifact(data,cnt,blinkchannel);
      %   blinkchannel = 'EEG058';%EEG058	+        %
      %   [data,cnt]=preproc_eye_artifact(data,cnt,blinkchannel);	+        % [data,cnt]=preproc_eye_artifact(data,cnt,blinkchannel);
      % end

      %%
      % ==================================================================
      % 5. REMOVE LINE NOISE
      % ==================================================================

      cfg             = [];
      cfg.bsfilter    = 'yes';
      cfg.bsfreq      = [49 51; 99 101; 149 151];
      data            = ft_preprocessing(cfg, data);


      % ==================================================================
      % 7. REMOVE TRIALS WITH MUSCLE BURSTS BEFORE RESPONSE
      % Remove muscle using the same z-value-based approach as for the eye
      % channels. Filter the data between 110-140 Hz and use a z-value threshold of 10.
      % ==================================================================

      cfg                              = [];
      cfg.continuous                   = 'yes'; % data has been epoched

      % channel selection, cutoff and padding
      cfg.artfctdef.zvalue.channel     = {'MEG'}; % make sure there are no NaNs
      cfg.artfctdef.zvalue.trlpadding  = 0;
      cfg.artfctdef.zvalue.fltpadding  = 0; % 0.2; - this crashes ft_artifact_zvalue!
      cfg.artfctdef.zvalue.artpadding  = 0.1;
      cfg.artfctdef.zvalue.interactive = 'no';

      % algorithmic parameters
      cfg.artfctdef.zvalue.bpfilter    = 'yes';
      cfg.artfctdef.zvalue.bpfreq      = [110 140];
      cfg.artfctdef.zvalue.bpfiltord   = 9;
      cfg.artfctdef.zvalue.bpfilttype  = 'but';
      cfg.artfctdef.zvalue.hilbert     = 'yes';
      cfg.artfctdef.zvalue.boxcar      = 0.2;

      % set cutoff
      cfg.artfctdef.zvalue.cutoff      = 30;
      [~, artifact_Muscle]             = ft_artifact_zvalue(cfg, data);

      cfg                              = [];
      cfg.artfctdef.reject             = 'complete'; %But identify where.
      % 102/103 718826, compare artifact_Muscle samples against the sampleinfo...
      cfg.artfctdef.muscle.artifact    = artifact_Muscle;
      data2                             = ft_rejectartifact(cfg,data);

      % % plot final power spectrum
      freq            = ft_freqanalysis(cfgfreq, data);
      subplot(2,3,cnt);
      %loglog(freq.freq, freq.powspctrm, 'linewidth', 0.5); hold on;
      loglog(freq.freq, (freq.powspctrm), 'k', 'linewidth', 0.1);
      axis tight; axis square; box off; %ylim(ylims);
      set(gca, 'xtick', [10 50 100], 'tickdir', 'out');

      %Highpass filter to get rid of all frequencies below 2Hz
      cfg          = [];
      cfg.hpfilter = 'yes';
      cfg.channel  = {'MEG'};
      cfg.hpfreq   = 2;
      data         = ft_preprocessing(cfg,data);

      %%
      %Change folder and save approapriate data + figures
      lisdir = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/preprocessed/',cfgin.blocktype);
      cd(lisdir)
      name = sprintf('%sP%s/%s/',lisdir,datafile(2:3),cfgin.stim_self);

      %If the folder does not already exist, create it.
      if 7==exist(name,'dir')
        cd(name)
      else
        mkdir(name)
        cd(name)
      end

      filestore=sprintf('preproc_%s_P%s_block%d.mat',cfgin.stim_self,datafile(2:3),iblock);
      save(filestore,'data','-v7.3')

      filestore=sprintf('preproc_noMEG_%s_P%s_block%d.mat',cfgin.stim_self,datafile(2:3),iblock);
      save(filestore,'dataNoMEG','-v7.3')



      %Save the artifacts
      artstore=sprintf('artifacts_%s_P%s_block%d.mat',cfgin.stim_self,datafile(2:3),iblock);
      save(artstore,'artifact_Jump','idx_jump','artifact_Muscle') %Jumpos?

      %save the invisible figure
      figurestore=sprintf('Overview_%s_P%s_block%d.png',cfgin.stim_self,datafile(2:3),iblock);
      saveas(gca,figurestore,'png')


    end


  catch err

    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/')
    fid=fopen('preprocErrors','a+');
    c=clock;
    fprintf(fid,sprintf('\n\n\n\nNew entry for %s at %i/%i/%i %i:%i\n',cfgin.restingfile,fix(c(1)),fix(c(2)),fix(c(3)),fix(c(4)),fix(c(5))))

    fprintf(fid,'%s',err.getReport('extended','hyperlinks','off'))

    fclose(fid)


  end

end
