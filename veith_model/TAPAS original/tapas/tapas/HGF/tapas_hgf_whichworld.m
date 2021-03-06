function [traj, infStates] = tapas_hgf_whichworld(r, p, varargin)
% Calculates the trajectories of the agent's representations under the HGF
%
% This function can be called in two ways:
% 
% (1) tapas_hgf_whichworld(r, p)
%   
%     where r is the structure generated by tapas_fitModel and p is the parameter vector in native space;
%
% (2) tapas_hgf_whichworld(r, ptrans, 'trans')
% 
%     where r is the structure generated by tapas_fitModel, ptrans is the parameter vector in
%     transformed space, and 'trans' is a flag indicating this.
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

% Check whether we have a configuration structure
if ~isfield(r,'c_prc')
    error('tapas:hgf:ConfigRequired', 'Configuration required: before calling tapas_hgf_whichworld, tapas_hgf_whichworld_config has to be called.');
end

% Transform paramaters back to their native space if needed
if ~isempty(varargin) && strcmp(varargin{1},'trans');
    p = tapas_hgf_whichworld_transp(r, p);
end

% Number of worlds
nw = r.c_prc.nw;

% Bernoulli parameters that characterize
% worlds (column vector)
bp = [0.85; 0.15];

% Unpack parameters
mu2_0 = p(1:nw);
sa2_0 = p(nw+1:2*nw);
mu3_0 = p(2*nw+1);
sa3_0 = p(2*nw+2);
ka    = p(2*nw+3);
om    = p(2*nw+4);
th    = p(2*nw+5);
m     = p(2*nw+6);
phi   = p(2*nw+7);

% Add dummy "zeroth" trial
u = [0; r.u(:,1)];

% Number of trials (including prior)
n = length(u);

% Initialize updated quantities

% Representations
mu1 = NaN(n,nw);
pi1 = NaN(n,nw);
mu2 = NaN(n,nw);
pi2 = NaN(n,nw);
mu3 = NaN(n,1);
pi3 = NaN(n,1);

% Other quantities
mu1hat = NaN(n,nw);
pi1hat = NaN(n,nw);
mu2hat = NaN(n,nw);
pi2hat = NaN(n,nw);
mu3hat = NaN(n,1);
pi3hat = NaN(n,1);
v2     = NaN(n,1);
w2     = NaN(n,nw);
da1    = NaN(n,nw);
da2    = NaN(n,nw);

% Representation priors
% Note: first entries of the other quantities remain
% NaN because they are undefined and are thrown away
% at the end; their presence simply leads to consistent
% trial indices.
mu1(1,:) = tapas_sgm(mu2_0, 1);
pi1(1,:) = 1./(mu1(1,:).*(1-mu1(1,:)));
mu2(1,:) = mu2_0;
pi2(1,:) = 1./sa2_0;
mu3(1)   = mu3_0;
pi3(1)   = 1/sa3_0;

% Pass through representation update loop
for k = 2:1:n
    if not(ismember(k-1, r.ign))
        
        %%%%%%%%%%%%%%%%%%%%%%
        % Effect of input u(k)
        %%%%%%%%%%%%%%%%%%%%%%

        % 1st level
        % ~~~~~~~~~
        % Predictions
        mu1hat(k,:) = tapas_sgm(mu2(k-1,:), 1);
        
        % Precisions of predictions
        pi1hat(k,:) = 1./(mu1hat(k,:).*(1 -mu1hat(k,:)));

        % Updates (simply applying Bayes' theorem)
        
        % Likelihood of outcome u(k)
        llh = bp.^u(k).*(1-bp).^(1-u(k));
        
        % Marginal likelihood of outcome
        mllh = mu1hat(k,:)*llh;
        
        % Posterior for each world
        mu1(k,:) = mu1hat(k,:).*llh'./mllh;

        % Precision of posterior
        pi1(k,:) = 1./(mu1(k,:).*(1-mu1(k,:)));
        
        % Prediction errors
        da1(k,:) = mu1(k,:) -mu1hat(k,:);

        % 2nd level
        % ~~~~~~~~~
        % Predictions
        mu2hat(k,:) = mu2(k-1,:);
        
        % Precisions of predictions
        pi2hat(k,:) = 1./(1./pi2(k-1,:) +exp(ka *mu3(k-1) +om));

        % Updates
        pi2(k,:) = pi2hat(k,:) +1./pi1hat(k,:);

        mu2(k,:) = mu2hat(k,:) +1./pi2(k,:) .*da1(k,:);

        % Volatility prediction errors
        da2(k,:) = (1./pi2(k,:) +(mu2(k,:) -mu2hat(k,:)).^2) .*pi2hat(k,:) -1;


        % 3rd level
        % ~~~~~~~~~
        % Predictions
        mu3hat(k) = mu3(k-1) +phi *(m -mu3(k-1));
        
        % Precision of prediction
        pi3hat(k) = 1/(1/pi3(k-1) +th);

        % Weighting factors
        v2(k)   = exp(ka *mu3(k-1) +om);
        w2(k,:) = v2(k) *pi2hat(k,:);

        % Updates
        pi3(k) = pi3hat(k) +1/nw*sum(1/2 *ka^2 *w2(k,:) .*(w2(k,:) +(2 *w2(k,:) -1) .*da2(k,:)));

        if pi3(k) <= 0
            error('tapas:hgf:NegPostPrec', 'Negative posterior precision. Parameters are in a region where model assumptions are violated.');
        end

        mu3(k) = mu3hat(k) +sum(1/2 *1/pi3(k) *ka *w2(k,:) .*da2(k,:));
    
    else
        mu1(k,:) = mu1(k-1,:);
        pi1(k,:) = pi1(k-1,:);
        mu2(k,:) = mu2(k-1,:);
        pi2(k,:) = pi2(k-1,:);
        mu3(k)   = mu3(k-1);
        pi3(k)   = pi3(k-1);

        mu1hat(k,:) = mu1hat(k-1,:);
        pi1hat(k,:) = pi1hat(k-1,:);
        mu2hat(k,:) = mu2hat(k-1,:);
        pi2hat(k,:) = pi2hat(k-1,:);
        mu3hat(k)   = mu3hat(k-1);
        pi3hat(k)   = pi3hat(k-1);
        v2(k)       = v2(k-1);
        w2(k,:)     = w2(k-1,:);
        da1(k,:)    = da1(k-1,:);
        da2(k,:)    = da2(k-1,:);
    end
end

% Implied learning rates at the first level
sgmmu2 = tapas_sgm(mu2, 1);
lr1    = diff(sgmmu2)./da1(2:n,:); 

% Remove representation priors
mu1(1,:)  = [];
pi1(1,:)  = [];
mu2(1,:)  = [];
pi2(1,:)  = [];
mu3(1)    = [];
pi3(1)    = [];

% Remove other dummy initial values
mu1hat(1,:) = [];
pi1hat(1,:) = [];
mu2hat(1,:) = [];
pi2hat(1,:) = [];
mu3hat(1,:) = [];
pi3hat(1)   = [];
v2(1)       = [];
w2(1,:)     = [];
da1(1,:)    = [];
da2(1,:)    = [];

% Create result data structure
traj = struct;

traj.mu = NaN(n-1,3,nw);
traj.mu(:,1,:) = mu1;
traj.mu(:,2,:) = mu2;
traj.mu(:,3,1) = mu3;

traj.sa = NaN(n-1,3,nw);
traj.sa(:,1,:) = 1./pi1;
traj.sa(:,2,:) = 1./pi2;
traj.sa(:,3,1) = 1./pi3;

traj.muhat = NaN(n-1,3,nw);
traj.muhat(:,1,:) = mu1hat;
traj.muhat(:,2,:) = mu2hat;
traj.muhat(:,3,1) = mu3hat;

traj.sahat = NaN(n-1,3,nw);
traj.sahat(:,1,:) = 1./pi1hat;
traj.sahat(:,2,:) = 1./pi2hat;
traj.sahat(:,3,1) = 1./pi3hat;

traj.v       = v2;
traj.w       = w2;

traj.da = NaN(n-1,2,nw);
traj.da(:,1,:) = da1;
traj.da(:,2,:) = da2;

% Updates with respect to prediction
traj.ud = traj.muhat -traj.mu;

% Psi (precision weights on prediction errors)
psi        = NaN(n-1,3,nw);
psi(:,2,:) = 1./pi2;
psi(:,3,:) = diag(1./pi3) *pi2hat;
traj.psi   = psi;

% Epsilons (precision-weighted prediction errors)
epsi        = NaN(n-1,3,nw);
epsi(:,2,:) = squeeze(psi(:,2,:)) .*da1;
epsi(:,3,:) = squeeze(psi(:,3,:)) .*da2;
traj.epsi   = epsi;

% Full learning rate (full weights on prediction errors)
wt        = NaN(n-1,3,nw);
wt(:,1,:) = lr1;
wt(:,2,:) = psi(:,2,:);
wt(:,3,:) = 1/2 *ka *diag(1/pi3) *w2;
traj.wt   = wt;

% Create matrices for use by the observation model
infStates = NaN(n-1,3,nw,4);
infStates(:,:,:,1) = traj.muhat;
infStates(:,:,:,2) = traj.sahat;
infStates(:,:,:,3) = traj.mu;
infStates(:,:,:,4) = traj.sa;

return;
