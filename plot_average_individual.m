function plot_average_individual(cfgin,freq,switchTrial,stableTrial)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and plot across interests
%Created 16/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


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
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
%cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='SwitchvsNoswitch';
freq.powspctrm=switchTrial-stableTrial;
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax1,flipud(brewermap(64,'RdBu')))

ax2=subplot(2,2,2)
freq.powspctrm = switchTrial;
cfg.title='Switch';
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax2,flipud(brewermap(64,'RdBu')))

ax3=subplot(2,2,3)
cfg.title='NoSwitch';
freq.powspctrm = stableTrial;
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax3,flipud(brewermap(64,'RdBu')))

ax4=subplot(2,2,4)
title('tMap')
%Create tmaps. If across dim 1, testing sig across channels
%between switch and no switch averages.
[h,p]=ttest2(switchTrial(idx_occ,:,start_idx:end_idx),...
stableTrial(idx_occ,:,start_idx:end_idx),'Dim',1);

colormap(ax4,cbrewer('seq', 'YlOrBr', 200))
set(hf, 'Position', [0 0 500 500])
imagesc(squeeze(p))
%change the x values displayed
xticklabels = freq.time(start_idx:21:end_idx);
xticks = linspace(1, find(freq.time==xticklabels(end)),numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)
%change the y values displayed
yticklabels = freq.freq(3:10:end);
yticks = linspace(3,find(freq.freq==yticklabels(end)),numel(freq.freq(3:10:end)));
set(gca, 'YTick', yticks, 'YTickLabel', yticklabels)
set(gca,'YDir','normal')
caxis([0 0.005])
colorbar
title('P values for ttest2')

%Save figure active.

cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/figures',cfgin.blocktype))
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim2_SwitchvsNoSwitch_lowRealfreq_%d_TFR',cfgin.part_ID);%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')

end
