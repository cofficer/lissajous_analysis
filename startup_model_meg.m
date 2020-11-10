
addpath(genpath('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/'))
addpath('/home/chris/Documents/lissajous/code/lissajous_analysis/')
% addpath(genpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/toolboxes_matlab/vis3D'))
% addpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/toolboxes_matlab/fieldtrip')
addpath('/home/chris/Documents/lissajous/code/fieldtrip-20200607')
ft_defaults

addpath('/home/chris/Documents/lissajous/code/tapas')
tapas_init('hgf')

load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')
