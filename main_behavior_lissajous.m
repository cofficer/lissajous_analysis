%Main behavior script for lissajous


load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior/allTrialsTable.mat')

max(trlTA.trlN)

figure(1),clf
plot(trlTA.trlN)

for ipart = 1:length(trlTA.participant(end))

  idx_part = trlTA.participant==ipart;

  %Get resp data of interest. Replace the response with 1.0s.
  resp = trlTA.responseValue(idx_part);
  %resp(resp==225) = 0;
  %resp(resp==232) = 1;

  %Split the trials into each block. 134 self-occlusions per block.
  idx_block = 1;
  numBlocks = floor(length(trlTA.responseValue(idx_part))/134);
  for iblock = 1:numBlocks

    if iblock == 1
      resp_all=resp(1:134);
      resp_all(end+1) = NaN;
    else
      nextBlock = resp(length(resp_all):134*iblock);
      resp_all = [resp_all;NaN;nextBlock];
    end

  end
end


runlength1=diff(find(diff(trlT.responseValue(trlT.responseValue~=0))~=0));


runlength=diff(find(diff(resp_all)~=0));

saveas(gca,'hist.png','png')

compute_distmoments(runlength)
