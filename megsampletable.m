function [ trlT ] = megsampletable( samples,values )
%Input samples from all events and output a neat table structure, where
%each row represents a trial.



%Withdraw all samples of interest into variables from struct
SelfOcclusionSample           = samples.selfocclusion1sample;
CueOnsetSample                = samples.go_cuesample;
responseSample                = samples.responseSample;
CueOffsetSample               = samples.off_cueSample;
blockStart                    = samples.block_startSample;
responseValue                 = values.response;

%the index of a new dataset attachment.
BPblockind = find(diff(responseSample)<0==1);

%include the start and finish index
BPblockind = [0 BPblockind length(responseSample)];

%the index of each new dataset attachment.
SOblockind = find(diff(SelfOcclusionSample)<0==1);

%include the start and finish index
SOblockind = [0 SOblockind length(SelfOcclusionSample)];

%the index of each new dataset attachment.
CueOffind = find(diff(CueOffsetSample)<0==1);

%include the start and finish index
CueOffind = [0 CueOffind length(CueOffsetSample)];

%iteration to store all trials
iSOAll = 1; 

%loop datasets
for idat = 1:3
    
    %get the events  from the current dataset
    currentSelfOcclusions = SelfOcclusionSample(SOblockind(idat)+1:SOblockind(idat+1));
    currentReponses       = responseSample(BPblockind(idat)+1:BPblockind(idat+1));
    currentCueOffset      = CueOffsetSample(CueOffind(idat)+1:CueOffind(idat+1));
    
    
    
    %Loop the selfocclusions for the current dataset. 
    for iSO = 1:length(currentSelfOcclusions)-1

        %Index the buttonpresses for the current pair of self-occlusions.
        indcurrentBP = find(currentSelfOcclusions(iSO)<currentReponses & currentSelfOcclusions(iSO+1)>currentReponses);
        
        %Index the cueoff for the current pair of self-occlusions.
        indcurrentCO = find(currentSelfOcclusions(iSO)<currentCueOffset & currentSelfOcclusions(iSO+1)>currentCueOffset);
        
        
        %Check if a buttonpress is found
        if ~isempty(indcurrentBP)   
            %Store all the samples of button presses. 
            responseCellArray{iSOAll}= responseSample(indcurrentBP); 
            valueCellArray{iSOAll}   = responseValue(indcurrentBP); 
            
        end
        
        %Check if a cue off is found
        if ~isempty(indcurrentCO)
            %Store all the samples of button presses.
            cueoffCellArray{iSOAll}= CueOffsetSample(indcurrentCO);
        end
        
        %Increase the current trial
        iSOAll = iSOAll + 1;
        
        
    end
    
    %add one extra empty cell at the end for the final self-occlusion, not
    %actually a trial.
    responseCellArray{iSOAll}= [];
    valueCellArray{iSOAll}= [];
    cueoffCellArray{iSOAll}  = [];
    iSOAll = iSOAll + 1;
    %Start trial, end trial...
end



valueCellArray=valueCellArray';
responseCellArray=responseCellArray';
cueoffCellArray=cueoffCellArray';
SelfOcclusionSample=SelfOcclusionSample';
CueOnsetSample=CueOnsetSample';

StartTrial = SelfOcclusionSample-2400;
EndTrial   = SelfOcclusionSample+7200; %Time per trial epoch i 6,5 since first self-occlusion. Total 8,5. 
trlN       = [1:length(StartTrial)]';


trlT = table(StartTrial,EndTrial,SelfOcclusionSample,CueOnsetSample,responseCellArray,valueCellArray,cueoffCellArray,trlN);




end

