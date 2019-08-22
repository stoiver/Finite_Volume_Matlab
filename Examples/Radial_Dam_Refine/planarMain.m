function [parms,meshT,qT] = planarMain(DT,finalT)
%
% Main function to setup evolution of
% initial data defined in radialMesh.m
%
%  function [parms,meshT,qT] = planarMain(DT,finalT)
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
parms.edgeFlux = 'swtEdgeFlux';
parms.boundaryConc = 'swtBoundaryConc';
parms.riemann = 'swtRiemannCK';
parms.dirBCFunct = 'swtExact';
parms.flux  = 'swtFlux';
parms.fluxFunct = 'swtFluxFunct1';
parms.simpleFluxFunct = 'swtSimpleFlux1';

order = 2;
if order == 1
  parms.phiLimiter = 'swtLimiter0';
  parms.phiInterpolator = 'fvmPWL0';
  parms.odetype = 'adaptOdeEuler1';
elseif order == 2
  parms.phiLimiter = 'swtLimiter1';
  parms.phiInterpolator = 'fvmPWL1';
  parms.odetype = 'adaptOdeRK2';
else
  error('Order should equal 1 or 2')
end
parms.reactionFunct = 'swtReaction';

parms.beta = 0.5;
parms.delta = 1e-5;

parms.adapt = 1;
parms.coarsen_factor = 0.4;
parms.refine_factor = 1.0;
parms.refine_limit = 128;
parms.coarsen_limit = 1;
parms.max_indicator = 0.01;

%-------------------------------------
% Paraters to change initial conditions
%-------------------------------------
parms.initialMesh = 'planarMesh';
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