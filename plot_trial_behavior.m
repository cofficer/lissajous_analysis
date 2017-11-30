function plot_trial_behavior
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in behavioral data, and plot across events.
  %Created 23/11/2017.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Reado the reading of all trialinfo, for some reason I did not includ
  %the cue onset or stim onset. 

  %Load or create a table of all trial-based behavior.
  %Create.


  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/trial/freq/')

  freqfiles= dir('*stim_high*');


  %Load all participants
  for ifiles = 1:length(freqfiles)
    disp(freqfiles(ifiles).name)
    load(freqfiles(ifiles).name)
    trl_info{ifiles}=freq.trialinfo;
  end

  % 3rd=selfO. 5=stim_off. 7=response. 9th=trial
  trl_info{1}(2,:)

  %Plot the distribution using gramm.
  %Time from stim_off until response
  RT=[];
  for ipart = 1:length(trl_info)

    old_len = length(RT);
    cur_len = length(trl_info{1})+old_len;

    RT(old_len+1:cur_len) = (trl_info{1}(:,7)-trl_info{1}(:,5))./1200;

  end


%New way of saving Figure using gramm
clear g;close all
g=gramm('x',RT);
% g.geom_jitter();
g.stat_density();
% g.geom_abline()
g.set_names('column','Origin','x','Reaction time');
g.set_text_options('base_size',20);
g.set_color_options('chroma',0,'lightness',20)
%g.set_title('');
g.draw();

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
%Name of figure
filetyp='svg';
%name filess
formatOut = 'yyyy-mm-dd';
todaystr = datestr(now,formatOut);
namefigure = sprintf('ReactionTimeDist');%fractionTrialsRemaining
filetype    = 'svg';
figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
g.export('file_name',figurename,'file_type',filetype);






end
