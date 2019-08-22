function [am] = fvmIntQ(mesh,q)
%
% function [am] = fvmIntQ(mesh,q)
%

if nargin ~= 2
  error('Need 2 arguments')
end


%--------------------------------
% Start Computation
%--------------------------------
mesh = fvmAreaTri(mesh);

n = size(q,1);
am = zeros(n,1);

for i = 1:n
  am(i) = sum(q(i,:).*mesh.area);
end
