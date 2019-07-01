function [flux] = fvmAddUpwindFlux(flux,mesh,qmid,nv)
%
% function [flux] = fvmAddUpwindFlux(flux,mesh,qmid,nv)
%
% Add Contribution of flux due to normal 
% velocity and concentration at the 3 midpoints
% of the triangles. So q contains the concentration at
% the midpoints 1,2,3 and nv the edge length weighted 
% normal velocities at the midpoints


%----------------------------------
% Use concentration from the upwind
% direction of the flow.
% if outflow remove from triangle 
% and add to neighbour
%----------------------------------
mesh = fvmNeigh(mesh);
nf = size(flux,2);
n = size(flux,1);

for i = 1:n
  sflux = sparse(1,nf);
  for j=1:3
    jj = find(nv(j,:)>0);
    if ~isempty(jj)
      ii = ones(size(jj));
      aa = - nv(j,jj).*squeeze(qmid(i,j,jj))';
      sflux = sflux + sparse(ii,jj,aa,1,nf);
    end
    
    jj = find(nv(j,:)>0 & mesh.tneigh(j,:)>0);
    if ~isempty(jj)
      jjj = mesh.tneigh(j,jj);
      ii = ones(size(jj));
      aa = nv(j,jj).*squeeze(qmid(i,j,jj))';
      sflux = sflux + sparse(ii,jjj,aa,1,nf);
    end
    
  end
  flux(i,:) = flux(i,:) + full(sflux);
end



