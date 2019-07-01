function [mesh,q] = radialMesh

mesh = fvmSetMeshStruct;

node = [-1 -1; 1 -1; 1 1; -1 1];
elem = [2 3 1; 4 1 3];


for i = 1:8% Try different level here. 7 is good.
    [node,elem] = uniformbisect(node,elem);
end

mesh.t = elem';
mesh.p = node';

centroid = fvmCentroid(mesh);
disk = (centroid(1,:).^2 + centroid(2,:).^2 ) < 0.25^2;



q  = zeros(3,size(mesh.t,2));
q(1,:) = (1-disk)*0.2 + disk*0.5;

mesh = fvmAreaTri(mesh);
mesh.tneigh = [];

mesh.elevation = zeros(1,size(mesh.p,2));
mesh.friction  = zeros(1,size(mesh.p,2));
mesh.geometry  = 'radial';
mesh = fvmDiameters(mesh);