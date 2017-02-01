
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
    name     =  ds_files(inames).name;
    
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
if sum(numP==[3,4,5])

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


%Create variables for all events. 
offcueN      = 1;
selfN        = 1;
go_cueN      = 1;
responseN    = 1;
responseScN  = 1;
block_startN = 1;

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

            selfocclusion1sample(selfN) = fullevent(trgvalIndex(i)).sample;
            selfN=selfN+1;
 
        case go_cue
 
            go_cuesample(go_cueN) = fullevent(trgvalIndex(i)).sample;
            go_cuevalue(go_cueN)  = fullevent(trgvalIndex(i)).value;
            go_cueN = go_cueN + 1; 

        case {resp_leftL2,resp_leftR2,resp_rightL2,resp_rightR2}
            
                 responseValue(responseN)  = fullevent(trgvalIndex(i)).value;
                 responseSample(responseN) = fullevent(trgvalIndex(i)).sample;
                 responseN      = responseN+1;       
        
         case {resp_leftL,resp_leftR,resp_rightL,resp_rightR}
%             

            responseScriptValue(responseScN)  = fullevent(trgvalIndex(i)).value;
            responseScriptSample(responseScN) = fullevent(trgvalIndex(i)).sample;
            responseScN = responseScN+1;

        
        case {off_cue}
            
            off_cueSample( offcueN) = fullevent(trgvalIndex(i)).sample;
            off_cueValue( offcueN) = fullevent(trgvalIndex(i)).value;
            offcueN = offcueN+1;
   
            
        case {block_start}
            
            block_startSample( block_startN) = fullevent(trgvalIndex(i)).sample;
            block_startValue( block_startN) = fullevent(trgvalIndex(i)).value;
            block_startN = block_startN+1;
            

    
    end

end

%%
%Use the arrays for all events to construct a table: 
if numP<4
selfocclusion1sample = selfocclusion1sample-(1200*2.25); %Remove the added 2.25s from poor triggers
end
%trialStart = selfocclusion1sample-2; %Trial starts two seconds before self-occl.


%collect all relevant samples in one structure.
samples.go_cuesample=go_cuesample ;         %
samples.responseScriptSample=responseScriptSample;
samples.responseSample=responseSample;
samples.off_cueSample=off_cueSample;
samples.block_startSample=block_startSample; %Use to restrict button presses. 
samples.selfocclusion1sample=selfocclusion1sample; %Use to restrict button presses. 

%collect all relevant values in one structure.
values.response = responseValue;
samples.numP    = numP;

%Call function to create a neat table of samples. 
trlT = megsampletable(samples,values);




end
  
