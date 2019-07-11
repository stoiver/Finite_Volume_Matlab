function [dqoverq] = swMomentumSink(t,q,flag,parms,mesh)
%
% function [dqoverq] = swMomentumSink(t,q,flag,parms,mesh)
%

g = parms.g;

if ~nargin==5
  error('Not enough input arguments')
end

nt = size(mesh.t,2);
dqoverq = zeros(3,nt);
  
%-------------------------------
% Do momentum sink
%-------------------------------
if ~isempty(mesh.alphabeta)
  nt = size(mesh.t,2);
  S_bx = zeros(1,nt);
  S_by = zeros(1,nt);
  S_bx = mesh.alphabeta(1,:);
  S_by = mesh.alphabeta(2,:);
  dqoverq(2,:) = - g*q(1,:).*S_bx;
  dqoverq(3,:) = - g*q(1,:).*S_by;
end





