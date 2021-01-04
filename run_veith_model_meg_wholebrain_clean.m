function run_veith_model_meg_wholebrain_clean
% % % % % % % % % % % % % % 
% Correlate with whole brain instead of the roi 
% Moreover, use baselined data.
% Created 04/01/2021. @Cofficer
% % % % % % % % % % % % % %



% Load model data and trial data. 

load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_veith_22nov.mat')

load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo_blocks.mat')

%   find all participant id./media/chris/Elements/Projects/Lissajous
participants = dir('/media/chris/Elements/Projects/Lissajous/continous_self_freq/*freq_low_selfocclBlock2.mat');

for ipart = 1:29
    
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
    
    %find the right samples
    trlTA_1_clean = trlTA_1(~isnan(trlTA_1.responseValue),:);
    
    plot(trlTA_1.StartTrial)
    hold on
    plot(freqAll.sampletrials(:,1))
    legend('trlt','freq')
    
    % important need to check that all sample numbers are unique.
    if length(unique(freqAll.sampletrials(:,1)))==length(freqAll.sampletrials)
        disp('all trials unique samples')
    else
        error('error in sample uniques')
        
    end
    
    
    idx_match = [];
    new_resps = [];
    
    %add new columns in trialfun
    freqAll.trialinfo(:,8)=NaN;
    freqAll.trialinfo(:,9)=NaN;
    
    for itrials = 1:length(trlTA_1_clean.StartTrial)
        if ipart<4
            [matching , matchid ] = ismember(trlTA_1_clean.StartTrial(itrials),freqAll.sampletrials(:,1)-1500);
            
        else
            [matching , matchid ] = ismember(trlTA_1_clean.StartTrial(itrials),freqAll.sampletrials(:,1)+1200);
        end
        
        if matching == 1
            freqAll.trialinfo(matchid,8) = model_dat(itrials);
            freqAll.trialinfo(matchid,9) = resp_mode(itrials);
            new_resps = [new_resps;resp_mode(itrials)];
        end
    end
    
%     
%     freqresp = freqAll.trialinfo(:,5);
%     
%     freqresp(freqresp==225)=0;
%     freqresp(freqresp==232)=1;
%     freqresp(freqresp==226)=0;
%     freqresp(freqresp==228)=1;
%     freqresp(freqresp==236)=1;
%     
%     plot(freqresp)
%     hold on;
%     
%     plot(freqAll.trialinfo(:,9)+0.2)
%     legend('freqAll','model')
    
    
    
    
    % solution to remove all the nonresponseive trials
    
    cfg = [];
    cfg.trials = freqAll.trialinfo(:,5)~=0;
    if ipart == 6
        cfg.trials(end)=0;
    end
    freqAll = ft_selectdata(cfg,freqAll);
    
    freqAll.sampletrials = freqAll.sampletrials(freqAll.cfg.trials);
    
    tmpfreq = freqAll;
    
    cfg = [];
    cfg.avgoverrpt  = 'yes';
    
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
    
    doplot = 0 ;
    if doplot
        close all;
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
        figurefreqname = sprintf('%s_part%s_%s_nobaselinetest_runall.png',todaystr,parts,namefigure);
        saveas(gca,figurefreqname,'png')
    end
    
         namefigure = 'lowfreq_model_muhat2';
         cd('/home/chris/Dropbox/PhD/Projects/Lissajous/analysis')
         save(sprintf('%spart_%s_nobaselinetest.mat',parts,namefigure),'freq_corrmap')
    
end
end