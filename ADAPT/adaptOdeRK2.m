function [time,q,mesh] = adaptOdeRK2(tInterval,q,options,parms,mesh,f2)
%
% [time,q,mesh] = adaptOdeRK2(tInterval,q,options,parms,mesh,f2)
%
% Update q using first order Euler method, with inner
% timestep controlled by the wave speeds as calculated by 
% the flux function parms.fluxFunct
%
% options, f2 are added to be consistent with the matlab ode solvers. 
% mesh is using the f1 slot of the standard matlab ode solvers
%

global ODE_MAXIT

if size(tInterval,2)~=2
   error('tInterval should only contain initial and final times')
end

DT = parms.DT;
dtmin = parms.dtmin;

fprintf('\n');

flag = [];

%--------------------------------------
% Evolve solution
%--------------------------------------
time = tInterval(1);
i = 0;
while time < tInterval(2)
  i = i+1;
  [flux0,smax0] = feval(parms.fluxFunct,time,q,flag,parms,mesh);
  dx = mesh.diameters;
  smax0 = smax0+1e-10;
  dtime = min(max(min(dx./smax0,DT),dtmin),tInterval(2)-time);
  dtime = min(dtime,[],2);
  
  q1 = q + dtime*flux0;
  [flux1,smax1] = feval(parms.fluxFunct,time,q1,flag,parms,mesh);
  qnew = 0.5*q + 0.5*q1 + 0.5*dtime*flux1;
  
  %-----------------
  % Fix negative heights
  %-----------------
  ipos = qnew(1,:) >= 0;
  qnew = qnew.*ipos;
  
  %--------------------------------
  % Based on advection update 
  % refine/coarsen mesh
  %--------------------------------
  [indicator, tol_indicator] = adaptIndicatorNEQ(q,mesh,parms,dtime,qnew);
  [q, mesh]  = adaptRefineCoarsen(qnew,mesh,parms, indicator, tol_indicator);
 
  %---------------------------------
  % Now do slope using explicit method
  %---------------------------------
  if ~isempty(parms.reactionFunct)
    dq = feval(parms.reactionFunct,time,q,flag,parms,mesh);
    q = q + dtime*dq;
  end
  
  %---------------------------------
  % Now do friction calculation
  % Use a pseudo backward Euler for stability
  %---------------------------------  
  if ~isempty(parms.frictionFunct)
    dqoverq = feval(parms.frictionFunct,time,q,flag,parms,mesh);
    q = q./(1-dtime*dqoverq);
  end
    
  %---------------------------------
  % Now do momentum sink calculation
  % Use backward Euler for stability
  %---------------------------------
  if ~isempty(parms.momentumSinkFunct)
    dqoverq = feval(parms.momentumSinkFunct,time,q,flag,parms,mesh);
    q = q./(1-dtime*dqoverq);
  end
  
  %--------------------------------
  % Now some bookkeepping
  %--------------------------------
  time = time + dtime;
  %fprintf('%8.5e ',dtime)
  
  if i > ODE_MAXIT
    fprintf('\n')
    disp('Max no of sub time steps, Reset i to continue')
    keyboard
  end
end
      

%smax = max(smax0,smax1);
fprintf('\n');
