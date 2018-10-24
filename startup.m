
%Startup settings:

%Set paths
warning off

whichFieldtrip = 'git';%git '2017-2';

if strcmp(whichFieldtrip,'2015')

    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis'))
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20151020/')
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20151020/qsub')
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous'))
     addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos'))
    ft_defaults

elseif strcmp(whichFieldtrip,'2016')

    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis'))
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20160601/')
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20160601/qsub')
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous'))
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos'))
    ft_defaults


elseif strcmp(whichFieldtrip,'2017')


    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis'))
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170124/')
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170124/qsub')
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous'))
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos'))
    ft_defaults

elseif strcmp(whichFieldtrip,'2017-2')


    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/analysis'))
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170528/')
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170528/qsub')
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous'))
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos'))
    ft_defaults

elseif strcmp(whichFieldtrip,'2017-3')


    % addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/'))
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170802/')
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170802/qsub')
    addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip-20170802/qsubcellfun')
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous'))
    addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos'))
    ft_defaults

  elseif strcmp(whichFieldtrip,'git')


      % addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/code/'))
      addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip/')
      addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip/qsub')
      addpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/fieldtrip/qsubcellfun')
      addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous'))
      addpath(genpath('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos'))
      addpath(genpath('/home/chrisgahn/Documents/MATLAB/toolkits/'))
      ft_defaults
  elseif strcmp(whichFieldtrip,'local')
    addpath('/Users/c.gahnstrohm/Desktop/toolboxes_matlab/fieldtrip')
    addpath(genpath('/Users/c.gahnstrohm/Desktop/toolboxes_matlab/cbrewer'))
    addpath(genpath('/Users/c.gahnstrohm/Desktop/lissajous_code'))
    addpath('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/continuous_self_freqavg')
    global ft_default
    ft_default.spmversion = 'spm12'
    ft_defaults


end
ft_hastoolbox('brewermap', 1);

%Set graphs:
set(0,'DefaultAxesColorOrder',cbrewer('qual','Set2',8))
set(0,'DefaultLineLineWidth',1.2)
set(0,'DefaultFigureColormap',cbrewer('div','PuOr',64))
