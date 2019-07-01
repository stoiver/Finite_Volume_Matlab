function [h,u,w] = swTransformHUW(h,uh,wh,parms)
%
% function [h,u,w] = swTransformHUW(h,uh,wh,parms)
%
% Transform between conserved and standard variables for the 
% shallow water equations

nt = size(h,2);
epsilon = parms.delta;
h = (h>epsilon).*h;

jj = find(h>0);
u = zeros(1,nt);
u(jj) = uh(jj)./h(jj);
w = zeros(1,nt);
w(jj) = wh(jj)./h(jj);

return
