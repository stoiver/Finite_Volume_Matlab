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
[mesh, q] = radialMesh;

%height = max(q(1,:),[],2);

fvmSetPlotScale([0 1])
fvmSetPlotRange([0 1])

%-------------------
% Set up transmissive boundaries
%-------------------
mesh = fvmNeigh(mesh);

return
