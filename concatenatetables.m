

%A script for conctenating the behavioral data from all participants
%extracted from the MEG data.
clear all
trlTA = [];



%So far six participants.
for inumP = 1:29


    trlT=check_lissajousCONT(inumP);


    %This finds the runlengths, but it ignores the invalid responses which
    %is problematic

    trlT.responseValue(find(trlT.responseValue==0))=NaN;

    %Find all the places where the difference between two trials is not 0,
    %that is find the trials with perceptual reversals. Then find the
    %difference between those indices. The number of the index difference
    %is how long the perception lasted for. But not true if there is a
    %NaN...
    %The only way his would work is if you ignored the NaNs for the
    %indices.
    runlength1=diff(find(diff(trlT.responseValue)~=0));



    diffSequence1 = unique(runlength1);

    sequenceOccurence1=[];

    for idiffseq=1:numel(diffSequence1)

        sequenceOccurence1(idiffseq) = sum(runlength1==diffSequence1(idiffseq));


    end


    continuousSeq1=zeros(1,length(diffSequence1));

    continuousSeq1(diffSequence1)=sequenceOccurence1;



    reversetime=[];


    for ireversals = 1:length(continuousSeq1)


        reversetime=[reversetime,repmat(ireversals*4.5,1,continuousSeq1(ireversals))];

        %reversetime(ireversals)=continuousSeq1(ireversals)*ireversals*4,5;


    end


    coV(inumP) = std(reversetime)/mean(reversetime);
    


    trlTA = [trlTA;trlT];

    disp(inumP)

end

disp('Finished concatenating all trials')

%Add together the 225/228 and the 226/232, issue is or 3 participants the
%buttons were switched.

%trlTA.responseValue(trlTA.responseValue==228)=225;
%trlTA.responseValue(trlTA.responseValue==226)=232;

save('/home/chris/Dropbox/PhD/Projects/Lissajous/behaviour/Table_continfo_trlnumblock.mat','trlTA')
