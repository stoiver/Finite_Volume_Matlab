
function [parms,mesh,qT] = fvmMain(parms,mesh,qT)
%
% Main fvm driver program for Godunov type methods 
%
%  function [parms,mesh,qT] = fvmMain(parms,mesh,qT)
%
%
%


global FVM_PARAMETERS
global FVM_K
global ODE_MAXIT

ODE_MAXIT = 1000;
FVM_PARAMETERS(1)= 1;
FVM_K = 0;


if nargin < 1
  error('Need at least the parms structure set');
end

if nargin == 2
  error('Need 1 or 3 arguments')
end

%----------------------------------------
% Computation start
%----------------------------------------

%--------------------------------------------
% Setup an initial triangulation if necessary
%--------------------------------------------
if nargin == 1
  [mesh,q] = fvmLoadMesh(parms);
end

%-------------------------------------------
% Start evolution
%-------------------------------------------
nt = mesh.nt;
np = mesh.np;

%parms.dx = min(mesh.diameters);

if nargin == 1
  inc = 1;
  qT{inc} = q;
  startT = 0.0;
  rtime = 0.0;
else
  inc = parms.inc;
  startT = parms.time(inc);
  rtime = parms.time;
end

DT = parms.DT;
finalT = parms.finalT;
q = qT{inc};

intq = fvmIntQ(mesh,q);
maxq = max(q,[],2);
minq = min(q,[],2);

rmin = minq;
rmax = maxq;
rint = intq;



fprintf('TIME %g \n',startT)
fprintf('  IntQ = %12.8e \n',intq)
fprintf('  max value = %g \n',maxq)
fprintf('  min value = %g \n',minq)

if parms.graphics
  fvmPlotTriSurf(mesh,q,parms);
  drawnow
  %pause
end

options = [];

%size(q)
%size(DT)
%parms.odetype
%parms.fluxFunct
%finalT
%DT
%mesh
%mesh.tneigh

%---------------------------------------
% evolve Solution
%---------------------------------------

for time = startT+DT:DT:finalT
  [tout,q] = feval(parms.odetype,[time-DT,time],...
      q,options,parms,mesh);

   intq = fvmIntQ(mesh,q);
   maxq = max(q,[],2);
   minq = min(q,[],2);
   rmin = [rmin minq];
   rmax = [rmax maxq];
   rint = [rint intq];
   rtime =[rtime time];
   
   fprintf('TIME %g \n',time)
   fprintf('  IntQ = %12.8e \n',intq)
   fprintf('  max value = %g \n',maxq)
   fprintf('  min value = %g \n',minq)
   
   if parms.graphics
     fvmPlotTriSurf(mesh,q,parms);
   end
   inc = inc + 1;
   qT{inc} = q;
   if FVM_K > 0
     keyboard
   end
   
end


parms.maxq = rmax;
parms.minq = rmin;
parms.int = rint;
parms.time = rtime;
parms.nt = nt;
parms.np = np;
parms.inc = inc;



