
%Read events from the lissajous raw data

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/code')

%The first data set is for trialbased in this condition. 
%Take the script from trialfun. Create a trialdefinition. 
%Pre-selfocclusion + button press. 


%define triggers, 
block_start         = 1;     %fixation onset
trial_start         = 11;   %stimulus horizontal onset
stim_start          = 21;   %stimulus vertical onset
stim_off            = 22;   %stimulus vertical onset
go_cue              = 31;   %response horizontal right 
off_cue             = 32;   %response horizontal left
signal_off          = 33;   %end of signal ??? 
self_occlusion      = 10;   %response vertical left
resp_leftL          = 41;   %41 1st button from left
resp_leftL2         = 225;  %from uppt002
resp_leftR          = 42;   %2nd button from left
resp_leftR2         = 226;   %2nd button from left
resp_rightL         = 45;   %1st button from left
resp_rightL2        = 228;   %1st button from left
resp_rightR         = 46;   %46 2nd button from left
resp_rightR2        = 232;   %46 2nd button from left
resp_bad            = 43;   %2nd button from left

trial_end           = 61; %New block onset
block_end           = 90; %Not currenlty in use. 

%All triggers
trigAll     =[1,11,21,22,31,32,33,10,41,42,45,46,43,61,90,232,225];



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%%%Continuous trials, mainly plotting.                                   %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Plot the mean switch rate, self occlusion. 
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
load('tomTableP01.mat')
load('chrisTableP02.mat')

%loaded at trlT
load('TableP03CONT.mat')

%Change the responsevalues for P03
trlT.responseValue(trlT.responseValue==226)=225;
trlT.responseValue(trlT.responseValue==228)=232;


%Plotting the raw choices:
figure(1),clf
hold on;
subplot(2,1,1)
plot(trlT.responseValue(trlT.responseValue~=0))
ylim([220 236])

%subplot(2,1,2)
%plot(trlT2.responseValue(trlT2.responseValue~=0))
%ylim([220 236])

%Plotting the streaks of same choice. 
plot((diff(trlT.responseValue(trlT.responseValue~=0))~=0))
figure(2),clf
hold on;
subplot(2,1,1)
plot((diff(trlT.responseValue(trlT.responseValue~=0))~=0))
ylim([-1 2])

%subplot(2,1,2)
%plot((diff(trlT2.responseValue(trlT2.responseValue~=0))~=0))
%ylim([-1 2])

%Plot barplots of left vs right choices

%The propensity for left or right choices. 
leftBP1 = sum(trlT.responseValue(1:end-1)==225);
rightBP1 = sum(trlT.responseValue(1:end-1)==232);

%The propensity for left or right choices. 
%leftBP2 = sum(trlT2.responseValue(1:end-1)==225);
%rightBP2 = sum(trlT2.responseValue(1:end-1)==232);

figure(3),clf
hold on;
subplot(2,1,1)
bar([leftBP1 rightBP1])
set(gca,'XtickLabel',{'Left','Right'})

title('Choice bias, left vs right')

%subplot(2,1,2)
%bar([leftBP2 rightBP2])
%set(gca,'XtickLabel',{'Left','Right'})

%Plot the sequences of identical choices. Number of repetitios
runlength1=diff(find(diff(trlT.responseValue(trlT.responseValue~=0))~=0));

%runlength2=diff(find(diff(trlT2.responseValue(trlT2.responseValue~=0))~=0));


figure(4),clf

hold on;
subplot(2,1,1)

hist(runlength1)
title('Histogram of perceptual dominance for run of self-occlusions')
%subplot(2,1,2)
%hist(runlength2)


%
figure(5),clf
hold on;
plot(sort(runlength1'))

%plot(sort(runlength2'))

%calculate the occurenece of the sequences
diffSequence1 = unique(runlength1);

%diffSequence2 = unique(runlength2);

for idiffseq=1:numel(diffSequence1)

    sequenceOccurence1(idiffseq) = sum(runlength1==diffSequence1(idiffseq));
    

end

% 
% for idiffseq=1:numel(diffSequence2)
% 
%     sequenceOccurence2(idiffseq) = sum(runlength2==diffSequence2(idiffseq));
%     
% 
% end


continuousSeq=zeros(1,31);

%continuousSeq2=continuousSeq;

%continuousSeq2(diffSequence2)=sequenceOccurence2;

continuousSeq1=continuousSeq;

continuousSeq1(diffSequence1)=sequenceOccurence1;


%Create a cumulative plot
figure(6),clf
hold on;
bar([(continuousSeq1)]','stacked')
title('Stacked bar plot of perceptual dominance for run of self-occlusions')

%bar(diffSequence1,sequenceOccurence1)

legend Tom Chris

%Plotting in log log, to see the linear decay better
figure(7),clf

hold on
plot(log2(1:31),log2(continuousSeq1),'o')

%plot(log2(1:31),log2(continuousSeq2),'o')

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Create plots for the trial-based blocks                                 %
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

clear

allResponses = [225;226;228;232];

%loop over participants
figure(1)
title('Tom and Chris Trial-based block responses')

trlT=check_lissajousTRIAL(numP);


typesResponse=unique(trlT.responseValue(trlT.responseValue>0));
totalResp=[];
%plot bars for each response type
for iresp = 1:length(typesResponse)
   
    totalResp(iresp) = sum(trlT.responseValue==typesResponse(iresp));
    
    
end


%Define the labels for the x axis.
buttons = {'Left to left','Left to right','Right to left','Right to right'};

%Find the positions where responses are missing.
[typesResponse,existResponseIndex,bi]=intersect(allResponses,typesResponse);

missingResponse=setdiff(1:4,existResponseIndex);

%Add 0 to the missing reponse in the correct position
totalResp(existResponseIndex')=totalResp;

totalResp(missingResponse)=0;

%Plot the bars
figure(1)

bar(totalResp)
if numP==1
    title('Frequency for every type of stimulus response')
end

set(gca,'XTickLabel',buttons)



%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%%% Plot all response types for the continuous blocks.                  %%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
clear
cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
%load('tomTableP01.mat')
%load('chrisTableP02.mat')
figure(2)
numP=3;

trlT=check_lissajousCONT(numP);

%Calulate the occuarance for each response pair. 
allResponses = [225;232];

%Preallocate the sum of each response pair
leftL =0;
leftR =0;
rightL=0;
rightR=0;

%Change the responsevalues for P03
trlT.responseValue(trlT.responseValue==226)=225;
trlT.responseValue(trlT.responseValue==228)=232;

for itrl=1:length(trlT.responseValue)

if itrl>1
    
    %Compare the last and the current response
    lastTrl = trlT.responseValue(itrl-1);

    currentTrl = trlT.responseValue(itrl);

    bothTrl = [lastTrl,currentTrl];
    
    switch int2str(bothTrl)
        
        %Left to left
        case int2str([allResponses(1) allResponses(1)])
            
            leftL = leftL+1;
            
        %Left to right    
        case int2str([allResponses(1) allResponses(2)])
                        
            leftR = leftR+1;
            
        %Right to left
        case int2str([allResponses(2) allResponses(1)])
                        
            rightL = rightL+1;
            
        %Right to right
        case int2str([allResponses(2) allResponses(2)])
                        
            rightR = rightR+1;
            
    end
end    
bar([leftL leftR rightL rightR])
buttons = {'Left to left','Left to right','Right to left','Right to right'};
set(gca,'XTickLabel',buttons)

end


%%

%Plot the self-occlusion accurately in time, together with all the
%response. Start with the first 100

numP=3;
trlT=check_lissajousCONT(numP);

%Get all the samples on an equal increasing range. Could just plot each
%block individually. 
%Storing the self oclusion samples. 
selfOcclusionSamples = (trlT.selfocclusion2sample(1:120,:)/1200);

selfOcclusionSamples = selfOcclusionSamples-selfOcclusionSamples(1)+1;


%Storing the button reponses:

responseSamples = (trlT.responseSample(1:120,:)/1200);

responseSamples = responseSamples-responseSamples(1)+1;

%Store the go cues:
gocueSamples = (trlT.go_cuesample(1:120,:)/1200);

gocueSamples = gocueSamples-gocueSamples(1)+1;


close all
%plotting the self occlusions
line([selfOcclusionSamples(1:20),selfOcclusionSamples(1:20)],[0 0.5],'Color',[0.5 0.1 0.8])
hold on;
line([responseSamples(1:20),responseSamples(1:20)],[0 1],'Color',[0.3 0.5 0.4])
line([gocueSamples(20:40),gocueSamples(1:20)],[0 0.25],'Color',[0.9 0.1 0.4])

ylim([-1 2])

%%
%Checking the discrepancy of the button presses when comparing the UPPT
%channels. 

disc=trlT.responseScriptSample(trlT.responseScriptSample>0)-trlT.responseSample(trlT.responseScriptSample>0);

disc=mean(disc(abs(disc)<1000));

%%
%Checking the discrepancy of self-occlusions and button presses. 
%Get the average of all three self-occlusions and the responses. 

selfOcclusion1Samples = (trlT.selfocclusion1sample(1:120,:)/1200);

%selfOcclusion1Samples = selfOcclusion1Samples-selfOcclusion1Samples(1)+1;


selfOcclusion2Samples = (trlT.selfocclusion2sample(1:120,:)/1200);

selfOcclusion2Samples = mean(selfOcclusion2Samples-selfOcclusion1Samples)-2.25;


selfOcclusion3Samples = (trlT.selfocclusion3sample(1:120,:)/1200);

selfOcclusion3Samples = mean(selfOcclusion3Samples-selfOcclusion1Samples)-2.25;



responseSamples = (trlT.responseSample(1:120,:)/1200)-selfOcclusion1Samples;

responseSamples = mean(responseSamples(responseSamples>1));

selfOcclusion1Samples = mean(selfOcclusion1Samples-selfOcclusion1Samples)-2.25;

%goCue:
cuetime=trlT.go_cuesample(trlT.go_cuesample>0)-(trlT.selfocclusion1sample(trlT.go_cuesample>0));

close all
%plotting the self occlusions
line([selfOcclusion1Samples,selfOcclusion1Samples],[0 0.25],'Color',[0.9 0.1 0.4])
hold on;
line([responseSamples,responseSamples],[0 1],'Color',[0.3 0.5 0.4])
line([selfOcclusion2Samples,selfOcclusion2Samples],[0 0.25],'Color',[0.9 0.1 0.4])
line([selfOcclusion3Samples,selfOcclusion3Samples],[0 0.25],'Color',[0.9 0.1 0.4])

ylim([-1 2])
xlim([-4 16])
