function plot_trial_all(~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and plot across interests
%Created 22/11/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%Load and average all averaged high data.
clear all

blocktype = 'trial' %continuous or trial
stim_self = ''; %'' or resp.
cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average/self',blocktype))

%Define if looking at switch vs no switch
sw_vs_nsw = 0;

freqfiles= dir('*all_low*');
load(freqfiles(1).name)


%Create matrix for all participants.
dims = size(freq.powspctrm);
all_freq = zeros(29,dims(1),dims(2),dims(3));
if sw_vs_nsw
  all_sw = zeros(29,dims(1),dims(2),dims(3));
  all_nsw = zeros(29,dims(1),dims(2),dims(3));
end

%Load all participants
for ifiles = 1:length(freqfiles)
  disp((freqfiles(ifiles).name))
  load(freqfiles(ifiles).name)
  all_freq(ifiles,:,:,:) = freq.powspctrm;

  %also store all the switch and no switch trial averages.
  if sw_vs_nsw
    all_sw(ifiles,:,:,:) = switchTrial.powspctrm;
    all_nsw(ifiles,:,:,:) = stableTrial.powspctrm;
  end

end


%remove part3
%freq=

freq.powspctrm=squeeze(nanmean(all_freq,1));
%freq.powspctrm=(squeeze(nanmean(all_sw,1))+squeeze(nanmean(all_nsw,1)))./2;
%13 - 18, ab=squeeze(mean(freq.powspctrm(:,:,38:48),3)); ab=squeeze(mean(ab(:,13:28),2));
%idx_occ=find(ab<-2.05); idx_lissajous=freq.label(idx_occ);


if sw_vs_nsw
  freq.powspctrm=(squeeze(nanmean(all_sw,1))-squeeze(nanmean(all_nsw,1)));
  %all_freq=all_sw-all_nsw;
end

%Load the sensors of interest
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/2018-01-05_visual_sensors.mat')

%plot the TFR
%TODO: find the IDX of all motor sensors, and use those to plot TFR.
%idx_lissajous = freq.label(idx_occ);
idx_occ=strfind(freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));
idx_lissajous = visual_sensors;
idx_motor = {'MRC13','MRC14','MRC15','MRC16','MRC22','MRC23'...
            'MRC24','MRC31','MRC41','MRF64','MRF65','MRF63'...
            'MRF54','MRF55','MRF56','MRF66','MRF46'...
            'MLC13','MLC14','MLC15','MLC16','MLC22','MLC23'...
            'MLC24','MLC31','MLC41','MLF64','MLF65','MLF63'...
            'MLF54','MLF55','MLF56','MLF66','MLF46'};

% for ipartn =1:29

hf=figure(1),clf
ax2=subplot(1,1,1)
% freq.powspctrm = switchTrial;
cfg=[];
cfg.zlim         = [-10 10];
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
% cfg.xlim         = %[-0.25 0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
cfg.channel      = idx_lissajous;%freq.label(idx_occ);%idx_motor';%
cfg.interactive = 'no';
cfg.title='Visual sensors only';
%%%%%%%%%%%%%%%%%%%%%%%
%temporary loop
% freq.powspctrm=squeeze(all_freq(ipartn,:,:,:));
%%%%%%%%%%%%%%%%%%%%%%%
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax2,flipud(brewermap(64,'RdBu')))


cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',blocktype))
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim18_lowfreq_TRIAL_TFR_zlim10_preOnsetBaseline_1pars');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')
% end
%plot the TOPO
for ipartn =1:29
%Loop over each participant test
hf=figure(1),clf
ax2=subplot(1,1,1)
% freq.powspctrm = switchTrial;
cfg=[];
cfg.zlim         = [-3e-28 3e-28];
cfg.ylim         = [7 12];%7 12
% cfg.ylim         = [15 25];
cfg.layout       = 'CTF275_helmet.mat';
cfg.xlim         = [-0.5 -0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='TOPO freq freq';
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
namefigure = sprintf('prelim10_7-12Hzfreq_CONT_TOPO_t-05-0s');%Stage of analysis, frequencies, type plot, baselinewindow

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
