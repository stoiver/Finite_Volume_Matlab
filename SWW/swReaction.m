function [dq] = swReaction(t,q,flag,parms,mesh)
%
% function [dq] = swReaction(t,q,flag,parms,mesh)
%

g = parms.g;

if ~nargin==5
  error('Not enough input arguments')
end

nt = size(mesh.t,2);
dq = zeros(3,nt);
 
%-------------------------------
% Do Slope using explicit method
%-------------------------------
if ~isempty(mesh.elevation) 
  mesh = fvmCalcGradElevation(mesh,'ifnecessary');
  % Return dy/dt = F(t,y).
  nt = size(mesh.t,2);
  S_0x = mesh.gradElevation(1,:);
  S_0y = mesh.gradElevation(2,:);

  dq(2,:) = g*q(1,:).*S_0x;
  dq(3,:) = g*q(1,:).*S_0y;
end
  
%-------------------------------
% Do the friction
%-------------------------------
if ~isempty(mesh.friction) 
  mesh = fvmCalcGradElevation(mesh,'ifnecessary');
  % Return dy/dt = F(t,y).
  nt = size(mesh.t,2);
  %if size(y,1)~=nt*3
  %  error('Input vector not compatible with mesh')
  %end
  %q = reshape(y,3,nt);
  S_0x = -mesh.gradElevation(1,:);
  S_0y = -mesh.gradElevation(2,:);
  S_fx = zeros(1,nt);
  S_fy = zeros(1,nt);
  %ii = find(q(1,:)>1e-5);
  %if ~isempty(ii)
  %  manning = ( mesh.friction(mesh.t(1,ii)) + ...
    %mesh.friction(mesh.t(2,ii)) +  mesh.friction(mesh.t(3,ii)) )/3.0;
   % normqh = sqrt(q(2,ii).^2+q(3,ii).^2);
   % S_fx(ii) = manning.^2 .* q(2,ii) .* normqh ./ q(1,ii).^(10/3);
   % S_fy(ii) = manning.^2 .* q(3,ii) .* normqh ./ q(1,ii).^(10/3);
 % end
  dq(2,:) = g*q(1,:).*(S_0x - S_fx);
  dq(3,:) = g*q(1,:).*(S_0y - S_fy);
  %out1 = out1(:);
end

%-------------------------------
% Do momentum sink
%-------------------------------
%if ~isempty(mesh.alphabeta)
%  nt = size(mesh.t,2);
%  S_bx = zeros(1,nt);
%  S_by = zeros(1,nt);
%  S_bx = mesh.alphabeta(1,:).*q(2,:);
%  S_by = mesh.alphabeta(2,:).*q(3,:);
%  dq(2,:) = - g*q(1,:).*S_bx;
%  dq(3,:) = - g*q(1,:).*S_by;
%end





