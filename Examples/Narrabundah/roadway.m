

[parms, mesh, qT] = narrabundahMain(0.1, 20);

mesh = fvmCentroid(mesh);

centroid = mesh.centroid;

% Location [300  ; -120] found using plot

[val, ind] = min(sum((centroid - [300; -120]).^2))

qq = zeros(3,201);

for i=1:201
    qq(:,i) = qT{i}(:,ind);
end

plot(parms.time, sqrt(qq(2,:).^2 + qq(3,:).^2)./(qq(1,:)+0.00001))
title('speed')

plot(parms.time, qq(1,:))
title('depth')


