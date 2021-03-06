function y = tapas_gaussian_obs_sim(r, infStates, p)
% Simulates observations with Gaussian noise
%
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.

mu = infStates(:,1,1);
ze = p;
n = length(mu);

y = mu+sqrt(ze)*randn(n, 1);

return;
