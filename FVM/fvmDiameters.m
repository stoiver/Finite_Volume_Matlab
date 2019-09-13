function [mesh] = fvmDiameters(mesh,flag)
%
% mesh = fvmDiameters(mesh,flag)
%
% Utility function to find the diameters of the triangles
%
% flag = 'recalc' 'calc' 'ifnecessary'
%
% if flag == 'recalc' or 'calc' then the calculation is done.
% if flag == 'ifnecessay' then if mesh.tneigh doesnt exist the 
%            the calculation is done
%

if nargin ~= 1 & nargin ~= 2 
  error('Need 1 or 2 arguments')
end

if nargin == 1
  flag = 'recalc';
end

if strcmp(flag,'ifnecessary')
  if ~isempty(mesh.diameters)
    return
  end
end

%--------------------------------
% Start Computation
%--------------------------------
p = mesh.p;
t = mesh.t;

c = fvmCentroid(mesh);

m1 = (p(:,t(2,:))+p(:,t(3,:)))/2.0;
m2 = (p(:,t(3,:))+p(:,t(1,:)))/2.0;
m3 = (p(:,t(1,:))+p(:,t(2,:)))/2.0;

cm1 = c - m1;
cm2 = c - m2;
cm3 = c - m3;

d1 = sum(cm1.^2,1).^(0.5);
d2 = sum(cm2.^2,1).^(0.5);
d3 = sum(cm3.^2,1).^(0.5);

mesh.diameters = min(min(d1,d2),d3);
[~, nt] = size(t);
[~, np] = size(p);
mesh.np = np;
mesh.nt = nt;



