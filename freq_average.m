function [avgFreq] = freq_average(cfgin)
%Load in freq data, and average across appropriate trials and frequencies

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/')

freqrange  = 'low';
doplot     = 1;
compSwitch = 1;
freqpath   = dir(sprintf('*%s*',freqrange));


if doplot
  figure(1),clf
end

%Loop over participants
for ipart = 1:length(freqpath)

  load(freqpath(ipart).name)

  %select trials, and average over trials
    gdtrl = freq.trialinfo(:,6)~=43;

    %If comparing perceptual switch with no switch.
    if compSwitch
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
      %baseline before substraction
      %cfg = [];
      %cfg.baseline = [0.5 1];
      %cfg.baselinetype = 'relative';
      %freq = ft_freqbaseline(cfg,freq);
      %freqS = ft_freqbaseline(cfg,freqS);
      freq.powspctrm = (freqS.powspctrm-freq.powspctrm);
    else

      %Probably good to baseline before averaging.
      %Not sure anymore.
      %cfg = [];
      %cfg.baseline = [0.5 1];
      %cfg.baselinetype = 'relative';
      %freq = ft_freqbaseline(cfg,freq);

      cfg   = [];
      cfg.trials = gdtrl;
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



end

avgFreq=squeeze(mean(avgFreq,1));
freq.powspctrm=avgFreq;

% %plot TFR
if doplot
  %subplot(3,3,ipart)
  %select channels
  idx_occ=strfind(freq.label,'O');
  idx_occ=find(~cellfun(@isempty,idx_occ));

  cfg = [];
  cfg.baseline = [2.5 3];
  cfg.baselinetype = 'relative';
  cfg.masktype     = 'saturation';
  cfg.zlim         = [0.8 1.2];
  cfg.ylim         = [3 35];
  cfg.layout       = 'CTF275_helmet.lay';
  cfg.xlim         = [2.5 6];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'no';
  ft_singleplotTFR(cfg,freq);
  %ft_multiplotTFR(cfg,freq)
  %ft_topoplotTFR(cfg,freq)
  %ft_hastoolbox('brewermap', 1);
  colormap(flipud(brewermap(64,'RdBu')))
  colorbar
end

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/figures')
saveas(gca,'beta3SingleTFRP23.png','png')

%%
% for the multiple plots also
cfg = [];
cfg.xlim = [0.6:0.35:4];
%cfg.ylim = [7 12];
cfg.zlim = [0.7 1.3];
cfg.baseline = [0.5 1];
cfg.baselinetype = 'relative';
cfg.masktype     = 'saturation';
cfg.layout = 'CTF275_helmet.lay';
cfg.comment = 'xlim';
cfg.commentpos = 'title';
figure;
colormap(flipud(brewermap(64,'RdBu')))
ft_topoplotTFR(cfg,freq);

end
