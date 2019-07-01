function [flux] = linearFlux(mesh,eqn,fops,q,qmid)

%---------------------------------------
% Check equation information
%---------------------------------------
if ~isfield(eqn,'vel')
  error('velocity should be passed via equation argument')
end

if ~isfield(eqn,'vn1') | ~isfield(eqn,'vn2')
   [eqn.vn1, eqn.vn2] = linearNormalVel(mesh,eqn.vel);
end

%----------------------------------------
% Start Computation
%----------------------------------------
fvmPrint('Start of linearFlux \n')


flux = zeros(size(q));
  
flux = linearAddFlux(flux,mesh,qmid,eqn.vn1/2.0);
flux = linearAddFlux(flux,mesh,qmid,eqn.vn2/2.0);


mesh = fvmAreaTri(mesh,'ifnecessary');
n = size(q,1);
for i = 1:n
  flux(i,:) = flux(i,:)./mesh.area;
end