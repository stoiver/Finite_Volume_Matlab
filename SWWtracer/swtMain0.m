function [parms,mesh,qT] = swtMain0(parms,mesh,qT)
%
%

global FVM_PARAMETERS
global FVM_K
global ODE_MAXIT

ODE_MAXIT = 300;

FVM_PARAMETERS(1)= 1;
FVM_K = 0;

%----------------------------------------
% Computation start
%----------------------------------------

nt = size(mesh.t,2)
np = size(mesh.p,2)

%---------------------------------------
% evolve Solution
%---------------------------------------
mesh = fvmNeigh(mesh);
mesh = fvmAreaTri(mesh);
mesh = fvmNormals(mesh);

DT    = parms.dt;
initT = parms.time(end);
finalT = initT+5.0;

q = qT{parms.inc};
parms.nd = size(q,2);

intq = fvmIntQ(mesh,q);
maxq = max(q,[],2)
minq = min(q,[],2)

rmin = minq;
rmax = maxq;
rint = intq;
rtime = initT;

fprintf('TIME %g \n',initT)
fprintf('  IntQ = %12.8e \n',intq)
fprintf('  max value = %g \n',maxq)
fprintf('  min value = %g \n',minq)

scale(1) = 0.0;
scale(2) = maxq(1);
fvmSetPlotScale(scale);

%fvmPlotMesh(mesh,q,scale);
%fvmPlotTriSurf(mesh,q);
inc = parms.inc;

for time = DT:DT:finalT
  [tout,q] = feval(parms.type,parms.fluxFunct,[time-DT,time],...
      q,parms,mesh);

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
   
   %fvmPlotMesh(mesh,q,scale);
   fvmPlotTriSurf(mesh,q);
   inc = inc + 1;
   qT{inc} = q;
   if FVM_K > 0
     keyboard
   end
   
end

parms.finalT = finalT;
parms.maxq = rmax;
parms.minq = rmin;
parms.int = rint;
parms.time = rtime;
parms.nt = nt;
parms.np = np;
parms.inc = inc;

