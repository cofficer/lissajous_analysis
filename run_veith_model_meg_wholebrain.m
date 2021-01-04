function run_veith_model_meg_wholebrain
% % % % % % % % % % % % % % 
% Correlate with whole brain instead of the roi 
% Moreover, use baselined data.
% Created 24/09/2020. @Cofficer
% % % % % % % % % % % % % % 

% load all model data
% load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas.mat')
% load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_HGFv6.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_veith_22nov.mat')

% load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')
% load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo_trlnumblock_v2.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo_blocks.mat')

%   find all participant id./media/chris/Elements/Projects/Lissajous
participants = dir('/media/chris/Elements/Projects/Lissajous/continous_self_freq/*freq_low_selfocclBlock2.mat');
  
% error part1,2,3,4,6,16 Missmatch with number of trials. 
% error part13, 15, 26 no modelling results.
% Start with fixing error of missmatch. 
for ipart = 1:9
    
    parts = participants(ipart).name(1:2);

    % daq - the timecourse for the inverted model. Not the correct parameter. 
    % let's look at the prediction errors instead on different levels. 
    % mu = model prediction 
    % muhat = model prediction, one step ahead?
    model_dat = Model{8}.subject{str2num(parts)}.session.traj.muhat(:,2);
    resp_mode = Model{8}.subject{str2num(parts)}.session.y;

    filenames = dir(sprintf('/media/chris/Elements/Projects/Lissajous/continous_self_freq/%sfreq_low_selfocclBlock*.mat',parts));

    trlTA_1 = trlTA(trlTA.participant==str2num(parts),:);

    for iblock = 1:length(filenames)
      disp(iblock)
      cd('/media/chris/Elements/Projects/Lissajous/continous_self_freq/')
      load(filenames(iblock).name)

      % TODO: remove artifacts, muscle and eye.
      latency = [-2.5 2.5];
      %seems strange how many trials are removed...        
      [freq,freqsamples, idx_artifacts] = clean_resp(trlTA_1,freq,parts,iblock, latency);

      % av=sum(~isnan(freq.powspctrm(:)));

      if iblock == 1

        all_trial = freq.trialinfo;

        freqsamples_all = freqsamples;
        idx_artifacts_all = idx_artifacts;
        freqAll=freq;
        freqAll.sampletrials = freqAll.cfg.previous.previous.previous.previous.previous.previous.previous.trl(freqAll.cfg.trials,1:2);

      else
        all_trial = [all_trial;freq.trialinfo];
        freqsamples_all = [freqsamples_all;freqsamples];
        idx_artifacts_all = [idx_artifacts_all;idx_artifacts];
        [freqAll] = append_trialfreq([],freqAll,freq);
      end

    end
    
    %compare the behaviour of the freq and the trlTA and the model
    %p18, perfect overlap. However, model_dat is missing 5 trials
    %FIX: the reason is the NaNs. Remove nans from idx_artifacts and it should match. 
    %p01: the idx_artifacts is larger than the freqAll trials. 3 trials too
    %many are removed. 689 vs 697. Diff 8... 
    %p02: model_dat 3 too many trials... 
    %P04, cannot run idx_artifacts_all removal off NaN values. 
    %There is a large issue here of trialfun definition... 
%     size(trlTA_1.responseValue(idx_artifacts_all))
%     size(idx_artifacts_all)
%     
%     % resp model, has already removed all the NaNs from trlTA. 
%     % 
     if ismember(ipart,[19,22,8])
        model_dat=model_dat(1:271);
        idx_artifacts_all_model = idx_artifacts_all(~isnan(trlTA_1.responseValue(1:271)));
        model_dat=model_dat(idx_artifacts_all_model); 
     else
        idx_artifacts_all_model = idx_artifacts_all(~isnan(trlTA_1.responseValue));
        model_dat=model_dat(idx_artifacts_all_model); 
     end
     
     if ipart == 2
        model_dat= [model_dat(1:210)',model_dat(212:325)', model_dat(327:485)', 0, model_dat(486:643)',model_dat(645:650)',model_dat(652:696)',model_dat(698:end)',0];
     end
     
     if ipart == 3 %to complete
         %checking the samples of start trial,
         %1500 difference between table and lissajous. 
         %same number of trials
         %perfect match... 
        resp_mode_0 = resp_mode==0;
        resp_mode_1 = resp_mode==1;
        resp_mode(resp_mode_0)=1;
        resp_mode(resp_mode_1)=0;
        
        plot(freqAll.sampletrials(:,1)-1500)
        hold on
        plot(trlTA_1.StartTrial)
        legend('freqAll','trlTA')
        
        
        %find the right samples 
        % take the trials that are remaining in freqAll. Make sure these 
        % samples are present in the trials used in modelling. 
        % we could do this on a per loaded freq data basis. 
        % Now we have the same trails and trialinfo as in the modelling.          
        trlTA_1_clean = trlTA_1(~isnan(trlTA_1.responseValue),:);
        
%         trlTA_1_clean.StartTrial
        
        % important need to check that all sample numbers are unique. 
        if length(unique(freqAll.sampletrials(:,1)))==length(freqAll.sampletrials)
            disp('all trials unique samples')
        end
            
        
        %check if current trial exists in freqAll sampletrials. 
        %first we need to remove all the sampletrials that do not 
        %exist in freqAll. 
        %easy to compare.. maybe not that easy. 
        % trlTA_1_clean is the proxy for model_dat. 
        % we check each of sample value against freq data. If one sample is
        % missing then we remove from trlTA_1_clean aka, model_dat. 
        % maybe does not make sense to remove from model_dat before
        % checking samples. 
        
        idx_match = [];
        new_resps = [];
        
        %add new columns in trialfun
        freqAll.trialinfo(:,8)=NaN;
        freqAll.trialinfo(:,9)=NaN;
        
        for itrials = 1:length(trlTA_1_clean.StartTrial)
            [matching , matchid ] = ismember(trlTA_1_clean.StartTrial(itrials),freqAll.sampletrials(:,1)-1500);
            
            if matching == 1
                freqAll.trialinfo(matchid,8) = model_dat(itrials);
                freqAll.trialinfo(matchid,9) = resp_mode(itrials);
                new_resps = [new_resps;resp_mode(itrials)];
            end
        end
        
        
        %all samples in freqall should be in trltaclean. remove ones that
        %are not.
        %There needs to be a record of the trials removed in clean_resp
        
        %Trials are removed in two stages, in clean_resp and before that? 
        %it should not matter what was done before since we still have the
        %samples. 
        
  
        
        freqresp = freqAll.trialinfo(:,5);
        
        freqresp(freqresp==225)=0;
        freqresp(freqresp==232)=1;
        freqresp(freqresp==226)=0;
        freqresp(freqresp==228)=1;
        freqresp(freqresp==236)=1;
        
        plot(freqresp)
        hold on;
  
        plot(freqAll.trialinfo(:,9)+0.2)
        legend('freqAll','model')
        
        
     end
     
     if ipart == 4
         %There may be issues with the triggers here. Perhaps I can try
         %redoing the preprocessing just to check the trials. 
         %the issue is that the original preprocessing used the Matlab
         %triggers, and I think they only record when pressing buttons
         %within the cue segment. For the modelling we use all the button
         %presses. We need a different way to map the responses.
         %Additionally, the button presses seem incorrect. 
     end 
     
     if ipart == 5 
         %works
     end
     
     if ipart == 1
        % The proper way would be to include the model prediction values
        % into the trialinfo. This is actually possible since the
        % clean_resp input is all the trials...
        trltaresp = trlTA_1.responseValue(idx_artifacts_all);
        trltaresp(trltaresp==225)=0;
        trltaresp(trltaresp==232)=1;
        trltaresp(trltaresp==226)=0;
        trltaresp(trltaresp==228)=1;
        freqresp = freqAll.trialinfo(:,5);
        
        freqresp(freqresp==225)=0;
        freqresp(freqresp==232)=1;
        freqresp(freqresp==226)=0;
        freqresp(freqresp==228)=1;
        freqresp(freqresp==236)=1;
        
        
        
        plot(trltaresp-0.2)
        
        plot(freqresp)
        hold on;
        resp_mode_check = resp_mode(idx_artifacts_all_model);
        resp_mode_check(254)=[];
        plot(resp_mode_check+0.2)
        legend('freqAll','model')
        
     end

%
%      size(trltaresp)
%     
% %     
%     trltaresp = trlTA_1.responseValue(idx_artifacts_all);
%     
%     trltaresp(trltaresp==225)=0;
%     trltaresp(trltaresp==232)=1;
%     trltaresp(trltaresp==226)=0;
%     trltaresp(trltaresp==228)=1;
% %     
%     freqresp = freqAll.trialinfo(:,5);
%     freqresp(freqresp==225)=0;
%     freqresp(freqresp==232)=1;
%     freqresp(freqresp==226)=0;
%     freqresp(freqresp==228)=1;
%     freqresp(freqresp==236)=1;
%     
%     %TODO: BUG: still not exactly right, even though the correct number of trials.     
%     plot(trltaresp-0.2)
%     hold on;
%     plot(freqresp)
%     plot(resp_mode(idx_artifacts_all_model)+0.2)
%     legend('trlTA','freqAll','model')
%     
    
    %Can do detailed per participant edits here. 
    if ipart == 2
        resp_mode_idx = resp_mode(idx_artifacts_all_model);
        diffmodelfreq = resp_mode_idx(1:length(freqresp))-freqresp;
        
        idx_diffmodelfreq = find(diffmodelfreq~=0);
        
        
        resp_mode_idx(idx_diffmodelfreq(1))=[];
        
        %proper hacks below 485
        resp_mode_idx2 = [resp_mode_idx(1:210)',resp_mode_idx(212:325)', resp_mode_idx(327:485)', 0, resp_mode_idx(486:643)',resp_mode_idx(645:650)',resp_mode_idx(652:696)',resp_mode_idx(698:end)',1];

%         
%         resp_mode_idx(326)=[];
%         resp_mode_idx(409)=[];
%         resp_mode_idx(411)=[];
        
        plot(resp_mode_idx(1:length(freqresp))-freqresp)
        plot(freqresp)
        hold on
%         plot(resp_mode)
        plot(resp_mode_idx2)
        ylim([-0.2 1.2])
        legend('freq','model')
        
    end
%     plot(trlTA_1.responseValue(idx_artifacts_all))
%     hold on;
%     plot(freqAll.trialinfo(:,5)+2)
%     plot(resp_mode)
%     ylim([220 238])
%     legend('trlTA','freqAll','model')
%     
    
    
    % first take only the trails from freq that we have in model.
    % Why are we adding 7200 to the freqsamples? Originally it is the end
    % of trial sample, subtracted by 3600, unless ipart == 1, when that is
    % 2700. Can I add by that much lees then? Nope. 
    % More likely, ismember does not make sense when the numbers are
    % repeating? 
    % first three datasets had this -(1200*2.25) on selfocclusion samples 
    % The missmatch appears to come from incorrect sample numbers in trlTA
    % data. 
    % Issue: the index_mask is configured to work for different behaviour
    % input. Should use trlTA or freq behav? The former. 
%     index_mask = ismember(freqsamples_all+7200,trlTA_1.EndTrial(trlTA_1.responseValue>0));
 
    % mask_dat=mask_dat(index_mask,:);

%     index_model = ismember(trlTA_1.EndTrial(trlTA_1.responseValue>0),freqsamples_all+7200);


    % only take the model trials where the samples of the model trials match the samples of the
    % frequency trials.
    % However the problem is the reverse. Making sure that we are only taking the model trials
    % that have the same samples as the freq trials.
    
%     model_dat=model_dat(index_model);
    %FIX: remove anns from idx_artifacts_all

    

    %
    % for part1, there are more valid freq trials. Are there trial numbers for both? 
%     close
%     plot(Model{2}.subject{str2num(parts)}.session.y(index_model)+1)
%     hold on
%     plot(freqAll.trialinfo(:,5)>230)
%     ylim([-1 3])
%     legend('model','freq')
    

   % solution to remove all the nonresponseive trials
 
    cfg = [];
    cfg.trials = freqAll.trialinfo(:,5)~=0;
    if ipart == 6
        cfg.trials(end)=0;
    end 
    freqAll = ft_selectdata(cfg,freqAll);
    
    freqAll.sampletrials = freqAll.sampletrials(freqAll.cfg.trials);

    tmpfreq = freqAll;
%     freq_corrmap = tmpfreq;

%     cfg = [];
%     cfg.baseline = [-2.5 -1.5];
%     cfg.baselinetype = ['db'];
%     tmpfreq = ft_freqbaseline(cfg,tmpfreq);

    % No longer average over time or freq so we can look at the full response. 
    cfg = [];
    cfg.avgoverrpt  = 'yes';
    % % cfg.avgovertime  = 'yes';
    % cfg.avgoverfreq  = 'yes';
    % 
    freq_corrmap = ft_selectdata(cfg,tmpfreq);

    takesize = size(freq_corrmap.powspctrm);

    corrmap = zeros(takesize);

    % run correlation 
    % there are nans in the freq powscptrm. Most likely from nans when removing
    % artifacts. 
    model_dat = freqAll.trialinfo(:,8);
    model_dat = abs(model_dat);
    
    for ichannel = 1:274
        for itime = 1:101
            for ifreq = 1:33
                R = corrcoef(model_dat,tmpfreq.powspctrm(:,ichannel,ifreq,itime),'rows','complete');
                corrmap(ichannel,ifreq,itime) = R(2,1);
            end
        end
    end


    freq_corrmap.powspctrm=corrmap;
    
    doplot = 1 ; 
    if doplot
        figure('Position',[10 10 1800 1200],'visible','off')%
        cfg = [];
        cfg.xlim = [-2.5:0.2:2.5];
        cfg.ylim         = [15 30];
        cfg.zlim = [-0.1 0.1];
        cfg.layout       = 'CTF275_helmet.lay';
        ft_topoplotTFR(cfg,freq_corrmap)

        cd('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/modelcorr')
        %New naming file standard. Apply to all projects.
        namefigure = 'model8_traj_muhat2';
        formatOut = 'yyyy-mm-dd';
        todaystr = datestr(now,formatOut);
        figurefreqname = sprintf('%s_part%s_%s_nobaselinetest.png',todaystr,parts,namefigure);
        saveas(gca,figurefreqname,'png')
    end
    
%     namefigure = 'lowfreq_model_muhat2';
%     cd('/home/chris/Dropbox/PhD/Projects/Lissajous/analysis')
%     save(sprintf('%spart_%s_nobaselinetest.mat',parts,namefigure),'freq_corrmap')

end
end