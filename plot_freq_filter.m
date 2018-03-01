function out = plot_freq_filter(~)


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/filtered')

freqpath   = dir('*.mat');


  namecell = {freqpath.name};

  partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

  partnum = cellfun(@str2num,partnum,'UniformOutput',false);

  blocks_ID = find(ismember([partnum{:}],cfgin.part_ID));


%pre-store variables
all_switch = zeros(length(freqpath),274,38,91);
all_stable = zeros(length(freqpath),274,38,91);

for ipath = 1:length(freqpath)

  disp(ipath)
  load(freqpath(ipath).name)

  all_switch(ipath,:,:,:)  = switchTrial.powspctrm;
  all_stable(ipath,:,:,:)  = stableTrial.powspctrm;



end

%average over freq switch and stable
all_switch=squeeze(mean(all_switch(:,:,13:28,:),3));
all_stable=squeeze(mean(all_stable(:,:,13:28,:),3));

all_switch=squeeze(mean(all_switch(:,:,36:46),3));
all_stable=squeeze(mean(all_stable(:,:,36:46),3));

[H,P,CI,STATS]=ttest(all_switch,all_stable,'dim',1);


cfg =[];
cfg.avgoverfreq = 'yes';
freq = ft_selectdata(cfg,freq);

cfg =[];
cfg.avgovertime = 'yes';
freq = ft_selectdata(cfg,freq);


freq.powspctrm = STATS.tstat';

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

% for ipartn =1:29

hf=figure(1),clf
ax2=subplot(1,1,1)
% freq.powspctrm = switchTrial;
cfg=[];
cfg.zlim         = [-3 3];
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
% cfg.xlim         = %[-0.25 0];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = idx_lissajous;%freq.label(idx_occ);%idx_motor';%
cfg.interactive = 'no';
cfg.title='Visual sensors only';
%%%%%%%%%%%%%%%%%%%%%%%
%temporary loop
% freq.powspctrm=squeeze(all_freq(ipartn,:,:,:));
%%%%%%%%%%%%%%%%%%%%%%%
% ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax2,flipud(brewermap(64,'RdBu')))

blocktype='continuous';

cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',blocktype))
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim10_highfreq_cont_self-locked_filteredTOPO');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')


end
