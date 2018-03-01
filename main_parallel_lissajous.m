
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Main lissajous wrapper for all parallelized processing of scripts..%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%
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
    % if ismember(icfg,[2])
    %   continue % idxs=[11,18,21,22,24,25,26,27];
    % end

    cfgin{idx_cfg}.restingfile             = restingpaths(icfg).name;%40 100. test 232, issues.
    fullpath                            = dir(sprintf('%s%s/*01.ds',mainDir,restingpaths(icfg).name));
    cfgin{idx_cfg}.fullpath                = sprintf('%s%s',mainDir,fullpath.name);
    %Define which blocks to run.
    cfgin{idx_cfg}.blocktype               = 'continuous'; % trial or continuous.
    cfgin{idx_cfg}.stim_self               = 'self'; %For cont resp use resp. For Cont use cont. For preproc_trial. Either stim or self.
                                                         %Or stim_off = data from when stimulus offset.
                                                         %Baseline = time-period 100-600ms after stim offset
    %Define baseline period.
    cfgin{idx_cfg}.prestim = 4.4; %Before self_occlusion
    cfgin{idx_cfg}.poststim = 5.3;

    idx_cfg = idx_cfg + 1;
    %cfgin=cfgin{28}
end

%Define script to run and whether to run on the torque
runcfg.execute         = 'filter'; %freq preproc, parallel, findsquid, check_nSensors,freq_plot
runcfg.timreq          = 2000;      %number of minutes.
runcfg.parallel        = 'local';  %local or torque


%Execute jobs on the torque
switch runcfg.execute


    case 'preproc'
        %restingPreprocNumbers(cfgin{1})
        %cellfun(@preproc_lissajous, cfgin,'UniformOutput',false)
        nnodes = 1;%64; % how many licenses?
        stack = 1;%round(length(cfg1)/nnodes);
        qsubcellfun(@preproc_lissajous, cfgin, 'compile', 'no', ...
              'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');

    case 'freq'
        %restingPreprocNumbers(cfgin{1})
        %cellfun(@freq_lissajous, cfgin,'UniformOutput',false);
        runcfg.nnodes = 1;%64; % how many licenses?
        runcfg.stack = 1;%round(length(cfg1)/nnodes);

        if strcmp(cfgin{1}.blocktype,'continuous')

          freq_lissajous_wrap(cfgin,runcfg)

        else
          qsubcellfun(@freq_lissajous, cfgin, 'compile', 'no', ...
            'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');
        end

    case 'freq_plot'



      filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin{1}.blocktype)
      cd(filepath)

      %settings for plotting and loading or creating average freq files.
      for icfgin = 1:length(cfgin)
        cfgin{icfgin}.part_ID=str2num(cfgin{icfgin}.restingfile(2:3));
        cfgin{icfgin}.freqrange='high';
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
      qsubcellfun(@main_individual_freq, cfgin, 'compile', 'no', ...
        'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');



    case 'filter'

      filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin{1}.blocktype)
      cd(filepath)

      %settings for plotting and loading or creating average freq files.
      for icfgin = 1:length(cfgin)
        cfgin{icfgin}.part_ID=str2num(cfgin{icfgin}.restingfile(2:3));
        cfgin{icfgin}.freqrange='high';
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





%%
%Remove the components
