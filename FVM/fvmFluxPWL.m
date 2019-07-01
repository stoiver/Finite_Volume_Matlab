function [flux] = fvmFluxPWL(time,q,flag,mesh,eqn,fops)
%
%  [flux] = fvmFluxPWL(time,q,flag,mesh,equation,fluxops)
%
% Calculate the flux by first calculating a Limited Piece Wise Linear
% reconstruct of the concentration and calculate the calcuate the flux
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
fprintf('.');

%---------------------------------------
% Calculate 2nd order approximation to
% q and then limit
%---------------------------------------
qmid = fvmPWL2(mesh,eqn,q);
qmid = fvmLimiter(mesh,fops,q,qmid);

%----------------------------------------
% Accumulate Flux through each edge
%----------------------------------------
flux = feval(eqn.fluxFunct,mesh,eqn,fops,q,qmid);

