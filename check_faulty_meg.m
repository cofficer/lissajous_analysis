function check_faulty_MEG(~)
%This function provides an overivew of all available data of a given
%Participant.





%part 8.
dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/',cfgin.restingfile(2:3));
cd(dsfile)

%Identify datasets, and load correct block.
datasets = dir('*ds');
cd(dsfile)

iblock=2;
datafile=datasets(iblock).name;

%Load data into trial-based format.
cfg                         = [];
cfg.dataset                 = datafile;
cfg.trialfun                = 'trialfun_lissajous_CONT';; % this is the default
cfg.trialdef.eventtype      = 'UPPT001';
cfg.trialdef.eventvalue     = 10; % self-occlusion trigger value
%TODO: save preprocessed data occuring before the stimulus onset.
%Stim or selfocclusion is preprocessed

if ~strcmp(cfgin.blocktype,'continuous')
  if strcmp(cfgin.stim_self,'stim')
    cfg.trialdef.prestim        = -4.5; % -2in seconds
    cfg.trialdef.poststim       = 13; % 1in seconds
  elseif strcmp(cfgin.stim_self,'baseline')
    cfg.trialdef.prestim        = -4.3; %200ms bf stimoff. Negative means after self-occlusion
    cfg.trialdef.poststim       = 5.3;  %800ms after stimoff.
  else
    cfg.trialdef.prestim        = cfgin.prestim%1;%5.5; % 2.25in seconds
    cfg.trialdef.poststim       = cfgin.poststim%7;%5; % 4.25in seconds
  end
else
  cfg.trialdef.prestim          = 2.25
  cfg.trialdef.poststim         = 2.25
end


%Stores all the trial information
cfg = ft_definetrial(cfg);

%Participant8 block 2, is completely fine.

event = ft_read_event(datafile);%'headerformat',[],'eventformat',[],'dataformat',[]












end
