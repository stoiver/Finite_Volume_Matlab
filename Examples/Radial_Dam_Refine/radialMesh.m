function [mesh,q] = radialMesh

%----------------------
% Use ifem to create
% initial node and elem
%----------------------
node = [-1 -1; 1 -1; 1 1; -1 1];
elem = [2 3 1; 4 1 3];

for i = 1:7 % Try different level here. 7 is good.
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

nd = 3;
q  = zeros(nd,mesh.nt);
q(1,:) = (1-disk)*0.2 + disk*0.5;

if nd > 3
  for j = 4:nd
    q(j,:) = (j-3)*(centroid(j-3,:)<0.25).*q(1,:);
  end
end

end
