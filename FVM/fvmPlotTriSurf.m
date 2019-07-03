function fvmPlotTriSurf(mesh,q,parms)
%
% fvmPlotTriSurf(mesh,q,parms)
%
% Plot a triangular mesh with concentration given by
% q(dim,:), Default dim = 1
%
if nargin < 3
  parms = fvmSetParmsStruct;
  parms.plotdim = 1;
  parms.beta = 1;
  parms.smooth = 1;
  parms.phiInterpolator = 'fvmPWL1';
  parms.phiLimiter = 'fvmLimiter';
  
end

dim = parms.plotdim;
beta = parms.beta;
smooth = parms.smooth;

xmin = min(mesh.p(1,:),[],2);
xmax = max(mesh.p(1,:),[],2);

ymin = min(mesh.p(2,:),[],2);
ymax = max(mesh.p(2,:),[],2);


if smooth == 1
  pq = fvmTdataToPdata(mesh,q(dim,:));
  if parms.plotelevation
     pqe = pq+mesh.elevation;
  else
     pqe = pq;
  end

  trisurf(mesh.t',mesh.p(1,:),mesh.p(2,:),pqe,pq,'EdgeColor','none')
  shading interp

  light('Position',[0 -2 1])
  lighting phong
  fvmSetPlot;
  range = fvmGetPlotRange;
  axis([xmin, xmax, ymin,ymax, range(1), range(2)]);
  pbaspect([1 1 1]);
  drawnow
    
else
  qmid       = feval(parms.phiInterpolator, mesh,parms,q);
  [qmid, qv] = feval(parms.phiLimiter, mesh,parms,q,qmid);
  
  C = squeeze(qv(1,:,:));
  
  X = [mesh.p(1,mesh.t(1,:)) ; mesh.p(1,mesh.t(2,:)) ; mesh.p(1,mesh.t(3,:)) ];
  Y = [mesh.p(2,mesh.t(1,:)) ; mesh.p(2,mesh.t(2,:)) ; mesh.p(2,mesh.t(3,:)) ];
  Z = [mesh.elevation(mesh.t(1,:)) ; mesh.elevation(mesh.t(2,:)) ;...
    mesh.elevation(mesh.t(3,:)) ]+C;
  
  clf;
  patch(X,Y,Z,C,'FaceColor','interp','EdgeColor','none');

  light('Position',[0 -2 1])
  lighting none
  
  fvmSetPlot;
  range = fvmGetPlotRange;
  axis([xmin, xmax, ymin,ymax, range(1), range(2)]);
  pbaspect([1 1 1]);
  drawnow
end




