function plot_cont_bias
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  %Load in behavioral data, and plot across events.
  %Created 29/03/2018.
  %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/code')
  startup_liss

  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  load('Table_continfo.mat')

  avg_trls = size(trlTA,1)/29;

  %remove bad trials, only keep stable or switch trials.
  %looks to already be done, with NaNs inserted.
  resps = trlTA(:,:).responseValue;

  %Change 226 and 228 to correct.
  % unique(resp_nonan)
  resps(resps==226)=225;
  resps(resps==228)=232;

  idx_map_switch = find(trlTA.participant==19);
  idx_map_switch=idx_map_switch(1);

  %shift the responses after part 18.
  idx_225 = resps==225;
  idx_225 = idx_225(idx_map_switch:end);
  new_resps = resps(idx_map_switch:end);
  new_resps(idx_225) = 232;

  idx_232 = resps==232;
  idx_232 = idx_232(idx_map_switch:end);
  new_resps(idx_232) = 225;

  resps(idx_map_switch:end)=new_resps;

  %Overall bias response...
  idx_nan = ~isnan(resps);
  table_nonan = trlTA(idx_nan,:);
  resp_nonan = resps(idx_nan);

  %gramm plots
  tot_232 = sum(resps==232);
  tot_225 = sum(resps==225);

  %Check the bias per participant
  for ipart = 1:29;

    curr_idx = table_nonan.participant==ipart;

    %bias
    left = sum(resps(curr_idx)==225);
    right = sum(resps(curr_idx)==232);

    bias(ipart) = left/right;

  end

  bias_mag=abs(bias-1);

  clear g;close all
  % g(1,1)=gramm('x',[1:29,1:29],'y',[bias,ones(1,29)],'color',[ones(1,29),ones(1,29)*2]);
  g(1,1)=gramm('x',[1:29],'y',[bias_mag]);
  g(1,1).geom_point();
  g(1,1).set_text_options('base_size',20);
  figure('Position',[100 100 800 600]);
  g(1,1).set_names('x','Participant #','y','Magnitude bias');
  g(1,1).set_point_options('base_size',10)
  g.draw();
  cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
  %Name of figure
  filetyp='svg';
  %name filess
  formatOut = 'yyyy-mm-dd';
  todaystr = datestr(now,formatOut);
  namefigure = sprintf('cont_magbias_blocks_line');%fractionTrialsRemaining
  filetype    = 'svg';
  figurename = sprintf('%s_%s.%s',todaystr,namefigure,filetype);
  g.export('file_name',figurename,'file_type',filetype);

end
