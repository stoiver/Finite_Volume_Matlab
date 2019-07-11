function [dqoverq] = swFriction(t,q,flag,parms,mesh)
%
% function [dqoverq] = swFriction(t,q,flag,parms,mesh)
%

g = parms.g;

if ~nargin==5
  error('Not enough input arguments')
end

nt = size(mesh.t,2);
dqoverq = zeros(3,nt);
  
%-------------------------------
% Do the friction
%-------------------------------
if ~isempty(mesh.friction) 
  S_fx = zeros(1,nt);
  S_fy = zeros(1,nt);
  ii = find(q(1,:)>1e-8);
  if ~isempty(ii)
    manning = ( mesh.friction(mesh.t(1,ii)) + mesh.friction(mesh.t(2,ii)) +  mesh.friction(mesh.t(3,ii)) )/3.0;
    normqh = sqrt(q(2,ii).^2+q(3,ii).^2);
    S_fx(ii) = manning.^2 .* normqh ./ q(1,ii).^(7/3);
    S_fy(ii) = manning.^2 .* normqh ./ q(1,ii).^(7/3);
  end
  dqoverq(2,:) = -g*S_fx;
  dqoverq(3,:) = -g*S_fy;
end







