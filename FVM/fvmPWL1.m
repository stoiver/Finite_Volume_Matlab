function [qmid, gradq] = fvmPWL1(mesh,eqn,q)
%
% function [qmid, gradq] = fvmPWL1(mesh,eqn,q)
%
% Calculate a piecewise linear approximation of q using 
% the value of q at the centroid given in the input
% arguments. The function will be ofthe form 
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
% Using method described in "Solution of 2d Shallow Water Equations"
% K. Anastasious & C. T. Chan, Int. J. Numer. Meth. Fluids, Vol 24: 
% 1225-1245 (1997)

%----------------------------------
% Calculation start
%----------------------------------
mesh = fvmNeigh(mesh,'ifnecessary');
mesh = fvmAreaTri(mesh,'ifnecessary');

%---------------------------------------
% Calculate gradient for only interior triangles
%---------------------------------------
gradq = zeros(2,size(q,1),size(q,2));
inside = find(mesh.tneigh(1,:)>0 & mesh.tneigh(2,:)>0 & mesh.tneigh(3,:)>0);

ngh1 = mesh.tneigh(1,inside);
ngh2 = mesh.tneigh(2,inside);
ngh3 = mesh.tneigh(3,inside);

c = fvmCentroid(mesh);

M = [ 0 1 ; -1 0];

c1 = c(:,ngh1);
c2 = c(:,ngh2);
c3 = c(:,ngh3);

n1 = M*(c3 - c2);
n2 = M*(c1 - c3);
n3 = M*(c2 - c1);

%----------------------------
% Calculate area of triangle 
% formed by the neighbouring 
% centroids
%----------------------------
x1 = c1(1,:);
y1 = c1(2,:);

x2 = c2(1,:);
y2 = c2(2,:);

x3 = c3(1,:);
y3 = c3(2,:);

area = 0.5* ( x1.*y2 + x2.*y3 + x3.*y1 - x1.*y3 - x2.*y1 - x3.*y2 );

%----------------------------
% Now find gradient
%----------------------------
nd = size(q,1);
for i=1:nd
  gradq(:,i,inside) =  ...
      0.5*(q([i;i],ngh1).*(n2+n3) + q([i;i],ngh2).*(n3+n1) + ...
      q([i;i],ngh3).*(n1+n2))./[area;area];
end

%----------------------------
% From average value and gradient
% calcualte the values of the
% PW Linear function at the 
% midpoints of the triangle
%-----------------------------
qmid = zeros(size(q,1),3,size(q,2));
for i=1:3
  qmid(:,i,:) = q;
end


cc =c(:,inside);
t1 = mesh.t(1,inside);
t2 = mesh.t(2,inside);
t3 = mesh.t(3,inside);

m1 = (mesh.p(:,t2)+mesh.p(:,t3))/2.0;
m2 = (mesh.p(:,t3)+mesh.p(:,t1))/2.0;
m3 = (mesh.p(:,t1)+mesh.p(:,t2))/2.0;

cm = zeros(2,3,size(m1,2));

cm(:,1,:) = m1 - cc;
cm(:,2,:) = m2 - cc;
cm(:,3,:) = m3 - cc;

for i = 1:3
  for j = 1:nd
    qmid(j,i,inside) = qmid(j,i,inside) + ...
	gradq(1,j,inside).*cm(1,i,:) + gradq(2,j,inside).*cm(2,i,:);
  end
end

