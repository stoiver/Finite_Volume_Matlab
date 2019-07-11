function [parms] = fvmSetParmsStruct

parms.beta = [];
parms.delta = [];

parms.edgeFlux = [];
parms.boundaryConc = [];
parms.riemann = [];
parms.dirBCFunct = [];
parms.fluxFunct = [];
parms.flux = [];
parms.simpleFluxFunct = [];
parms.phiLimiter = [];
parms.phiInterpolator = [];
parms.reactionFunct = [];
parms.frictionFunct = [];
parms.momentumSinkFunct = [];

parms.initialMesh = [];
parms.resolution = [];
parms.lengths = [];
parms.slope = [];
parms.reservoir.side = [];
parms.reservoir.breach = [];
parms.reservoir.height = [];
parms.manning = [];

parms.g = [];

parms.DT = [];
parms.dtmin = [];
parms.odetype = [];

parms.graphics = 1;
parms.plotelevation = 1;
parms.plotdim = 1;
parms.smooth = 1;


return
