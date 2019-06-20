function [r,p] = veith_model_meg(parts,Model,trlTA_1,statout)

  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Extract model predictions per self-occlusion
  %based on the active inference framework.
  %TODO: Divide each block into separate sessions.
  %TODO: Figure out how to treat error trials.
  %TODO: Figure out why 13 and 15 contain errors.
  %Created 18/12/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


model_dat=Model{2}.subject{str2num(parts)}.session.traj.daq(:,1);
resp_mode=Model{2}.subject{str2num(parts)}.session.y;

filenames = dir(sprintf('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/continous_self_freq/%sfreq_low_selfocclBlock*.mat',parts));
for iblock = 1:length(filenames)
  disp(iblock)
  load(filenames(iblock).name)

  % TODO: remove artifacts, muscle and eye.
  % TODO: add the model prediction as an extra column in trialfun. Make into function?

  [freq,freqsamples] = clean_resp(trlTA_1,freq);
  % TODO: mask the significant cluster and sum the MEG values.
  % TODO: get only the trials with response.
  % TODO: reduce the time of interest.
  % av=sum(~isnan(freq.powspctrm(:)));


  if iblock == 1


    mask_dat  = freq.powspctrm(:,statout.mask);
    all_trial = freq.trialinfo;
    freqsamples_all = freqsamples;
  else
    mask_dat  = [mask_dat;freq.powspctrm(:,statout.mask)];
    all_trial = [all_trial;freq.trialinfo];
    freqsamples_all = [freqsamples_all;freqsamples];
  end

end

% HACK: not sure if this works but seems fine.
% part 5, block 4 error, one trial off.
% for part1 we need to change offset by 2700.

% model_dat has a few too many trials...

% first take only the trails from freq that we have in model.
index_mask = ismember(freqsamples_all+7200,trlTA_1.EndTrial(trlTA_1.responseValue>0));

mask_dat=mask_dat(index_mask,:);

index_model = ismember(trlTA_1.EndTrial(trlTA_1.responseValue>0),freqsamples_all+7200);


% only take the model trials where the samples of the model trials match the samples of the
% frequency trials.
% However the problem is the reverse. Making sure that we are only taking the model trials
% that have the same samples as the freq trials.
model_dat=model_dat(index_model);
%
% % all the samples existing in the model, which is too many by 4.
% tmp_model_info=trlTA_1.EndTrial(trlTA_1.responseValue>0);
%
% index_model_reverse = ismember(freqsamples_all+7200,tmp_model_info(index_model));
%
% ab=model_dat(index_model_reverse);

%
% ab=trlTA_1.EndTrial(trlTA_1.responseValue>0);
% av=freqsamples_all+7200;
%
% ab(1:400)-av(1:400)
%
% %
% figure(1),clf
% plot(trlTA_1.EndTrial(trlTA_1.responseValue>0))
% hold on
% plot(freqsamples_all+7200)
% legend model freq

[r,p]     = corr((model_dat),nansum(mask_dat,2));

% scatter(abs(model_dat),nansum(mask_dat,2))

% TODO: Correlate that value with the prediction error
% TODO:


end
