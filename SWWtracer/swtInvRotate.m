function [q] = swInvRotate(Tq,normals)
%
% function [q] = swInvRotate(Tq,normals)
%
% Rotate the momentem components of Tq 
% from coords based on normals to x,y coords
%


q = zeros(size(Tq));

n1 = normals(1,:);
n2 = normals(2,:);

q(1,:) = Tq(1,:);

q(2,:) =  n1.*Tq(2,:) - n2.*Tq(3,:);
q(3,:) =  n2.*Tq(2,:) + n1.*Tq(3,:);
