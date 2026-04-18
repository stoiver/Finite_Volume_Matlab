function fvmPlotTriSurf(mesh,q,parms,fig_no)
%
% fvmPlotTriSurf(mesh,q,parms,fig_no)
%
% Plot a triangular mesh with concentration given by
% q(dim,:), Default dim = 1
%

if nargin < 4
  fig_no = 1;
end

graphics_toolkit('gnuplot')

if nargin < 3
  parms = fvmSetParmsStruct;
  parms.plotdim = 1;
  parms.smooth = 1;
end

dim = parms.plotdim;

if ~isfield(parms, 'plotmesh')
  parms.plotmesh = 0;
end

xmin = min(mesh.p(1,:));
xmax = max(mesh.p(1,:));
ymin = min(mesh.p(2,:));
ymax = max(mesh.p(2,:));

%------------------------------------------
% Triangle centroid coordinates and values
%------------------------------------------
cx = (mesh.p(1,mesh.t(1,:)) + mesh.p(1,mesh.t(2,:)) + mesh.p(1,mesh.t(3,:))) / 3;
cy = (mesh.p(2,mesh.t(1,:)) + mesh.p(2,mesh.t(2,:)) + mesh.p(2,mesh.t(3,:))) / 3;
cq = q(dim,:);

%------------------------------------------
% Interpolate to regular grid for contourf
%------------------------------------------
npts = 200;
xi = linspace(xmin, xmax, npts);
yi = linspace(ymin, ymax, npts);
[XI, YI] = meshgrid(xi, yi);
ZI = griddata(cx, cy, cq, XI, YI);

figure(fig_no)
clf;
ZI(isnan(ZI)) = 0;
pcolor(XI, YI, ZI);
shading interp
fvmSetPlot;
if parms.plotmesh
  hold on
  ex = mesh.p(1, [mesh.t(1,:); mesh.t(2,:); mesh.t(3,:); mesh.t(1,:)]);
  ey = mesh.p(2, [mesh.t(1,:); mesh.t(2,:); mesh.t(3,:); mesh.t(1,:)]);
  plot(ex, ey, 'Color', [0.4 0.4 0.4], 'LineWidth', 0.3)
  hold off
end
view(2)
rotate3d off
axis([xmin xmax ymin ymax])
drawnow
