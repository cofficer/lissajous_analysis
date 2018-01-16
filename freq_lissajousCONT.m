function freq = freq_lissajousCONT(cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Run time-frequency analysis for continuous data. 28/08-2017. cofficer.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %TODO: Consider the case of no button presses. Remove for now.
  %%

  %loop and load preproc data
  %example /mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/preprocessed/P22/
  %
  try

    %Setting for spectral decomposition
    cfg             = [];
    cfg.output      = 'pow';
    % cfg.output = 'fourier';
    cfg.channel     = 'MEG';
    cfg.keeptapers  = 'no';
    cfg.pad         = 7;
    cfg.method      = 'mtmconvol';
    cfg.trigger     = 'selfoccl';
    cfg.channel     ='MEG'; %
    cfg.trials      = 'all';
    cfg.freqanalysistype = 'low';

    cd(cfgin.dirpart)
    load(cfgin.iblock)

    outputfile = sprintf('%sfreq_%s_%sBlock%s-26-26.mat',cfgin.restingfile(2:3),cfg.freqanalysistype,cfg.trigger,cfgin.iblock(1));

    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/')

    %Only do analysis if file is missing
    if exist(outputfile)==0


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



      switch cfg.freqanalysistype
      case 'high'
        cfg.taper = 'dpss'; % high frequency-optimized analysis (smooth)
        cfg.keeptrials  = 'yes';
        cfg.foi = 35:5:150;
        cfg.t_ftimwin = (20./cfg.foi);%ones(length(cfg.foi),1) .* 0.5; %(20./cfg.foi)
        cfg.tapsmofrq = 0.2 *cfg.foi; %ones(length(cfg.foi),1) .* 8; % 0.2 *cfg.foi
      case 'low'
        cfg.taper = 'hanning'; % low frequency-optimized analysis
        cfg.keeptrials  = 'yes'; % needed for fourier-output
        %           cfg.keeptapers = 'yes'; % idem
        cfg.foi = 3:35;
        cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.5; %400ms time window?
        cfg.tapsmofrq = ones(length(cfg.foi),1) .* 4;
      case 'full'
        cfg.taper = 'dpss'; % high frequency-optimized analysis (smooth)
        cfg.keeptrials  = 'yes';
        cfg.foi = 0:2:150;
        cfg.t_ftimwin = ones(length(cfg.foi),1) .* 0.5;   % length of time window = 0.4 sec
        cfg.tapsmofrq = ones(length(cfg.foi),1) .* 8;

      end


      %Select the step sizes.
      if strcmp(cfg.trigger,'baseline')

        cfg.toi = -0.50:0.05:0;

      elseif strcmp(cfg.trigger,'selfoccl')

        %cfg.toi = 0.25:0.05:4.25;
        cfg.toi = -2.35:0.05:2.35;

      elseif strcmp(cfg.trigger,'resp')

        cfg.toi = -0.60:0.05:0;            %still to figure

      elseif strcmp(cfg.trigger,'cue')

        cfg.toi = -0.5:0.05:0.5;            %still to figure

      end




      %Fieltrip fourier
      cfg.polyremoval = -1; %Detrend that data.
      freq = ft_freqanalysis(cfg, data);

      %Combine planar
      cfgC=[];
      cfgC.trials='all';
      cfgC.combinemethod='sum';
      freq=ft_combineplanar(cfgC,freq);


      % %save(outputfile,'freq','-v7.3');
      % %plot TFR
      %  cfg = [];
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


      [pathstr, name] = fileparts(cfgin.fullpath);
      fprintf('Saving %s from...\n %s\n', name, pathstr)

      save(outputfile, 'freq','-v7.3');



    end

  catch err

    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/')
    fid=fopen('freqContErrors','a+');
    c=clock;
    fprintf(fid,sprintf('\n\n\n\nNew entry for %s at %i/%i/%i %i:%i\n',cfgin.restingfile,fix(c(1)),fix(c(2)),fix(c(3)),fix(c(4)),fix(c(5))))

    fprintf(fid,'%s\n\n',err.message)

    fclose(fid)


  end

end
