function [mesh] = fvmAreaTri(mesh,flag)
%
% function [mesh] = fvmAreaTri(mesh,flag)
%
% Calculates the area of each triangle and stores it in the
% field area
%
%
% if flag == 'recalc' or 'calc' then the calculation is done.
% if flag == 'ifnecessay' then if mesh.area doesnt exist the 
%            the calculation is done
%

if nargin ~= 1 & nargin ~= 2 
  error('Need 1 or 2 arguments')
end

if nargin == 1
  flag = 'recalc';
end

if strcmp(flag,'ifnecessary')
  if ~isempty(mesh.area)
    return
  end
end

%--------------------------------
% Start Computation
%--------------------------------

x1 = mesh.p(1,mesh.t(1,:));
y1 = mesh.p(2,mesh.t(1,:));

x2 = mesh.p(1,mesh.t(2,:));
y2 = mesh.p(2,mesh.t(2,:));

x3 = mesh.p(1,mesh.t(3,:));
y3 = mesh.p(2,mesh.t(3,:));

mesh.area = 0.5* ( x1.*y2 + x2.*y3 + x3.*y1 - x1.*y3 - x2.*y1 - x3.*y2 );

