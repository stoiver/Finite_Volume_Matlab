function fvmSetPlotScale(scale)

global gscale

if nargin<1
  gscale = [0 11];
else
  gscale = scale;
end


