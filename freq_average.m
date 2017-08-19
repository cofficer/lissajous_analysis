function [avgFreq] = freq_average(cfgin)
%Load in freq data, and average across appropriate trials and frequencies

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/')

freqrange = 'low';

freqpath = dir(sprintf('*%s*',freqrange));

figure(1),clf
%Loop over participants
for ipart = 1:12;%length(freqpath)
  load(freqpath(ipart).name)

  %select trials, and average over trials
  gdtrl = freq.trialinfo(:,6)~=43;
  cfg   = [];
  cfg.trials = gdtrl;
  cfg.avgoverrpt = 'yes';
  freq  = ft_selectdata(cfg,freq)


  % %plot TFR
    cfg = [];
    cfg.baseline = [0.5 1];
    cfg.baselinetype = 'relchange';
    cfg.masktype     = 'saturation';
    cfg.zlim         = 'maxmin';
    cfg.layout       = 'CTF275_helmet.lay';
    cfg.xlim         = [1.25 3.25 ];
   % %cfg.channel      = 'MRC15';
    cfg.interactive = 'no';
   % %ft_singleplotTFR(cfg,freq);
   % %ft_multiplotTFR(cfg,freq)
   subplot(4,3,ipart)
    ft_topoplotTFR(cfg,freq)

end



end
