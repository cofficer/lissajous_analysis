function [pvec, pstruct] = tapas_hgf_binary_transp(r, ptrans)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.


pvec    = NaN(1,length(ptrans));
pstruct = struct;

l = r.c_prc.n_levels;

pvec(1:l)         = ptrans(1:l);                           % mu_0
pstruct.mu_0      = pvec(1:l);
pvec(l+1:2*l)     = exp(ptrans(l+1:2*l));                  % sa_0
pstruct.sa_0      = pvec(l+1:2*l);
pvec(2*l+1:3*l)   = ptrans(2*l+1:3*l);                     % rho
pstruct.rho       = pvec(2*l+1:3*l);
pvec(3*l+1:4*l-1) = exp(ptrans(3*l+1:4*l-1));              % ka
pstruct.ka        = pvec(3*l+1:4*l-1);
pvec(4*l:5*l-1)   = ptrans(4*l:5*l-1);                     % om
pstruct.om        = pvec(4*l:5*l-1);

pvec(end-5)       = exp(ptrans(end-5));                    % InitPi
pstruct.tau         = pvec(end-5);
pvec(end-4)       = exp(ptrans(end-4));                        % ErrorPi
pstruct.tau_s         = pvec(end-4);
pvec(end-3)       = exp(ptrans(end-3));                        % StereoPi
pstruct.noise       = pvec(end-3);
pvec(end-2)       = exp(ptrans(end-2));                    % InitPi
pstruct.sigma       = pvec(end-2);
pvec(end-1)       = exp(ptrans(end-1));                        % ErrorPi
pstruct.boundary         = pvec(end-1);
pvec(end)       = exp(ptrans(end));                        % StereoPi
pstruct.certainty       = pvec(end);


return;
