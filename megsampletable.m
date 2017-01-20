function [ trlT ] = megsampletable( samples )
%Input samples from all events and output a neat table structure, where
%each row represents a trial.



%Withdraw all samples of interest into variables from struct
SelfOcclusionSample           = samples.selfocclusion1sample;
CueOnsetSample                = samples.go_cuesample;
responseSample                = samples.responseSample;
CueOffsetSample               = samples.off_cueSample;
blockStart                    = samples.block_startSample;


%the index of a new dataset attachment.
BPblockind = find(diff(responseSample)<0==1);

%include the start and finish index
BPblockind = [1 BPblockind length(responseSample)];


%the index of each new dataset attachment.
SOblockind = find(diff(SelfOcclusionSample)<0==1);

%include the start and finish index
SOblockind = [1 SOblockind length(SelfOcclusionSample)];

%loop datasets
for idat = 1:3
    
    %get the events from the current dataset
    currentSelfOcclusions = SelfOcclusionSample(SOblockind(idat):SOblockind(idat+1));
    currentReponses       = responseSample(SOblockind(idat):SOblockind(idat+1));
    
    for iSO = 1:length(currentSelfOcclusions)

        %Use the same system as before.
        
        
        %Index the buttonpresses for the current pair of self-occlusions.
        indcurrentBP = find(currentSelfOcclusions(iSO)<currentReponses & currentSelfOcclusions(iSO+1)>currentReponses);
        
        
        %Now, only add and remove the buttonpress if the self-occlusion and BP
        %are in the same dataset.
        
        %Check if a buttonpress is found
        if ~isempty(indcurrentBP)
            
            
            
            responseCellArray{iSO}= responseSample(indcurrentBP);
            
%             
%             %Are both indexes in the same dataset:
%             if iSO <= SOblockind(1) && indcurrentBP(1) <= BPblockind(1)
%                 
%                 %Store the acquired buttonpreses, that can handle uneven dimensions
%                 responseCellArray{iSO}= responseSample(indcurrentBP);
%                 
%             elseif iSO > SOblockind(2) && indcurrentBP(1) > BPblockind(2)
%                 
%                 %Store the acquired buttonpreses, that can handle uneven dimensions
%                 responseCellArray{iSO}= responseSample(indcurrentBP);
%                 
%             elseif SOblockind(1) > iSO <= SOblockind(2) && BPblockind(1)>indcurrentBP(1) <= BPblockind(2)
%                 
%                 %Store the acquired buttonpreses, that can handle uneven dimensions
%                 responseCellArray{iSO}= responseSample(indcurrentBP);
%                 
%                 
%                 
%                 
%             end
        end
        
        
        
        
        if iSO == 36
            a=1;
        end
    end
end

trlT = table(SelfOcclusionSample,CueOnsetSample,responseSample,CueOffsetSample,blockStart);

end

