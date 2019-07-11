function [flux,smax] = swSimpleFlux(time,q,flag,parms,mesh)
%
%  [flux,smax,s] = swSimpleFlux(time,q,parms,mesh)
%
% Calculate the flux on the piecewise constant concentration q
% using van Leer type limiter method, passed by parms.phiInterpolator
% and parms.phiLimiter, and flux given by the H(q) at the midpoints
% with H given by swFlux


%---------------------------------------
% To save some time we can pass through
% some extra arrays.
% Otherwise calculate them now
%---------------------------------------
if nargin < 4
   error('Not enough input arguments');
end

%---------------------------------------
% Check mesh infomation
%---------------------------------------
if isempty(mesh.p) | isempty(mesh.t)
  error('Mesh information not passed correctly')
end

%---------------------------------------
% Computation start
%---------------------------------------
fvmPrint('Start of swSimpleFlux \n');
fprintf('.');

%---------------------------------------
% The concentration at the midpoints of the
% triangles qmid, is just q. 
%---------------------------------------
qmid = feval(parms.phiInterpolator,mesh,parms,q);
qmid = feval(parms.phiLimiter,mesh,parms,q,qmid);

%----------------------------------------
% Accumulate Flux through each edge
%----------------------------------------
[flux,smax] = fvmSimpleFlux(mesh,parms,q,qmid);

