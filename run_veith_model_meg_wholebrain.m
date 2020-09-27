function run_veith_model_meg_wholebrain
% % % % % % % % % % % % % % 
% Correlate with whole brain instead of the roi 
% Moreover, use baselined data.
% Created 24/09/2020. @Cofficer
% % % % % % % % % % % % % % 

% load all model data
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/model_tapas_HGFv6.mat')

load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo.mat')
load('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo_trlnumblock.mat')

%   find all participant id.
participants = dir('/home/chris/Documents/lissajous/data/continous_self_freq/*freq_low_selfocclBlock2.mat');
  
% error part1,2,3,4,6,16 Missmatch with number of trials. 
% error part13, 15, 26 no modelling results.
% Start with fixing error of missmatch. 
for ipart =1:29
    
    parts = participants(ipart).name(1:2);

    % daq - the timecourse for the inverted model. Not the correct parameter. 
    % let's look at the prediction errors instead on different levels. 
    % mu = model prediction 
    % muhat = model prediction, one step ahead?
    model_dat = Model{2}.subject{str2num(parts)}.session.traj.epsi(:,2);
    resp_mode = Model{2}.subject{str2num(parts)}.session.y;

    filenames = dir(sprintf('/home/chris/Documents/lissajous/data/continous_self_freq/%sfreq_low_selfocclBlock*.mat',parts));

    trlTA_1 = trlTA(trlTA.participant==str2num(parts),:);

    for iblock = 1:length(filenames)
      disp(iblock)
      cd('/home/chris/Documents/lissajous/data/continous_self_freq/')
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
      else
        all_trial = [all_trial;freq.trialinfo];
        freqsamples_all = [freqsamples_all;freqsamples];
        idx_artifacts_all = [idx_artifacts_all;idx_artifacts];
        [freqAll] = append_trialfreq([],freqAll,freq);
      end

    end
    
    % first take only the trails from freq that we have in model.
    % Why are we adding 7200 to the freqsamples? Originally it is the end
    % of trial sample, subtracted by 3600, unless ipart == 1, when that is
    % 2700. Can I add by that much lees then? Nope. 
    % More likely, ismember does not make sense when the numbers are
    % repeating? 
    % first three datasets had this -(1200*2.25) on selfocclusion samples 
    % The missmatch appears to come from incorrect sample numbers in trlTA
    % data. 
    index_mask = ismember(freqsamples_all+7200,trlTA_1.EndTrial(trlTA_1.responseValue>0));
 
    % mask_dat=mask_dat(index_mask,:);

    index_model = ismember(trlTA_1.EndTrial(trlTA_1.responseValue>0),freqsamples_all+7200);


    % only take the model trials where the samples of the model trials match the samples of the
    % frequency trials.
    % However the problem is the reverse. Making sure that we are only taking the model trials
    % that have the same samples as the freq trials.
%     model_dat=model_dat(index_model);
    model_dat=model_dat(idx_artifacts_all)

    %
    % for part1, there are more valid freq trials. Are there trial numbers for both? 
%     close
%     plot(Model{2}.subject{str2num(parts)}.session.y(index_model)+1)
%     hold on
%     plot(freqAll.trialinfo(:,5)>230)
%     ylim([-1 3])
%     legend('model','freq')
    
    tmpfreq = freqAll;
%     freq_corrmap = tmpfreq;

%     cfg = [];
%     cfg.baseline = [0.6 0.9];
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
        figure('Position',[10 10 1800 1200],'visible','off')%
        cfg = [];
        cfg.xlim = [-2.5:0.2:2.5];
        cfg.ylim         = [15 30];
        cfg.zlim = [-0.1 0.1];
        cfg.layout       = 'CTF275_helmet.lay';
        ft_topoplotTFR(cfg,freq_corrmap)

        cd('/home/chris/Dropbox/PhD/Projects/Lissajous/results_plots/modelcorr')
        %New naming file standard. Apply to all projects.
        namefigure = 'modeltraj_epsi2';
        formatOut = 'yyyy-mm-dd';
        todaystr = datestr(now,formatOut);
        figurefreqname = sprintf('%s_part%s_%s_nobaselinetest.png',todaystr,parts,namefigure);
        saveas(gca,figurefreqname,'png')
    end
    
    namefigure = 'lowfreq_model_epsi2';
    cd('/home/chris/Dropbox/PhD/Projects/Lissajous/analysis')
    save(sprintf('%spart_%s_nobaselinetest.mat',parts,namefigure),'freq_corrmap')

end
end