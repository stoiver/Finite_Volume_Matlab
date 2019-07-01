function [mesh]=fvmRectMesh(parms)
%
% function [mesh]=fvmRectMesh(parms)
% 
% Setup a square grid with n1 by n2 grid
% points, with side lengths len1 by len2
% set in parms.res and parms.lengths

if isempty(parms.resolution)
  parms.resolution = [10,10];
end

if isempty(parms.lengths)
  parms.lengths = [50,50];
end

n1 = parms.resolution(1);
n2 = parms.resolution(2);
len1 = parms.lengths(1);
len2 = parms.lengths(2);

%------------------------
% Start Computation
%------------------------
mesh = fvmSetMeshStruct;

x = (0:1/n1:1)*len1;
y = (1:-1/n2:0)*len2;

[xx,yy] = meshgrid(x,y);

xx = xx(:);
yy = yy(:);
p = [ xx' ; yy'];


[nx ny] = meshgrid(0:n1,1:n2+1);

nn = ny + nx*(n2+1);

t1 = nn(2:end,1:end-1);
t2 = nn(2:end,2:end);
t3 = nn(1:end-1,2:end);

t = [ t1(:)' ; t2(:)' ; t3(:)'];

%t1 = nn(2:end,1:end-1);
t2 = nn(1:end-1,2:end);
t3 = nn(1:end-1,1:end-1);

tt = [ t1(:)' ; t2(:)' ; t3(:)'];
  
t = [ t , tt];


e = [];

mesh.p = p;
mesh.t = t;
mesh.e = e;
mesh.geometry = 'rectmesh';
mesh = fvmDiameters(mesh);



mesh.elevation = zeros(1,size(mesh.p,2));
mesh.friction = zeros(1,size(mesh.p,2));


