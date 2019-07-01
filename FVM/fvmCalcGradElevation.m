function m = fvmCalcGradElevation(m,flag)
%
% mesh = fvmCalcGradElevation(mesh)
% 
% Given the elevation (stored in mesh.elevation)
% calculate the gradient assoicated with each 
% triangle and store in in mesh.gradElevation
%
% flag = 'recalc' 'calc' 'ifnecessary'
%
% if flag == 'recalc' or 'calc' then the calculation is done.
% if flag == 'ifnecessay' then if mesh.tneigh doesnt exist the 
%            the calculation is done
%

if nargin == 1
  flag = 'recalc';
end

if ~isfield(m,'elevation')
  error('Elevation field of mesh has not been set')
end

if strcmp(flag,'ifnecessary')
  if isfield(m,'gradElevation')
    return
  end
end

%--------------------------------
% Start Computation
%--------------------------------

v1 = m.p(:,m.t(2,:)) - m.p(:,m.t(1,:));
v2 = m.p(:,m.t(3,:)) - m.p(:,m.t(1,:));

dd = v1(1,:).*v2(2,:) - v1(2,:).*v2(1,:);

df1 = m.elevation(m.t(2,:)) - m.elevation(m.t(1,:));
df2 = m.elevation(m.t(3,:)) - m.elevation(m.t(1,:));

vfx  = df1.*v2(2,:) - df2.*v1(2,:);
vfy  = df2.*v1(1,:) - df1.*v2(1,:);

g = zeros(2,size(m.t,2));

g(1,:) = vfx./dd;
g(2,:) = vfy./dd;


m.gradElevation = g;

