function [time,q] = odeHarten2(tInterval,q,options,parms,f1,f2)

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
  %---------------------------------
  % First do Advection
  %---------------------------------
  [flux,smax] = feval(parms.simpleFluxFunct,time,q,flag,parms,f1);
  dx = f1.diameters;
  smax = smax+1e-10;
  dtime = min(max(min(dx./smax,DT),dtmin),tInterval(2)-time);
  dtime = min(dtime,[],2);
  q1 = q + 0.5*dtime*flux;
  
  [flux,smax] = feval(parms.fluxFunct,time,q1,flag,parms,f1);
  qnew = q + dtime*flux;

  %-----------------
  % Check for negative heights
  %-----------------
  while (min(qnew(1,:))< 0)
    fprintf('\n REDUCING TIMESTEP min(h) = %12.5e \n',min(qnew(1,:)));
    %find(qnew(1,:)<0)
    
    %keyboard

    dtime = dtime/2.0;
    [flux,smax] = feval(parms.simpleFluxFunct,time,q,flag,parms,f1);
    q1 = q + 0.5*dtime*flux;
  
    [flux,smax] = feval(parms.fluxFunct,time,q1,flag,parms,f1);
    qnew = q + dtime*flux;
  end
  
  q = qnew; 
  
  %---------------------------------
  % Now do slope and friction. Should 
  % make this second order using fraction
  % steps, or combining with the advection step
  %---------------------------------
  dq = feval(parms.reactionFunct,time,q,flag,parms,f1);
  q = q + dtime*dq; 
    
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

%for i=2:size(times,2)
%   time = times(i);
%   dtime = times(i)-times(i-1);
%   [flux,smax] = feval(fun,time,q,flag,f1);
%   q = q + dtime*flux;
%end      

fprintf('\n');
