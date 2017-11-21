
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

for icfg = 1:length(restingpaths)

    cfgin{icfg}.restingfile             = restingpaths(icfg).name;%40 100. test 232, issues.
    fullpath                            = dir(sprintf('%s%s/*01.ds',mainDir,restingpaths(icfg).name));
    cfgin{icfg}.fullpath                = sprintf('%s%s',mainDir,fullpath.name);
    %Define which blocks to run.
    cfgin{icfg}.blocktype               = 'trial'; % trial or continuous.

    %cfgin=cfgin{29}
end


%Define script to run and whether to run on the torque
runcfg.execute         = 'freq'; %freq preproc, parallel, findsquid, check_nSensors
runcfg.timreq          = 2000;      %number of minutes.
runcfg.parallel        = 'torque';  %local or torque


%Execute jobs on the torque
switch runcfg.execute


    case 'preproc'
        %restingPreprocNumbers(cfgin{1})
        %cellfun(@restingPreprocNumbers, cfgin);
        nnodes = 1;%64; % how many licenses?
        stack = 1;%round(length(cfg1)/nnodes);
        qsubcellfun(@preproc_lissajous, cfgin, 'compile', 'no', ...
              'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');

    case 'freq'
        %restingPreprocNumbers(cfgin{1})
        %cellfun(@restingPreprocNumbers, cfgin);
        runcfg.nnodes = 1;%64; % how many licenses?
        runcfg.stack = 1;%round(length(cfg1)/nnodes);

        if strcmp(cfgin{1}.blocktype,'continuous')

          freq_lissajous_wrap(cfgin,runcfg)

        else
          qsubcellfun(@freq_lissajous, cfgin, 'compile', 'no', ...
            'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');
        end

    case 'freq_plot'


      %remove some participants from plotting.
      part_available = 1:29;
      remove_part = ones(1,length(part_available));
      remove_part(1)=0; % Only one reponse
      remove_part(8)=0;
      remove_part(11)=0;
      remove_part(16)=0;

      cfg =[];
      part_available(logical(~remove_part))=[];
      cfg.part_available=part_available;
      d_average = '/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/average/';
      cd(d_average)
      freqrange  = 'low';

      %Load data which has already been averaged...
      cfg.load_avg = 0;

      %insert the
      for icfgin = 1:length(cfgin)
        cfgin{icfgin}.part_ID=icfgin;
      end

      %remove error participants.
      cfgin={cfgin{part_available}};


      runcfg.nnodes = 1;%64; % how many licenses?
      runcfg.stack = 1;%round(length(cfg1)/nnodes);
      qsubcellfun(@main_individual_freq, cfgin, 'compile', 'no', ...
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
