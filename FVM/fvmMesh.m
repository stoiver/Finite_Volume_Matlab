function [mesh] = fvmMesh(node, elem, geometry)

mesh = fvmSetMeshStruct;

if nargin < 3
    geometry = 'unknown';
end

if nargin < 2
    error('Need at least two input arguments, node and elem')
end

%-----------------------------
% check size of node and elem
%-----------------------------
if size(elem,1) == 3
    mesh.t = elem;
elseif size(elem,2) == 3
    mesh.t = elem';
else
    error('elem array wrong size')
end

if size(node,1) == 2
    mesh.p = node;
elseif size(node,2) == 2
    mesh.p = node';
else
    error('node array wrong size')
end

mesh.nt = size(mesh.t,2);
mesh.np = size(mesh.p,2);

mesh.geometry  = geometry;

mesh = fvmNeigh(mesh,'ifnecessary');
mesh = fvmAreaTri(mesh,'ifnecessary');
mesh = fvmNormals(mesh,'ifnecessary');
mesh = fvmDiameters(mesh,'ifnecessary');

mesh.dxmin = min(mesh.diameters);
mesh.areamin = min(mesh.area);

end


