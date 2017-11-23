function [sensors]=trial_sensor_selection(cfgin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Created 2017-11-24
%Sensors identified which are maximally
%to the rotating lissajous figure.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Considerations:
%Region of interest, 60-90Hz, centered on 400ms after initial rotation.
%Which sensors are significantly activated when comparing rotating and
%non-rotating
%Questions:
%Identify different sensors for different participants?
%We can then use these sensors to look at the contra-lateral responses.
%Storage format:
%Save the sensors for each participant in a struct? OR call this function
%For each participant and run the analysis. Save.
%What is the best analysis to find the best sensor selection?
%First off, should remove blinks occuring during time of interest.
%Secondly, should remove trials that are not relevant, that is test trials.
%Thirdly, should identify the cause of any artifactual looking TOPO plots.
%-more specifically the cases where there is very localized increase/decrease
%from what might a sensor jump?
%Fourth,
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%





%Sidenote: Would it not be amazing to have an adjustable 3D tool, which is
%interactive, whereby you can rotate between source/sensor space, with any
%freq settings or baseline setting or source model. And adjustable in time,
%And fully equiped with statistical analysis. This is why I would need
%to start working in an all-purpose language again, like Python. 








end
