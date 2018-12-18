function [freq_switch]=find_continuous_stay_duration(freq)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %This function will find the number of stable self-occlusion occuring
  %after every perceptual switch.
  %Could also only return the switch trials.
  %Created 19-Nov-2018
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

  %With only switch per trial information, it should be possible to add the
  %distance to next switch... Is that a good metric?

  new_trialinfo   = freq.trialinfo;

  %Initialize the new row which will contain the percept duration values.
  new_trialinfo(:,end+1)        = zeros(1,length(new_trialinfo));

  %Find the position of all the switches.
  %at those position, insert the distance to the next switch
  %However, it should be the upcoming distance to the next switch...
  %One way to get around bad_resp is to pretend they are switches.
  bad_resp                      = find(freq.trialinfo(:,5)==0);
  freq.trialinfo(bad_resp,end)  = 1;
  distance_switches             = diff(find([1;freq.trialinfo(:,end)]));
  index_switches                = find([freq.trialinfo(:,end)]);
  new_trialinfo(index_switches,end) = [distance_switches(2:end);NaN]; %Instead of nan insert the

  freq.trialinfo                = new_trialinfo;

  % return only the switch trials
  cfg         = [];
  cfg.trials  = logical([freq.trialinfo(:,end-1)]');
  cfg.latency = [-0.5 0.5];
  freq_switch = ft_selectdata(cfg,freq);

  % consider also making the mask - better to separate.
end
