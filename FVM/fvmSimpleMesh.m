function [mesh] = fvmSimpleMesh


mesh = fvmSetMeshStruct;

p = zeros(2,6);
t = zeros(3,4);

p(:,1) = [-1; 1];
p(:,2) = [0; 1];
p(:,3) = [1; 1];
p(:,4) = [0; 0];
p(:,5) = [1; 0];
p(:,6) = [1; -1];

t(:,1) = [1; 4; 2];
t(:,2) = [2; 4; 5];
t(:,3) = [2; 5; 3];
t(:,4) = [4; 6; 5];


mesh.p = p;
mesh.t = t;
mesh.e = [];
mesh.geometry = 'vsimplemesh';
mesh  = fvmDiameters(mesh);


mesh = fvmNeigh(mesh);

mesh.tneigh(2,1) = -1;
mesh.tneigh(3,1) = -2;

mesh.tneigh(1,3) = -4;

return
