function [flux,smax,qmid] = swtFluxFunct1(time,q,flag,parms,mesh)
%
%  [flux,smax] = swtFluxFunct1(time,q,parms,mesh)
%
% Calculate the the flux on the piecewise constant concentration q
% using the flux function passed via the eqn argument (eqn.fluxFunct)
%
% The limiting is done on the [h u v] variables (instead of [h uh vh])


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
if isempty(mesh.p) || isempty(mesh.t)
  error('Mesh information not passed correctly')
end

%---------------------------------------
% Computation start
%---------------------------------------
fvmPrint('Start of swFluxFunct \n');
fprintf('.');

%---------------------------------------
% The concentration at the midpoints of the
% triangles qmid, is just q. 
% Do the interpolation on the standard
% variables
%---------------------------------------
qs = swtTransformQ(q,parms);
qmids = feval(parms.phiInterpolator,mesh,parms,qs);
qmids = feval(parms.phiLimiter,mesh,parms,qs,qmids);
qmid = swtInvTransformQ(qmids,parms);

%----------------------------------------
% Accumulate Flux through each edge
%----------------------------------------
[flux,smax] = fvmGodunovFlux(mesh,parms,q,qmid);



