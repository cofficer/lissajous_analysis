function [avgFreq] = freq_average(cfgin)
%Load in freq data, and average across appropriate trials and frequencies

filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype)

cd(filepath)

freqrange  = 'low';
doplot     = 0;
compSwitch = 0;
freqpath   = dir(sprintf('*%s*',freqrange));


if doplot
  figure(1),clf
end

%Remove participant nr 10, super weird artifacts.
namecell = {freqpath.name};

partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

idx_partnum = ~strcmp(partnum,'10');

namecell = namecell(idx_partnum);

suplot = 0;
%Loop over participants
for ipart = 1:length(namecell)
  suplot=suplot+1;

  %Load the freq data
  load(namecell{ipart})



  %While the same participant, average together and at the First
  %new participant plot the TFR.


    %If comparing perceptual switch with no switch.
    if compSwitch

        %select trials, and average over trials
      gdtrl = freq.trialinfo(:,6)~=43;
      switchtrl1 = freq.trialinfo(:,6)==42; %45
      switchtrl2 = freq.trialinfo(:,6)==45; %45
      noswitchtrl1 = freq.trialinfo(:,6)==41; %45
      noswitchtrl2 = freq.trialinfo(:,6)==46; %45

      allswitch = switchtrl1+switchtrl2;
      allnoswch = noswitchtrl1+noswitchtrl2;
      cfg   = [];
      cfg.trials = logical(allswitch);
      %cfg.frequency = [12 35];
      cfg.avgoverrpt = 'yes';
      freqS  = ft_selectdata(cfg,freq);
      cfg.trials = logical(allnoswch);
      freq  = ft_selectdata(cfg,freq);
      %baseline before substraction?
      freq.powspctrm = (freqS.powspctrm-freq.powspctrm);
    elseif strcmp(freq.dimord,'rpt_chan_freq_time')

        %select trials, and average over trials
      %gdtrl = freq.trialinfo(:,6)~=43;
      %Probably good to baseline before averaging.
      %Not sure anymore.
      %cfg = [];
      %cfg.baseline = [0.5 1];
      %cfg.baselinetype = 'relative';
      %freq = ft_freqbaseline(cfg,freq);

      %Find the indices of switches and non switches.
      idx_switch   = (abs(diff(freq.trialinfo(:,5)))==7);
      nopress      = freq.trialinfo(:,5)==0;
      idx_noswitch = diff(freq.trialinfo(:,5))==0;
      %Remove the trials where there is no buttonpress.
      idx_noswitch(nopress)=0;

      currNum = partnum(ipart);

      cfg   = [];
      cfg.trials = idx_noswitch;
      %cfg.frequency = [12 35];
      cfg.avgoverrpt = 'yes';
      freq  = ft_selectdata(cfg,freq);
    end
    if ipart == 1
      %initialize full powspctrm
      avgFreq = zeros(length(freqpath),size(freq.powspctrm,1),size(freq.powspctrm,2),size(freq.powspctrm,3));
      avgFreq(1,:,:,:) = freq.powspctrm;
    else
      avgFreq(ipart,:,:,:) = freq.powspctrm;

    end


    % %plot TFR
    if doplot
      subplot(3,1,suplot)
      %select channels
      idx_occ=strfind(freq.label,'O');
      idx_occ=find(~cellfun(@isempty,idx_occ));

      cfg = [];
      cfg.baseline = [0.25 4.25];
      cfg.baselinetype = 'relative';
      cfg.masktype     = 'saturation';
      cfg.zlim         = [0.6 1.4];
      cfg.ylim         = [3 35];
      cfg.layout       = 'CTF275_helmet.lay';
      cfg.xlim         = [0.25 4.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
      %cfg.channel      = freq.label(idx_occ);
      cfg.interactive = 'no';
      ft_singleplotTFR(cfg,freq);
      %ft_multiplotTFR(cfg,freq)
      ft_topoplotTFR(cfg,freq)
      %ft_hastoolbox('brewermap', 1);
      colormap(flipud(brewermap(64,'RdBu')))
      %colorbar
    end

end

avgFreq=squeeze(nanmean(avgFreq,1));
freq.powspctrm=avgFreq;

% %plot TFR
if doplot
  %subplot(3,3,ipart)
  %select channels
  idx_occ=strfind(freq.label,'O');
  idx_occ=find(~cellfun(@isempty,idx_occ));

  cfg = [];
  cfg.baseline = [1.5 2];
  cfg.baselinetype = 'relative';
  cfg.masktype     = 'saturation';
  cfg.zlim         = [0.8 1.2];
  cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  cfg.xlim         = [0.25 4.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  %cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  ft_singleplotTFR(cfg,freq);
  %ft_multiplotTFR(cfg,freq)
  ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(flipud(brewermap(64,'RdBu')))
  %colorbar
end

noswitch=load('freqLowNoSwitches.mat');
switches=load('freqLowSwitches.mat');

freq.powspctrm=switches.freq.powspctrm;

freq.powspctrm=switches.freq.powspctrm-noswitch.freq.powspctrm;

cfg = [];
cfg.baseline = [1.5 2];
cfg.baselinetype = 'relative';
noswitch.freq = ft_freqbaseline(cfg,noswitch.freq);

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')

%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('prelim_lowfreq_topo_baserange%1.1f-%1.1fs',cfg.baseline(1),cfg.baseline(2));%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,'lowTOPOOccipitalSwitchOnlyMany.png','png')
saveas(gca,'testingSubstr.png','png')
%%
% for the multiple plots also
cfg = [];
cfg.xlim = [0.25:0.35:4.25];
%cfg.ylim = [7 12];
cfg.zlim = [0.85 1.15];
cfg.baseline = [1.5 2];
cfg.baselinetype = 'relative';
cfg.masktype     = 'saturation';
cfg.layout = 'CTF275_helmet.lay';
cfg.comment = 'xlim';
cfg.commentpos = 'title';
figure;
colormap(flipud(brewermap(64,'RdBu')))
ft_topoplotTFR(cfg,freq);

end
