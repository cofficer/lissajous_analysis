
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

    cfgin{idx_cfg}.restingfile             = restingpaths(icfg).name;%40 100. test 232, issues.
    fullpath                            = dir(sprintf('%s%s/*01.ds',mainDir,restingpaths(icfg).name));
    cfgin{idx_cfg}.fullpath                = sprintf('%s%s',mainDir,fullpath.name);
    %Define which blocks to run.
    cfgin{idx_cfg}.blocktype               = 'trial'; % trial or continuous.
    cfgin{idx_cfg}.stim_self               = 'stim'; %For preproc_trial. Either stim or self.

    idx_cfg = idx_cfg + 1;
    %cfgin=cfgin{4}
end


%Define script to run and whether to run on the torque
runcfg.execute         = 'freq_plot'; %freq preproc, parallel, findsquid, check_nSensors,freq_plot
runcfg.timreq          = 2000;      %number of minutes.
runcfg.parallel        = 'torque';  %local or torque


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
        %cellfun(@restingPreprocNumbers, cfgin);
        runcfg.nnodes = 1;%64; % how many licenses?
        runcfg.stack = 1;%round(length(cfg1)/nnodes);

        if strcmp(cfgin{1}.blocktype,'continuous')

          freq_lissajous_wrap(cfgin,runcfg)

        else
          qsubcellfun(@freq_lissajous, cfgin, 'compile', 'no', ...
            'memreq', 1024^3, 'timreq', runcfg.timreq*60, 'stack', runcfg.stack, 'StopOnError', false, 'backend', runcfg.parallel,'matlabcmd','matlab91');
        end

    case 'freq_plot'


      %remove some participants from plotting.

      part_available = str2num(cfgin{1}.restingfile(2:3)):str2num(cfgin{end}.restingfile(2:3));
      remove_part = ones(1,length(part_available));

      if strcmp(cfgin{1}.blocktype,'continuous')
        remove_part(1)=0; % Only one reponse
        remove_part(8)=0;
        remove_part(11)=0;
        remove_part(16)=0;
        cfg =[];
        part_available(logical(~remove_part))=[];
        cfg.part_available=part_available;

        %remove error participants.
        cfgin={cfgin{part_available}};
      end



      %cfgin.blocktype='trial';

      filepath = sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin{1}.blocktype)
      cd(filepath)

      %settings for plotting and loading or creating average freq files.
      for icfgin = 1:length(cfgin)
        cfgin{icfgin}.part_ID=str2num(cfgin{icfgin}.restingfile(2:3));
        cfgin{icfgin}.freqrange='high';
        %Create new average freq or not.
        cfgin{icfgin}.load_avg   = 'all'; %switch,createSwitch,createAll
        %Create topo of tfr plots
        cfgin{icfgin}.topo_tfr = 'topo-all';
      end



      runcfg.nnodes = 1;%64; % how many licenses?
      runcfg.stack = 1;%round(length(cfg1)/nnodes);
      %cellfun(@main_individual_freq, cfgin,'UniformOutput',false);
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
