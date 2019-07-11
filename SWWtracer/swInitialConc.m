function [q] = swInitialConc(mesh,type)
%
% function [q] = swInitialConc(mesh,type)
%
% Setup initial condition for Shallow Water equation
%
% type = 'circle' 'square'
%

if nargin == 1
  type = 'circle';
end

%--------------------------------
% Start Computation
%--------------------------------

%--------------------------------
% First get some info about the 
% mesh
%--------------------------------
minx = min(mesh.p(1,:));
maxx = max(mesh.p(1,:));
miny = min(mesh.p(2,:));
maxy = max(mesh.p(2,:));

if strcmp(mesh.geometry,'hmesh')
  error('For geometry hmesh, q should already be set')
end

switch lower(type)
   case 'circle',
      centres = [ (minx+maxx)/2 ; (miny+maxy)/2 ]; 
      centres = centres(:,ones(1,size(mesh.p,2)));
      radius2 = ((maxx-minx)/5).^2;
      pq = sum((mesh.p-centres).^2);
      pq = pq<radius2;
      scale = [1 10];
      q(1,:) = (scale(2)-scale(1))*...
	  (pq(mesh.t(1,:))+pq(mesh.t(2,:))+pq(mesh.t(3,:)))/3.0 + scale(1);
      q(2,:) = zeros(1,size(mesh.t,2));
      q(3,:) = q(2,:);
    case 'square',
      c = fvmCentroid(mesh);
      scale = [1 10];
      q(1,:) = scale(1) + ...
	  (scale(2)-scale(1))*...
	  (c(1,:)>-0.2 & c(1,:)<0.2 & c(2,:)>-0.2 & c(2,:)<0.2);
      q(2,:) = zeros(1,size(mesh.t,2));
      q(3,:) = q(2,:);
    otherwise,
      error('type not set correctly');
end


fvmSetPlotScale(scale);
