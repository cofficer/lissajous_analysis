function [freq,switchTrial,stableTrial]=plot_TFRs_average(part_ID)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in averaged freq data, and plot average.
%Created 26/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%Select participants with more than 100 trials of each conditions
load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/buttonpress_all.mat')
BP1_ind = BP1>100;
BP2_ind = BP2>100;
BP_ind = (BP1_ind.*BP2_ind);


part_available = 1:29;
remove_part = ones(1,length(part_available));
remove_part(1)=0; % Only one reponse
remove_part(8)=0;
remove_part(10)=0; %artifacts
remove_part(11)=0;
remove_part(16)=0;

remove_part=BP_ind.*remove_part;

part_available(logical(~remove_part))=[];


cfgin.blocktype='continuous';
filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/average',cfgin.blocktype)
cd(filepath)

freqrange  = 'low';
doplot     = 0;
compSwitch = 0;
freqpath   = dir(sprintf('*%s*',freqrange));

%Remove participant nr 10, super weird artifacts.
namecell = {freqpath.name};

partnum = cellfun(@(x) x(14:15),namecell,'UniformOutput',false);
partnum = strrep(partnum,'.','');


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


end
