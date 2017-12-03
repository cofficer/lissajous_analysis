function plot_average_individual_all(cfgin,freq)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in freq data, and plot across interests
%Created 22/11/2017.
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
if strcmp(cfgin.freqrange,'high')
cfg.ylim         = [60 100];
elseif strcmp(cfgin.freqrange,'low')
  %Do beta for now.
  cfg.ylim         = [12 35];
end

cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [4.1 4.4];%[-0.75 -0.5];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
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
if strcmp(cfgin.freqrange,'high')
cfg.ylim         = [60 100];
elseif strcmp(cfgin.freqrange,'low')
  %Do beta for now.
  cfg.ylim         = [12 35];
end
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [4.4 4.8];%[-0.5 -0.15];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
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
if strcmp(cfgin.freqrange,'high')
cfg.ylim         = [60 100];
elseif strcmp(cfgin.freqrange,'low')
  %Do beta for now.
  cfg.ylim         = [12 35];
end
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [4.8 5.2];%[-0.15 0.15];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
% cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
cfg.title='all';
% ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(ax1,flipud(brewermap(64,'RdBu')))

ax1=subplot(2,2,4)
cfg=[];
cfg.zlim         = [-10 10];
if strcmp(cfgin.freqrange,'high')
  cfg.ylim         = [60 100];
elseif strcmp(cfgin.freqrange,'low')
  %Do beta for now.
  cfg.ylim         = [12 35];
end
cfg.layout       = 'CTF275_helmet.lay';
cfg.xlim         = [3.7 4];%[0.15 0.5];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
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
namefigure = sprintf('prelim10_%s_preCuebase_all_%d_TOPO',cfgin.freqrange,cfgin.part_ID);%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
set(hf,'PaperpositionMode','Auto')
saveas(hf,figurefreqname,'png')

end
