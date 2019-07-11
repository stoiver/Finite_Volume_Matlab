function [mesh,q] = swInitSquare0(parms)
%
% function [mesh,q] = swInitSquare0(parms)
%
% Setup initial condition for Shallow Water equation
%
%

%--------------------------------
% Start Computation
%--------------------------------
mesh = fvmRectMesh(parms);

%--------------------------------
% First get some info about the 
% mesh
%--------------------------------
minx = min(mesh.p(1,:));
maxx = max(mesh.p(1,:));
miny = min(mesh.p(2,:));
maxy = max(mesh.p(2,:));

c = fvmCentroid(mesh);
scale = [1 10];
q(1,:) = scale(1) + ...
  (scale(2)-scale(1))*...
  (c(1,:)>-0.2 & c(1,:)<0.2 & c(2,:)>-0.2 & c(2,:)<0.2);
q(2,:) = zeros(1,size(mesh.t,2));
q(3,:) = q(2,:);

fvmSetPlotScale(scale);
