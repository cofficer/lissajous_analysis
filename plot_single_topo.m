% % Testing some plotting
%   load('/home/chris/Dropbox/PhD/Projects/Lissajous/trial/2017-11-29_freq_gamma_average.mat')
%   load('/home/chris/Documents/lissajous/data/continous_self_freq/16freq_low_selfocclBlock3.mat')
  load('/home/chris/Dropbox/PhD/Projects/Lissajous/continuous_self_freqavg/freqavgs_switch_low_14.mat')
  figure(1),clf
  freq2=freq;
  cfg=[];
  cfg.xlim = [-0.4:0.2:1.4];
%   cfg.ylim         = [60 90];
  cfg.time=[0];
  cfg.layout       = 'CTF275_helmet.lay';
  %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
  % cfg.channel      = freq.label(idx_occ);
  cfg.interactive = 'yes';
%   cfg.baseline = [-2.5 -2];
%   cfg.highlightchannel=freq2.label(data_comp<-80);
%   cfg.highlight='on';
%   cfg.highlightcolor =[0.5 0.5 0.5];
%   cfg.highlightsize=22;
%   freq2.dimord = 'chan_freq_time';
%   freq2.powspctrm=squeeze(freq2.powspctrm(25,:,:,:));
  ft_topoplotTFR(cfg,freq2)
%%
figure(2),clf
freq2=switchTrial;
cfg=[];
cfg.xlim = [-0.4:0.2:1.4];
cfg.layout       = 'CTF275_helmet.lay';
cfg.interactive = 'yes';
ft_topoplotTFR(cfg,freq2)
%%
figure(3),clf
freq2=stableTrial;
cfg=[];
cfg.xlim = [-0.4:0.2:1.4];
cfg.layout       = 'CTF275_helmet.lay';
cfg.interactive = 'yes';
ft_topoplotTFR(cfg,freq2)
%%
figure(4),clf
freq2=switchTrial
freq2.powspctrm=(switchTrial.powspctrm-stableTrial.powspctrm)./stableTrial.powspctrm;
cfg=[];
cfg.xlim = [-0.4:0.2:1.4];
cfg.layout       = 'CTF275_helmet.lay';
cfg.interactive = 'yes';
ft_topoplotTFR(cfg,freq2)

