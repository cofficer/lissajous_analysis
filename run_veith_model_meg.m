function run_veith_model_meg
% Main function which uses the model fits and
% runs a correlation between the model and the masked MEG activity.


% TODO: add function to remove eye movements.
% Currently all those artifacts are included.
% try function.
% TODO: The freq_artifact_remove should occur after the model fitting...
% [idx_artifacts, freq] = freq_artifact_remove(freq,cfgin,ipart)


% first participant issue. error in 13 15 26. reload 23.
for ipart = 1:29

  try
    disp(ipart)
    parts = num2str(ipart);
    if ipart<10
      parts=strcat('0',parts)
    end
    trlTA_1 = trlTA(trlTA.participant==ipart,:);
    [r,p] = veith_model_meg(parts,Model,trlTA_1,statout);

    % get nan for 3
    corr_stat{ipart}.r = r;
    corr_stat{ipart}.p = p;
  catch
    nothing=[];
  end

end

cd('/Users/c.gahnstrohm/Dropbox/PhD/Projects/Lissajous/behaviour/')
save('corr_stat.mat','corr_stat')

for iipart = 1:29



  if ~isempty(model_dat{2}.subject{iipart})
    if iipart == 1
      model_p = model_dat{2}.subject{iipart}.session.traj.daq(:,1);
      mod_fits(iipart) = model_dat{2}.subject{iipart}.session.optim.AIC;
    else
      model_p=[model_p;model_dat{2}.subject{iipart}.session.traj.daq(:,1)];
      mod_fits=[mod_fits;model_dat{2}.subject{iipart}.session.optim.AIC];
    end
  end

end
