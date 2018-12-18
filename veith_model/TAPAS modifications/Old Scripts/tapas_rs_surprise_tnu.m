function logp = tapas_rs_surprise(r, infStates, ptrans)


% Calculates the log-probability of response speed y (in units of ms^-1) according to the surprise
% model introduced in:
%
% Vossel, S.*, Mathys, C.*, Daunizeau, J., Bauer, M., Driver, J., Friston, K. J., and Stephan, K. E.
% (2013). Spatial Attention, Precision, and Bayesian Inference: A Study of Saccadic Response Speed.
% Cerebral Cortex.
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Transform zetas to their native space
ze1v = exp(ptrans(1));
ze1i = exp(ptrans(2));
ze2  = exp(ptrans(3));
ze3  = exp(ptrans(4));

ze1v_amb = exp(ptrans(5));
ze1i_amb = exp(ptrans(6));
ze2_amb  = exp(ptrans(7));

ze=exp(ptrans(8));


% Initialize returned log-probabilities as NaNs so that NaN is
% returned for all irregualar trials
logp = NaN(length(infStates(:,1,1)),1);
logp1 = NaN(length(infStates(:,1,1)),1);
logp2 = NaN(length(infStates(:,1,1)),1);

% Weed irregular trials out from inferred states, responses, and inputs
mu1hat = infStates(:,1,1);
mu1hat(r.irr) = [];

x=infStates(:,1,5);
x(r.irr,:)=[];

y(:,1) = r.y(:,3); % response speed
y(:,2)=r.y(:,2); % preceptual decision
y(r.irr,:) = [];

u = r.u;
u(r.irr,:) = [];


% Calculate alpha (i.e., attention)
alpha = 1./(1-log2(mu1hat));

% Calculate predicted response speed
for i=1:length(u)
    
if u(i,3)~=0.5    
rs(i,1) = u(i,1).*(ze1v + ze2*alpha(i)) + (1-u(i,1)).*(ze1i + ze2*(1-alpha(i)));   
elseif u(i,3)==0.5 
rs(i,1) = u(i,1).*(ze1v_amb + ze2_amb*alpha(i)) + (1-u(i,1)).*(ze1i_amb + ze2_amb*(1-alpha(i)));    
end

end



% for i=1:length(u)
% rs(i,1) = u(i,4).*(ze1v + ze2*x(i)) + (1-u(i,4)).*(ze1i + ze2*(1-x(i)));   
% end    
%     
%     

% Calculate log-probabilities for non-irregular trials
% Note: 8*atan(1) == 2*pi (this is used to guard against
% errors resulting from having used pi as a variable).
logp1(~ismember(1:length(logp),r.irr)) = -1/2.*log(8*atan(1).*ze3) -(y(:,1)-rs).^2./(2.*ze3);


logx = log(x);
log1pxm1 = log1p(x-1);
logx(1-x<1e-4) = log1pxm1(1-x<1e-4);
log1mx = log(1-x);
log1pmx = log1p(-x);
log1mx(x<1e-4) = log1pmx(x<1e-4); 

% % Calculate log-probabilities for non-irregular trials
logp2(not(ismember(1:length(logp),r.irr))) = y(:,2).*ze.*(logx -log1mx) +ze.*log1mx -log((1-x).^ze +x.^ze);
logp=logp1+logp2;



return;
