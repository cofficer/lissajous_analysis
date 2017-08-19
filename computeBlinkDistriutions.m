function [ all_art_tp ] = computeBlinkDistriutions( numP )
%Calulate the distribution of all the blinks in relation to the
%self-occlusions. 

%Inititate the end result 
all_art_tp=[];



%numP=11;

for inumP = 20:29
if inumP<10
cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P0%i',inumP))
else
    cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%i',inumP))
end
%The first data set is for trialbased in this condition. 
%Take the script from trialfun. Create a trialdefinition. 
%Pre-selfocclusion + button press. 

ds_files = dir('*.ds');
for inames=2:length(ds_files)
    name     =  ds_files(inames).name;
    
    
dsfile = name;

cfg                         = [];
cfg.dataset                 = dsfile;
cfg.trialfun                = 'ft_trialfun_general'; % this is the default
cfg.trialdef.eventtype      = 'UPPT001';
cfg.trialdef.eventvalue     = 10; % the value of the stimulus trigger for fully incongruent (FIC).
cfg.trialdef.prestim        = 2.25; % in seconds
cfg.trialdef.poststim       = 2.25; % in seconds

cfg = ft_definetrial(cfg);


%Only take the preprocessing step for the 
cfg.channel    ={'UADC004'}; %{'MEG', 'EOG','EEG', 'HLC0011','HLC0012','HLC0013', ...
                 % 'HLC0021','HLC0022','HLC0023', ...
                 % 'HLC0031','HLC0032','HLC0033'};
cfg.continuous = 'yes';
data = ft_preprocessing(cfg);


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
 cfg.artfctdef.zvalue.interactive = 'no';
 cfg.artfctdef.zvalue.channel   = cfg.channel;
[cfgAll, artifact_eog]               = ft_artifact_zvalue(cfg, data);

cfg                             = [];
% cfg.artfctdef.reject            = 'complete';
cfg.artfctdef.eog.artifact      = artifact_eog;

%Compute the distance from self-occlusion the blink occured.

%Find the trial each artifact comes from.
for iartifact = 1:length(artifact_eog)

    %index of the trial where artifact is found.
    idx_trl_art = find(artifact_eog(iartifact,1)>cfgAll.previous.trl(:,1));
    
    idx_trl_art = idx_trl_art(end);
   
    %Calulate where the blink occured with respect to the self-occlusion.
    self_occl_sample = cfgAll.previous.trl(idx_trl_art,2)+cfgAll.previous.trl(idx_trl_art,3);

    artifact_timepoint(iartifact) = (self_occl_sample-artifact_eog(iartifact,1))/1200;

end

%append all the timepoints of all the continuous data.
all_art_tp = [all_art_tp,artifact_timepoint];
end
end

histogram(all_art_tp)

%%
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/figures')
saveas(gca,'part1-19blinkdist.png')


end

