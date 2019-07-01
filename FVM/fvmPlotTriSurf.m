function fvmPlotTriSurf(mesh,q,parms)
%
% fvmPlotTriSurf(mesh,q,parms)
%
% Plot a triangular mesh with concentration given by
% q(dim,:), Default dim = 1
%
if nargin < 3
  parms = fvmSetParmsStruct;
end

dim = parms.plotdim;

xmin = min(mesh.p(1,:),[],2);
xmax = max(mesh.p(1,:),[],2);

ymin = min(mesh.p(2,:),[],2);
ymax = max(mesh.p(2,:),[],2);

inter = 1;

if inter
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
  drawnow  
else
  parms.beta = 1;
  qmid = fvmPWL2(mesh,parms,q);
  [qmid, qv] = swLimiter2(mesh,parms,q,qmid);
  
  C = squeeze(qv(1,:,:));
  
  X = [mesh.p(1,mesh.t(1,:)) ; mesh.p(1,mesh.t(2,:)) ; mesh.p(1,mesh.t(3,:)) ];
  Y = [mesh.p(2,mesh.t(1,:)) ; mesh.p(2,mesh.t(2,:)) ; mesh.p(2,mesh.t(3,:)) ];
  Z = [mesh.elevation(mesh.t(1,:)) ; mesh.elevation(mesh.t(2,:)) ;...
    mesh.elevation(mesh.t(3,:)) ]+C;
  
  ii = 1; jj = 2;
  X1 = [ mesh.p(1,mesh.t(ii,:)) ; mesh.p(1,mesh.t(jj,:)) ;...
    mesh.p(1,mesh.t(ii,:))  ; mesh.p(1,mesh.t(jj,:)) ];
  Y1 = [ mesh.p(2,mesh.t(ii,:)) ; mesh.p(2,mesh.t(jj,:)) ;...
    mesh.p(2,mesh.t(ii,:))  ; mesh.p(2,mesh.t(jj,:)) ];
  Z1 = [ mesh.elevation(mesh.t(ii,:)) ; mesh.elevation(mesh.t(jj,:)) ;...
    mesh.elevation(mesh.t(ii,:))+C(ii,:) ; ...
    mesh.elevation(mesh.t(jj,:))+C(jj,:)];
  
  ii = 2; jj = 3;
  X2 = [ mesh.p(1,mesh.t(ii,:)) ; mesh.p(1,mesh.t(jj,:)) ;...
    mesh.p(1,mesh.t(ii,:))  ; mesh.p(1,mesh.t(jj,:)) ];
  Y2 = [ mesh.p(2,mesh.t(ii,:)) ; mesh.p(2,mesh.t(jj,:)) ;...
    mesh.p(2,mesh.t(ii,:))  ; mesh.p(2,mesh.t(jj,:)) ];
  Z2 = [ mesh.elevation(mesh.t(ii,:)) ; mesh.elevation(mesh.t(jj,:)) ;...
    mesh.elevation(mesh.t(ii,:))+C(ii,:) ; ...
    mesh.elevation(mesh.t(jj,:))+C(jj,:)];
  
  ii = 3; jj = 1;
  X3 = [ mesh.p(1,mesh.t(ii,:)) ; mesh.p(1,mesh.t(jj,:)) ;...
    mesh.p(1,mesh.t(ii,:))  ; mesh.p(1,mesh.t(jj,:)) ];
  Y3 = [ mesh.p(2,mesh.t(ii,:)) ; mesh.p(2,mesh.t(jj,:)) ;...
    mesh.p(2,mesh.t(ii,:))  ; mesh.p(2,mesh.t(jj,:)) ];
  Z3 = [ mesh.elevation(mesh.t(ii,:)) ; mesh.elevation(mesh.t(jj,:)) ;...
    mesh.elevation(mesh.t(ii,:))+C(ii,:) ; ...
    mesh.elevation(mesh.t(jj,:))+C(jj,:)];
  
  
  %shading faceted
  C1 = zeros(size(X1));
  C2 = zeros(size(C));
  patch(X,Y,Z,C2,'facecolor','flat','edgecolor','none');
  hold on
  %ii = find(max(C)>0);
  %if ~isempty(ii)
  %  C1 = C1(ii);
  %  X1 = X1(ii); Y1 = Y1(ii); Z1 = Z1(ii);
  %  X2 = X2(ii); Y2 = Y2(ii); Z2 = Z2(ii);
  %  X3 = X3(ii); Y3 = Y3(ii); Z3 = Z3(ii);
  %end
  %patch([X1 X2 X3],[Y1 Y2 Y3],[Z1 Z2 Z3],[C1 C1 C1]);
  hold off
  shading faceted

  light('Position',[0 -2 1])
  lighting none
  
  fvmSetPlot;
  range = fvmGetPlotRange;
  axis([xmin, xmax, ymin,ymax, range(1), range(2)]);
  drawnow
end




