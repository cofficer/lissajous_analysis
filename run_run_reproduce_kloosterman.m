
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Correlate switch-related activity with
%upcoming perceptual duration.
%In order to replicate the correlation:
%1. Piecewise linear detrending of the scalar MEG/trial. -STRANGE.
%2. Group the resulting scalar trial values into 10 equal valued bins.
%2. normalize by the median percept duration. Or don't.
%Created 20/09/2018.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

loop_parts=2:29;
for ipart = 1:length(loop_parts)
  if loop_parts(ipart)<10
    run_switch_behaviour_reproduce_kloosterman(sprintf('0%s',num2str(loop_parts(ipart))))
  else
    run_switch_behaviour_reproduce_kloosterman(sprintf('%s',num2str(loop_parts(ipart))))
  end
end
