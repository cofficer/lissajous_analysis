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
remove_part(25)=0;

% remove_part(29)=0;
% remove_part(19)=0;
% remove_part(17)=0;
% remove_part(28)=0;
% remove_part(24)=0;
% remove_part(23)=0;
% remove_part(22)=0;
% remove_part(21)=0;

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
partnum = cell2mat(cellfun(@str2num,partnum,'un',0));

%Found the participants which are present as average data
%and are not flagged as bad form hard coding and 100trials of each..
part_idx = ismember(partnum,part_available);


namecell = namecell(part_idx);


freq_switch = zeros(length(namecell),274,33,101);
freq_stable = zeros(length(namecell),274,33,101);
%Loop over participants
for ipart = 1:length(namecell)

  %Load the freq data
  load(namecell{ipart})
  disp(sprintf('Loading data from participant: %s',namecell{ipart}))
  %store details about each freq.
  freq_switch(ipart,:,:,:) = switchTrial;
  freq_stable(ipart,:,:,:) = stableTrial; %freq.powspctrm=switchTrial;

end

freq_switch=squeeze(nanmean(freq_switch,1));
freq_stable=squeeze(nanmean(freq_stable,1));

freq.powspctrm =freq_stable;%freq_switch-freq_stable;

idx_occ=strfind(freq.label,'O');
idx_occ=find(~cellfun(@isempty,idx_occ));
figure(1),clf
cfg = [];
cfg.baseline = [2 2.3];
cfg.baselinetype = 'relative';
cfg.masktype     = 'saturation';
cfg.zlim         = [-5 5];
%cfg.ylim         = [3 35];
cfg.layout       = 'CTF275_helmet.lay';
%cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
cfg.channel      = freq.label(idx_occ);
cfg.interactive = 'no';
ft_singleplotTFR(cfg,freq);
%ft_multiplotTFR(cfg,freq)
%ft_topoplotTFR(cfg,freq)
%ft_hastoolbox('brewermap', 1);
colormap(flipud(brewermap(64,'RdBu')))


%Save figure active.
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures')
%New naming file standard. Apply to all projects.
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('OwnBaseline_Stable_lowfreq_TFR_%dParticipants',ipart);%Stage of analysis, frequencies, type plot, baselinewindow

figurefreqname = sprintf('%s_%s.png',todaystr,namefigure)%2012-06-28 idyllwild library - sd - exterior massing model 04.skp

saveas(gca,figurefreqname,'png')
end
