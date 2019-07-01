function [pdata] = fvmTdataToPdata(mesh,tdata,flag)
%
% function [pdata] = fvmTdataToPdata(mesh,tdata,flag)
%
% Calculate distance averaged data pdata, at nodes
% of triangles using given data tdata, at the centroid of 
% each triangle
% flag = 'lweight' or 'ones'

if nargin == 2 
  flag = 'lweight';
end

%--------------------------------
% Start Computation
%--------------------------------

np = size(mesh.p,2);
nt = size(mesh.t,2);
nd = size(tdata,1);
ntdata = size(tdata,2);

if ntdata ~= nt
  error('data not compatible with number of triangles')
end

%-------------------
% Calculate centroid
%-------------------
centroid = (mesh.p(:,mesh.t(1,:))+ mesh.p(:,mesh.t(2,:))+ ...
    mesh.p(:,mesh.t(3,:)))/3.0;

tdist = sparse(nd,np);
pdata = sparse(nd,np);

ii =  (1:nd)'; ii = ii(:,ones(1,nt)); ii = ii(:);
for i=1:3
  switch flag
     case 'lweight',
        dist = sqrt(sum((mesh.p(:,mesh.t(i,:))-centroid).^2));
     otherwise,
        dist = ones(nd,nt);
  end
  dist = dist(ones(nd,1),:);

  jj = mesh.t(i,:); jj = jj(ones(nd,1),:); jj = jj(:);  
  ddata =  dist.*tdata; ddata = ddata(:);
  dd = dist(:);
  
  pdata = pdata + sparse(ii,jj,ddata,nd,np);
  tdist = tdist + sparse(ii,jj,dd,nd,np);

%  pdata(:,t(i,:)) = pdata(:,t(i,:)) + dist.*tdata;
%  tdist(:,t(i,:)) = tdist(:,t(i,:)) + dist;

end

pdata = full(pdata./tdist);
