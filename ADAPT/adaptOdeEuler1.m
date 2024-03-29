function [time,q,mesh] = adaptOdeEuler1(tInterval,q,options,parms,mesh,f2)
%
% [time,q,mesh] = AdaptOdeEuler1(tInterval,q,options,parms,mesh,f2)
%
% Update q using first order Euler method, with inner
% timestep controlled by the wave speeds as calculated by 
% the flux function parms.fluxFunct
%
% After each Euler update, determine triangles to be adapted. The adapted
% q and mesh are returned. 
%
% The arguements options, f2 are added to be consistent with the 
% matlab ode solvers. mesh is using the f1 slot of the standard 
% matlab ode solver.
%


global ODE_MAXIT

if size(tInterval,2)~=2
   error('tInterval should only contain initial and final times')
end

DT = parms.DT;
dtmin = parms.dtmin;

fprintf('\n');
%-------------------------------------
% Ensure times are consistent with dt
% and tInterval
%-------------------------------------
%times = tInterval(1):dt:tInterval(2);
%if times(end)-tInterval(2)<0.0
%   times = [times , tInterval(2)];
%end 

flag = [];

%--------------------------------------
% Evolve solution
%--------------------------------------
time = tInterval(1);
i = 0;
while time < tInterval(2)
  i = i+1;
  %---------------------------------
  % First do Advection
  %---------------------------------
  [flux,smax] = feval(parms.fluxFunct,time,q,flag,parms,mesh);
  dx = mesh.diameters;
  
  dtime = min(max(min(dx./smax,DT),dtmin),tInterval(2)-time);
  dtime = min(dtime,[],2);
  qnew = q + dtime*flux;
  
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
 
  %q = qnew;
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

fprintf('\n');
