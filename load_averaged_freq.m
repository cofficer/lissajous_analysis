
function [freq,avg_freq_stable,avg_freq_switch]=load_averaged_freq(frequencies,cfgin)
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Created 2017-10-11
  %Loads all averaged freq continuous data.
  %TODO: accomodate trial-based freq data.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


  cd(sprintf('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/%s/freq/',cfgin.blocktype))

  datainfosLow = dir(sprintf('*%s*.mat',frequencies));

  datainfosAll = dir('*.mat');

  datainfoHigh = datainfosAll(~ismember({datainfosAll.name},{datainfosLow.name}));

  datainfos=datainfosLow;

  %Just to get the freq info stored in all structs.
  load(datainfos(1).name)

  %average modulation for switch vs no switch.
  avg_freq_svsn=zeros(length(datainfos),274,length(freq.freq),101);
  avg_freq_switch=zeros(length(datainfos),274,length(freq.freq),101);
  avg_freq_stable=zeros(length(datainfos),274,length(freq.freq),101);

  for idata = 1:length(datainfos)
    disp(datainfos(idata).name)

    load(datainfos(idata).name)

    %average modulation for switch vs no switch.
    avg_freq_svsn(idata,:,:,:) = freq.powspctrm;
    avg_freq_switch(idata,:,:,:)=switchTrial;
    avg_freq_stable(idata,:,:,:)=stableTrial;

  end
  avg_freq_svsn=squeeze(nanmean(avg_freq_svsn,1));
  avg_freq_switch=squeeze(nanmean(avg_freq_switch,1));
  avg_freq_stable=squeeze(nanmean(avg_freq_stable,1));

end
