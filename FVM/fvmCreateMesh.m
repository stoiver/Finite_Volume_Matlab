function [mesh] = fvmCreateMesh(node, elem, geometry)

if nargin < 3
    geometry = 'unknown';
end

if nargin < 2
    error('Need at least two input arguments, node and elem')
end

mesh.t = elem';
mesh.p = node';
mesh.nt = size(mesh.t,2);
mesh.np = size(mesh.p,2);

mesh.geometry  = geometry;

mesh = fvmNeigh(mesh,'ifnecessary');
mesh = fvmAreaTri(mesh,'ifnecessary');
mesh = fvmNormals(mesh,'ifnecessary');
mesh = fvmDiameters(mesh,'ifnecessary');

mesh.dx = min(mesh.diameters);

end


