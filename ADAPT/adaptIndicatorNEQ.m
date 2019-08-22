function [indicator,tol_indicator,qnew]  = adaptIndicatorNEQ(q,mesh,parms,dtime,qnew)
%
% [indicator,tol_indicator,qnew]  = adaptIndicatorNEQ(q,mesh,parms,dtime,qnew)
%
% Calculate a refinement indicator based on numerical entropy

g = parms.g; 


h1  = qnew(1,:);
uh1 = qnew(2,:);
vh1 = qnew(3,:);

u1  = uh1./h1;
v1  = vh1./h1;

entropy_evolved = qnew(4,:);
entropy_formula = 0.5*h1.*(u1.^2+v1.^2) + 0.5*g*h1.^2;

%ch1 = qnew(4,:);


indicator  = max(abs((1/dtime)*(entropy_formula-entropy_evolved)...
    ./sqrt(sqrt(mesh.diameters))), mesh.diameters);
%indicator_ch = abs((1/dtime)*(ch0-ch1));

%indicator = max(indicator_e, indicator_ch);

max_indicator = max(abs(indicator))

tol_indicator = parms.max_indicator*parms.refine_factor;

% Set entropy to calculated
qnew(4,:) = entropy_formula;


end