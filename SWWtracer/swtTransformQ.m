function [qs] = swtTransformQ(qc,parms)
%
% function [qs] = swtTransformQ(qc,parms)
%
% Transform between conserved (qc = [h uh vh hc ..])
% and standard variables (qs = [h u v c ..]) for the 
% shallow water equations


epsilon = parms.delta;

qs = zeros(size(qc));

h = qc(1,:);
h = max(0.0, h);

hf = 2.0*h./(h.^2 + (max(epsilon, h)).^2);

qs(1,:) = h;
qs(2:end,:) = qc(2:end,:).*hf;


return
