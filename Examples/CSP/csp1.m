function [mesh,q] = csp1(parms)
%
% function [mesh,q] = csp1(parms)
% 
% Produce a mesh and concentation field
% associated with the hackett water supply
% reservoir with just one section releasing 
% water


%----------------------------
% Read in basic mesh
%----------------------------
[mesh, q] = cspMesh;

height = max(q(1,:),[],2);

fvmSetPlotScale([0 height])
fvmSetPlotRange([0 height])

%-------------------
% Set up transmissive boundaries
%-------------------
mesh = fvmNeigh(mesh);

return
