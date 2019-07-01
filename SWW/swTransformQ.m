function [qs] = swTransformQ(qc,parms)
%
% function [qs] = swTransformHUW(qc,parms)
%
% Transform between conserved (qc = [h uh vh])
% and standard variables (qs = [h u v]) for the 
% shallow water equations

sizeqc = size(qc);
extra = prod(sizeqc)/3;
qc = reshape(qc,[3 extra]);
nt = size(qc,2);
epsilon = parms.delta;
qs(1,:) = (qc(1,:)>epsilon).*qc(1,:);

jj = find(qs(1,:)>0);
qs(2,:) = zeros(1,nt);
qs(2,jj) = qc(2,jj)./qs(1,jj);
qs(3,:) = zeros(1,nt);
qs(3,jj) = qc(3,jj)./qs(1,jj);

qs = reshape(qs,sizeqc);



return
