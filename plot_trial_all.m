function plot_trial_all(~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and plot across interests
%Created 22/11/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%Load and average all averaged high data.
clear all

blocktype = 'continuous' %continuous or trial
stim_self = ''; %'' or resp.
cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/self',blocktype))


freqfiles= dir('freqavgs*low*');
load(freqfiles(1).name)


%Create matrix for all participants.
dims = size(freq.powspctrm);
all_freq = zeros(29,dims(1),dims(2),dims(3));

%Load all participants
for ifiles = 1:length(freqfiles)
  disp((freqfiles(ifiles).name))
  load(freqfiles(ifiles).name)
  all_freq(ifiles,:,:,:) = freq.powspctrm;

end


%remove part3

freq.powspctrm=squeeze(nanmean(all_freq,1));

%Load the sensors of interest
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-01-05_visual_sensors.mat')

%plot the TFR
%TODO: find the IDX of all motor sensors, and use those to plot TFR.
idx_occ=strfind(freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));
idx_lissajous = visual_sensors;
idx_motor = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
            'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
            'MRF54','MRF55','MRF56','MRF66','MRF46'...
            'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
            'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
            'MLF54','MLF55','MLF56','MLF66','MLF46'};

hf=figure(1),clf
ax2=subplot(1,1,1)
% freq.powspctrm = switchTrial;
cfg=[];
cfg.zlim         = [-15 15];
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
% cfg.xlim         = %[-0.25 0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
cfg.channel      = idx_motor;%freq.label(idx_occ);%idx_motor';%
cfg.interactive = 'no';
cfg.title='Motor sensors only';
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax2,flipud(brewermap(64,'RdBu')))


cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures'))
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim7_lowfreq_-235-2355s_continuous_selfo-locked_motor-sensors');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')

%plot the TOPO
for ipartn =1:29
%Loop over each participant test
hf=figure(1),clf
ax2=subplot(1,1,1)
% freq.powspctrm = switchTrial;
cfg=[];
cfg.zlim         = [-50 50];
% cfg.ylim         = [60 90];%7 12
cfg.ylim         = [15 25];
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [-1.2 -0.8];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='TOPO low freq';
cfg.colorbar           = 'yes'
% ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
% freq.powspctrm=squeeze(all_freq(ipartn,:,:,:));
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax2,flipud(brewermap(64,'RdBu')))

cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures'))
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim7_15-25Hz_continuous_TOPO_-12-08s-cue_-235-185sbaseline');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')
end

%%
%Define index for time lengths
if strcmp(cfgin.blocktype,'trial')
  start_idx = 1;
  end_idx   = length(freq.time)
else
  start_idx = 9;
  end_idx   = 93;
end
%%
%Plot and save
idx_occ=strfind(freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));

hf=figure(1),clf
ax1=subplot(2,2,1)
cfg=[];
cfg.zlim         = [-10 10];
cfg.ylim         = [60 100];
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [-0.75 -0.5];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='all';
% ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax1,flipud(brewermap(64,'RdBu')))

ax1=subplot(2,2,2)
cfg=[];
cfg.zlim         = [-10 10];
cfg.ylim         = [60 100];
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [-0.5 -0.15];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='all';
% ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax1,flipud(brewermap(64,'RdBu')))
%
%

ax1=subplot(2,2,3)
cfg=[];
cfg.zlim         = [-10 10];
cfg.ylim         = [60 100];
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [-0.15 0.15];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='all';
% ft_singleplotTFR(cfg,freq);
% ft_multiplotTFR(cfg,freq);
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax1,flipud(brewermap(64,'RdBu')))

ax1=subplot(2,2,4)
cfg=[];
cfg.zlim         = [-10 10];
cfg.ylim         = [60 100];
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [0.15 0.5];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='all';
% ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax1,flipud(brewermap(64,'RdBu')))

cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',cfgin.blocktype))
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim6_%sRealfreq_all_%d_TOPO',cfgin.freqrange,cfgin.part_ID);%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')

end
