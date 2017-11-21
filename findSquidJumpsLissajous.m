function [channelJump,trialnum]=findSquidJumpsLissajous( data,pathname )
  %Identify all the jumps in the data input


  doplot=0;
  %calculate squid jumps
  cfg = [] ;
  cfg.length = 7;
  %lengthsec = 7;
  cfg.toilim =[0 7];
  %cfg.offset = 1:1200*lengthsec:1200*301;
  cfg.overlap =0;

  %Only change the trialstructure if it is continuous
  if length(data.trial) < 2
    data = ft_redefinetrial(cfg,data) ;
  end


  % detrend and demean
  cfg             = [];
  cfg.detrend     = 'yes';
  cfg.demean      = 'yes';
  %cfg1.trials     = cfg1.trial{1}
  %cfg.hpfilter = 'yes';
  %cfg.channel  = {'MEG'};
  %cfg.hpfreq   = 60;
  data            = ft_preprocessing(cfg, data);

  % compute the intercept of the loglog fourier spectrum on each trial
  disp('searching for trials with squid jumps...');


  % get the fourier spectrum per trial and sensor
  cfgfreq             = [];
  cfgfreq.method      = 'mtmfft';
  cfgfreq.output      = 'pow';
  cfgfreq.taper       = 'hanning';
  cfgfreq.channel     = 'MEG';
  cfgfreq.foi         = 1:130;
  cfgfreq.keeptrials  = 'yes';
  freq                = ft_freqanalysis(cfgfreq, data);

  % compute the intercept of the loglog fourier spectrum on each trial
  disp('searching for trials with squid jumps...');
  intercept       = nan(size(freq.powspctrm, 1), size(freq.powspctrm, 2));
  x = [ones(size(freq.freq))' log(freq.freq)'];

  for t = 1:size(freq.powspctrm, 1),
    for c = 1:size(freq.powspctrm, 2),
      b = x\log(squeeze(freq.powspctrm(t,c,:)));
      intercept(t,c) = b(1);
    end
  end


  % detect jumps as outliers, actually this returns the channels too...
  alphalvl = 0.01;
  [~, idx] = deleteoutliers(intercept(:),alphalvl);

  %subplot(4,4,cnt); cnt = cnt + 1;
  if isempty(idx),
    fprintf('no squid jump trials found \n');
    %title('No jumps'); axis off;
    channelJump=[];
    trialnum   =[];
  else

    jumps_total=length(idx);

    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/')
    fid=fopen('logfile_squidJumps','a+');
    c=clock;
    fprintf(fid,sprintf('\n\nNew entry for %s at %i/%i/%i %i:%i\n\n',pathname,fix(c(1)),fix(c(2)),fix(c(3)),fix(c(4)),fix(c(5))))

    fprintf(fid,'Number of squid jumps: %i',jumps_total)

    fclose(fid)

    %For each detected jump, loop and get the name


    %reload data
    %load(pathname.restingfile)

    channelJump = cell(length(idx),1);
    for iout = 1:length(idx)

      %I belive that y is trial and x is channel.
      [y,x] = ind2sub(size(intercept),idx(iout)) ;

      %Store the name of the channel
      channelJump(iout) = freq.label(x);
      trialnum(iout)    = y;
    end
  end
end
