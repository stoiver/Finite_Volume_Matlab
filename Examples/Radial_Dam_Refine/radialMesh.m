function [mesh,q] = radialMesh

%----------------------
% Use ifem to create
% initial node and elem
%----------------------
node = [-1 -1; 1 -1; 1 1; -1 1];
elem = [2 3 1; 4 1 3];

for i = 1:5% Try different level here. 7 is good.
    [node,elem] = uniformbisect(node,elem);
end

%-----------------------
% Now create our fvmMesh
%-----------------------
mesh = fvmMesh(node,elem,'radial');

%-------------------------
% Setup Initial conditions
%-------------------------
mesh.elevation = zeros(1,mesh.np);
mesh.friction  = zeros(1,mesh.np);

centroid = fvmCentroid(mesh);
disk = (centroid(1,:).^2 + centroid(2,:).^2 ) < 0.25^2;

q  = zeros(3,mesh.nt);
q(1,:) = (1-disk)*0.2 + disk*0.5;

end
