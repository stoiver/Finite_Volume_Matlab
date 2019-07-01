function [mesh,q1] = cspMesh

mesh = fvmSetMeshStruct;

fem

mesh


q1 = zeros(3,size(mesh.t,2));
q1 = q{1};

size(q1);

%
% Get the orientation right
%

mesh.t([1;2],:) = mesh.t([2;1],:);

mesh = fvmAreaTri(mesh);
mesh.tneigh = [];

%find(mesh.area<0)

%keyboard
mesh.elevation = zeros(1,size(mesh.p,2));
mesh.friction = mesh.elevation;
mesh.geometry = 'csp';
mesh = fvmDiameters(mesh);


