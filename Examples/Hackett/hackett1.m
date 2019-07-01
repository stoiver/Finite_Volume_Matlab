function [mesh,q] = hackett1(parms)
%
% function [mesh,q] = hackett1(parms)
% 
% Produce a mesh and concentation field
% associated with the hackett water supply
% reservoir with just one section releasing 
% water


%----------------------------
% Read in basic mesh
%----------------------------
[mesh, depth] = hackettMesh;

%----------------------------
% Water depth is the average 
% the depth at the nodes
%----------------------------
q = zeros(3,size(mesh.t,2));

q(1,:) = depth;

height = max(q(1,:),[],2);


fvmSetPlotScale([0 height])
fvmSetPlotRange([610 660])

%-------------------
% Set up transmissive boundaries
%-------------------
mesh = fvmNeigh(mesh);

for i = 1:3
  ii = find(mesh.tneigh(i,:)==0);
  if ~isempty(ii)
    mesh.tneigh(i,ii) = -1;
  end
end

%--------------------
% 
%--------------------

%iii = [496   500   501   502];
%jjj = [2134        2144        2048        2141];
%mesh.tneigh(:,iii)
%mesh.tneigh(:,jjj)

for i=1:3
  ii = find(mesh.tneigh(i,:)>0);
  %size(ii)
  if ~isempty(ii)  
    jj = find(depth(ii)~=depth(mesh.tneigh(i,ii)));
    if ~isempty(jj)
      ii = ii(jj);
      if i==1
       iii = ii(17:27);
       jjj = mesh.tneigh(1,iii);
      end
      %n = size(ii,2);
      %ii = ii(1:n);
      %size(ii)
      %i
      mesh.tneigh(i,ii) = 0;
    end
  end
end

mesh.tneigh(1,iii) = jjj;
depth(iii)
mesh.t(:,iii)
mesh.tneigh(1,jjj) = iii;
depth(jjj)
mesh.t(:,jjj)
mesh.tneigh(:,iii)
mesh.tneigh(:,jjj)
return
