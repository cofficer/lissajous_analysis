function [avgFreq] = freq_average(cfgin)
%Load in freq data, and average across appropriate trials and frequencies

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/')

freqrange = 'high';

freqpath = dir(sprintf('*%s*',freqrange));

figure(1),clf
%Loop over participants
for ipart = 1:9;%length(freqpath)

  load(freqpath(ipart).name)

  if freqrange == 'low'
  %select trials, and average over trials
    gdtrl = freq.trialinfo(:,6)~=43;
    cfg   = [];
    cfg.trials = gdtrl;
    cfg.avgoverrpt = 'yes';
    freq  = ft_selectdata(cfg,freq)
  end
  %select channels
  idx_occ=strfind(freq.label,'O');
  idx_occ=find(~cellfun(@isempty,idx_occ));


  % %plot TFR
    cfg = [];
    cfg.baseline = [0.5 1];
    cfg.baselinetype = 'relchange';
    cfg.masktype     = 'saturation';
    cfg.zlim         = [-0.15 0.15];
    cfg.layout       = 'CTF275_helmet.lay';
    cfg.xlim         = [2 2.4 ];
    cfg.channel      = freq.label(idx_occ);
    cfg.interactive = 'no';
   ft_singleplotTFR(cfg,freq);
   % %ft_multiplotTFR(cfg,freq)
   subplot(3,3,ipart)
    %ft_topoplotTFR(cfg,freq)
    colorbar

end

saveas(gca,'testTFRhigh.png','png')


end
