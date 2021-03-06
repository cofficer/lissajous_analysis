function data = freq_lissajous(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Run time-frequency analysis, for trial.
%Edited 2017-11-21
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%

%load preproc data, define stim or self.
if strcmp(cfgin.stim_self,'stim_off')
  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/preproc_stim_%s.mat',cfgin.restingfile,cfgin.restingfile);

elseif strcmp(cfgin.stim_self,'stimoff')
  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/%s/preproc_%s_%s_block1.mat',cfgin.restingfile,cfgin.stim_self,cfgin.stim_self,cfgin.restingfile);

elseif strcmp(cfgin.stim_self,'stim')

  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/%s/preproc_stim_%s_block1.mat',cfgin.restingfile,cfgin.stim_self,cfgin.restingfile);

elseif strcmp(cfgin.stim_self,'self')

  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/%s/preproc_self_%s_block1.mat',cfgin.restingfile,cfgin.stim_self,cfgin.restingfile);

elseif strcmp(cfgin.stim_self,'baseline')

  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/%s/preproc_stim_%s.mat',cfgin.restingfile,cfgin.stim_self,cfgin.restingfile);
elseif strcmp(cfgin.stim_self,'cue')

  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/%s/preproc_stim_%s.mat',cfgin.restingfile,cfgin.stim_self,cfgin.restingfile);

else

  dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/preprocessed/%s/preproc%s.mat',cfgin.restingfile,cfgin.restingfile);

end

load(dsfile)

%Seperate the data into orthogonal sensors
cfg_pn = [];
cfg_pn.method = 'distance';
cfg_pn.template = 'C:\Users\Thomas Meindertsma\Documents\MATLAB\CTF275_neighb.mat';
cfg_pn.template = 'CTF275_neighb';
cfg_pn.channel = 'MEG';

cfg_mp.planarmethod = 'sincos';
cfg_mp.trials = 'all';
cfg_mp.channel = 'MEG';
cfg_mp.neighbours = ft_prepare_neighbours(cfg_pn, data);
data = ft_megplanar(cfg_mp, data);


%Setting for spectral decomposition
cfg             = [];
cfg.output      = 'pow';
% cfg.output = 'fourier';
cfg.channel     = 'MEG';
cfg.keeptapers  = 'no';
cfg.pad         = ceil(max(cellfun(@numel, data.time)/data.fsample));
cfg.method      = 'mtmconvol';
cfg.trigger     = cfgin.stim_self; %stim. selfoccl.
cfg.channel     ='MEG'; %
cfg.trials      = 'all';
cfg.freqanalysistype = cfgin.freqrange;


switch cfg.freqanalysistype
        case 'high'
            cfg.taper = 'dpss'; % high frequency-optimized analysis (smooth)
            cfg.keeptrials  = 'yes';
            cfg.foi = 36:2:110;
            % cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.5;
            % cfg.tapsmofrq = ones(length(cfg.foi),1) .* 8;
            cfg.t_ftimwin = ones(length(cfg.foi),1)*0.2;%(20./cfg.foi);%ones(length(cfg.foi),1) .* 0.5; %(20./cfg.foi)
            cfg.tapsmofrq = ones(length(cfg.foi),1)*10;%0.1 *cfg.foi; %ones(length(cfg.foi),1) .* 8; % 0.2 *cfg.foi
        case 'low'
            cfg.taper = 'hanning'; % low frequency-optimized analysis
            cfg.keeptrials  = 'yes'; % needed for fourier-output
%           cfg.keeptapers = 'yes'; % idem
            cfg.foi = 3:35;
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.5; %400ms time window?
            cfg.tapsmofrq = ones(length(cfg.foi),1) .* 8;
        case 'full'
            cfg.taper = 'dpss'; % high frequency-optimized analysis (smooth)
            cfg.keeptrials  = 'yes';
            cfg.foi = 0:2:150;
            cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.5;   % length of time window = 0.4 sec
            cfg.tapsmofrq = ones(length(cfg.foi),1) .* 8;

end


%Select the step sizes.
if strcmp(cfg.trigger,'baseline')

  cfg.toi = 4.6:0.05:5.1;

elseif strcmp(cfg.trigger,'selfoccl')

  cfg.toi = 0.5:0.05:4;

elseif strcmp(cfg.trigger,'self')

  cfg.toi = -3.5:0.05:0.5;

elseif strcmp(cfg.trigger,'resp')

  cfg.toi = -0.60:0.05:0;            %still to figure

elseif strcmp(cfg.trigger,'cue')

  cfg.toi = -1.5:0.05:0.5;            %still to figure

elseif strcmp(cfg.trigger,'stim')

  cfg.toi = -3.5:0.05:-1.5;            %still to figure
elseif strcmp(cfg.trigger,'stim_off')

  cfg.toi = -2.5:0.05:1.5;      %3.75-6.75      %still to figure 3s=1.1gb. 5gb/part.
elseif strcmp(cfg.trigger,'stimoff')

  cfg.toi = -2.5:0.05:1.5;      %3.75-6.75      %still to figure 3s=1.1gb. 5gb/part.

end




%Fieltrip fourier
freq = ft_freqanalysis(cfg, data);

%Combine planar
cfgC=[];
cfgC.trials='all';
cfgC.combinemethod='sum';
freq=ft_combineplanar(cfgC,freq);


% %
% %plot TFR
%  cfg = [];
% freq.powspctrm(1,1,1,:)
%  cfg.baseline = [0.5 1];
%  cfg.baselinetype = 'relchange';
%  cfg.masktype     = 'saturation';
%  cfg.zlim         = 'maxmin';
%  cfg.layout       = 'CTF275.lay';
%  cfg.xlim         = [1.25 3.25 ];
% % %cfg.channel      = 'MRC15';
%  cfg.interactive = 'yes';
% % figure
% % %ft_singleplotTFR(cfg,freq);
% % %ft_multiplotTFR(cfg,freq)
%  ft_topoplotTFR(cfg,freq)


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/')
[pathstr, name] = fileparts(cfgin.fullpath);
fprintf('Saving %s from...\n %s\n', name, pathstr)

if strcmp(cfgin.stim_self,'stim')

  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/stim')

  outputfile = sprintf('%sfreq_stim_%s_%s.mat',cfgin.restingfile(2:3),cfg.freqanalysistype,cfg.trigger);

elseif strcmp(cfgin.stim_self,'baseline')
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/baseline')

  outputfile = sprintf('%sfreq_%s_%s_%s.mat',cfgin.restingfile(2:3),cfgin.stim_self,cfg.freqanalysistype,cfg.trigger);

elseif strcmp(cfgin.stim_self,'stimoff')
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/stimoff')

  outputfile = sprintf('%sfreq_%s_%s_%s.mat',cfgin.restingfile(2:3),cfgin.stim_self,cfg.freqanalysistype,cfg.trigger);

elseif strcmp(cfgin.stim_self,'cue')
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/cue')

  outputfile = sprintf('%sfreq_%s_%s_%s.mat',cfgin.restingfile(2:3),cfgin.stim_self,cfg.freqanalysistype,cfg.trigger);

elseif strcmp(cfgin.stim_self,'self')
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/self')

  outputfile = sprintf('%sfreq_%s_%s_%s.mat',cfgin.restingfile(2:3),cfgin.stim_self,cfg.freqanalysistype,cfg.trigger);

else
  outputfile = sprintf('%sfreq_%s_%s.mat',cfgin.restingfile(2:3),cfg.freqanalysistype,cfg.trigger);
end


save(outputfile, 'freq','-v7.3');


end
