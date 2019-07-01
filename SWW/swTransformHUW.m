function [h,u,w] = swTransformHUW(h,uh,wh,parms)
%
% function [h,u,w] = swTransformHUW(h,uh,wh,parms)
%
% Transform between conserved and standard variables for the 
% shallow water equations

nt = size(h,2);
epsilon = parms.delta;
%h = (h>epsilon).*h;

h0 = max(0.0, h);
hf = 2.0*h0./(h0.^2 + (max(epsilon, h0)).^2);

%jj = find(h>0);
%u = zeros(1,nt);
u = uh.*hf;
%w = zeros(1,nt);
w = wh.*hf;

return
