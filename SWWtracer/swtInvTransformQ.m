function [qc] = swtInvTransformQ(qs,parms)
%
% function [qc] = swtInvTransformQ(qs,parms)
%
% Transform between standard (qs = [h u v c ...])
% and conserved variables (qc = [h uh vh hc ...]) for the 
% shallow water equations and auxilary quantities


qc = qs;
h =  max(0.0, qs(1,:));
qc(2:end,:) = h.*qs(2:end,:);

return
