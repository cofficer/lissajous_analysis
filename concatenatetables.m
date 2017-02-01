

%A script for conctenating the behavioral data from all participants
%extracted from the MEG data. 

trlTA = []; 

%So far six participants.
for inumP = 1:12
    
    
    trlT=check_lissajousCONT(inumP);
    
    trlTA = [trlTA;trlT];
    
    disp(inumP)
    
end

disp('Finished concatenating all trials')

%Add together the 225/228 and the 226/232, issue is or 3 participants the
%buttons were switched. 

trlTA.responseValue(trlTA.responseValue==228)=225;
trlTA.responseValue(trlTA.responseValue==226)=232;