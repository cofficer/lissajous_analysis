
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
%number of self-occlusions
nselfO=0;

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
            
              %Start the go cue var for table insertion. 
            %if trlN==1
            
            nselfO = nselfO+1;
            trlN   = nselfO;
            
            %Create the table only one after the first trial
            if trlN==2
                
                trlT=table(starttrl,selfocclusion1sample,go_cuesample,go_cuevalue,responseSample,responseValue,responseScriptValue,responseScriptSample,trlN);
                
            end
            
            if trlN==1
            selfocclusion1sample = fullevent(trgvalIndex(i)).sample;
                
                %On all subsequent trials, insert values to table
            
             starttrl = fullevent(trgvalIndex(i)).sample;

          
            else
                
                
                trlT.selfocclusion1sample(trlN,1)=fullevent(trgvalIndex(i)).sample;
                trlT.starttrl(trlN,1) = fullevent(trgvalIndex(i)).sample;
                trlT.trlN(trlN,1)=trlN;
                if trlN==8
                a=1;
                end
            end
            

           
        case go_cue
            
            %Start the go cue var for table insertion. 
            if trlN==1
            
                go_cuesample = fullevent(trgvalIndex(i)).sample;
                go_cuevalue = fullevent(trgvalIndex(i)).value;
                
                %On all subsequent trials, insert values to table
            else
                

                %take the cue from the previous trial
                trlT.go_cuesample(trlN,1)=fullevent(trgvalIndex(i)).sample;
                trlT.go_cuevalue(trlN,1)=fullevent(trgvalIndex(i)).value;
                
                %go_cuesample = fullevent(trgvalIndex(i)).sample;
                %go_cuevalue = fullevent(trgvalIndex(i)).value;
                
            end

            
        case {resp_leftL2,resp_leftR2,resp_rightL2,resp_rightR2}
            
            if trlN==1
            
                responseValue = fullevent(trgvalIndex(i)).value;
                responseSample = fullevent(trgvalIndex(i)).sample;
                responseScriptValue=NaN;
                responseScriptSample=NaN;
            else
                
                trlT.responseSample(trlN,1)=fullevent(trgvalIndex(i)).sample;
                trlT.responseValue(trlN,1)=fullevent(trgvalIndex(i)).value;
                
            
            end
            
        %temporary case
        
         case {resp_leftL,resp_leftR,resp_rightL,resp_rightR}
            
            if trlN==1
            
                responseScriptValue = fullevent(trgvalIndex(i)).value;
                responseScriptSample = fullevent(trgvalIndex(i)).sample;
                
            else
                
                trlT.responseScriptSample(trlN,1)=fullevent(trgvalIndex(i)).sample;
                trlT.responseScriptValue(trlN,1)=fullevent(trgvalIndex(i)).value;
                
            
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
  
