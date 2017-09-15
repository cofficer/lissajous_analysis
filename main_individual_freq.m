


part_available = 1:29;
remove_part = ones(1,length(part_available));
remove_part(1)=0;
remove_part(8)=0;
remove_part(11)=0;
remove_part(16)=0;
part_available(logical(~remove_part))=[];

%loop over part_ID, and proft???
for part_idx = 1:length(part_available)
[freq,switchTrial,stableTrial]=freq_average_individual(part_available(part_idx))
plot_average_individual(part_ID,freq,switchTrial,stableTrial)

end
