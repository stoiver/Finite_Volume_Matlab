function [mesh] = fvmSetMeshStruct
%
% function [mesh] = fvmSetMeshStruct
%
% Set up the mesh structure so we don't have to use isfield
%

mesh.p = [];
mesh.t = [];
%mesh.e = [];

mesh.diameters = [];
mesh.normals = [];
mesh.tneigh = [];
mesh.area = [];

mesh.geometry = [];
mesh.areamin = [];
mesh.dxmin = [];

mesh.elevation_c = [];
mesh.friction_c = [];

% Do we need this?
mesh.alphabeta = [];

end
