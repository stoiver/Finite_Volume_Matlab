function [flux,smax] = fvmFlux(time,q,flag,mesh,eqn,solveops)
%
%  [flux,smax] = fvmFlux(time,q,flag,mesh,equation,solveops)
%
% Calculate the the flux on the piecewise constant concentration q
% using the flux function passed via the eqn argument (eqn.fluxFunct)


%---------------------------------------
% To save some time we can pass through
% some extra arrays.
% Otherwise calculate them now
%---------------------------------------
if nargin < 6
   error('Not enough input arguments');
end

%---------------------------------------
% Check mesh infomation
%---------------------------------------
if ~isfield(mesh,'p') | ~isfield(mesh,'e') | ~isfield(mesh,'t')
  error('Mesh information not passed correctly')
end

%---------------------------------------
% Computation start
%---------------------------------------
fvmPrint('Start of fvmFlux \n');
fprintf('.');

%---------------------------------------
% The concentration at the midpoints of the
% triangles qmid, is just q. 
%---------------------------------------
qmid = fvmPWL1(mesh,eqn,q);
qmid = fvmLimiter(mesh,solveops,q,qmid);

%----------------------------------------
% Accumulate Flux through each edge
%----------------------------------------
[flux,smax] = fvmGodunovFlux(mesh,eqn,solveops,q,qmid);

