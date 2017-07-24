function [ data ] = delete_artifact_Lissajous( artifactTrl, data)
%Remove the blinks but inserting the average values of current trial or NaNs


  %Find the indices of artifacts, add one so that there is no +

  trialDiff = artifactTrl(:,2)-artifactTrl(:,1);

  %Insert NaNs for each artfifact
  for iart = 1:size(artifactTrl,1)



     %Find if artifact extends beyond one trial
     if trialDiff(iart)~=0

     end

     %Insert the incorrect data.
     meanDatPre  = data.trial{artifactTrl(iart,1)}(1:artifactTrl(iart,3))  ;
     meanDatPost = [meanDatPre data.trial{artifactTrl(iart,1)}(artifactTrl(iart,4):end)];
     data.trial{artifactTrl(iart,1)}(artifactTrl(iart,3):artifactTrl(iart,4)) = mean(data.trial{artifactTrl(iart,1)},2);
     %insert nans for all the artifacts
     %data.time{1}(onset_artifacts(iart,1):onset_artifacts(iart,2))   = NaN;

     %data.trial{1}(:,onset_artifacts(iart,1):onset_artifacts(iart,2))   = NaN;



  end

  %Get nan indeces
  indNanTrl = isnan(data.trial{1}(1,:));

  %remove all the nan values
  data.time{1}(indNanTrl)=[];


  data.trial{1}(:,indNanTrl)=[];

end
