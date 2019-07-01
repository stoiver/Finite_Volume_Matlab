function [mesh] = fvmNeigh(mesh,flag)
%
% mesh = fvmNeigh(mesh,flag)
%
% Utility function to find the triangle on the left of an edge.
% neigh is a sparse matrix so that the non zero entries correspond
% to an edge and the value of the associated entry is the triangle 
% to the left of the edge. It is assumed that all triangles are 
% stored counter clockwise
%
% Useful for some flux calculations
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
  if ~isempty(mesh.tneigh)
    return
  end
end

%--------------------------------
% Start Computation
%--------------------------------
nt = size(mesh.t,2);
np = size(mesh.p,2);

i = [ mesh.t(1,:) mesh.t(2,:) mesh.t(3,:) ];
j = [ mesh.t(2,:) mesh.t(3,:) mesh.t(1,:) ];


flag = 1:nt;
flag = [ flag flag flag];

neigh=sparse(i,j,flag);

%------------------------------
% Now this should be slow!
%------------------------------
tneigh = zeros(3,nt);

%for it=1:nt
%  tneigh(1,it) = neigh(t(3,it),t(2,it));
%  tneigh(2,it) = neigh(t(1,it),t(3,it));
%  tneigh(3,it) = neigh(t(2,it),t(1,it));
%end

tneigh(1,:) = neigh(mesh.t(3,:)+(mesh.t(2,:)-1)*np);
tneigh(2,:) = neigh(mesh.t(1,:)+(mesh.t(3,:)-1)*np);
tneigh(3,:) = neigh(mesh.t(2,:)+(mesh.t(1,:)-1)*np);



mesh.tneigh = tneigh;
