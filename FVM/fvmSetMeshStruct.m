function [mesh] = fvmSetMeshStruct
%
% function [mesh] = fvmSetMeshStruct
%
% Set up the mesh structure so we don't have to use isfield
%

mesh.p = [];
mesh.t = [];
mesh.e = [];
mesh.elevation = [];
mesh.friction  = [];
mesh.alphabeta = [];

mesh.diameters = [];
mesh.normals = [];
mesh.geometry = [];
mesh.tneigh = [];
mesh.area = [];
