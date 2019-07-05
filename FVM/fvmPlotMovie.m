function fvmPlotMovie(parms,mT,qT,scale,range)
%
% function fvmPlotMovie(parms,mT,qT,scale,range)
%
% Plot the evolution defined by r,mT,qT
% as created by fvm main program
%
% Can also set the vertical range of the plot
% using scale. Otherwise the scale is set to the min and
% max of the first component of the initial qT

if ~iscell(qT)
    error('qT should be a cell array with time evolution of q')
end

if ~iscell(mT)
    m = mT;
end
    

maxinc = parms.inc;

for inc = 1:maxinc
  q = qT{inc};
  if iscell(mT)
      m = mT{inc}
  end
  
  time = (inc-1)*parms.DT;
  intq = fvmIntQ(m,q);
  maxq = max(q,[],2);
  minq = min(q,[],2);
  m.nt = size(m.t,2);
  m.np = size(m.p,2);
   
  fprintf('TIME %g \n',time)
  fprintf('  nt = %g \n',m.nt)
  fprintf('  np = %g \n',m.np)
  fprintf('  IntQ = %12.8e \n',intq)
  fprintf('  max value = %g \n',maxq)
  fprintf('  min value = %g \n',minq)

  if inc == 1
    if nargin < 4
      if minq(1)>=maxq(1)
         error('Initial scale range is zero, Manually set scale')
      end
      scale = [minq(1), maxq(1)];
    end
    fvmSetPlotScale(scale);
    if nargin < 5
       range(1) = min(m.elevation,[],2);
       range(2) = max(m.elevation,[],2)+scale(2);
    end
    fvmSetPlotRange(range);
  end

  fvmPlotTriSurf(m,q,parms);
  drawnow;

end
