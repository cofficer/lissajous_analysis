%% get starting values for response speeds

%% loaded res?!

for i=1:31
 minimal(i)=min(response_speed{i})  
 maxminusmin(i)=max(response_speed{i})-min(response_speed{i}); 
end

mean(minimal)
mean(maxminusmin)