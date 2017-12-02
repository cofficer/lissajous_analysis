function plot_trial_behavior
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in behavioral data, and plot across events.
  %Created 23/11/2017.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %Reado the reading of all trialinfo, for some reason I did not includ
  %the cue onset or stim onset.

  clear all
  %%
  %Change the folder to where eyelink data is contained
  mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/';
  cd(mainDir)

  %Store all the seperate data files
  restingpaths = dir('P*');
  restingpaths = restingpaths(1:end);

  %Loop all data files into seperate jobs
  idx_cfg=1;
  for icfg = 1:length(restingpaths)

    cfgin{idx_cfg}.restingfile             = restingpaths(icfg).name;%40 100. test 232, issues.
    fullpath                            = dir(sprintf('%s%s/*01.ds',mainDir,restingpaths(icfg).name));
    cfgin{idx_cfg}.fullpath                = sprintf('%s%s',mainDir,fullpath.name);
    %Define which blocks to run.
    cfgin{idx_cfg}.blocktype               = 'trial'; % trial or continuous.
    cfgin{idx_cfg}.stim_self               = 'stim'; %For preproc_trial. Either stim or self.

    idx_cfg = idx_cfg + 1;
    %cfgin=cfgin{4}
  end

  %Loop over all participants, and extract the trial information.
  for icfgin = 1:length(cfgin)

    dsfile = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P%s/',cfgin{icfgin}.restingfile(2:3));
    cd(dsfile)

    %Identify datasets, and load correct block.
    datasets = dir('*ds');

    cd(dsfile)
    datafile=datasets(1).name;

    %Load data into trial-based format.
    cfg                         = [];
    trldef = 'trialfun_lissajous';
    cfg.dataset                 = datafile;
    cfg.trialfun                = trldef; % this is the default
    cfg.trialdef.eventtype      = 'UPPT001';
    cfg.trialdef.eventvalue     = 10; % self-occlusion trigger value
    %TODO: save preprocessed data occuring before the stimulus onset.
    %Stim or selfocclusion is preprocessed
    cfgin{icfgin}.stim_self='stim';
    if strcmp(cfgin{icfgin}.stim_self,'stim')
      cfg.trialdef.prestim        = -2; % in seconds
      cfg.trialdef.poststim       = 1; % in seconds
    else
      cfg.trialdef.prestim        = 2.25; % in seconds
      cfg.trialdef.poststim       = 2.25; % in seconds
    end
    %Stores all the trial information
    cfg = ft_definetrial(cfg);
    %Load or create a table of all trial-based behavior.
    %Create.
    trl_info{icfgin}=cfg.trl;
  end

  % 4rd=stim_on. 6=self-o. 8=stim_off. 10=cue. 12th=resp, 14=end
  trl_info{1}(2,:)

  tot_info = vertcat(trl_info{:});
  %Make the trl_info into a table to remove potential errors in indexing.

  cue_on      = tot_info(:,10);
  stim_on     = tot_info(:,4);
  stim_off    = tot_info(:,8);
  resp        = tot_info(:,12);
  self_occ    = tot_info(:,6);
  block_end   = tot_info(:,14);

  T_info=table(stim_on,self_occ,stim_off,cue_on,resp,block_end);
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  % save('Table_trialinfo.mat','T_info') %load('Table_trialinfo.mat')

  Cue_stimoff   = (T_info.cue_on-T_info.stim_off)./1200;
  RT_stimoff    = (T_info.resp-T_info.stim_off)./1200;
  S_onoff       = (T_info.block_end-T_info.stim_off)./1200;


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
