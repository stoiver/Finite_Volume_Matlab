function fvmSaveView
%
% fvmSaveView
%
% Save the current view for later use in the fvmPlot
% commands

global FVM_VIEW

[FVM_VIEW(1) FVM_VIEW(2)] = view;

return
