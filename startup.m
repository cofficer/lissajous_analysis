
%Startup settings: 

%Set paths
warning off

whichFieldtrip = '2017-2';


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
    
    
end
%Set graphs:
set(0,'DefaultAxesColorOrder',cbrewer('qual','Set2',8))
set(0,'DefaultLineLineWidth',1.2)
set(0,'DefaultFigureColormap',cbrewer('div','PuOr',64))

