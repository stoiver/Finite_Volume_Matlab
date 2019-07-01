function [vn1,vn2] = fvmNormalVel(mesh,vel)

%  function [vn1,vn2] = fvmNormalVel(mesh,vel)
%
% Calculate Contribution due to velocities
% "through" sides of triangle
% Calculate edge length weighted normal
% velocities due to velocities at each 
% of edge.

if nargin ~= 2
  error('need 2 arguments')
end

%--------------------------------
% Start Computation
%--------------------------------

%M = [ 0 1 ; -1 0 ];
nt = size(mesh.t,2);

%n1 = M*(mesh.p(:,mesh.t(3,:)) - mesh.p(:,mesh.t(2,:)));
%n2 = M*(mesh.p(:,mesh.t(1,:)) - mesh.p(:,mesh.t(3,:)));
%n3 = M*(mesh.p(:,mesh.t(2,:)) - mesh.p(:,mesh.t(1,:)));

mesh = fvmNormals(mesh,'ifnecessary');

%---------------------------------
% Form edgelength scaled normal vectors
%----------------------------------
n1 = reshape(mesh.normals(:,1,:),2,nt).*mesh.edgelengths([1 1],:);
n2 = reshape(mesh.normals(:,2,:),2,nt).*mesh.edgelengths([1 1],:);
n3 = reshape(mesh.normals(:,3,:),2,nt).*mesh.edgelengths([1 1],:);

vn1 = zeros(3,nt);
vn2 = zeros(3,nt);

vn1(1,:) = sum(vel(:,mesh.t(3,:)).*n1(:,:));
vn1(2,:) = sum(vel(:,mesh.t(1,:)).*n2(:,:));
vn1(3,:) = sum(vel(:,mesh.t(2,:)).*n3(:,:));

vn2(1,:) = sum(vel(:,mesh.t(2,:)).*n1(:,:));
vn2(2,:) = sum(vel(:,mesh.t(3,:)).*n2(:,:));
vn2(3,:) = sum(vel(:,mesh.t(1,:)).*n3(:,:));

