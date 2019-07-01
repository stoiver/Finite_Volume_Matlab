function fvmPlotTri(mesh,q,flag,view)
%
% function fvmPlotTri(mesh,flag,view)
%
% Plots the mesh with the triangle and point numbers

if nargin<1
  error('No mesh specified')
end

p = mesh.p;
t = mesh.t;
nt = size(t,2);
np = size(p,2);

if nargin<2
  q = zeros(1,nt);
end

if nargin<3
  flag = 'notext';
end

if nargin<4
  xmin = min(mesh.p(1,:));
  xmax = max(mesh.p(1,:));
  ymin = min(mesh.p(2,:));
  ymax = max(mesh.p(2,:));
  view = [xmin xmax ymin ymax];
end

pq = fvmTdataToPdata(mesh,q);

xmin = view(1);
xmax = view(2);
ymin = view(3);
ymax = view(4);

clf;
hold on;
%axis off;

size(mesh.p(1,:))
size(pq)
axis(view)
if strcmp(flag,'notext')
  trimesh(mesh.t',mesh.p(1,:),mesh.p(2,:),pq)
  drawnow
end

if strcmp(flag,'text')
  
  trimesh(mesh.t',mesh.p(1,:),mesh.p(2,:),zeros(1,np))
  
  centroid = (p(:,t(1,:))+ p(:,t(2,:))+ p(:,t(3,:)))/3.0;
  

  for it=1:nt
    if (  centroid(1,it)>xmin & centroid(1,it)<xmax & ...
	  centroid(2,it)>ymin & centroid(2,it)<ymax)
      text(centroid(1,it),centroid(2,it), ...
	  strcat(num2str(it),'   ',num2str(q(it))));
    end
  end
  for ip=1:np    
    if (  p(1,ip)>xmin & p(1,ip)<xmax & ...
	  p(2,ip)>ymin & p(2,ip)<ymax)
      text(p(1,ip),p(2,ip),num2str(ip));
    end
  end
end

drawnow
hold off
