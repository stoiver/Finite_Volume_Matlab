function [flux,smax] = swEdgeFlux(ql,qr,normals,parms)
%
% function [flux] = swEdgeFlux(ql,qr,normals,parms)
%
% Calculate the flux across an edge with normal n, using Riemann solver
% passed by eqn.riemann
%

%----------------------------
% First Convert to normal and tangential
% directions
%----------------------------

Tql = swRotate(ql,normals);
Tqr = swRotate(qr,normals);

%-------------------------------
% Calculate normal and tangential 
% fluxes
%-------------------------------
[f,smax] = feval(parms.riemann,Tql,Tqr,parms);

%------------------------------
% Form x,y flux Components
%------------------------------
flux = swInvRotate(f,normals);




