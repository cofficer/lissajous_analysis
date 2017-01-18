
function trlT=check_lissajousCONT(numP)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Read events from the lissajous raw data, for continuous blocks.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P0%i',numP))

%The first data set is for trialbased in this condition. 
%Take the script from trialfun. Create a trialdefinition. 
%Pre-selfocclusion + button press. 

ds_files = dir('*.ds');
for inames=2:length(ds_files)
name     =  ds_files(2).name;

event = ft_read_event(name);

%create the fullevent containing all the trials. 
if inames==2
    
    fullevent=event;

else
    
%add all datasets together.    
fullevent=[fullevent;event];

end



end


%define triggers, 
block_start         = 1;     %fixation onset
trial_start         = 11;   %stimulus horizontal onset
stim_start          = 21;   %stimulus vertical onset
stim_off            = 22;   %stimulus vertical onset
go_cue              = 31;   %response horizontal right 
off_cue             = 32;   %response horizontal left
signal_off          = 33;   %end of signal ??? 
self_occlusion      = 10;   %response vertical left
resp_leftL          = 41;   %1st button from left
resp_leftL2         = 225;  %1st button from left from uppt002
resp_leftR          = 42;   %2nd button from left
resp_leftR2         = 226;  %2nd button from left
resp_rightL         = 45;   %3rd button from left
resp_rightL2        = 228;  %3rd button from left
resp_rightR         = 46;   %4th button from left
resp_rightR2        = 232;  %4th button from left
resp_bad            = 43;   %

trial_end           = 61; %New block onset
block_end           = 90; %Not currenlty in use. 

%All triggers
trigAll     =[1,11,21,22,31,32,33,10,41,42,45,46,43,61,90,232,225];

%Change the buttons used for P03:;;;
if numP==3

    trigAll     =[1,11,21,22,31,32,33,10,41,42,45,46,43,61,90,226,228];


end

% start by selecting all events
trgval = strcmp('UPPT001',{fullevent.type}); % this should be a row vector
trgvalIndex = find(trgval);



% select only the buttonpresses
trgvalbuttonpress = strcmp('UPPT002',{fullevent.type}); % this should be a row vector
trgvalIndexbuttonpress = find(trgvalbuttonpress);

trgvalIndex = sort([trgvalIndex,trgvalIndexbuttonpress]);

%Convert from logical to double. 
trgval=double(trgval);

  for i=trgvalIndex
      
      %Find the event from the possible triggers
      currT=trigAll(trigAll==fullevent(i).value);
      if currT >1;
        trgval(i)=currT;
      end

  end


%Create a matrix with all the relevant trigger columns + offsets etc.
trl=zeros(sum(trgval==block_start),numel(trigAll)+1); %A few more than it should be which should be looked into. 

%Establish point of reference after each trigger==64. Counting trials. 
trlN=1;
%Define trloff (trial offset). Need to be a running value during each
%trial. 
trloff=0;

iter_selfocclusion = 1;


for i=1:length(trgvalIndex)
    
    %If the trigger is not yet implemented, skip it for now.
    if isempty(trigAll(trigAll==fullevent(trgvalIndex(i)).value))
        continue
    end
    %catch empty fields in the event table and interpret them meaningfully
%     if isempty(event(trgvalIndex(i)).offset)
%         % time axis has no offset relative to the event
%         event(trgvalIndex(i)).offset = 0;
%     end
%     if isempty(event(trgvalIndex(i)).duration)
%         % the event does not specify a duration
%         event(trgvalIndex(i)).duration = 0;
%     end
%     % determine where the trial starts with respect to the event
%     if ~isfield(cfg.trialdef, 'prestim')
%         trloff = trloff+event(trgvalIndex(i)).offset;
%         trlbeg = event(trgvalIndex(i)).sample;
%     else
%         % override the offset of the event
%         trloff = round(-cfg.trialdef.prestim*fsr);
%         % also shift the begin sample with the specified amount
%         trlbeg = event(trgvalIndex(i)).sample + trloff;
%     end
    


    %Start of a new trial. 
    switch fullevent(trgvalIndex(i)).value
        
        case {self_occlusion}
            
            %each trial includes 3 self-occlusions. 
            if iter_selfocclusion==1 && trlN==1
            
                selfocclusion1sample(1,trlN)=fullevent(trgvalIndex(i)).sample;
                iter_selfocclusion=iter_selfocclusion+1;
                
                %start the trial at the sample of the first selfO
                starttrl(trlN) = fullevent(trgvalIndex(i)).sample;
                
            elseif iter_selfocclusion==2 && trlN==1
                
                selfocclusion2sample(trlN)=fullevent(trgvalIndex(i)).sample;
                iter_selfocclusion=iter_selfocclusion+1;
                
            elseif iter_selfocclusion==3 && trlN==1
                
                selfocclusion3sample(trlN)=fullevent(trgvalIndex(i)).sample;
                iter_selfocclusion=iter_selfocclusion+1;
                
                %End the trial at the sample of the third selfO
                endtrl(trlN) = fullevent(trgvalIndex(i)).sample;
                
                %After definin the third selfO, we can move to the next
                %trial.
                trlN=trlN+1;
                %iter_selfocclusion = 1;
                trlT=table(starttrl,endtrl,selfocclusion1sample,selfocclusion2sample,selfocclusion3sample,go_cuesample,go_cuevalue,responseSample,responseValue,trlN);
                
            else
                
                %The start of the trial becomes the last trials second selO
                trlT.selfocclusion1sample(trlN,1)=trlT.selfocclusion2sample(trlN-1,1);%event(trgvalIndex(i)).sample;
                trlT.starttrl(trlN,1) = trlT.selfocclusion2sample(trlN-1,1);
                
                %The main seflO become the last trial last selfO
                trlT.selfocclusion2sample(trlN,1)=trlT.selfocclusion3sample(trlN-1,1);%event(trgvalIndex(i)).sample;
                
                %The last selfO is the current trigger and the end of the
                %trial
                trlT.selfocclusion3sample(trlN,1)=fullevent(trgvalIndex(i)).sample;%event(trgvalIndex(i)).sample;
                trlT.endtrl(trlN,1) = fullevent(trgvalIndex(i)).sample;
                trlN=trlN+1;
                trlT.trlN(trlN,1) = trlN;
            end
            
            %trl(trlN,1)=trlbeg;
            trl(trlN,3)=fullevent(trgvalIndex(i)).sample;
            trl(trlN,4)=trial_start;
            trl(trlN,14)=trlN;
            trloff=0;
           
        case go_cue
            
            %Start the go cue var for table insertion. 
            if trlN==1
            
                go_cuesample = fullevent(trgvalIndex(i)).sample;
                go_cuevalue = fullevent(trgvalIndex(i)).value;
                
                %On all subsequent trials, insert values to table
            else
                

                %take the cue from the previous trial
                trlT.go_cuesample(trlN,1)=go_cuesample;
                trlT.go_cuevalue(trlN,1)=go_cuevalue;
                
                go_cuesample = fullevent(trgvalIndex(i)).sample;
                go_cuevalue = fullevent(trgvalIndex(i)).value;
                
            end

            
        case {resp_leftL2,resp_leftR2,resp_rightL2,resp_rightR2}
            
            if trlN==1
            
                responseValue = fullevent(trgvalIndex(i)).value;
                responseSample = fullevent(trgvalIndex(i)).sample;
                
            else
                
                trlT.responseSample(trlN,1)=fullevent(trgvalIndex(i)).sample;
                trlT.responseValue(trlN,1)=fullevent(trgvalIndex(i)).value;
                
            
            end
        
        case {off_cue}
            trl(trlN,11)=fullevent(trgvalIndex(i)).sample;
            trl(trlN,12)=fullevent(trgvalIndex(i)).value;
            %Adding 2.4s to include more data after feedback. 36963-36863
            trl(trlN,2)=fullevent(trgvalIndex(i)).sample+4800;
   
            
        case {block_start}
            %trl(trlN,13)=event(trgvalIndex(i)).sample;
            
            if trlN==1
               
                
                
            end
            
            trl(trlN,13)=fullevent(trgvalIndex(i)).value;
    
    end

end


end
  
