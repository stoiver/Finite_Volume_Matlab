function swtCaseMovie(r,m,qT,scale)
%
% function swtCaseMovie(r,m,qT,scale)
%
% Plot the evolution defined by r,m,qT
% as created by fvm main program
%
% Can also set the vertical range of the plot
% using scale. Otherwise the scale is set to the min and
% max of the first component of the initial qT

maxinc = r.inc;

for inc = 1:maxinc
  q = qT{inc};
  time = (inc-1)*r.DT;
  intq = fvmIntQ(m,q);
  maxq = max(q,[],2);
  minq = min(q,[],2);
   
  fprintf('TIME %g \n',time)
  fprintf('  IntQ = %12.8e \n',intq)
  fprintf('  max value = %g \n',maxq)
  fprintf('  min value = %g \n',minq)

  if inc == 1
    if nargin < 4
      if minq(1)>=maxq(1)
	error('Initial scale range is zero, Manually set scale')
      end
      scale = [0, maxq(1)];
    end
    range(1) = min(m.elevation,[],2);
    range(2) = max(m.elevation,[],2)+scale(2);
    fvmSetPlotScale(scale);
    fvmSetPlotRange(range);
  end

  fvmPlotTriSurf(m,q);

end
