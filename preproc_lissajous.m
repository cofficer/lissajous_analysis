
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preprocessing trl-based data - Lissajous project%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = preproc_lissajous(cfgin)
%The key here is to use the already defined tables for samples when calling
%trialfun function which I should define next.

%define ds file, this is actually from the trial-based data
dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/%s/',cfgin.restingfile);
cd(dsfile)

%Identify datasets, and load correct block.
datasets = dir('*ds');


if cfgin.blocktype == 'trial'
  dsfile=datasets(1).name;
elseif cfgin.blocktype == 'trial'
  %Choosing the second dataset is arbitrary.
  dsfile=datasets(2).name;
end

%Load data into trial-based format.
cfg                         = [];
cfg.dataset                 = dsfile;
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'UPPT001';
cfg.trialdef.eventvalue     = 10; % self-occlusion trigger value
cfg.trialdef.prestim        = 2.25; % in seconds
cfg.trialdef.poststim       = 2.25; % in seconds
cfg = ft_definetrial(cfg);
cfg.channel    ={'all'};
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);


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

%%
%Highpass filter to get rid of all frequencies below 2Hz
cfg          = [];
cfg.hpfilter = 'yes';
cfg.channel  = {'MEG'};
cfg.hpfreq   = 2;
data         = ft_preprocessing(cfg,data);

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

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos/resting/preprocessed')

%%


% compute head rotation wrt first trial
cc_rel = computeHeadRotation(data);
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

%Identify blinks... succumed to a for loop...
for itrials = 1:length(dataNoMEG.trial)

    dataNoMEG.trial{itrials}(idx_blink,:) = abs(dataNoMEG.trial{itrials}(idx_blink,:));

end

%plot one eyelink trial to check for weird filter artifacts.
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/')
figure(1),clf
plot(dataNoMEG.trial{200}(idx_blink,:))
saveas(gca,'testing.png','png')

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

% reject blinks when they occur between ref and the offset of the stim
%crittoilim = [data.trialinfo(:,2) - data.trialinfo(:,1) - 0.4*data.fsample ...
%    data.trialinfo(:,5) - data.trialinfo(:,1) + 0.8*data.fsample] / data.fsample;
%cfg.artfctdef.crittoilim        = crittoilim;
%data                            = ft_rejectartifact(cfg, data);

%plot the blink rate horizontal??
cfg=[];
cfg.channel = 'UADC003'; %UADC003 UADC004 if eyelink is present
blinks = ft_selectdata(cfg,dataNoMEG);

%Could reduce blinks data to only trials with blinks.
%Identify blinks... succumed to a for loop...
for iart = 1:length(cfgart.artfctdef.zvalue.artifact)

    %Compare the samples identified by the artifact detection and the
    %samples of each trial to identify the trial with artifact.

    artifactTrl(iart) = floor(cfgart.artfctdef.zvalue.artifact(iart,1)/2250);

    %There should be some kind of modulus to use here to find in which interval of 2250
    %the artifact sample is contained within
    avgBlinks(iart,:) = blinks.trial{artifactTrl(iart)};

end

subplot(2,3,cnt); cnt = cnt + 1;

figure(1),clf
%plot(mean(avgBlinks,1))
plot((avgBlinks(10,:)))
axis tight; axis square; box off;
title('Blink rate 3')
saveas(gca,'testing.png','png')
%%
% ==================================================================
% 4. REMOVE TRIALS WITH JUMPS
% Compute the power spectrum of all trials and a linear line on the loglog-
% transformed power spectrum. Jumps cause broad range increase in the power
% spectrum so trials containing jumps can be selected by detecting outliers
% in the intercepts of the fitted lines (using Grubb?s test for outliers).
% ==================================================================

%call function which calculates all jumps
channelJump=findSquidJumps(data,dsfile(61:63));
artifact_Jump = channelJump;
subplot(2,3,cnt); cnt = cnt + 1;

%If there are jumps, plot them.
if ~isempty(channelJump)
  %subplot...
  for ijump = 1:length(channelJump)
    plot(data.trial{1}( ismember(data.label,channelJump{ijump}),:))
    hold on
  end
else
  title('No jumps')
end

% if ~isempty(idx_jump)

  % for iout = 1:length(idx_jump)

    %I belive that y is trial and x is channel.
    % [y,x] = ind2sub(size(intercept),idx_jump(iout)) ;

    %Store the name of the channel
    % channelJump{iout} = freq.label(x);

    %Plot each channel containing a jump.
    % plot(data.trial{1}( ismember(data.label,channelJump{iout}),:))
    % hold on

  % end
  % axis tight; axis square; box off;
  %set(gca, 'xtick', [10 50 100], 'tickdir', 'out', 'xticklabel', []);
  % title(sprintf('Jumps found'));
% else
  % title(sprintf('No jumps'));
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
cfg.artfctdef.reject             = 'partial';
cfg.artfctdef.muscle.artifact    = artifact_Muscle;

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
sampleinfo = data.sampleinfo
[ data ] = delete_artifact_Numbers(artifact_Muscle, data, sampleinfo);

%%
%Change folder and save approapriate data + figures
lisdir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/';
cd(lisdir)
name = sprintf('%sP%s/',lisdir,dsfile(62:63));

%If the folder does not already exist, create it.
if 7==exist(name,'dir')
  cd(name)
else
  mkdir(name)
  cd(name)
end

filestore=sprintf('preproc%s.mat',dsfile(end-8:end-4));
save(filestore,'data')

%Save the artifacts
artstore=sprintf('artifacts%s.mat',dsfile(end-8:end-4));

save(artstore,'artifact_eogVertical','artifact_eogHorizontal','artifact_Muscle','artifact_Jump') %Jumpos?

%save the invisible figure
figurestore=sprintf('Overview%s.png',dsfile(end-8:end-4));
saveas(gca,figurestore,'png')

end
