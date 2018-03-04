
%Startup settings:

%Set paths
warning off

whichFieldtrip = 'git';%'2017-2';

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
      ft_defaults


end
ft_hastoolbox('brewermap', 1);

%Set graphs:
set(0,'DefaultAxesColorOrder',cbrewer('qual','Set2',8))
set(0,'DefaultLineLineWidth',1.2)
set(0,'DefaultFigureColormap',cbrewer('div','PuOr',64))
