
addpath(genpath('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/'))
addpath('/home/chris/Documents/lissajous/code/lissajous_analysis/')
% addpath(genpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/toolboxes_matlab/vis3D'))
%addpath('/Users/c.gahnstrohm/Dropbox/spiers07_desktop/toolboxes_matlab/fieldtrip')
addpath('/home/chris/Documents/lissajous/code/fieldtrip-20200607')
ft_defaults

% Choose which tapas, use veith for now
% addpath('/home/chris/Documents/lissajous/code/tapas')
addpath('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/modeling_from_veith/run_model/TAPAS original/tapas2/tapas')
addpath('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/modeling_from_veith/run_model/TAPAS modifications/')

cd('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/modeling_from_veith/run_model/')
tapas_init('hgf')

load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/modeling_from_veith/modelling_results.mat')