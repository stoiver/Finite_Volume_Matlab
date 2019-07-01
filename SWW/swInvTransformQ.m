function [qc] = swInvTransformQ(qs,parms)
%
% function [qc] = swInvTransformQ(qs,parms)
%
% Transform between standard (qs = [h u v])
% and conserved variables (qc = [h uh vh]) for the 
% shallow water equations

sizeqs = size(qs);
extra = prod(sizeqs)/3;
qs = reshape(qs,[3 extra]);
nt = size(qs,2);

qc(1,:) = qs(1,:);
qc(2,:) = qs(1,:).*qs(2,:);
qc(3,:) = qs(1,:).*qs(3,:);

qc = reshape(qc,sizeqs);

return
