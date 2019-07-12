function [flux,smax] = fvmGodunovFlux(mesh,parms,q,qmid)
%
% function [flux,smax] = fvmGodunovFlux(mesh,parms,q,qmid)
%
% Calculate the flux of a nonLinear Flux
% out of the triangles of the mesh
%


global FVM_K

%------------------------------
% For each triangle calculate the 
% flux across each edge and accumulate 
% into flux for triangle
% Weight each flux by the length qmid
% of the edge
%------------------------------
mesh = fvmNeigh(mesh,'ifnecessary');
mesh = fvmNormals(mesh,'ifnecessary');
flux = zeros(size(q));

nd = parms.nd;
nt = mesh.nt;

smax = zeros(1,nt);

for i = 1:3
  normals = squeeze(mesh.normals(:,i,:));
  ql = squeeze(qmid(:,i,:));
  
  %keyboard
  qr = zeros(size(ql));

  %-------------------------------
  % Find the triangles with neighbours
  % and then find the corresponding 
  % edge of the neighbour, given in 
  % kk. Then calculate memory locations
  % of the corresponding qmid values 
  % and assign to the appropriate qr vector
  %-------------------------------
  jj = find(mesh.tneigh(i,:)>0);
  nghs = mesh.tneigh(i,jj);
  nghnghs = mesh.tneigh(:,nghs);
  jjj = repmat(jj,3,1);
  [ii,~] = find(nghnghs == jjj);

  jn = (jj-1)*nd;
  jnn = 1+jn;
  for dd = 2:nd
    jnn = [jnn ; dd+jn];
  end
  jnn = jnn(:);

  in = (ii'-1)*nd + (nghs-1)*nd*3;
  inn = 1+in;
  for dd = 2:nd
    inn = [inn ; dd+in];
  end
  inn = inn(:);
  
  %keyboard
  
  qr(jnn) = qmid(inn);
  
  %-------------------------------
  % Calculate the concentrations
  % across boundaries
  %-------------------------------
  ii = find(mesh.tneigh(i,:)<=0);
  if ~isempty(ii)
    flags = mesh.tneigh(i,ii);
    qr(:,ii) = feval(parms.boundaryConc,ql(:,ii),normals(:,ii),flags);
  end

  %------------------------------
  % Now lets calculate fluxes across
  % edge, and accumulate into flux
  % vector for each triangle
  %------------------------------
  [edgeflux,sm] = feval(parms.edgeFlux,ql,qr,normals,parms);
  smax = max(smax,sm);
  
  ii = i*ones(1,nd);
  
  flux = flux - edgeflux.*mesh.edgelengths(ii,:);
end


if FVM_K > 0
  fprintf('sum of fluxes %12.5e %12.5e %12.5e \n',sum(flux,2))
end

%-------------------------------
% Normalise by area of triangles
%-------------------------------
mesh = fvmAreaTri(mesh,'ifnecessary');
for i = 1:nd
  flux(i,:) = flux(i,:)./mesh.area;
end
