function freq = freq_lissajous_wrap(cfgin,runcfg)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Handle time-frequency analysis for continuous data. 25/09-2017. cofficer.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Divide the analysis into several discreet jobs per block.
  %%


  %Would be more efficient to load available blocks
  %Instead of looping 2:4.

  i_exp=1;
  %expand the cfgin three times.
  for ipart = 1:length(cfgin)
  %  i_exp=i_exp+1;
    dirpart = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/preprocessed/%s/',...
    cfgin{ipart}.restingfile(1:3));
    cd(dirpart)

    dat_name = dir(sprintf('preproc_%s*.mat',cfgin{ipart}.stim_self));

    for iblock = 1:length(dat_name)
      cfgin_exp{i_exp} = cfgin{ipart};
      cfgin_exp{i_exp}.dirpart=dirpart;
      cfgin_exp{i_exp}.iblock=dat_name(iblock).name; % needs to contain the block number as well.
      %cfgin_exp=cfgin_exp{20};
      i_exp=i_exp+1;
    end


  end



  qsubcellfun(@freq_lissajousCONT, cfgin_exp, 'compile', 'no', ...
  'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');

end
