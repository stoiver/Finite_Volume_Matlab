function [flux,smax] = swFluxFunct(time,q,flag,parms,mesh)
%
%  [flux,smax,s] = swFluxFunct(time,q,parms,mesh)
%
% Calculate the the flux on the piecewise constant concentration q
% using the flux function passed via the eqn argument (eqn.fluxFunct)


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
fvmPrint('Start of swFluxFunct \n');
fprintf('.');

%---------------------------------------
% The concentration at the midpoints of the
% triangles qmid, is just q. 
%---------------------------------------
qmid = feval(parms.phiInterpolator,mesh,parms,q);
%size(qmid)
%fprintf('\nq(1,:) %20.15e %20.15e \n',min(q(1,:)),max(q(1,:)))
%fprintf('q(2,:) %20.15e %20.15e \n',min(q(2,:)),max(q(2,:)))
%fprintf('q(3,:) %20.15e %20.15e \n',min(q(3,:)),max(q(3,:)))
%fprintf('qm(1,:) %20.15e %20.15e \n',min(min(qmid(1,:,:))),max(max(qmid(1,:,:)%)))
%fprintf('qm(2,:) %20.15e %20.15e \n',min(min(qmid(2,:,:))),max(max(qmid(2,:,:)%)))
%fprintf('qm(3,:) %20.15e %20.15e \n',min(min(qmid(3,:,:))),max(max(qmid(3,:,:)%)))



%size(q)
%qmid = feval(parms.phiLimiter,mesh,parms,q,qmid);

%----------------------------------------
% Accumulate Flux through each edge
%----------------------------------------
[flux,smax] = fvmGodunovFlux(mesh,parms,q,qmid);

%fprintf('f(1,:) %20.15e %20.15e \n',min(flux(1,:)),max(flux(1,:)))
%fprintf('f(2,:) %20.15e %20.15e \n',min(flux(2,:)),max(flux(2,:)))
%fprintf('f(3,:) %20.15e %20.15e \n',min(flux(3,:)),max(flux(3,:)))
%fprintf('s(3,:) %20.15e %20.15e \n',min(smax),max(smax))
