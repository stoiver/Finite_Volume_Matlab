function [tdata] = fvmPdataToTdata(mesh,pdata)
%
% function [tdata] = fvmPdataToTdata(mesh,pdata)
%
% Calculate centroid values tdata, of pdata given at 
% the nodes of triangles.


%--------------------------------
% Start Computation
%--------------------------------

np = size(mesh.p,2);
%nt = size(mesh.t,2);

npdata = size(pdata,2);

if npdata ~= np
  error('data not compatible with number of nodes')
end

%-------------------
% Calculate centroid
% value
%-------------------

tdata = (pdata(mesh.t(1,:))+pdata(mesh.t(2,:))+pdata(mesh.t(3,:)))/3.0;
