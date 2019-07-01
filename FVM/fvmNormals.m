function [mesh] = fvmNormals(mesh,flag)

%  function [mesh] = fvmNormals(mesh,flag)
%
% Calculate the normals to the triangles
% Stored in mesh.normals
%
% if flag == 'recalc' or 'calc' then the calculation is done.
% if flag == 'ifnecessay' then if mesh.normals doesnt exist the 
%            the calculation is done
%

if nargin ~= 1 & nargin ~= 2 
  error('Need 1 or 2 arguments')
end

if nargin == 1
  flag = 'recalc';
end

if strcmp(flag,'ifnecessary')
  if ~isempty(mesh.normals)&~isempty(mesh.edgelengths)
    return
  end
end


%--------------------------------
% Start Computation
%--------------------------------

M = [ 0 1 ; -1 0 ];
nt = size(mesh.t,2);

n = zeros(2,3,nt);
el = zeros(3,nt);

n(:,1,:) = M*(mesh.p(:,mesh.t(3,:)) - mesh.p(:,mesh.t(2,:)));
n(:,2,:) = M*(mesh.p(:,mesh.t(1,:)) - mesh.p(:,mesh.t(3,:)));
n(:,3,:) = M*(mesh.p(:,mesh.t(2,:)) - mesh.p(:,mesh.t(1,:)));

for i = 1:3
  el(i,:) = sqrt(n(1,i,:).^2 + n(2,i,:).^2);
end

for i = 1:3
  n(:,i,:) = reshape(n(:,i,:),2,nt)./el([i;i],:);
end

mesh.normals = n;
mesh.edgelengths = el;


