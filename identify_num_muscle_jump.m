

% Identify the number of muscle artifacts and jump artifacts identified

clearvars -except cfgin

idx_art = 0;

for i_cfg = 1:length(cfgin)

  %preproc path
  cd(sprintf('%s%s/preprocessed/%s/%s/',cfgin{i_cfg}.fullpath(1:56),...
  cfgin{i_cfg}.blocktype,cfgin{i_cfg}.restingfile,cfgin{i_cfg}.stim_self))

  % find the number of files
  i_arts = dir('artifacts*');
  for ipart = 2:length(i_arts)+1

    idx_art = idx_art + 1;
    arfct_path = dir(sprintf('artifacts*%d.mat',ipart));

    load(arfct_path.name) % artifact_Jump/Muscle/idx_jump

    preproc_path = dir(sprintf('*noMEG*%d.mat',ipart));
    load(preproc_path.name) %dataNoMEG


    if isfield(dataNoMEG.cfg.previous.previous,'trl')
      sampleinfo = dataNoMEG.cfg.previous.previous.trl(:,1:2);
    else
      sampleinfo = dataNoMEG.cfg.previous.previous.previous.trl(:,1:2);
    end

    clear idx_mscle
    for iart = 1:size(artifact_Muscle,1)

      idx_trl_mscle_start = find(artifact_Muscle(iart,1)<sampleinfo(:,2));
      idx_trl_mscle_start = idx_trl_mscle_start(1);

      idx_trl_mscle_end = find(artifact_Muscle(iart,2)<sampleinfo(:,2));
      idx_trl_mscle_end = idx_trl_mscle_end(1);

      idx_mscle{iart} = unique([idx_trl_mscle_start,idx_trl_mscle_end]);

    end

    idx_mscle = unique([idx_mscle{:}]);

    num_muscle(idx_art) = size(idx_mscle,2);
    num_jump(idx_art) = size(idx_jump,2);
  end

end

avg_muscle = sum(num_muscle)/29
avg_jump = sum(num_jump)/29
