function [parms,mesh,qT] = narrabundahMain(DT,finalT)
%
% Main function to setup evolution of
% shallow water equations
%
%  function [parms,mesh,q] = narrabundahMain(DT,finalT)
%
%  Setup the parms for the problem by editting this file.
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
parms.fluxFunct = 'swFluxFunct1';
parms.flux  = 'swFlux';
parms.phiLimiter = 'swLimiter1';
parms.phiInterpolator = 'fvmPWL0';
parms.reactionFunct = 'swReaction';

parms.beta = 0.0;
parms.delta = 1e-5;

%-------------------------------------
% Paraters to change initial conditions
%-------------------------------------
parms.initialMesh = 'narrabundah0';
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
parms.dtmin = 1e-16;
parms.odetype = 'odeEuler1';

parms.graphics = 1;
parms.smooth = 1;
parms.printing = 0;


%-------------------------------------
% Now do the actual computation
%-------------------------------------
[parms,mesh,qT] = fvmMain(parms);



return

