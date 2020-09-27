function [ trlT ] = megsampletable( samples,values )
%Input samples from all events and output a neat table structure, where
%each row represents a trial.
%This function first creates an empty table and then proceeds to fill it
%with actual information. 



% %Withdraw all samples of interest into variables from struct
% SelfOcclusionSample           = samples.selfocclusion1sample;
% CueOnsetSample                = samples.go_cuesample;
% responseSample                = samples.responseSample;
% CueOffsetSample               = samples.off_cueSample;
% blockStart                    = samples.block_startSample;
% responseValuesamples                 = values.response;

%the index of a new dataset attachment.
BPblockind = find(diff(samples.responseSample)<0==1);

%include the start and finish index
BPblockind = [0 BPblockind length(samples.responseSample)];

%the index of each new dataset attachment.
SOblockind = find(diff(samples.selfocclusion1sample)<0==1);

%include the start and finish index
SOblockind = [0 SOblockind length(samples.selfocclusion1sample)];

%the index of each new dataset attachment.
CueOffind = find(diff(samples.off_cueSample)<0==1);

%include the start and finish index
CueOffind = [0 CueOffind length(samples.off_cueSample)];

%the index of each new dataset attachment.
CueOnind = find(diff(samples.go_cuesample)<0==1);

%include the start and finish index
CueOnind = [0 CueOnind length(samples.go_cuesample)];



%iteration to store all trials
iSOAll = 1; 




%Define auxilliary variables
StartTrial            = (samples.selfocclusion1sample-2400)';
EndTrial              = (samples.selfocclusion1sample+7200)'; %Time per trial epoch i 6,5 since first self-occlusion. Total 8,5. 
trlN                  = zeros(1,length(StartTrial))';
SelfOcclusionSample   = zeros(1,length(samples.selfocclusion1sample))';
CueOnsetSample        = zeros(1,length(samples.selfocclusion1sample))';
participant           = zeros(1,length(samples.selfocclusion1sample))';

responseSample = zeros(1,length(trlN))';
responseValue     = zeros(1,length(trlN))';
cueoffCellArray   = cell(1,length(trlN))';


%Create the table
trlT = table(StartTrial,EndTrial,SelfOcclusionSample,CueOnsetSample,responseSample,responseValue,cueoffCellArray,participant,trlN);




%loop datasets
for idat = 1:length(SOblockind)-1
    
    %get the events  from the current dataset
    currentSelfOcclusions = samples.selfocclusion1sample(SOblockind(idat)+1:SOblockind(idat+1));
    currentReponses       = samples.responseSample(BPblockind(idat)+1:BPblockind(idat+1));
    currentCueOffset      = samples.off_cueSample(CueOffind(idat)+1:CueOffind(idat+1));
    currentCueOnset       = samples.go_cuesample(CueOnind(idat)+1:CueOnind(idat+1));
    currValResonses       = values.response(BPblockind(idat)+1:BPblockind(idat+1));
 
    %Initiate trial number
    trlNumber = 0;
    
    %Loop the selfocclusions for the current dataset. 
    for iSO = 1:length(currentSelfOcclusions)-1

        %Index the buttonpresses for the current pair of self-occlusions.
        indcurrentBP = find(currentSelfOcclusions(iSO)<currentReponses & currentSelfOcclusions(iSO+1)>currentReponses);
        
        %Index the cueoff for the current pair of self-occlusions.
        indcurrentCO = find(currentSelfOcclusions(iSO)<currentCueOffset & currentSelfOcclusions(iSO+1)>currentCueOffset);
        
                
        %Index the cueon for the current pair of self-occlusions.
        indcurrentCUEON = find(currentSelfOcclusions(iSO)<currentCueOnset & currentSelfOcclusions(iSO+1)>currentCueOnset);

        
        %Check if a buttonpress is found
        if ~isempty(indcurrentBP)   
            %Store all the samples of button presses. 
            trlT.responseSample(iSOAll)= currentReponses(indcurrentBP(1)); 
            trlT.responseValue(iSOAll)   = currValResonses(indcurrentBP(1)); 
            
        end
        
        %Check if a cue off is found
        if ~isempty(indcurrentCO)
            %Store all the samples of button presses.
            trlT.cueoffCellArray{iSOAll}= currentCueOffset(indcurrentCO);
            
        end
        
       
        
        %Check if a cue on is found 
        if ~isempty(indcurrentCUEON)
            %Store all the samples of button presses.
            trlT.CueOnsetSample(iSOAll)= currentCueOnset(indcurrentCUEON(1));
            
            
            trlNumber = trlNumber+1;
            
            
            trlT.trlN(iSOAll) = trlNumber;
        end
        
        
        %Increase the current trial fo every self-occlusion
        iSOAll = iSOAll + 1;
        
        if iSOAll==812
            a=1;
        end
        
        
    end
    
    %Remove the last self-occlusion of each block. 
    %currentSelfOcclusions=currentSelfOcclusions(1:end-1);
    
    %add one extra empty cell at the end for the final self-occlusion, not
    %actually a trial.
%     responseCellArray{iSOAll}= [];
%     valueCellArray{iSOAll}= [];
%     cueoffCellArray{iSOAll}  = [];


    %Is it enough to only add one more between trials? 
    iSOAll = iSOAll + 1;

    
    %Start trial, end trial...
end


%Rotate all the variable for easier oversight. 
% valueCellArray=valueCellArray';
% responseCellArray=responseCellArray';
% cueoffCellArray=cueoffCellArray';
% SelfOcclusionSample=SelfOcclusionSample';
% CueOnsetSample=CueOnsetSample';


% 
% %Replace empty cells with a 0
% emptyIndex = cellfun(@isempty,valueCellArray);
% valueCellArray(emptyIndex)={0};
% 
% %Simple converion if same dimensions. 
% 
% valueCellArray = cell2mat(valueCellArray)';
% 
% trlT.responseValue(1:815) = valueCellArray;

trlT.SelfOcclusionSample = samples.selfocclusion1sample';
trlT.participant         = repmat(samples.numP,1,length(samples.selfocclusion1sample))';


%Create the table
%trlT = table(StartTrial,EndTrial,SelfOcclusionSample,CueOnsetSample,responseCellArray,responseValue,cueoffCellArray,trlN);


end

