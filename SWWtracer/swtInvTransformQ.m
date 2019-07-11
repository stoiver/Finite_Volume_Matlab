function [qc] = swInvTransformQ(qs,parms)
%
% function [qc] = swInvTransformQ(qs,parms)
%
% Transform between standard (qs = [h u v c ...])
% and conserved variables (qc = [h uh vh c ...]) for the 
% shallow water equations and auxilary quantities

nd = parms.nd; 

sizeqs = size(qs);
extra = prod(sizeqs)/nd;
qs = reshape(qs,[nd extra]);

qc = qs;

qc(2,:) = qs(1,:).*qs(2,:);
qc(3,:) = qs(1,:).*qs(3,:);


qc = reshape(qc,sizeqs);

return
