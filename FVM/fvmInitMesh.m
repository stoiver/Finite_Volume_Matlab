function [mesh] = fvmInitMesh(geometry)

[mesh.p, mesh.e, mesh.t] = initmesh(geometry);

mesh.geometry = geometry;

return
