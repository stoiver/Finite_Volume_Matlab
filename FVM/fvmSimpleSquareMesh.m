function [mesh] = fvmSimpleSquareMesh


mesh = fvmSetMeshStruct;

p = zeros(2,4);
t = zeros(3,2);

p(:,1) = [0; 0];
p(:,2) = [1; 0];
p(:,3) = [1; 1];
p(:,4) = [0; 1];


t(:,1) = [1; 2; 3];
t(:,2) = [1; 3; 4];



mesh.p = p;
mesh.t = t;
mesh.e = [];
mesh.geometry = 'square';
mesh  = fvmDiameters(mesh);


mesh = fvmNeigh(mesh);

mesh.tneigh(2,1) = -1;
mesh.tneigh(3,1) = -2;

mesh.tneigh(1,3) = -4;

return
