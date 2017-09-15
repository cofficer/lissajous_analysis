


part_available = 1:29;
remove_part = ones(1,length(part_available));
remove_part(1)=0;
remove_part(8)=0;
remove_part(11)=0;
remove_part(16)=0;
part_available(logical(~remove_part))=[];

%loop over part_ID, plot ... profit???
for part_idx = 24:length(part_available)
  [freq,switchTrial,stableTrial]=freq_average_individual(part_available(part_idx));
  plot_average_individual(part_available(part_idx),freq,switchTrial,stableTrial);

end



%Look at the mean modulation of switch vs no switch.

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/average')

datainfos = dir('*.mat');


%average modulation for switch vs no switch.
avg_freq_svsn=zeros(length(datainfos)-1,274,58,101);

for idata = 1:length(datainfos)
  disp(datainfos(idata).name)
  if strcmp(datainfos(idata).name,'freqavgs_23.mat')
    continue
  end
  load(datainfos(idata).name)

  %average modulation for switch vs no switch.
  avg_freq_svsn(idata,:,:,:) = freq.powspctrm;


end
avg_freq_svsn=squeeze(nanmean(avg_freq_svsn,1));

freq.powspctrm=avg_freq_svsn;


idx_occ=strfind(freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));
figure(1),clf
cfg=[];
cfg.zlim         = [-4 4];
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
%cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='SwitchvsNoswitch';
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
namefigure = sprintf('prelim2_SwitchvsNoSwitch_highAverage_TFR');%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,figurefreqname,'png')
