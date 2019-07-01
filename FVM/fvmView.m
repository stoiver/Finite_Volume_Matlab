function fvmView
%
% fvmView
%
% Choose a view, save by using rotate3d, then
% save using fvmSaveView
%
% This function sets up this view or reverts to default
%

global FVM_VIEW

if ~isempty(FVM_VIEW)
  view([ FVM_VIEW(1) FVM_VIEW(2)])
else
  view(3)
end

