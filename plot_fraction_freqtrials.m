



function [freqrange] = plot_fraction_freqtrials(~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Purpose to plot using gramm, the distribution of
%trials available per participant after running preprocessing
%11-Sep-2017, CG.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

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

%idx_partnum = ~strcmp(partnum,'10');
%namecell = namecell(idx_partnum);

%Loop over participants
for ipart = 1:length(namecell)

  %Load the freq data
  load(namecell{ipart})
  disp(sprintf('Loading data from participant: %s',namecell{ipart}(1:2)))
  %store details about each freq.
  partInfo(ipart).trialinfo = freq.trialinfo;
  partInfo(ipart).ID        = namecell{ipart}(1:2);
end

%Make this per participant instead of per block.
lastID=partInfo(1).ID(1:2);
ipart=1;
lenblock(1)=size(partInfo(1).trialinfo,1);

%Seperate into the two types of responses.
if sum(partInfo(1).trialinfo(:,5)==226)>0
  partInfo(1).trialinfo(partInfo(1).trialinfo(:,5)==226,5)=225;
  partInfo(1).trialinfo(partInfo(1).trialinfo(:,5)==228,5)=232;
elseif sum(partInfo(1).trialinfo(:,5)==228)>0
  partInfo(1).trialinfo(partInfo(1).trialinfo(:,5)==226,5)=225;
  partInfo(1).trialinfo(partInfo(1).trialinfo(:,5)==228,5)=232;
end
BP1(1) = sum(partInfo(1).trialinfo(:,5)==225);
BP2(1) = sum(partInfo(1).trialinfo(:,5)==232);
allID{1}=partInfo(1).ID(1:2);
%Loop to count number of trials remaining.
for ilen = 2:length(partInfo)

  % BPidx = unique(partInfo(ilen).trialinfo(:,5));
  % BP1idx = BPidx(1) partInfo(ilen).ID
  % BP2idx = BPidx(2)
  if sum(partInfo(ilen).trialinfo(:,5)==226)>0
    partInfo(ilen).trialinfo(partInfo(ilen).trialinfo(:,5)==226,5)=225;
    partInfo(ilen).trialinfo(partInfo(ilen).trialinfo(:,5)==228,5)=232;
  elseif sum(partInfo(ilen).trialinfo(:,5)==228)>0
    partInfo(ilen).trialinfo(partInfo(ilen).trialinfo(:,5)==228,5)=232;
    partInfo(ilen).trialinfo(partInfo(ilen).trialinfo(:,5)==226,5)=225;
  end
  %Store the ID of the current participant block
  currID = partInfo(ilen).ID(1:2);
  if strcmp(currID,lastID)
    %keep adding the trialnumbers
    lenblock(ipart)=lenblock(ipart)+size(partInfo(ilen).trialinfo,1);

    %Seperate into the two types of responses.

    BP1(ipart) = BP1(ipart) + sum(partInfo(ilen).trialinfo(:,5)==225);
    BP2(ipart) = BP2(ipart) + sum(partInfo(ilen).trialinfo(:,5)==232);

  else
    %update the lastID
    lastID=partInfo(ilen).ID(1:2);
    ipart=ipart+1;
    %Save the name of ID of each participant
    %To know what is left out.
    allID{ipart}=partInfo(ilen).ID(1:2);
    lenblock(ipart)=size(partInfo(ilen).trialinfo,1);
    %Seperate into the two types of responses.
    BP1(ipart) = sum(partInfo(ilen).trialinfo(:,5)==225);
    BP2(ipart) = sum(partInfo(ilen).trialinfo(:,5)==232);
  end
end

%Create struct with fields for relevant information.
responses.BP1 = BP1;
responses.BP2 = BP2;
responses.ID  = 1:length(BP1);


cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')

figure(1),clf
clear g
g=gramm('x',[1:29,1:29],'y',[BP1+BP2,BP2],'color',[ones(1,length(BP1)),ones(1,length(BP1))*2]');
g.geom_bar()
%g.stat_summary()
g.set_names('column','Origin','x','Participant category','y','trials remaining (max 804)','color','Left vs. right choices');
g.draw();

%name files
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('trialRemain_grouped');%fractionTrialsRemaining
filetype    = 'png';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp
g.export('file_name',figurename,'file_type',filetype)
%saveas(gca,figurename,'pdf')

end

%%Make a nice ggplot for practice.
