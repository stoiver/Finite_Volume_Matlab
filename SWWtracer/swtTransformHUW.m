function [h,u,w,c] = swtTransformHUW(h,uh,wh,ch,parms)
%
% function [h,u,w,c] = swTransformHUW(h,uh,wh,ch,parms)
%
% Transform between conserved and standard variables for the 
% shallow water equations

ntrace = size(ch,1);
c = [];

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

if ntrace>0
    c = ch.*hf;
end

return
