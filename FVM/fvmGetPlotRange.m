function [range] = fvmGetPlotRange

global FVM_GRANGE

if exist('FVM_GRANGE')
  range = FVM_GRANGE;
  if isempty(FVM_GRANGE)
    warning('Plot Range is empty: Set using fvmSetPlotRange')
  end
else
  error('Plot Range has not been set: Set using fvmSetPlotRange')
end

