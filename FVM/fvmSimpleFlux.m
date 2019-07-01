function [flux,smax] = fvmSimpleFlux(mesh,parms,q,qmid)
%
% function [flux,smax] = fvmSimpleFlux(mesh,parms,q,qmid)
%
% Calculate the flux of a nonLinear Flux
% out of the triangles of the mesh
%

global FVM_K;

%------------------------------
% For each triangle calculate the 
% flux across each edge and accumulate 
% into flux for triangle
% Weight each flux by the length 
% of the edge
%------------------------------
mesh = fvmNeigh(mesh,'ifnecessary');
mesh = fvmNormals(mesh,'ifnecessary');

flux = zeros(size(q));
nd = size(q,1);

smax = zeros(1,size(q,2));

for i = 1:3
  normals = squeeze(mesh.normals(:,i,:));
  ql = squeeze(qmid(:,i,:));

  %------------------------------
  % Now lets calculate fluxes across
  % edge, and accumulate into flux
  % vector for each triangle
  %------------------------------
  [edgeflux,sm] = feval(parms.flux,ql,normals,parms);
  smax = max(smax,sm);
  
  ii = i*ones(1,size(ql,1));
  flux = flux - edgeflux.*mesh.edgelengths(ii,:);
end


if FVM_K > 0
  fprintf('sum of fluxes %12.5e %12.5e %12.5e \n',sum(flux,2))
end

%-------------------------------
% Normalise by area of triangles
%-------------------------------
mesh = fvmAreaTri(mesh,'ifnecessary');
for i = 1:3
  flux(i,:) = flux(i,:)./mesh.area;
end
