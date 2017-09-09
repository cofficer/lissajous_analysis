
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preprocessing trl-based data - Lissajous project%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = preproc_lissajous(cfgin)
%The key here is to use the already defined tables for samples when calling
%trialfun function which I should define next.

%Inclose the whole function to catch potential error.
try
    %define ds file, this is actually from the trial-based data
    dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/%s/',cfgin.restingfile);
    cd(dsfile)

    %Identify datasets, and load correct block.
    datasets = dir('*ds');

    %TODO: Define how to loop over blocks.
    if strcmp(cfgin.blocktype,'trial')
        %dsfile=datasets(1).name;
        nblocks=1;
        startblock=1;
        %if continuous then there will be several datasets to analyze.
        trldef = 'trialfun_lissajous';
    elseif strcmp(cfgin.blocktype,'continuous')
        %Choosing the second dataset is arbitrary.
        %dsfile=datasets(2).name;
        nblocks=4;
        startblock=2;
        trldef = 'trialfun_lissajous_CONT';
    end

    for iblock = startblock:nblocks
        cd(dsfile)
        datafile=datasets(iblock).name;
        %Load data into trial-based format.
        cfg                         = [];
        cfg.dataset                 = datafile;
        cfg.trialfun                = trldef; % this is the default
        cfg.trialdef.eventtype      = 'UPPT001';
        cfg.trialdef.eventvalue     = 10; % self-occlusion trigger value
        cfg.trialdef.prestim        = 2.6; % in seconds
        cfg.trialdef.poststim       = 2.6; % in seconds cfg.trl=cfg.trl(1:25,:)

        cfg = ft_definetrial(cfg);
        %while testing only do 25 trials

        cfg.channel    ={'all'};
        cfg.continuous = 'yes';
        data = ft_preprocessing(cfg);

        if strcmp(cfgin.blocktype,'trial')
            %select the data around the self-occlusions
            cfg              = [];
            begsample        = 1;
            endsample        = 4.5*1200;
            cfg.begsample = ones(1,length(data.trial))';
            cfg.endsample = ones(1,length(data.trial))'*endsample;

            data = ft_redefinetrial(cfg,data);
        end
        %Resample the data
        cfg3.resample = 'yes';
        cfg3.fsample = 1200;
        cfg3.resamplefs = 500;
        cfg3.detrend = 'no';

        data = ft_resampledata(cfg3,data);

        %Get all data except for the MEG.
        cfg          = [];
        cfg.channel  = {'all','-MEG'};
        dataNoMEG    = ft_selectdata(cfg,data);

        %Get all MEG.
        cfg          = [];
        cfg.channel  = {'MEG'};
        data    = ft_selectdata(cfg,data);
        %%

        %%
        % plot a quick power spectrum
        % save those cfgs for later plotting
        cfgfreq             = [];
        cfgfreq.method      = 'mtmfft';
        cfgfreq.output      = 'pow';
        cfgfreq.taper       = 'hanning';
        cfgfreq.channel     = 'MEG';
        cfgfreq.foi         = 1:130;
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


        %%


        % compute head rotation wrt first trial
        cc_rel = computeHeadRotation(dataNoMEG);
        % plot the rotation of the head
        subplot(2,3,cnt); cnt = cnt + 1;
        plot(cc_rel); ylabel('HeadM');
        axis tight; box off;

        % ==================================================================
        % 3. Identify blinks (only during beginning of trial)
        % Remove trials with (horizontal) saccades (EOGH). Use the same settings as
        % for the EOGV-based blinks detection. The z-threshold can be set a bit higher
        % (z = [4 6]). Reject all trials that contain saccades before going further.
        % ==================================================================

        %find pupil index.
        idx_blink = find(ismember(dataNoMEG.label,{'UADC003'})==1);

        %Take the absolute of the blinks to make identification easier with zscoring.
        for itrials = 1:length(dataNoMEG.trial)

            dataNoMEG.trial{itrials}(idx_blink,:) = abs(dataNoMEG.trial{itrials}(idx_blink,:));

        end

        cfg                              = [];
        cfg.continuous                   = 'yes'; % data has been epoched

        % channel selection, cutoff and padding
        cfg.artfctdef.zvalue.channel     = {'UADC003'}; %UADC003 UADC004s

        % 001, 006, 0012 and 0018 are the vertical and horizontal eog chans
        cfg.artfctdef.zvalue.trlpadding  = 0; % padding doesnt work for data thats already on disk
        cfg.artfctdef.zvalue.fltpadding  = 0; % 0.2; this crashes the artifact func!
        cfg.artfctdef.zvalue.artpadding  = 0.1; % go a bit to the sides of blinks

        % algorithmic parameters
        cfg.artfctdef.zvalue.bpfilter   = 'no';

        % set cutoff
        cfg.artfctdef.zvalue.cutoff     = 4;
        cfg.artfctdef.zvalue.interactive = 'no';
        [cfgart, artifact_eog]               = ft_artifact_zvalue(cfg, dataNoMEG);

        artifact_eogHorizontal = artifact_eog;

        cfg                             = [];
        cfg.artfctdef.reject            = 'partial';
        cfg.artfctdef.eog.artifact      = artifact_eogHorizontal;

        %plot the blink rate horizontal??
        cfg=[];
        cfg.channel = 'UADC003'; %UADC003 UADC004 if eyelink is present
        blinks = ft_selectdata(cfg,dataNoMEG);

        %Could reduce blinks data to only trials with blinks.
        %Identify blinks... could make us of: cfgart.artfctdef.zvalue.trl
        artifactTrl=zeros(size(cfgart.artfctdef.zvalue.artifact,2),size(cfgart.artfctdef.zvalue.artifact,1));
        for iart = 1:size(cfgart.artfctdef.zvalue.artifact,1)

            %Compare the samples identified by the artifact detection and the
            %samples of each trial to identify the trial with artifact.
            %TODO: Check this error which occurs for blocks = 4, Part = 21.

            %Why add one to the floor? Because there is no trl = 0.
            artifactTrl(iart,1) = floor(cfgart.artfctdef.zvalue.artifact(iart,1)/2251)+1;

            artifactTrl(iart,2) = floor(cfgart.artfctdef.zvalue.artifact(iart,2)/2251)+1;

            %There should be some kind of modulus to use here to find in which interval of 2250
            %the artifact sample is contained within
            avgBlinks(iart,:) = blinks.trial{artifactTrl(iart)};

        end

        %Add the samples info to the trial numbers.
        %artifactTrl(:,3:4) = cfgart.artfctdef.zvalue.artifact;
        %in case no eye artifacts
        if length(cfgart.artfctdef.zvalue.artifact)>0
            %Remove the blinks but inserting NaNs
            artfctdef.eog.artifact=zeros(size(cfgart.artfctdef.zvalue.artifact));
            artfctdef.eog.artifact=cfgart.artfctdef.zvalue.artifact;
            %data.sampleinfo = data.cfg.previous.previous.previous.trl(:,1:2);
            %data = insertNan(artfctdef,data);
            cfg          = [];
            removeTrials = unique([artifactTrl(:,1);artifactTrl(:,2)]);
            allTrials    = ones(1,length(data.trial));
            allTrials(removeTrials)    = 0;
            cfg.trials   = logical(allTrials');
            data         = ft_redefinetrial(cfg, data);

            subplot(2,3,cnt); cnt = cnt + 1;
            %figure(1),clf
            plot(mean(avgBlinks,1))
            %plot(avgBlinks(:,:)')
            axis tight; axis square; box off;
            title('Blink rate 3')
        end
        %reject trial with blinks

        %saveas(gca,'testing.png','png')
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
            title('No jumps')
        end


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
        cfg.artfctdef.reject             = 'complete';
        cfg.artfctdef.muscle.artifact    = artifact_Muscle;
        data                             = ft_rejectartifact(cfg,data);
        %
        % % plot final power spectrum
        freq            = ft_freqanalysis(cfgfreq, data);
        subplot(2,3,cnt);
        %loglog(freq.freq, freq.powspctrm, 'linewidth', 0.5); hold on;
        loglog(freq.freq, squeeze(mean(freq.powspctrm)), 'k', 'linewidth', 1);
        axis tight; axis square; box off; %ylim(ylims);
        set(gca, 'xtick', [10 50 100], 'tickdir', 'out');

        %%

        %Run a function which removes the artifacts we want. So far only muscle,
        %also needs to include jumps

        %Make sampleinfo 0 because then artifacts are no longer added by the
        %sampleinfo from before
        %sampleinfo=sampleinfo-sampleinfo;

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
        name = sprintf('%s%s/',lisdir,datafile(1:3));

        %If the folder does not already exist, create it.
        if 7==exist(name,'dir')
            cd(name)
        else
            mkdir(name)
            cd(name)
        end



        if strcmp(cfgin.blocktype,'trial')
            filestore=sprintf('preproc%s.mat',datafile(1:3));
            save(filestore,'data')

            %Save the artifacts
            artstore=sprintf('artifacts%s.mat',datafile(1:3));

            save(artstore,'artifact_eogHorizontal','artifact_Muscle') %Jumpos?

            %save the invisible figure
            figurestore=sprintf('Overview%s.png',datafile(1:3));
            saveas(gca,figurestore,'png')
            trldef = 'trialfun_lissajous';
        elseif strcmp(cfgin.blocktype,'continuous')
            filestore=sprintf('%dpreproc26-26%s.mat',iblock,datafile(1:3));
            save(filestore,'data')

            %Save the artifacts
            artstore=sprintf('%dartifacts%s.mat',iblock,datafile(1:3));

            save(artstore,'artifact_eogHorizontal','artifact_Muscle') %Jumpos?

            %save the invisible figure
            figurestore=sprintf('%doverview%s.png',iblock,datafile(1:3));
            saveas(gca,figurestore,'png')
        end

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
