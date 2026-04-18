%
% exportHackettMesh.m
%
% Export the Hackett mesh data to CSV files for use with ANUGA.
%
% Run from the Examples/Hackett directory with FVM/ on the path.
%
% Produces:
%   hackett_nodes.csv     -- x, y, elevation, friction, initial_depth
%   hackett_triangles.csv -- triangle connectivity (0-indexed for Python)
%

[mesh, depth] = hackettMesh();

np = mesh.np;
nt = mesh.nt;

%----------------------------
% Build per-node initial depth
% depth is per-triangle; back-project to nodes by averaging
%----------------------------
node_depth = zeros(1, np);
node_count = zeros(1, np);
for i = 1:3
    node_depth(mesh.t(i,:)) = node_depth(mesh.t(i,:)) + depth;
    node_count(mesh.t(i,:)) = node_count(mesh.t(i,:)) + 1;
end
node_count(node_count == 0) = 1;
node_depth = node_depth ./ node_count;

%----------------------------
% Write nodes: x, y, elevation, friction, initial_depth
%----------------------------
nodes = [mesh.p(1,:)', mesh.p(2,:)', mesh.elevation', mesh.friction', node_depth'];
dlmwrite('hackett_nodes.csv', nodes, 'delimiter', ',', 'precision', 10);
fprintf('Wrote %d nodes to hackett_nodes.csv\n', np);

%----------------------------
% Write triangles: 0-indexed connectivity
%----------------------------
dlmwrite('hackett_triangles.csv', mesh.t'-1, 'delimiter', ',');
fprintf('Wrote %d triangles to hackett_triangles.csv\n', nt);
