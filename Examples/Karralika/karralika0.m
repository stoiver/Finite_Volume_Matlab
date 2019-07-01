function [mesh,q] = karralika0(parms)
%
% function [mesh,q] = karralika0(parms)
% 
% Produce a mesh and concentation field
% associated with the karralika water supply
% reservoir

%----------------------------
% Read in basic mesh
%----------------------------
[mesh, depth] = karralikaMesh;

%----------------------------
% Water depth is the average 
% of the depth at the nodes
%----------------------------
q = zeros(3,size(mesh.t,2));

q(1,:) = depth;

height = max(q(1,:),[],2);
fvmSetPlotScale([0 height])

%-------------------
% Set up transmissive boundaries
%-------------------
mesh = fvmNeigh(mesh);

for i = 1:3
  ii = find(mesh.tneigh(i,:)==0);
  if ~isempty(ii)
    mesh.tneigh(i,ii) = -1;
  end
end



return
