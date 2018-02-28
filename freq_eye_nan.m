function freq_eye_nan(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%First high-pass filter frequency data.
%Second, insert nan values in freq where blinks.
%Third, nanmean the data.
%Created 2018-02-16.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%freq path
cd(sprintf('%s%s/freq/%s/',cfgin.fullpath(1:56),cfgin.blocktype,cfgin.stim_self))
load('28freq_low_selfocclBlock2-26-26.mat')

%preproc path
cd(sprintf('%s%s/preprocessed/P28/%s/',cfgin.fullpath(1:56),cfgin.blocktype,cfgin.stim_self))
load('preproc_noMEG_self_P28_block2.mat')

%Procedures:
%1. Identify blinks and insert nans in freq data.
%2. Highpass filter the freq data.
%3. Nanmean freq data into averages. No baseline

%The only way to highpass might be to do so continuously...
t_start = 1;
t_stop  = 95;
for itrl = 1:size(freq.powspctrm,1)

  freq_concat(:,:,t_start:t_stop) = squeeze(freq.powspctrm(itrl,:,:,:));
  % time_concat(1,appropriate time indices) = data.time{itrl}(:);
  t_start = t_start+95;
  t_stop  = t_stop+95;
end

cfg =[];
cfg.avgoverrpt = 'yes';
freq = ft_selectdata(cfg,freq);

freq.powspctrm = freq_concat;
freq.time      = -2.35:0.05:1242.1;%num  size(freq_concat) 24890

%Highpass using FIR-method.
cfg = [];
cfg.fsample  = 20;
cfg.hpfreq     = 0.2;
cfg.type     = 'fir';
cfg.hpfilter ='yes';
freq2 = ft_preprocessing(cfg,freq);

%What is the ideal solution to get rid eye blinks and keep the data continuous?
%I will attempt to keep the data in trials and just assume 2.25s +/- is fine.

%redefine the preprocessed data to start and end at the freq.
cfg = [];
cfg.toilim = [-2.35 2.35];
dataNoMEG = ft_redefinetrial(cfg,dataNoMEG)

%Remove trials that are not present in the freq data.
cfg = [];
cfg.trials = zeros(1,length(dataNoMEG.time));
cfg.trials(freq.trialinfo(:,6))=1;
cfg.trials=logical(cfg.trials);
dataNoMEG = ft_selectdata(cfg,dataNoMEG);

%Eye artifact detection.
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
cfg.artfctdef.zvalue.cutoff     = 1; % to detect all blinks, be strict
% cfg.artfctdef.zvalue.interactive = 'yes';
% I think I need the downsampled samplinfo which is not present currently.
[~, artifact_eog]               = ft_artifact_zvalue(cfg, dataNoMEG); %816272

%in artifact_eog trials are appended. So samples = sample_trial * num_trials
%would like the output in the form of which trial and time-window is contaminated by blinks.
%I should first extend the blink time window by +/- half time-window, which is freq dependant.
%but 250ms (500/4 samples) for low.

start_blink = artifact_eog(:,1)-125;
end_blink   = artifact_eog(:,2)+125;


freq_nan = freq.powspctrm;

%predefine variables
sample_from_start   = zeros(1,length(start_blink));
sample_from_stop    = zeros(1,length(start_blink));
num_bins_start      = zeros(1,length(start_blink));
num_bins_stop       = zeros(1,length(start_blink));


%I need to figure out which time-bins are affected in which trials.
%Perhaps a for-look for mod(3001) would work
for iblinks = 1:length(start_blink)
  %find trial of the blink.
  %insert nan at the time-freq been affected.
  trl=floor(start_blink(iblinks)/length(dataNoMEG.time{1}));
  %How do find the affect tbins?
  %How many samples in each tbin? 25. 1 sample = 0.002s. 1 bin = 0.05.
  sample_from_start(iblinks)       = mod(start_blink(iblinks),length(dataNoMEG.time{1}));
  sample_from_stop(iblinks)        = mod(end_blink(iblinks),length(dataNoMEG.time{1}));
  num_bins_start(iblinks)          = floor(sample_from_start(iblinks)/length(dataNoMEG.time{1}));
  num_bins_stop(iblinks)           = ceil(sample_from_stop(iblinks)/length(dataNoMEG.time{1}));
  %the num_bins_start, until num_bins_stop
  if num_bins_start(iblinks)<1;num_bins_start(iblinks)=1;end

  freq_nan(trl,:,:,num_bins_start(iblinks):num_bins_stop(iblinks))=NaN;

end

  %nanmean and save the averages.

  %Append data, by taking the average
  %Make the freq the trial average
  cfg =[];
  cfg.avgoverrpt = 'yes';
  freq = ft_selectdata(cfg,freq);


  %substitute powspctrm with nanned data.
  freq.powspctrm=squeeze(nanmean(freq_nan,1));

  %Save the freq in new folder
  d_average = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/%s/',cfgin.blocktype,cfgin.stim_self);
  cd(d_average)
  freqtosave = sprintf('freqavgs_all_%s_%d',cfgin.freqrange,cfgin.part_ID);
  save(freqtosave,'freq')

end
