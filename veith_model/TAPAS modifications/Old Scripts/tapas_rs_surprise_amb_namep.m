function pstruct = tapas_rs_surprise_amb_namep(pvec)
% --------------------------------------------------------------------------------------------------
% Copyright (C) 2012-2013 Christoph Mathys, TNU, UZH & ETHZ
%
% This file is part of the HGF toolbox, which is released under the terms of the GNU General Public
% Licence (GPL), version 3. You can redistribute it and/or modify it under the terms of the GPL
% (either version 3 or, at your option, any later version). For further details, see the file
% COPYING or <http://www.gnu.org/licenses/>.


pstruct = struct;

pstruct.ze1v = pvec(1);
pstruct.ze1i = pvec(2);
pstruct.ze2  = pvec(3);
pstruct.ze3  = pvec(4);
pstruct.ze1v_amb = pvec(5);
pstruct.ze1i_amb = pvec(6);
pstruct.ze2_amb  = pvec(7)
return;
