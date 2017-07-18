
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Preprocessing trl-based data - Lissajous project%%%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

function data = preproc_lissajous
%The key here is to use the already defined tables for samples when calling
%trialfun function which I should define next. 
clear
%define ds file, this is actually from the trial-based data
dsfile = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P04/p04_lissajous_20170121_01.ds';

cfg                         = [];
cfg.dataset                 = dsfile;
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'UPPT001';
cfg.trialdef.eventvalue     = 10; % the value of the stimulus trigger for fully incongruent (FIC).
cfg.trialdef.prestim        = 2.25; % in seconds
cfg.trialdef.poststim       = 2.25; % in seconds

cfg = ft_definetrial(cfg);

%%
%run, epoching. 
cfg.channel    ={'all'}; %{'MEG', 'EOG','EEG', 'HLC0011','HLC0012','HLC0013', ...
                 % 'HLC0021','HLC0022','HLC0023', ...
                 % 'HLC0031','HLC0032','HLC0033'};
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);

%%
%From Anne, Donner git example

%Current subplot
cnt = 1;

% compute head rotation wrt first trial
cc_rel = computeHeadRotation(data);

% plot the rotation of the head
subplot(2,3,cnt); cnt = cnt + 1;
plot(cc_rel); ylabel('HeadM');
axis tight; box off;

% find outliers
[~, idx] = deleteoutliers(cc_rel);
[t,~]    = ind2sub(size(cc_rel),idx);

% only take those where the deviation is more than 6 mm
t = t(any(abs(cc_rel(t, :)) > 6, 2));

% show those on the plot
hold on;
for thist = 1:length(t),
    plot([t(thist) t(thist)], [max(get(gca, 'ylim')) max(get(gca, 'ylim'))], 'k.');
end

% remove those trials
cfg                     = [];
cfg.trials              = true(1, length(data.trial));
cfg.trials(unique(t))   = false; % remove these trials
data                    = ft_selectdata(cfg, data);
fprintf('removing %d excessive head motion trials \n', length(find(cfg.trials == 0)));

subplot(2,3,cnt); cnt = cnt + 1;
if isempty(t),
    title('No motion'); axis off;
else
    % show head motion without those removed
    cc_rel = computeHeadRotation(data);
    
    % plot the rotation of the head
    plot(cc_rel); ylabel('Motion resid');
    axis tight; box off;
end

% plot a quick power spectrum
% save those cfgs for later plotting
cfgfreq             = [];
cfgfreq.method      = 'mtmfft';
cfgfreq.output      = 'pow';
cfgfreq.taper       = 'hanning';
cfgfreq.channel     = 'MEG';
cfgfreq.foi         = 1:130;
cfgfreq.keeptrials  = 'no';
freq                = ft_freqanalysis(cfgfreq, data);

% plot those data and save for visual inspection
subplot(2,3,cnt); cnt = cnt + 1;
loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on;
loglog(freq.freq, mean(freq.powspctrm), 'k', 'linewidth', 1);
axis tight; axis square; box off;
set(gca, 'xtick', [10 50 100], 'tickdir', 'out', 'xticklabel', []);

% ==================================================================
% 2. REMOVE TRIALS WITH EYEBLINKS (only during beginning of trial)
% Bandpass filter the vertical EOG channel between 1-15 Hz and z-transform 
% this filtered time course. Select complete trials that exceed a threshold of  
% z =4 (alternatively you can set the z-threshold per data file or per subject 
% with the ?interactive? mode in ft_artifact_zvalue function). Reject trials 
% that contain blink artifacts before going on to the next step. For monitoring 
% purposes, plot the time courses of your trials before and after blink rejection.
% ==================================================================

cfg                              = [];
cfg.continuous                   = 'no'; % data has been epoched

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = {'UADC003'};

% 001, 006, 0012 and 0018 are the vertical and horizontal eog chans
cfg.artfctdef.zvalue.trlpadding  = 0; % avoid filter edge artefacts by setting to negative
cfg.artfctdef.zvalue.fltpadding  = 0;
cfg.artfctdef.zvalue.artpadding  = 0.05; % go a bit to the sides of blinks

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter   = 'yes';
cfg.artfctdef.zvalue.bpfilttype = 'but';
cfg.artfctdef.zvalue.bpfreq     = [1 15];
cfg.artfctdef.zvalue.bpfiltord  = 4;
cfg.artfctdef.zvalue.hilbert    = 'yes';

% set cutoff
cfg.artfctdef.zvalue.cutoff     = 2; % to detect all blinks, be strict
 cfg.artfctdef.zvalue.interactive = 'yes';
[~, artifact_eog]               = ft_artifact_zvalue(cfg, data);

cfg                             = [];
cfg.artfctdef.reject            = 'complete';
cfg.artfctdef.eog.artifact      = artifact_eog;

% reject blinks only when they occur between fix and stim offset
%crittoilim = [ data.trialinfo(:,2) - data.trialinfo(:,1) - 0.4*data.fsample ...
%    data.trialinfo(:,5) - data.trialinfo(:,1) + 0.8*data.fsample]  / data.fsample;
%cfg.artfctdef.crittoilim        = crittoilim;
data                            = ft_rejectartifact(cfg, data);

% ==================================================================
% 3. REMOVE TRIALS WITH SACCADES (only during beginning of trial)
% Remove trials with (horizontal) saccades (EOGH). Use the same settings as 
% for the EOGV-based blinks detection. The z-threshold can be set a bit higher 
% (z = [4 6]). Reject all trials that contain saccades before going further.
% ==================================================================

cfg                              = [];
cfg.continuous                   = 'no'; % data has been epoched

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = {'UADC004'};

% 001, 006, 0012 and 0018 are the vertical and horizontal eog chans
cfg.artfctdef.zvalue.trlpadding  = 0; % padding doesnt work for data thats already on disk
cfg.artfctdef.zvalue.fltpadding  = 0; % 0.2; this crashes the artifact func!
cfg.artfctdef.zvalue.artpadding  = 0.05; % go a bit to the sides of blinks

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter   = 'yes';
cfg.artfctdef.zvalue.bpfilttype = 'but';
cfg.artfctdef.zvalue.bpfreq     = [1 15];
cfg.artfctdef.zvalue.bpfiltord  = 4;
cfg.artfctdef.zvalue.hilbert    = 'yes';

% set cutoff
cfg.artfctdef.zvalue.cutoff     = 4;
 cfg.artfctdef.zvalue.interactive = 'yes';
[~, artifact_eog]               = ft_artifact_zvalue(cfg, data);

cfg                             = [];
% cfg.artfctdef.reject            = 'complete';
cfg.artfctdef.eog.artifact      = artifact_eog;

% reject blinks when they occur between ref and the offset of the stim
%crittoilim = [data.trialinfo(:,2) - data.trialinfo(:,1) - 0.4*data.fsample ...
%    data.trialinfo(:,5) - data.trialinfo(:,1) + 0.8*data.fsample] / data.fsample;
%cfg.artfctdef.crittoilim        = crittoilim;
data                            = ft_rejectartifact(cfg, data);

% ==================================================================
% 4. REMOVE TRIALS WITH JUMPS
% Compute the power spectrum of all trials and a linear line on the loglog-
% transformed power spectrum. Jumps cause broad range increase in the power 
% spectrum so trials containing jumps can be selected by detecting outliers 
% in the intercepts of the fitted lines (using Grubb?s test for outliers).
% ==================================================================

% detrend and demean
cfg             = [];
cfg.detrend     = 'yes';
cfg.demean      = 'yes';
data            = ft_preprocessing(cfg, data);

% get the fourier spectrum per trial and sensor
cfgfreq.keeptrials  = 'yes';
freq                = ft_freqanalysis(cfgfreq, data);

% compute the intercept of the loglog fourier spectrum on each trial
disp('searching for trials with squid jumps...');
intercept       = nan(size(freq.powspctrm, 1), size(freq.powspctrm, 2));
x = [ones(size(freq.freq))' log(freq.freq)'];

for t = 1:size(freq.powspctrm, 1),
    for c = 1:size(freq.powspctrm, 2),
        b = x\log(squeeze(freq.powspctrm(t,c,:)));
        intercept(t,c) = b(1);
    end
end

% detect jumps as outliers
[~, idx] = deleteoutliers(intercept(:));
subplot(2,3,cnt); cnt = cnt + 1;
if isempty(idx),
    fprintf('no squid jump trials found \n');
    title('No jumps'); axis off;
else
    fprintf('removing %d squid jump trials \n', length(unique(t)));
    [t,~] = ind2sub(size(intercept),idx);
    
    % remove those trials
    cfg                 = [];
    cfg.trials          = true(1, length(data.trial));
    cfg.trials(unique(t)) = false; % remove these trials
    data                = ft_selectdata(cfg, data);
    
    % plot the spectrum again
    cfgfreq.keeptrials = 'no';
    freq            = ft_freqanalysis(cfgfreq, data);
    loglog(freq.freq, freq.powspctrm, 'linewidth', 0.1); hold on;
    loglog(freq.freq, mean(freq.powspctrm), 'k', 'linewidth', 1);
    axis tight; axis square; box off;
    set(gca, 'xtick', [10 50 100], 'tickdir', 'out', 'xticklabel', []);
    title(sprintf('%d jumps removed', length(unique(t))));
end

% ==================================================================
% 5. REMOVE LINE NOISE
% ==================================================================

cfg             = [];
cfg.bsfilter    = 'yes';
cfg.bsfreq      = [49 51; 99 101; 149 151];
data            = ft_preprocessing(cfg, data);

% plot power spectrum
freq            = ft_freqanalysis(cfgfreq, data);
subplot(2,3,cnt); cnt = cnt + 1;
%loglog(freq.freq, freq.powspctrm, 'linewidth', 0.5); hold on;
loglog(freq.freq, (squeeze(mean(freq.powspctrm))), 'k', 'linewidth', 1);
axis tight;  axis square; box off;%ylim(ylims);
title('After bandstop');
set(gca, 'xtick', [10 50 100], 'tickdir', 'out', 'xticklabel', []);

% ==================================================================
% 6. REMOVE CARS BASED ON THRESHOLD
% Cars moving past the MEG lab cause big slow signal changes. Trials 
% containing these artifacts can be selected and removed by computing 
% the maximum range of the data for every trial. Trials with a larger 
% range than a threshold (standard = 0.75e-11) can be rejected (the standard 
% threshold might be low if you have long trials).
% ==================================================================
% 
% disp('Looking for CAR artifacts...');
% cfg = [];
% cfg.trials = true(1, length(data.trial));
% worstChanRange = nan(1, length(data.trial));
% for t = 1:length(data.trial),
%     % compute the range as the maximum of the peak-to-peak values within each channel
%     ptpval = max(data.trial{t}, [], 2) - min(data.trial{t}, [], 2);
%     % determine range and index of 'worst' channel
%     worstChanRange(t) = max(ptpval);
% end
% 
% % default range for peak-to-peak
% artfctdef.range           = 0.75e-11;
% 
% % decide whether to reject this trial
% cfg.trials = (worstChanRange < artfctdef.range);
% fprintf('removing %d CAR trials \n', length(find(cfg.trials == 0)));
% data = ft_selectdata(cfg, data);

% ==================================================================
% 7. REMOVE TRIALS WITH MUSCLE BURSTS BEFORE RESPONSE
% Remove muscle using the same z-value-based approach as for the eye 
% channels. Filter the data between 110-140 Hz and use a z-value threshold of 10.
% ==================================================================

cfg                              = [];
cfg.continuous                   = 'no'; % data has been epoched

% channel selection, cutoff and padding
cfg.artfctdef.zvalue.channel     = {'MEG'}; % make sure there are no NaNs
cfg.artfctdef.zvalue.trlpadding  = 0;
cfg.artfctdef.zvalue.fltpadding  = 0; % 0.2; - this crashes ft_artifact_zvalue!
cfg.artfctdef.zvalue.artpadding  = 0.1;

% algorithmic parameters
cfg.artfctdef.zvalue.bpfilter    = 'yes';
cfg.artfctdef.zvalue.bpfreq      = [110 140];
cfg.artfctdef.zvalue.bpfiltord   = 9;
cfg.artfctdef.zvalue.bpfilttype  = 'but';
cfg.artfctdef.zvalue.hilbert     = 'yes';
cfg.artfctdef.zvalue.boxcar      = 0.2;

% set cutoff
cfg.artfctdef.zvalue.cutoff      = 20;
[~, artifact_muscle]             = ft_artifact_zvalue(cfg, data);

cfg                              = [];
cfg.artfctdef.reject             = 'complete';
cfg.artfctdef.muscle.artifact    = artifact_muscle;

% only remove muscle bursts before the response
%crittoilim = [data.trialinfo(:,1) - data.trialinfo(:,1) ...
%    data.trialinfo(:,9) - data.trialinfo(:,1)]  ./ data.fsample;
%cfg.artfctdef.crittoilim        = crittoilim;
data                            = ft_rejectartifact(cfg, data);

% plot final power spectrum
freq            = ft_freqanalysis(cfgfreq, data);
subplot(2,3,cnt); 
%loglog(freq.freq, freq.powspctrm, 'linewidth', 0.5); hold on;
loglog(freq.freq, squeeze(mean(freq.powspctrm)), 'k', 'linewidth', 1);
axis tight; axis square; box off; %ylim(ylims);
set(gca, 'xtick', [10 50 100], 'tickdir', 'out');

%%
%Finally resample the data
cfg3.resample = 'yes';
cfg3.fsample = 1200;
cfg3.resamplefs = 400;
cfg3.detrend = 'no';

data = ft_resampledata(cfg3,data);

%%
%save figure of the resulting preprocessing
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/figures')
saveas(gca,'preprocess04trial.png')

end

