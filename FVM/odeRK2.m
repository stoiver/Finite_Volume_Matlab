function [time,q] = odeRK2(tInterval,q,options,parms,f1,f2)

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
while time < tInterval(2),
  i = i+1;
  [flux0,smax0] = feval(parms.fluxFunct,time,q,flag,parms,f1);
  dx = f1.diameters;
  smax0 = smax0+1e-10;
  dtime = min(max(min(dx./smax0,DT),dtmin),tInterval(2)-time);
  dtime = min(dtime,[],2);
  
  q1 = q + dtime*flux0;
  [flux1,smax1] = feval(parms.fluxFunct,time,q1,flag,parms,f1);
  q2 = 0.5*q + 0.5*q1 + 0.5*dtime*flux1;

  %-----------------
  % Check for negative heights
  %-----------------
  while (min(q2(1,:))< 0) ,
    fprintf('\n REDUCING TIMESTEP min(h) = %12.5e \n',min(q1(1,:)));
    %find(qnew(1,:)<0)
    
    %keyboard

    dtime = dtime/2.0;
    q1 = q + dtime*flux0;
    [flux1,smax1] = feval(parms.fluxFunct,time,q1,flag,parms,f1);
    q2 = 0.5*q + 0.5*q1 + 0.5*dtime*flux1;    
  end
  
  q = q2;  
  time = time + dtime;
  %fprintf('%8.5e ',dtime)
  if i > ODE_MAXIT
    fprintf('\n')
    disp('Max no of sub time steps, Reset i to zero to continue')
    keyboard
  end
end

%for i=2:size(times,2)
%   time = times(i);
%   dtime = times(i)-times(i-1);
%   [flux,smax] = feval(fun,time,q,flag,f1,f2,f3);
%   q = q + dtime*flux;
%end      

smax = max(smax0,smax1);
fprintf('\n');
