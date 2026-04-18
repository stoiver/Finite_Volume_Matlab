function fvmSetPlotScale(range)

global gscale

if nargin<1
  error('range not supplied')
else
  gscale = range;
end
