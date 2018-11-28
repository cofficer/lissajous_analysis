function output = plot_meg_stay_duration_kloosterman(nPart)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Correlate switch-related activity with
%upcoming perceptual duration.
%In order to replicate the correlation:
%1. Piecewise linear detrending of the scalar MEG/trial. -STRANGE.
%2. Group the resulting scalar trial values into 10 equal valued bins.
%2. normalize by the median percept duration. Or don't.
%Created 28/11/2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

cd('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/beta_cluster_self_switch')

nfiles = dir('*.mat');

load(nfiles(2).name)

end
