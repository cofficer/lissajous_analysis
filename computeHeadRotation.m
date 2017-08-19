
function cc_rel = computeHeadRotation(data)

% take only head position channels
cfg         = [];
cfg.channel = {'HLC0011','HLC0012','HLC0013', ...
    'HLC0021','HLC0022','HLC0023', ...
    'HLC0031','HLC0032','HLC0033'};
hpos        = ft_selectdata(cfg, data);

% calculate the mean coil position per trial
if length(hpos.trial)==1
    
    %define how often you want to calculate the coil positions
    numSec     = 5; 
    stepsize   = 1200*numSec;
    
    coil1 = nan(3, length(hpos.time{1}(1:stepsize:end))-1);
    coil2 = nan(3, length(hpos.time{1}(1:stepsize:end))-1);
    coil3 = nan(3, length(hpos.time{1}(1:stepsize:end))-1);
else
    coil1 = nan(3, length(hpos.trial));
    coil2 = nan(3, length(hpos.trial));
    coil3 = nan(3, length(hpos.trial));
end
%If there is only one trial then the coil calculations need to be made
%within that one trial every 20s
if length(hpos.trial)==1
    
    
    for t = 1:length(hpos.time{1}(1:stepsize:end))-1
    
    posStart = t*stepsize-stepsize+1;
    posEnd   = t*stepsize;
        
    coil1(:,t) = [mean(hpos.trial{1}(1,posStart:posEnd)); mean(hpos.trial{1}(2,posStart:posEnd)); mean(hpos.trial{1}(3,posStart:posEnd))];
    coil2(:,t) = [mean(hpos.trial{1}(4,posStart:posEnd)); mean(hpos.trial{1}(5,posStart:posEnd)); mean(hpos.trial{1}(6,posStart:posEnd))];
    coil3(:,t) = [mean(hpos.trial{1}(7,posStart:posEnd)); mean(hpos.trial{1}(8,posStart:posEnd)); mean(hpos.trial{1}(9,posStart:posEnd))];
    
    end
else
    for t = 1:length(hpos.trial),
        coil1(:,t) = [mean(hpos.trial{1,t}(1,:)); mean(hpos.trial{1,t}(2,:)); mean(hpos.trial{1,t}(3,:))];
        coil2(:,t) = [mean(hpos.trial{1,t}(4,:)); mean(hpos.trial{1,t}(5,:)); mean(hpos.trial{1,t}(6,:))];
        coil3(:,t) = [mean(hpos.trial{1,t}(7,:)); mean(hpos.trial{1,t}(8,:)); mean(hpos.trial{1,t}(9,:))];
    end
end
% calculate the headposition and orientation per trial (function at the
% bottom of this script)

cc     = circumcenter2(coil1, coil2, coil3);

% compute relative to the first trial
cc_rel = [cc - repmat(cc(:,1),1,size(cc,2))]';
cc_rel = 1000*cc_rel(:, 1:3); % translation in mm

end


