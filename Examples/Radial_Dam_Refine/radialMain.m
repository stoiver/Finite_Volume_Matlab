function [parms,meshT,qT] = radialMain(DT,finalT)
%
% Main function to setup evolution of
% initial data defined in radialMesh.m
%
%  function [parms,meshT,qT] = radialMain(DT,finalT)
%
% Setup the parms for the problem by editting this file.
%
% Returns cell arrays of mesh and q at each timestep. 
%

%-----------------------------
% Set Parameters if parms not
% provided
%-----------------------------
parms = fvmSetParmsStruct;

%-----------------------------
% Setting up the solution of
% shallow water equation
% Probably dont want to change these
%----------------------------
parms.edgeFlux = 'swEdgeFlux';
parms.boundaryConc = 'swBoundaryConc';
parms.riemann = 'swRiemannToro1';
parms.dirBCFunct = 'swExact';
parms.flux  = 'swFlux';
parms.fluxFunct = 'swFluxFunct1';
parms.simpleFluxFunct = 'swSimpleFlux1';

order = 2;
if order == 1
  parms.phiLimiter = 'swLimiter0';
  parms.phiInterpolator = 'fvmPWL0';
  parms.odetype = 'adaptOdeEuler1';
elseif order == 2
  parms.phiLimiter = 'swLimiter1';
  parms.phiInterpolator = 'fvmPWL1';
  parms.odetype = 'adaptOdeRK2';
else
  error('Order should equal 1 or 2')
end
parms.reactionFunct = 'swReaction';

parms.beta = 0.9;
parms.delta = 1e-5;

%-------------------------------------
% Paraters to change initial conditions
%-------------------------------------
parms.initialMesh = 'radial1';
parms.resolution = [50, 50];          % Resolution of grid using swInit* 
parms.lengths = [50, 50];             % Lengths of rectangular region using swInit*

%-------------------------------------
% Some global constants
%-------------------------------------
parms.g = 9.8;

%-------------------------------------
% Time evolution paramters
%-------------------------------------
parms.DT = DT;
parms.finalT = finalT;
parms.dtmin = 1e-7;

%-------------------------------------
% Graphics paramters
%-------------------------------------
parms.graphics = 1;
parms.smooth = 0;
parms.plotdim = 1;
fvmSetPlotRange([0 ; 2]);

%-------------------------------------
% Now do the actual computation
%-------------------------------------
[parms,meshT,qT] = adaptMain(parms);



return