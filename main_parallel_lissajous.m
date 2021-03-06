function main_parallel_lissajous(input)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Main lissajous wrapper for all parallelized processing of scripts..%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %
  %Remake this script into a function that can be passed through using bash.
  %Changed 20/03/2018.
  %
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  % clear all
  %%6-11
  %Change the folder to where eyelink data is contained
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/code')
  startup_liss
  % mainDir = '/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/raw_data';
  mainDir = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/';
  cd(mainDir)

  %Store all the seperate data files
  restingpaths = dir('P*');
  restingpaths = restingpaths(1:end);
  % idxs=[2,4,6,8,10,11,13,14,15,16,19,20,21,22,24];
  % cfgin=cfgin(idxs);
  % idx_rest = zeros(1,29);
  % idx_rest(idxs)=1;

  %Loop all data files into seperate jobs
  %do these: restingpaths=restingpaths(1,2,4,6,8,10,11,13,14,15,16,19,20,21,22,24)
  % idx_cfg=1;
  for icfg = 1:length(restingpaths)
    % icfg = input;
    % if ismember(icfg,[2])
    %   continue % idxs=[11,18,21,22,24,25,26,27];
    % end

    cfgin{icfg}.restingfile             = restingpaths(icfg).name;%40 100. test 232, issues.
    fullpath                      = dir(sprintf('%s%s/*01.ds',mainDir,restingpaths(icfg).name));
    cfgin{icfg}.fullpath                = sprintf('%s%s',mainDir,fullpath.name);
    %Define which blocks to run.
    cfgin{icfg}.blocktype               = 'trial'; % trial or continuous.
    cfgin{icfg}.stim_self               = 'self'; %For cont resp use resp. For Cont use cont. For preproc_trial. Either stim or self.
    %Or stim_off = data from when stimulus offset.
    %Baseline = time-period 100-600ms after stim offset
    %Define baseline period.
    cfgin{icfg}.prestim = 4.4; %Before self_occlusion
    cfgin{icfg}.poststim = 5.3;

    % idx_cfg = idx_cfg + 1;
    %cfgin=cfgin{icfg}
  end

    %Define script to run and whether to run on the torque
    runcfg.execute         = 'freq_plot'; %freq preproc, parallel, findsquid, check_nSensors,freq_plot
    runcfg.timreq          = 2000;      %number of minutes.
    runcfg.parallel        = 'local';  %local or torque


    %Execute jobs on the torque
    switch runcfg.execute

    case 'headmove'
      mm_move=[];
      for icfg2 = 20:29
        mm_move(icfg2-1,:) = average_head_rotation(cfgin{icfg2})
      end
      % oldmove =mm_move;
      % nanstd(mm_move(:))
    case 'preproc'
      %restingPreprocNumbers(cfgin{1})
      %cellfun(@preproc_lissajous, cfgin,'UniformOutput',false)
      nnodes = 1;%64; % how many licenses?
      stack = 1;%round(length(cfg1)/nnodes);
      % qsubcellfun(@preproc_lissajous, cfgin, 'compile', 'no', ...
      % 'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');
      preproc_lissajous(cfgin)

    case 'freq'
      %restingPreprocNumbers(cfgin{1})
      %cellfun(@freq_lissajous, cfgin,'UniformOutput',false);
      runcfg.nnodes = 1;%64; % how many licenses?
      runcfg.stack = 1;%round(length(cfg1)/nnodes);

      %Set freqrange
      % for icfg = 1:length(cfgin)
      %   cfgin{icfg}.freqrange = 'high';
      % end
      cfgin.freqrange='high';
      if strcmp(cfgin.blocktype,'continuous')

        freq_lissajous_wrap(cfgin,runcfg)

      else
        % qsubcellfun(@freq_lissajous, cfgin, 'compile', 'no', ...
        % 'memreq', 7e9, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');
        freq_lissajous(cfgin)

      end

    case 'freq_plot'



      filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin{1}.blocktype)
      cd(filepath)

      %settings for plotting and loading or creating average freq files.
       for icfgin = 1:length(cfgin)
        cfgin{icfgin}.part_ID=str2num(cfgin{icfgin}.restingfile(2:3));
        cfgin{icfgin}.freqrange='low';
        %Create new average freq or not.
        cfgin{icfgin}.load_avg   = 'createSwitch'; %switch,createSwitch,createAll, loadAll
        %Create topo of tfr plots
        %cfgin=cfgin{29} % cfgin=cfgin(1:28)
        cfgin{icfgin}.topo_tfr = 'no_plot'; %topo-all, no_plot
        %This depends on the what the data is locked to.
        %If baseline cue then load the precue data as basline.
        cfgin{icfgin}.baseline                = 'self'; %[-2.75 -2.25];

        %comment out to avoid saving the number of trials used for averaging.
        [info_stable,info_switch]=save_trial_info(cfgin{icfgin});
        stable_nr(icfgin)=size(info_stable,1);
        switch_nr(icfgin)=size(info_switch,1);
        % main_individual_freq(cfgin{icfgin})
       end

       %cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
       %save('trialNrTrial_StableSwitch.mat','stable_nr', 'switch_nr')


      runcfg.nnodes = 1;%64; % how many licenses?
      runcfg.stack = 1;%round(length(cfg1)/nnodes);
      %cellfun(@main_individual_freq, cfgin,'UniformOutput',false);
      % qsubcellfun(@main_individual_freq, cfgin, 'compile', 'no', ...
      % 'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');

      main_individual_freq(cfgin)

      %save info trials


    case 'filter'

      filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin{1}.blocktype)
      cd(filepath)

      %settings for plotting and loading or creating average freq files.
      for icfgin = 1:length(cfgin)
        cfgin{icfgin}.part_ID=str2num(cfgin{icfgin}.restingfile(2:3));
        cfgin{icfgin}.freqrange='low';
        %Create new average freq or not.
        cfgin{icfgin}.load_avg   = 'createAll'; %switch,createSwitch,createAll, loadAll
        %Create topo of tfr plots
        %cfgin=cfgin{29}
        cfgin{icfgin}.topo_tfr = 'no_plot'; %topo-all, no_plot
        %This depends on the what the data is locked to.
        %If baseline cue then load the precue data as basline.
        cfgin{icfgin}.baseline                = 'stimoff'; %[-2.75 -2.25];
      end



      runcfg.nnodes = 1;%64; % how many licenses?
      runcfg.stack = 1;%round(length(cfg1)/nnodes);
      %cellfun(@main_individual_freq, cfgin,'UniformOutput',false);
      qsubcellfun(@freq_filter, cfgin, 'compile', 'no', ...
      'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');


    end
  % end
  %%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Cell for execuing ICA analysis and saving all the resulting components.%
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %read all the names of resting datasets
  %cd('/mnt/homes/home024/ktsetsos/resting')

  %Store all the seperate data files
  %restingpaths = dir('*.mat');


  %Read csv of all paticipants to avoid
  %cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos/resting/preprocessed')
  %fid = fopen('participantsNoEyelink.csv');
  %C = textscan(fid, '%s');
  %fclose(fid);

  %define the script to run.
  %runcfg.execute = 'ICA';
  %runcfg.timreq          = 2000; % number of minutes.
  %runcfg.parallel         ='torque';


  %Datasets which contain eyelink ata and has been properly preprocessed
  %dataEyelink = setdiff({restingpaths.name},C{1});

  %for icfg = 1:length(dataEyelink)
  %    cfgin{icfg}             = dataEyelink{icfg};%40 100. test 232, issues.
  %end


  %Execute jobs on the torque
  %run_parallel_Numbers(runcfg, cfgin)


  %%
  %Run the script coherenceICA to compute the components which are the most
  %likely to contain both heart rate and blinks.


  %read all the names of resting datasets
  %cd('/mnt/homes/home024/ktsetsos/resting')

  %Store all the seperate data files
  %restingpaths = dir('*.mat');


  %Read csv of all paticipants to avoid
  %cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/ktsetsos/resting/preprocessed')
  %fid = fopen('participantsNoEyelink.csv');
  %C = textscan(fid, '%s');
  %fclose(fid);

  %define the script to run.
  %runcfg.execute = 'cohICA';
  %runcfg.timreq          = 2000; % number of minutes.
  %runcfg.parallel         ='torque';


  %Datasets which contain eyelink ata and has been properly preprocessed
  %dataEyelink = setdiff({restingpaths.name},C{1});

  %for icfg = 1:1%length(dataEyelink)
  %    cfgin{icfg}             = dataEyelink{100};%40 100. test 232, issues.
  %end


  %Execute jobs on the torque
  %run_parallel_Numbers(runcfg, cfgin)


end


%%
%Remove the components
