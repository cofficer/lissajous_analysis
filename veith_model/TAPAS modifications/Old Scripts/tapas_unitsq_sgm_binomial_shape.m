function logp = tapas_unitsq_sgm(r, infStates, ptrans)
% Calculates the log-probability of response y=1 under the unit-square sigmoid model
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Transform zeta to its native space
ze = exp(ptrans(1));
precision(1)=exp(ptrans(2));
precision(2)=exp(ptrans(3));
precision(3)=exp(ptrans(4));


% Initialize returned log-probabilities as NaNs so that NaN is
% returned for all irregualar trials
logp = NaN(length(infStates(:,1,1)),1);


% calculate q

for i=1:length(r.u) 
categories{i}=find(r.u(i,1:3)~=0.5);    
total_precision(i,1)=sum(precision(categories{i}));

perceptual_prior_mean(i,1)=0;
for ii=1:length(categories{i})
perceptual_prior_mean(i,1)=perceptual_prior_mean(i,1)+r.u(i, categories{i}(ii))*(precision(categories{i}(ii))/total_precision(i,1));  
end

perceptual_prior_sa(i,1)=1/total_precision(i,1); 

percept2=1; 
percept1=0;
       
ratio(i,1)=exp(((percept2-perceptual_prior_mean(i,1)).^2-(percept1-perceptual_prior_mean(i,1)).^2)./(2.*(perceptual_prior_sa(i,1)).^2));
        
Model.rel_posterior_percept_2(i,1)=1/(ratio(i,1)+1);
Model.rel_posterior_percept_1(i,1)=1-Model.rel_posterior_percept_2(i,1);

q(i,1)=Model.rel_posterior_percept_2(i,1);
end




% Weed irregular trials out from inferred states and responses
x = q;
x(r.irr) = [];
y = r.y(:,1);
y(r.irr) = [];

% Avoid any numerical problems when taking logarithms close to 1
logx = log(x);
log1pxm1 = log1p(x-1);
logx(1-x<1e-4) = log1pxm1(1-x<1e-4);
log1mx = log(1-x);
log1pmx = log1p(-x);
log1mx(x<1e-4) = log1pmx(x<1e-4); 

% Calculate log-probabilities for non-irregular trials
logp(not(ismember(1:length(logp),r.irr))) = y.*ze.*(logx -log1mx) +ze.*log1mx -log((1-x).^ze +x.^ze);

return;