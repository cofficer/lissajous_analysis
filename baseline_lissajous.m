function [freq_base1,freq_base2]=baseline_lissajous(freq1,freq2,cfg)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Load in already computed freq data
%Compute the baseline according to cfg.
%Created 8/09/2017.
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

freq1=freq1.powspctrm;
freq2=freq2.powspctrm;

toi = cfg.baselinewindow;

%Compute the average signal for combined baseline
freq12 = freq1(:,:,toi(1):toi(2))+freq2(:,:,toi(1):toi(2))./2;
freq12 = mean(freq12,3);

%Compute baseline, subtracting using freq of interest
if strcmp(cfg.subtractmode,'same')
freq_base1 = ((freq1-mean(freq1(:,:,toi(1):toi(2)),3))./freq12)*100;
freq_base2 = ((freq2-mean(freq2(:,:,toi(1):toi(2)),3))./freq12)*100;
%Compute baseline, subtracting using combined freq of interest
elseif strcmp(cfg.subtractmode,'combine')
freq_base1 = ((freq1-freq12)./freq12)*100;
freq_base2 = ((freq2-freq12)./freq12)*100;
end


end
