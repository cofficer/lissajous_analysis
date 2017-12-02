function plot_trial_behavior
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in behavioral data, and plot across events.
  %Created 23/11/2017.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Load all of the eyelink  data
  clear all
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior/blinks')
  file_blink=dir('*.mat');

  for ifile = 1:length(file_blink)
    disp(ifile)
    load(file_blink(ifile).name);

    all_blink{ifile}=mean(vertcat(blinks{:}),1);

  end

  all_blink = mean(vertcat(all_blink{:}),1);

  figure(1)
  plot(abs(all_blink))
  set(gca,'XTick',[1 1200 2400 3600 4800 6000] ); %This are going to be the only values affected.
  set(gca,'XTickLabel',[0 1 2 3 4 5] ); %This is what it's going to appear in those places.

  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  %Name of figure
  %name filess
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('Blink_distribution');%fractionTrialsRemaining
  filetype    = 'png';
  figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
  saveas(gca,figurename)

  %
  % % 4rd=stim_on. 6=self-o. 8=stim_off. 10=cue. 12th=resp, 14=end
  % trl_info{1}(2,:)
  %
  % tot_info = vertcat(trl_info{:});
  % %Make the trl_info into a table to remove potential errors in indexing.
  %
  % cue_on      = tot_info(:,10);
  % stim_on     = tot_info(:,4);
  % stim_off    = tot_info(:,8);
  % resp        = tot_info(:,12);
  % self_occ    = tot_info(:,6);
  % block_end   = tot_info(:,14);
  %
  % T_info=table(stim_on,self_occ,stim_off,cue_on,resp,block_end);
  % cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  % % save('Table_trialinfo.mat','T_info') %load('Table_trialinfo.mat')
  %
  % Cue_stimoff   = (T_info.cue_on-T_info.stim_off)./1200;
  % RT_stimoff    = (T_info.resp-T_info.stim_off)./1200;
  % S_onoff       = (T_info.block_end-T_info.stim_off)./1200;


  %New way of saving Figure using gramm
  ind_RT =ones(1,length([Cue_stimoff' RT_stimoff' S_onoff']));
  ind_RT(length(Cue_stimoff)+1:(length(Cue_stimoff)+1+length(RT_stimoff)))=2;
  ind_RT((length(Cue_stimoff)+1+length(RT_stimoff))+1:end)=3;

  clean_dat = [Cue_stimoff' RT_stimoff' S_onoff'];
  clean_idx = clean_dat>3;

  %Remove any time > 3sec.
  clean_dat(clean_idx) =[];
  ind_RT(clean_idx)=[];

  clear g;close all
  g=gramm('x',clean_dat,'color',ind_RT);
  % g.geom_jitter();
  g.stat_bin('nbins',200,'dodge',0,'fill','transparent');
  % g.stat_density()
  % g.geom_abline()
  g.set_names('column','Origin','x','Time (s)','color','Dists');
  % g.set_text_options('base_size',20);
  % g.set_color_options('chroma',0,'lightness',20)
  % g(2,1)=gramm('x',RT_stimoff);
  % % g.geom_jitter();
  % g(2,1).stat_density();
  % % g.geom_abline()
  % g(2,1).set_names('column','Origin','x','Reaction time, stim');
  g.set_text_options('base_size',20);
  % g(2,1).set_color_options('chroma',0,'lightness',20)
  g.set_title('Time (s) since rotation stop');
  %g.facet_grid('space','free')
  figure('Position',[100 100 800 600]);
  g.draw();
  g.facet_grid('scale','free')

  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  %Name of figure
  filetyp='svg';
  %name filess
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('ReactionTimeDist_CueRespOn');%fractionTrialsRemaining
  filetype    = 'svg';
  figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
  g.export('file_name',figurename,'file_type',filetype);



  %//////////////////////////
  %Plot only reaction Time
  %//////////////////////////
  clear g;close all
  g=gramm('x',(T_info.resp-T_info.cue_on)'./1200);
  % g.geom_jitter();
  g.stat_bin('nbins',200,'dodge',0,'fill','transparent');
  % g.stat_density()
  % g.geom_abline()
  g.set_names('column','Origin','x','Time (s)');
  % g.set_text_options('base_size',20);
  % g.set_color_options('chroma',0,'lightness',20)
  % g(2,1)=gramm('x',RT_stimoff);
  % % g.geom_jitter();
  % g(2,1).stat_density();
  % % g.geom_abline()
  % g(2,1).set_names('column','Origin','x','Reaction time, stim');
  g.set_text_options('base_size',20);
  % g(2,1).set_color_options('chroma',0,'lightness',20)
  %g.set_title('');
  %g.facet_grid('space','free')
  figure('Position',[100 100 800 600]);
  g.draw();
  g.facet_grid('scale','free')

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


    %//////////////////////////
    %Plot Dist Response to stimulus Movement.
    %//////////////////////////
    clear g;close all
    g=gramm('x',(T_info.block_end-T_info.resp)'./1200);
    % g.geom_jitter();
    g.stat_bin('nbins',200,'dodge',0,'fill','transparent');
    % g.stat_density()
    % g.geom_abline()
    g.set_names('column','Origin','x','Time (s)');
    % g.set_text_options('base_size',20);
    % g.set_color_options('chroma',0,'lightness',20)
    % g(2,1)=gramm('x',RT_stimoff);
    % % g.geom_jitter();
    % g(2,1).stat_density();
    % % g.geom_abline()
    % g(2,1).set_names('column','Origin','x','Reaction time, stim');
    g.set_text_options('base_size',20);
    % g(2,1).set_color_options('chroma',0,'lightness',20)
    %g.set_title('');
    %g.facet_grid('space','free')
    figure('Position',[100 100 800 600]);
    g.draw();
    g.facet_grid('scale','free')

    cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
    %Name of figure
    filetyp='svg';
    %name filess
    formatOut = 'yyyy-mm-dd';
    todaystr = datestr(now,formatOut);
    namefigure = sprintf('RespRotationOnsetDist');%fractionTrialsRemaining
    filetype    = 'svg';
    figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
    g.export('file_name',figurename,'file_type',filetype);

    %Percentage of response close to trial end.
    a=sum((T_info.block_end-T_info.resp)'./1200>0.5)/length(T_info.resp)

  %Percentage of late response
  sum((T_info.resp-T_info.cue_on)'./1200>1)/length(T_info.resp);


  end
