function [mesh,q] = swInitCircle0(parms)
%
% function [mesh,q] = swInitCircle0(parms)
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

centres = [ (minx+maxx)/2 ; (miny+maxy)/2 ]; 

centres = centres(:,ones(1,size(mesh.p,2)));
radius2 = ((maxx-minx)/5).^2;
pq = sum((mesh.p-centres).^2);
pq = pq<radius2;

scale = [0 10];
q(1,:) = (scale(2)-scale(1))*...
  (pq(mesh.t(1,:))+pq(mesh.t(2,:))+pq(mesh.t(3,:)))/3.0 + scale(1);
q(2,:) = zeros(1,size(mesh.t,2));
q(3,:) = q(2,:);

fvmSetPlotScale(scale);

return
