function freq = freq_lissajous_wrap(cfgin,runcfg)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Handle time-frequency analysis for continuous data. 25/09-2017. cofficer.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Divide the analysis into several discreet jobs per block.
  %%


  %Would be more efficient to load available blocks
  %Instead of looping 2:4.
  dirpart = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/preprocessed/%s/',cfgin.restingfile(1:3));
  cd(dirpart)

  dat_name = dir('*26-26*.mat');

  for iblock = 1:length(dat_name)
    cfgin.dirpart=dirpart;
    cfgin.iblock=dat_name(iblock).name; % needs to contain the block number as well.
    qsubcellfun(@freq_lissajousCONT, cfgin, 'compile', 'no', ...
    'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');
  end
end
