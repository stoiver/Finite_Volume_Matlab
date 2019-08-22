function [mesh,q] = planarMesh(parms)

g = parms.g;

%----------------------
% Use ifem to create
% initial node and elem
%----------------------
node = [-1 -1; 1 -1; 1 1; -1 1];
elem = [2 3 1; 4 1 3];

for i = 1:7 % Try different level here. 7 is good.
    [node,elem] = uniformbisect(node,elem);
end

%-----------------------
% Now create our fvmMesh
%-----------------------
mesh = fvmMesh(node,elem,'square');

%-------------------------
% Setup Initial conditions
%-------------------------
mesh.elevation = zeros(1,mesh.np);
mesh.friction  = zeros(1,mesh.np);

%-------------------------
% Setup initial quantity
%-------------------------
centroid = fvmCentroid(mesh);

left = centroid(1,:)< 0.0;
right = 1.0 - left;

h = left*0.5 + right*0.2;
u = zeros(size(h));
v = zeros(size(h));
e = 0.5*(h.*(u.^2 + v.^2) + g*h.^2);

nd = 4;
q  = zeros(nd,mesh.nt);
q(1,:) = h;
q(2,:) = h.*u;
q(3,:) = h.*v;
q(4,:) = e;


fvmSetPlotScale([0 2])
fvmSetPlotRange([0 2])
end
