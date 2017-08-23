%Main behavior script for lissajous


load('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior/allTrialsTable.mat')

allRun = [];
for ipart = 1:trlTA.participant(end)

  idx_part = trlTA.participant==ipart;

  %Get resp data of interest. Replace the response with 1.0s.
  resp = trlTA.responseValue(idx_part);
  %resp(resp==225) = 0;
  %resp(resp==232) = 1;

  %Split the trials into each block. 134 self-occlusions per block.
  idx_block = 1;

  %Always look the first five blocks and add the last.
  for iblock = 1:5

    if iblock == 1
      runlength{iblock} = diff([0; find(diff(resp(1:134))~=0);134])';
    else
      runlength{iblock} = diff([0; find(diff(resp(134*iblock-133:134*iblock))~=0);134])';
    end

  end
  runlength{iblock+1}  = diff([0; find(diff(resp(134*iblock+1:end))~=0);length(resp(134*iblock+1:end))])';

  [co_var(ipart),skew_var(ipart)]=compute_distmoments([runlength{:}]);
  meanPercepts(ipart) = mean([runlength{:}]);

  allRun = [allRun runlength{:}];

end

%Plot switches across all participants.
clear g
close
figure(1),clf
g = gramm('x',allRun);
g.stat_bin('edges',1:25,'normalization','probability');
g.set_names('column','Origin','x','Mean percept duration (self-occlusion)','y','% of switches','color','# Cylinders');
g.draw();
saveas(gca,'behavHistGramm.png','png')
%%
%Plot the coefficient of covariance against the mean
clear g
close
g(1,1)=gramm('x',meanPercepts,'y',co_var);
g(1,1).geom_point();
g(1,1).set_names('column','Origin','x','mean percept duration','y','Coefficient of variance','color','# Cylinders');
g(1,1).set_title('Coeff. of variance against the mean percept duration');


%plot the mean
g(1,2)=gramm('x',meanPercepts,'y',co_var);
g(1,2).stat_summary();
g(1,2).set_names('column','Origin','x','mean percept duration','y','Coefficient of variance','color','# Cylinders');
g(1,2).set_title('Summary stat mean');


g(2,1)=gramm('x',meanPercepts,'y',skew_var);
g(2,1).geom_point();
g(2,1).set_names('column','Origin','x','mean percept duration','y','skewness','color','# Cylinders');
g(2,1).set_title('skewness against the mean percept duration');


%plot the mean
g(2,2)=gramm('x',meanPercepts,'y',skew_var);
g(2,2).stat_summary();
g(2,2).set_names('column','Origin','x','mean percept duration','y','skewness','color','# Cylinders');
g(2,2).set_title('Summary stat mean');
g.draw();

cd('/mnt/homes/home024/chrisgahn/Documents/MATLAB/Lissajous/behavior')
saveas(gca,'behavOverview.png','png')
