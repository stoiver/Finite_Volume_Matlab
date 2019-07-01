function centroid = fvmCentroid(mesh)

p = mesh.p;
t = mesh.t;

centroid = (p(:,t(1,:)) + p(:,t(2,:))+ p(:,t(3,:)))/3.0;

