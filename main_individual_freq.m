
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main script for handling creation of individual plots per participant
%Created, 15/09/2017
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

part_available = 1:29;
remove_part = ones(1,length(part_available));
remove_part(1)=0; % Only one reponse
remove_part(8)=0;
remove_part(11)=0;
remove_part(16)=0;
part_available(logical(~remove_part))=[];

%loop over part_ID, plot ... profit???
for part_idx = 1:length(part_available)
  disp(part_idx)
  [freq,switchTrial,stableTrial]=freq_average_individual(part_available(part_idx));
  plot_average_individual(part_available(part_idx),freq,switchTrial,stableTrial);

end

%%

%Look at the mean modulation of switch vs no switch.

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/average')

datainfosLow = dir('*low*.mat');

datainfosAll = dir('*.mat');

datainfoHigh = datainfosAll(~ismember({datainfosAll.name},{datainfosLow.name}));

datainfos=datainfosLow;

%Just to get the freq info stored in all structs.
load(datainfos(1).name)

%average modulation for switch vs no switch.
avg_freq_svsn=zeros(length(datainfos),274,length(freq.freq),101);
avg_freq_switch=zeros(length(datainfos),274,length(freq.freq),101);
avg_freq_stable=zeros(length(datainfos),274,length(freq.freq),101);

for idata = 1:length(datainfos)
  disp(datainfos(idata).name)

  load(datainfos(idata).name)

  %average modulation for switch vs no switch.
  avg_freq_svsn(idata,:,:,:) = freq.powspctrm;
  avg_freq_switch(idata,:,:,:)=switchTrial;
  avg_freq_stable(idata,:,:,:)=stableTrial;

end
avg_freq_svsn=squeeze(nanmean(avg_freq_svsn,1));
avg_freq_switch=squeeze(nanmean(avg_freq_switch,1));
avg_freq_stable=squeeze(nanmean(avg_freq_stable,1));

%Insert the freq data averaged over participants.
freq.powspctrm=avg_freq_stable;


idx_occ=strfind(freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));
figure(1),clf
cfg=[];
cfg.zlim         = [-5 5];
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
%cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='Switch vs Stable';
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(flipud(brewermap(64,'RdBu')))


%Save figure active.
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim2_Stable_3-15HzAverage-2s_TOPO');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,figurefreqname,'png')


%plot the topoplot
figure(2),clf
cfg=[];
cfg.zlim         = [-8 8];
cfg.ylim         = [3 15];
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [-2 -1.7];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
%cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='Stable';
%ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(flipud(brewermap(64,'RdBu')))


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim2_NoswitchTrial_lowAverage_TOPO');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,figurefreqname,'png')

%create a tmap...

%Create tmaps. If across dim 1, testing sig across channels
%between switch and no switch averages.
[h,p]=ttest2(avg_freq_switch(idx_occ,:,9:93),...
avg_freq_stable(idx_occ,:,9:93),'Dim',1);
hf=figure(1),clf
colormap(cbrewer('seq', 'YlOrBr', 200))
set(hf, 'Position', [0 0 500 500])
imagesc(squeeze(p))
%change the x values displayed
xticklabels = freq.time(9:21:93);
xticks = linspace(1, find(freq.time==xticklabels(end)),numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
%change the y values displayed
yticklabels = freq.freq(3:10:end);
yticks = linspace(3,find(freq.freq==yticklabels(end)),numel(freq.freq(3:10:end)));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels)
set(gca,'YDir','normal')
caxis([0 0.1])
colorbar
title('P values for ttest2')


%Save figure active.
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim2_SwitchvsNoSwitch_lowfreq_TMAP2');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,figurefreqname,'png')
