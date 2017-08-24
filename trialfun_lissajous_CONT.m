function [trl, event] = trialfun_lissajous_CONT(cfgin)
% header and events are already in the asc structures
% returns a trl that should be identical to the structure obtained from MEG
% data

%define triggers
trigger.block_start    = 1;   % start of block
trigger.trial_start    = 11;   % onset of baseline period
trigger.stim_start     = 21;   % onset of luminance fluctuations
trigger.stim_off       = 22;   % onset of luminance fluctuations
trigger.go_cue         = 31;    % onset of signal (if present)
trigger.off_cue        = 32;    % offset of cue (if present)
trigger.signal_off     = 33;   % end of signal (if present)
trigger.self_occlusion = 10 ; %frame of self-occlusion
trigger.resp_leftL     = 41;    % 'left' response, from left
trigger.resp_rightL    = 42;   % 'right' response, from left
trigger.resp_leftR     = 45;    % 'left' response, from right
trigger.resp_rightR    = 46;   % 'right' response, from right
trigger.resp_bad       = 43;     % bad response (either double press, or task-irrelevant button)
%trigger.fb_correct = 51;   % feedback for hit or correct rejection
%trigger.fb_error = 52;     % feedback for false alarm, miss, mislocalization, or premature response
trigger.fb_bad         = 53;       % feedback for bad responses
trigger.trial_end      = 61;    % offset of feedback/onset of break period
trigger.block_end      = 90;    % end of block
trigger.RS_start       = 2;      % start of resting state block
trigger.RS_end         = 3;        % end of resting state block

%All triggers
trigAll     =[64,48,52,40,32,23,21,22,20,18,16,11,10];

hdr    = cfgin.headerfile; %cfg.headerfile;
fsr    = '1200'; %cfg.fsample;         % in Hz
begtrl = 1; % in seconds cfg.trialdef.prestim
endtrl = 2; % in seconds cfg.trialdef.poststim

%'/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/raw/P21/P21_lissajous_20170224_02.ds'
%Store the events

event = ft_read_event(hdr);%'headerformat',[],'eventformat',[],'dataformat',[]

% start by selecting all events
trgval = strcmp('UPPT001',{event.type}); % this should be a row vector
trgvalIndex = find(trgval);

% start by selecting all events
trgval2 = strcmp('UPPT002',{event.type}); % this should be a row vector
trgvalIndex2 = find(trgval2);
respVals = unique([event(trgvalIndex2).value]);
respSamp = [event(trgvalIndex2).sample];


%add the two indices together to get all the data.
trgvalIndex = sort([trgvalIndex trgvalIndex2(trgvalIndex2>trgvalIndex(2))]);

%trlTA.responseValue(trlTA.responseValue==228)=225;
%trlTA.responseValue(trlTA.responseValue==226)=232;

%What order is desired:
%First two columns, stimulus start sample and stimulus stop sample
%Third trigger self-occlusion, followed by the fourth col. sample offset from the start
%Fifth column, go_cue, sixth sample offset
%Seventh response val, eigth sample offset
%Ninth trial val, tenth sample end.
%11th block start or end. 12th sample.
%13th the trial number of the current block

ntrls = sum([event(trgvalIndex).value]==trigger.self_occlusion)
%Create a matrix with all the relevant trigger columns + offsets etc.
trl= zeros(sum([event(trgvalIndex).value]==trigger.self_occlusion)-2,9);%zeros(sum(trgval==goCue),numel(trigAll)+1); %Actually empty var.

%Establish point of reference after each trigger==64. Counting trials.
trlN=0;
%Define trloff (trial offset). Need to be a running value during each
%trial.
numSelfo=0;

%
iplot = 0;
if iplot

  all_events = event(trgvalIndex).value;

  left  = ([event(trgvalIndex2).value]==225);
  right = ([event(trgvalIndex2).value]==232);

  bpSample = [event(trgvalIndex2).sample];
  bpVal    = [event(trgvalIndex2).value]-225;
  bpVal(right)=1;
  g=gramm('x',bpSample(1:100),'y',bpVal(1:100),'color',[bpVal(1:100)==1]);
  g.geom_jitter();
  %g.coord_flip()
  g.draw();
  g.facet_axes_handles.YLim = [-1 2];
  saveas(gca,'sampleBP.png','png')
  close

end


for i=1:length(trgvalIndex)

    %Start of a new trial.
    switch event(trgvalIndex(i)).value
       case {trigger.block_start}
            
           if trlN ~= 0
            %Go back one trlN because the last selfOcclusion is not usable
               trlN = trlN-1;
           end
              
            trlN = trlN + 1;
            %The offset
            %find and index the upcoming trial start
           
            %Find the start of the two blocks and dependin on if 
            %it is the first trial or not, select the correct first 
            %trial sample after blockstart
            idx_bloktart = find([event(trgvalIndex).value]==1);
            
            if trlN == 1
                currTrlInd   = idx_bloktart(1)+1;
            else
                currTrlInd   = idx_bloktart(2)+1;
            end
            stimSample = event(trgvalIndex(currTrlInd)).sample;
            trl(trlN,3)= stimSample;
            trl(trlN,4)= event(trgvalIndex(currTrlInd)).value;
            %remove the prestim defin from the sample
            trl(trlN,1)=event(trgvalIndex(currTrlInd)).sample-cfgin.trialdef.prestim*1200;
            %Trial end, take the full time until next self-occlusion
            trl(trlN,2)=event(trgvalIndex(i)).sample + cfgin.trialdef.poststim*1200;
            trl(trlN,9)=trlN;

            %Number self-occlusios


        case trigger.self_occlusion

            trlN = trlN + 1;
            if trlN==137
                aa=1;
            end
            %The offse of all trials should be around the occlusions
            stimSample = event(trgvalIndex(i)).sample;
            %start of trial
            trl(trlN,1)=event(trgvalIndex(i)).sample-cfgin.trialdef.prestim*1200;
            %start of oclcusion
            trl(trlN,3) = stimSample;
            %value of occlusion
            trl(trlN,4) = event(trgvalIndex(i)).value;
            %Trial end, take the full time until next self-occlusion
            trl(trlN,2)=event(trgvalIndex(i)).sample + cfgin.trialdef.poststim*1200;
            %Trial start 2s before Stimulus onset
            trl(trlN,9)=trlN;


        case trigger.go_cue
            trl(trlN,5)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,6)=event(trgvalIndex(i)).value;

        case {respVals(1),respVals(2)}
            %response triggers
            trl(trlN,7)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,8)=event(trgvalIndex(i)).value;
            


            %      case {trigger.block_start}
            %          trl(trlN,12)=event(trgvalIndex(i)).sample-stimSample;
            %          trl(trlN,11)=event(trgvalIndex(i)).value;
            %Adding 2.4s to include more data after feedback.
            %trl(trlN,2)=event(trgvalIndex(i)).sample+endtrl*fsr;

            %case trigger.block_end
            %    trl(trlN-1,12)=event(trgvalIndex(i)).sample-stimSample;
            %    trl(trlN-1,11)=event(trgvalIndex(i)).value;

            %case {trigger.block_start,trigger.block_end}
            %    %trl(trlN,13)=event(trgvalIndex(i)).sample;
            %    trl(trlN,13)=event(trgvalIndex(i)).value;

    end
end

end
