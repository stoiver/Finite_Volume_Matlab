function [qmid, gradq] = fvmPWL2(mesh,parms,q)
%
% function [qmid, gradq] = fvmPWL2(mesh,parms,q)
%
% Calculate a piecewise linear approximation of q using 
% the value of q at the centroid given in the input
% arguments. The function will be of the form 
% 
%  q(x,y) = q_A + gradq_A . r
%
% where r is the position vector from the centroid of 
% triangle A
%
% The returned qmid(i,j,k) is the value of the i-th component of PWL
% function on the j-th edge of the k-th triangle
%
% gradq(i,j,k) is the j-th gradient of the i-th component of the PWL
% function on the k-th triangle 
%
% Using method of averaging centroid values to nodes and using that  
% for gradient calculation


%----------------------------------
% Calculation start
%----------------------------------

%-------------------
% Calculate gradient by averaging cell
% concentration to nodes
%-------------------
pq = fvmTdataToPdata(mesh,q);
pq = fvmSetBoundary(mesh,parms,pq);

n = size(q,1);
nt = size(q,2);

qmid = zeros(n,3,size(mesh.t,2));

for i = 1:n
  tq = reshape(pq(i,mesh.t(1:3,:)),3,nt);
  aq = q(i,:)-sum(tq)/3.0;
  tq = tq+aq([1 1 1],:);

  qmid(i,1,:) = (tq(2,:)+tq(3,:))/2.0;
  qmid(i,2,:) = (tq(3,:)+tq(1,:))/2.0;
  qmid(i,3,:) = (tq(1,:)+tq(2,:))/2.0;
end

if nargout>1
   gradq = fvmCalcGrad(mesh,pq);
end









