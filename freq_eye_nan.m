function freq_eye_nan(~)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%insert nan values in freq analysis structure
%Created 2018-02-16.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%freq path
cd(sprintf('%s%s/freq/%s/',cfgin.fullpath(1:56),cfgin.blocktype,cfgin.stim_self))

%preproc path


load('28freq_low_selfocclBlock2-26-26.mat')

%Procedures:
%1. Identify blinks and insert nans in freq data.
%2. Highpass filter the freq data.
%3. Nanmean freq data into averages. No baseline




end
