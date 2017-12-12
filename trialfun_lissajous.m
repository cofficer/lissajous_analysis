function [trl, event] = trialfun_lissajous(cfgin)
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
begtrl = -cfgin.trialdef.prestim*1200;
endtrl = cfgin.trialdef.poststim*1200;


%Store the events

event = ft_read_event(hdr);%'headerformat',[],'eventformat',[],'dataformat',[]

% start by selecting all events
trgval = strcmp('UPPT001',{event.type}); % this should be a row vector
trgvalIndex = find(trgval);


%Find the first instance of stimulus start and use that

first_stim_on = find([event(trgvalIndex).value]==21);

%Only keep trgvalIndex after the first instance of stimulus onset.
trgvalIndex=trgvalIndex(first_stim_on(1):end);


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



%Create a matrix with all the relevant trigger columns + offsets etc.
trl= zeros(sum([event(trgvalIndex).value]==trigger.self_occlusion),15);%zeros(sum(trgval==goCue),numel(trigAll)+1); %Actually empty var.

%Establish point of reference after each trigger==64. Counting trials.
trlN=1;
%Define trloff (trial offset). Need to be a running value during each
%trial.
trloff=0;

for i=1:length(trgvalIndex)

    %Start of a new trial.
    switch event(trgvalIndex(i)).value
        case trigger.stim_start;
            %trl(trlN,1)=trlbeg;
            stimSample = event(trgvalIndex(i)).sample;
            trl(trlN,4)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,3)=begtrl;
            trl(trlN,15)=trlN;
            trloff=0;
            trl(trlN,1)=event(trgvalIndex(i)).sample+begtrl;
            trl(trlN,2)=event(trgvalIndex(i)).sample+endtrl;

        case trigger.self_occlusion
            %Simulus onset trial offset
            trl(trlN,6)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,5)=event(trgvalIndex(i)).value;
            %Trial start 2s before Stimulus onset

        case trigger.stim_off
            %Onset of go cue
            trl(trlN,8)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,7)=event(trgvalIndex(i)).value;

        case trigger.go_cue
            %Onset of go cue
            trl(trlN,10)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,9)=event(trgvalIndex(i)).value;

        case {trigger.resp_leftL,trigger.resp_rightL,trigger.resp_leftR,trigger.resp_rightR,trigger.resp_bad}
            %response triggers
            trl(trlN,12)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN,11)=event(trgvalIndex(i)).value;

            trlN=trlN+1;
  %      case {trigger.block_start}
  %          trl(trlN,12)=event(trgvalIndex(i)).sample-stimSample;
  %          trl(trlN,11)=event(trgvalIndex(i)).value;
            %Adding 2.4s to include more data after feedback.
            %trl(trlN,2)=event(trgvalIndex(i)).sample+endtrl*fsr;

        case trigger.block_end
            trl(trlN-1,14)=event(trgvalIndex(i)).sample-stimSample;
            trl(trlN-1,13)=event(trgvalIndex(i)).value;

        %case {trigger.block_start,trigger.block_end}
        %    %trl(trlN,13)=event(trgvalIndex(i)).sample;
        %    trl(trlN,13)=event(trgvalIndex(i)).value;

    end

end





end
