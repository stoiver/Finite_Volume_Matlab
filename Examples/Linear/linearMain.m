function [results,mesh,q] = linearMain(n,dt,odetype,fluxops)
% Main fvm driver program
%  function [results,mesh,q] = linearMain(n,dt,odetype)
%
% odetype = {'upwind'} | 'pwl' | 'initial'
%
% Main program for testing Linear System equation.
%

global FVM_PARAMETERS
FVM_PARAMETERS(1) = 1;

if nargin < 3
  odetype = 'pwl';
end

if nargin < 1 | isempty(n)
  n = 2;
end

if nargin < 4
  fluxops.beta = 1.0;
end

%----------------------------------------
% Computation start
%----------------------------------------

%--------------------------------------------
% Setup an initial triangulation to play with
% for testing finite volume method
%--------------------------------------------

%mesh = fvmInitMesh('circleg');
%mesh = fvmInitMesh('squareg');
mesh = fvmPoiMesh(n);

%for i=1:n
%  mesh = fvmRefineMesh(mesh);
%end
 
%-----------------------------------------
% setup Initial concentration (3 dimensional)
%-----------------------------------------

q = linearInitialConc(mesh,'default3');

%-------------------------------------------
% Start evolution
%-------------------------------------------

nt = size(mesh.t,2)
np = size(mesh.p,2)

if nargin < 2
   dt = 1/sqrt(np);
end 

%-------------------------------------------
% Setup some equation and geometry calculations
%-------------------------------------------
disp('vel calculation'); 
  tvel = fvmInitialVel(mesh,'11');
  eqn.vel = fvmTdataToPdata(mesh,tvel);
  eqn.fluxFunct = 'linearFlux';
  eqn.dirBCFunct = 'linearExact';
  [eqn.vn1, eqn.vn2] = linearNormalVel(mesh,eqn.vel);

%disp('neigh calculation'); 
%  mesh = fvmNeigh(mesh);
%disp('area  calculation'); 
%  mesh = fvmAreaTri(mesh);

%---------------------------------------
% evolve Solution
%---------------------------------------
odeops.dt = dt;
DT = 0.1;
finalT = 0.7;


intq = fvmIntQ(mesh,q);
maxq = max(q,[],2)
minq = min(q,[],2)

rmin = minq;
rmax = maxq;
rint = intq;
rtime = 0.0;

fprintf('TIME %g \n',0.0)
fprintf('  IntQ = %12.8e \n',intq)
fprintf('  max value = %g \n',maxq)
fprintf('  min value = %g \n',minq)

fvmPlotEvolution(mesh,q);

if strcmp(odetype,'initial')
   return
end


for time = DT:DT:finalT
   switch odetype
   case 'pwl'
      [tout,q] = odeEuler1('fvmFluxPWL',[time-DT,time],...
         q,odeops,mesh,eqn,fluxops);
   case 'upwind',
      [tout,q] = odeEuler1('fvmFlux',[time-DT,time],...
         q,odeops,mesh,eqn,fluxops);
   otherwise ,
      error('odetype not specified');
   end
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
   
   fvmPlotEvolution(mesh,q);
   
end

results.n = n;
results.dt = dt;
results.odetype = odetype;
results.DT = DT;
results.finalT = finalT;
results.maxq = rmax;
results.minq = rmin;
results.int = rint;
results.time = rtime;
results.beta = fluxops.beta;
results.nt = nt;
results.np = np;