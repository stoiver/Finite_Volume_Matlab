function [indicator, tol_indicator]  = adaptIndicatorNEQ(q,mesh,parms,dtime,qnew)
%
% [indicator, tol_indicator]  = adaptIndicatorNEQ(q,mesh,parms,dtime,qnew)
%
% Calculate a refinement indicator based on numerical entropy

g = parms.g; 

h0  = q(1,:);
uh0 = q(2,:);
vh0 = q(3,:);

u0  = uh0./h0;
v0  = vh0./h0;
entropy_before = 0.5*h0.*(u0.^2+v0.^2) + 0.5*g*h0.^2;

h1  = qnew(1,:);
uh1 = qnew(2,:);
vh1 = qnew(3,:);

u1  = uh1./h1;
v1  = vh1./h1;
entropy_formula = 0.5*h1.*(u1.^2+v1.^2) + 0.5*g*h1.^2;


indicator = abs((1/dtime)*(entropy_formula-entropy_before));

tol_indicator = 0.1*max(abs(indicator));

end