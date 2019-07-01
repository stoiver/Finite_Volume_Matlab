function fvmPlotSurf(mesh,q,dim,x,y)

if nargin < 3
  dim = 1;
end

if nargin < 4
  xmin = min(mesh.p(1,:),[],2);
  xmax = max(mesh.p(1,:),[],2);
  
  x = xmin:(xmax-xmin)/40:xmax;
end

if nargin < 5
  ymin = min(mesh.p(2,:),[],2);
  ymax = max(mesh.p(2,:),[],2);
  y = ymin:(ymax-ymin)/40:ymax;
end

pq = fvmTdataToPdata(mesh,q(dim,:)); 
uxy = fvmMesh2Grid(mesh.p,mesh.t,pq',x,y);
[xx,yy] = meshgrid(x,y);


%clf;
surf(xx,yy,uxy)

fvmSetPlot;

scale = fvmGetPlotScale;
axis([xmin, xmax, ymin,ymax, scale(1), scale(2)]);


pause(1)
