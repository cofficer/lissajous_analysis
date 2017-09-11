



function [freqrange] = plot_fraction_freqtrials(~)


clear all;
cfgin.blocktype='continuous';
filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype)

cd(filepath)

freqrange  = 'low';
doplot     = 0;
compSwitch = 0;
freqpath   = dir(sprintf('*%s*-26-26*',freqrange));




%Remove participant nr 10, super weird artifacts.
namecell = {freqpath.name};

partnum = cellfun(@(x) x(1:2),namecell,'UniformOutput',false);

idx_partnum = ~strcmp(partnum,'10');

namecell = namecell(idx_partnum);

%Loop over participants
for ipart = 1:length(namecell)

  %Load the freq data
  load(namecell{ipart})

  %store details about each freq.
  partInfo(ipart).trialinfo = freq.trialinfo;
  partInfo(ipart).ID        = namecell{ipart};
end

%Make this per participant instead of per block.
lastID=partInfo(1).ID(1:2);
ipart=1;
lenblock(1)=size(partInfo(1).trialinfo,1);

%Loop to count number of trials remaining.
for ilen = 2:length(partInfo)
  currID = partInfo(ilen).ID(1:2);
  if strcmp(currID,lastID)
    %keep adding the trialnumbers
    lenblock(ipart)=lenblock(ipart)+size(partInfo(ilen).trialinfo,1);
  else
    %update the lastID
    lastID=partInfo(ilen).ID(1:2);
    ipart=ipart+1;
    lenblock(ipart)=size(partInfo(ilen).trialinfo,1);
  end
end


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')

figure(1),clf
g=gramm('x',1:length(lenblock),'y',lenblock/804);
g.geom_bar()
g.set_names('column','Origin','x','Participant category','y','% of trials remain (max 804)','color','# Cylinders');
g.draw();

%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('fractionTrialsRemaining');
filetype    = 'png';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
g.export('file_name',figurename,'file_type',filetype)
%saveas(gca,figurename,'pdf')

end

%%Make a nice ggplot for practice.
