function fvmPlotMesh(mesh,fig_no)
%
% function fvmPlotMesh(mesh, fig_no)
%

if nargin < 2
  fig_no = 1;
end 


x = zeros(3,mesh.nt);
y = zeros(3,mesh.nt);
z = zeros(3,mesh.nt);
%c = qq;

for i=1:3 
  x(i,:) = mesh.p(1,mesh.t(i,:));
  y(i,:) = mesh.p(2,mesh.t(i,:));
end


figure(fig_no)
clf
%patch(x,y,c,'EdgeColor','none');
patch(x,y,z);


%fvmSetPlot;
view(2);

drawnow

