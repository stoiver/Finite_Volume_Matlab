function fvmPlotMesh(mesh,q,scale)
%
% function fvmPlotMesh(mesh,q,scale)
%

if nargin == 1
  q = zeros(1, size(mesh.t,2));
end


qq = q(1,:);

if nargin < 3
  scale = fvmGetPlotScale;
end

x = zeros(3,size(mesh.t,2));
y = zeros(3,size(mesh.t,2));
c = qq;

for i=1:3 
  x(i,:) = mesh.p(1,mesh.t(i,:));
  y(i,:) = mesh.p(2,mesh.t(i,:));
end



clf
%patch(x,y,c,'EdgeColor','none');
patch(x,y,c);


fvmSetPlot;

drawnow

