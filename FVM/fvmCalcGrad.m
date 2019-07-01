function [grad] = fvmCalcGrad(mesh,pd)

%--------------------------------------
% Start Calculation
%--------------------------------------

n = size(pd,1);
grad = zeros(n,2,size(mesh.t,2));

for i = 1:n
  dpd2 = pd(i,mesh.t(2,:))-pd(i,mesh.t(1,:));
  dpd3 = pd(i,mesh.t(3,:))-pd(i,mesh.t(1,:));
  
  dx2 = mesh.p(1,mesh.t(2,:)) - mesh.p(1,mesh.t(1,:));
  dx3 = mesh.p(1,mesh.t(3,:)) - mesh.p(1,mesh.t(1,:));
  
  dy2 = mesh.p(2,mesh.t(2,:)) - mesh.p(2,mesh.t(1,:));
  dy3 = mesh.p(2,mesh.t(3,:)) - mesh.p(2,mesh.t(1,:));
  
  detm = dx2.*dy3 - dx3.*dy2;
  
  grad(i,1,:) = (dy3.*dpd2 - dy2.*dpd3)./detm; 
  grad(i,2,:) = (dx2.*dpd3 - dx3.*dpd2)./detm;
end
