function output = plot_cluster_switchnoswitch(cfgin)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Correlate switch-related activity with
  %upcoming perceptual duration.
  %Created 17/11/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

 
  
  %What are we looking for? Consistency in the results across participants.
  %Lets compare fast RTs with slow RTs and observe the visual cortical
  %responses. 
  
  %   find all participant id.
  participants = dir('/home/chris/Documents/lissajous/data/continous_self_freq/*freq_low_selfocclBlock2.mat');
  
  % Load all the freq blocks and joing them
  for ipart = 1:29
      close all
      files = dir(sprintf('/home/chris/Documents/lissajous/data/continous_self_freq/%sfreq_low_selfocclBlock*.mat',participants(ipart).name(1:2)));
      
      cd(files(1).folder)
      
      %   load(sprintf('/home/chris/Documents/lissajous/data/contin
      freqAll = [];
      
      for ifile = 1:length(files)
          cfg = [];
          
          load(files(ifile).name);
          
          if ifile>1
              [freqAll] = append_trialfreq([],freqAll,freq);
          else
              freqAll=freq;
          end
          
      end
      
      %   load(sprintf('/home/chris/Documents/lissajous/data/continous_self_freq/%dfreq_low_selfocclBlock4.mat',14))
      
      %Loop over the 4 types of conditions. Switch, no switch, and
      %left/right rotation/response. 
      
      for itype=1:4
          figure('Position',[10 10 1800 1200])
          cfg = [];
          cfg.trials = logical(zeros(1,size(freqAll.powspctrm,1)));
          
          switch itype
              case 1
                  indexsameresp = freqAll.trialinfo(:,5)==232 & freqAll.trialinfo(:,7)==0; %225 232
                  namefigure=sprintf('topos_lowfreqs_allblocks_selfoccl_fulltime_right_noswitch');
              case 2
                  indexsameresp = freqAll.trialinfo(:,5)==225 & freqAll.trialinfo(:,7)==0; %225 232
                  namefigure=sprintf('topos_lowfreqs_allblocks_selfoccl_fulltime_left_noswitch');
              case 3
                  indexsameresp = freqAll.trialinfo(:,5)==232 & freqAll.trialinfo(:,7)==1; %225 232
                  namefigure=sprintf('topos_lowfreqs_allblocks_selfoccl_fulltime_right_switch');
              case 4
                  indexsameresp = freqAll.trialinfo(:,5)==225 & freqAll.trialinfo(:,7)==1; %225 232
                  namefigure=sprintf('topos_lowfreqs_allblocks_selfoccl_fulltime_left_switch');
          end
          

          %Remove trials with jumps
           trialMean = zscore(mean(mean(freqAll.powspctrm(:,:,15,:),4),2));
           badtrial = isoutlier(trialMean,'gesd','maxnumoutliers',2);
           
%           plot(trialMean)
%           indexsameresp(trialMean>10) = logical(0);
% isoutlier(trialMean,'gesd','maxnumoutliers',2) 
% gesd: Applies the generalized extreme Studentized deviate test for outliers. 
% This iterative method is similar to 'grubbs', but can perform better when there are multiple outliers masking each other.
          
          cfg.trials(indexsameresp)=1;
          cfg.trials(badtrial) = 0;
          cfg.trials = logical(cfg.trials);
          cfg.avgoverrpt  = 'yes';
          freq2 = ft_selectdata(cfg,freqAll);
          
          cfg = [];
          cfg.baseline = [0.6 0.9];
          cfg.baselinetype = ['db'];
          freq2 = ft_freqbaseline(cfg,freq2);
          
          cfg=[];
%           cfg.baseline = [-2.5 2.5];
          cfg.zlim = [-2 2];
          cfg.baselinetype = 'relative';
          cfg.xlim = [-2.5:0.2:2.5];
          cfg.ylim         = [15 30];
          cfg.layout       = 'CTF275_helmet.lay';
          ft_topoplotTFR(cfg,freq2)

                %save figure
          % 225 left reponse, 232 right response. Not sure if that means left
          % rotation or response.

          

          cd('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/basicphys')
          %New naming file standard. Apply to all projects.
          formatOut = 'yyyy-mm-dd';
          todaystr = datestr(now,formatOut);
          figurefreqname = sprintf('%s_part%d_%s_baselinew0609.png',todaystr,ipart,namefigure);
          saveas(gca,figurefreqname,'png')
      
     end
      %%

      
  end
  
  
  %%
  %Behaviour:
%   cue_times = freq.trialinfo(:,2)./1200;
%   
%   
%   resp_times = freq.trialinfo(:,4)./1200;
%   cue_times(resp_times==0) = [];
%   resp_times(resp_times==0)=[];
%   
%   
%   plot(resp_times-cue_times)
% %   histogram(cue_times,30)
%   
%   
%   
%   
%   
%   
%   
%   %Get the stat.mask
%   % load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/continuous/freq/figures/2018-06-04_statistics_switchvsnoswitch.mat')
%   %Get the most recent stat.mask and plot it to check....
% %   load('/Users/c.gahnstrohm/Dropbox/PhD/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
   load('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/2018-11-17_statistics_switchvsnoswitch.mat')
% 
%   % %Sum over time, and freq.
%   data_comp = statout.stat;
%   data_comp(~statout.mask)=NaN
%   %sum over channels...
%   %time
%   data_comp=nansum(data_comp(:,:,:),3);
%   %freq
%   data_comp=nansum(data_comp(:,:,:),2);
%   
%   for in = 10:29
%       load(sprintf('/home/chris/Documents/lissajous/data/continous_self_freq/%dfreq_low_selfocclBlock4.mat',in))
%       
%       figure(in-9),clf
%       freq2=freq;
%       cfg = [];
%       cfg.trials=logical(zeros(1,size(freq.powspctrm,1)));
%       indexsameresp = freq.trialinfo(:,5)==225; %225 232
%       cfg.trials(indexsameresp)=1;
%       cfg.avgoverrpt  = 'yes'
%       freq2 = ft_selectdata(cfg,freq);
%       
%       cfg=[];
%       cfg.ylim         = [15 30];
%       cfg.xlim = [-0.4:0.4:2.5];
%       cfg.baseline = [-1 -0.5];
%       cfg.layout       = 'CTF275_helmet.lay';
%       %cfg.xlim         = [-2.25 2.25];%[2 2.25];%[0.5 4 ];%[2.1 2.4];%
%       % cfg.channel      = freq.label(idx_occ);
%       cfg.interactive = 'no';
%       %   cfg.highlightchannel=freq2.label(data_comp<-80);
%       %   cfg.highlight='on';
%       cfg.highlightcolor =[0.5 0.5 0.5];
%       cfg.highlightsize=22;
%       %   freq2.powspctrm=zeros(size(freq2.powspctrm));
%       ft_topoplotTFR(cfg,freq2)
%       
%       
%   end
end 