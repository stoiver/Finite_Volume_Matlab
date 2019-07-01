function [Tq] = swRotate(q,normals)
%
% function [Tq] = swRotate(q,normals)
%
% Rotate the momentem components of q 
% from x,y coord to coord based on normals
%


Tq = zeros(size(q));

n1 = normals(1,:);
n2 = normals(2,:);

Tq(1,:) = q(1,:);

Tq(2,:) =  n1.*q(2,:) + n2.*q(3,:);
Tq(3,:) = -n2.*q(2,:) + n1.*q(3,:);
