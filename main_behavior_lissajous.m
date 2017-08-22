%Main behavior script for lissajous


load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior/allTrialsTable.mat')

max(trlTA.trlN)

figure(1),clf
plot(trlTA.trlN)

saveas(gca,'trialsNpl.png','png')
