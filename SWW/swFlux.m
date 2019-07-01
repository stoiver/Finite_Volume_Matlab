function [flux,smax] = swFlux(q,normals,parms)
%
% function [flux,smax] = swFlux(q,normals,parms)
%
% Calculate the flux across an edge with normal n, 
% using Shallow water flux
%

%----------------------------
% First Convert to normal and tangential
% directions
%----------------------------

Tq = swRotate(q,normals);

%-------------------------------
% Calculate normal and tangential 
% fluxes
%-------------------------------
[h,u,w] = swTransformHUW(Tq(1,:),Tq(2,:),Tq(3,:),parms);

f = zeros(size(q));

f(1,:) = h.*u;
f(2,:) = u.*u.*h + 0.5*parms.g*h.*h;
f(3,:) = u.*w.*h;

t1 = sqrt(parms.g*h);

smax = max(abs(u+t1),abs(u-t1));

%------------------------------
% Form x,y flux Components
%------------------------------
flux = swInvRotate(f,normals);




