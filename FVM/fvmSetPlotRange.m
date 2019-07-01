function fvmSetPlotScale(range)

global FVM_GRANGE

if nargin<1
  error('range not supplied')
else
  FVM_GRANGE = range;
end
