
function trlT=check_lissajousTRIAL(numP)
%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create table for the trial-based blocks                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P0%i',numP))

ds_files = dir('*.ds');

name     =  ds_files(1).name;

event = ft_read_event(name);




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


% start by selecting all events
trgval = strcmp('UPPT001',{event.type}); % this should be a row vector
trgvalIndex = find(trgval);



% select only the buttonpresses
trgvalbuttonpress = strcmp('UPPT002',{event.type}); % this should be a row vector
trgvalIndexbuttonpress = find(trgvalbuttonpress);

trgvalIndex = sort([trgvalIndex,trgvalIndexbuttonpress]);

%Convert from logical to double. 
trgval=double(trgval);

  for i=trgvalIndex
      
      %Find the event from the possible triggers
      currT=trigAll(trigAll==event(i).value);
      if currT >1;
        trgval(i)=currT;
      end

  end

  
%Establish point of reference after each trigger==64. Counting trials. 
trlN=1;


%Change the code for participant 3 so that the events start at the start of
%the first complete trial. Start the loop at 7th event, 11.
if numP==3
    
    starti=7;
else
    starti=1;
    
end

for i=starti:length(trgvalIndex)

    
    
    %Start of a new trial. 
    switch event(trgvalIndex(i)).value
        
        case {stim_start}
            
            %each trial includes 3 self-occlusions. 
            if trlN==1
                
                stim_onSample=event(trgvalIndex(i)).sample;
                
                               
            else
                
                trlT.trlN(trlN,1)=trlN;
                trlT.stim_onSample(trlN,1)=event(trgvalIndex(i)).sample;
  
            end
            
    case {self_occlusion}
            
            %each trial includes 3 self-occlusions. 
            if trlN==1
                
                selfocclusion1sample=event(trgvalIndex(i)).sample;
     
            else
                
                trlT.selfocclusion1sample(trlN,1)=event(trgvalIndex(i)).sample;
  
            end
           
            
            
         case {stim_off}
            
            %each trial includes 3 self-occlusions. 
            if trlN==1
                
                stim_offSample=event(trgvalIndex(i)).sample;
                
            else
                
                trlT.stim_offSample(trlN,1)=event(trgvalIndex(i)).sample;
  
            end
        case go_cue
            
            %Start the go cue var for table insertion. 
            if trlN==1
            
                go_cuesample = event(trgvalIndex(i)).sample;
                %go_cuevalue = fullevent(trgvalIndex(i)).value;
                
                %On all subsequent trials, insert values to table
            else
                

                %take the cue from the previous trial
                trlT.go_cuesample(trlN,1)=go_cuesample;
                %trlT.go_cuevalue(trlN,1)=go_cuevalue;
                
                go_cuesample = event(trgvalIndex(i)).sample;
                
            end

            
        case {resp_leftL2,resp_leftR2,resp_rightL2,resp_rightR2}
            
            if trlN==1
            
                responseValue = event(trgvalIndex(i)).value;
                responseSample = event(trgvalIndex(i)).sample;
                
            else
                
                trlT.responseSample(trlN,1)=event(trgvalIndex(i)).sample;
                trlT.responseValue(trlN,1)=event(trgvalIndex(i)).value;
                
            
            end
        
        case {off_cue}

            
            if trlN==1
            
                off_cueSample = event(trgvalIndex(i)).sample;
                
            end
            
            trl.off_cueSample = event(trgvalIndex(i)).sample;
            
            
            
        case {block_start}
            %trl(trlN,13)=event(trgvalIndex(i)).sample;
            
            if trlN==1
               
                a=1;
                
            end
            
            trl(trlN,13)=event(trgvalIndex(i)).value;
            
        case {trial_end}
            
            
            
            %iter_selfocclusion = 1;stim_offSample
            if trlN == 1
                trial_endSample=event(trgvalIndex(i)).sample;
                trlT=table(stim_onSample,trial_endSample,selfocclusion1sample,stim_offSample,go_cuesample,responseSample,responseValue,trlN);
            
            
            else
                
                trlT.trial_endSample(trlN,1) = event(trgvalIndex(i)).sample;
            
            end
            trlN=trlN+1;
            
                
    
    end

end
  
  %%
  %plot the occurence of each type of perception.
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  unique([event(trgvalbuttonpress).value])
  
  chrisTrials=[event(trgvalbuttonpress).value];
end
  
  
