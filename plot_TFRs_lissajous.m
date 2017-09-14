function [] = plot_TFRs_lissajous(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in already computed freq data and plot
%Created 8/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear all;close all;
%Settings for analysis.
cfgin.blocktype = 'continuous'
do_baseline     = 1;


%Load in data.
filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype)
cd(filepath)
noswitch=load('freqHighNoSwitches26-26.mat');
switches=load('freqHighSwitches26-26.mat');

if do_baseline

  cfg = [];
  cfg.baselinewindow = [1.5 2];
  %Testing different subtraction settings.
  cfg.subtractmode   ='combine';
  cfg.timeperiod     = [20,70];
  
  % cfg.baseline = [1.5 2];
  % cfg.baselinetype = 'relative';
  % noswitch.freq = ft_freqbaseline(cfg,noswitch.freq);
  % switches.freq = ft_freqbaseline(cfg,switches.freq);
  [noswitch.freq.powspctrm,switches.freq.powspctrm]=baseline_lissajous(noswitch.freq,switches.freq,cfg);

end

%select channels over occipital cortex
idx_occ=strfind(switches.freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));

%Create tmaps. If across dim 1, testing sig across channels
%between switch and no switch averages.
[h,p]=ttest2(switches.freq.powspctrm(idx_occ,:,20:70),...
noswitch.freq.powspctrm(idx_occ,:,20:70),'Dim',1);


%plot the tmap

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
hf = figure(1),clf;
%set(hf,'DefaultFigureColormap',cbrewer('qual', 'YlOrBr', 400))
colormap(cbrewer('seq', 'YlOrBr', 200))
set(hf, 'Position', [0 0 500 500])
imagesc(squeeze(p))
%change the x values displayed
xticklabels = switches.freq.time(1:10:end);
xticks = linspace(1, numel(switches.freq.time),numel(xticklabels));
set(gca, 'XTick', xticks, 'XTickLabel', xticklabels)

set(gca,'YDir','normal')
caxis([0 0.0005])
colorbar
title('P values for ttest2')
ylabel('Frequencies')
xlabel('time (s)')

%Name of figure
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
if do_baseline
  namefigure = sprintf('highfreqTmap_CustomBaserange26-26%1.1f-%1.1fs%s',...
  cfg.baselinewindow(1),cfg.baselinewindow(2),cfg.subtractmode);%Stage of analysis, frequencies, type plot, baselinewindow
else
  namefigure = 'highfreqTmap26-26';
end

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure);
saveas(gca,figurefreqname,'png')
end
