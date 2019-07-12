function [flux,smax] = swtEdgeFlux0(ql,qr,normals,parms,solveops)
%
% function [flux] = swtEdgeFlux(ql,qr,normals,eqn,solveops)
%
% Calculate the flux across an edge with normal n, using Riemann solver
% passed by eqn.riemann for SW + tracer
%

%----------------------------
% First Convert to normal and tangential
% directions
%----------------------------

nd = parms.nd;
nt = size(ql,2);

h_l  = ql(1,:);
uh_l = ql(2,:);
vh_l = ql(3,:);

for j = 1:nd-4
  c_l{j}  = ql(j+3,:);
end

h_r  = qr(1,:);
uh_r = qr(2,:);
vh_r = qr(3,:);

for j = 1:nd-4
  c_r{j}  = qr(j+3,:);
end


%fprintf(' max(h_l) = %12.5e min(h_l) = %12.5e \n',max(h_l),min(h_l))
%fprintf(' max(uh_l) = %12.5e min(uh_l) = %12.5e \n',max(uh_l),min(uh_l))
%fprintf(' max(vh_l) = %12.5e min(vh_l) = %12.5e \n',max(vh_l),min(vh_l))

%fprintf(' max(h_r) = %12.5e min(h_r) = %12.5e \n',max(h_r),min(h_r))
%fprintf(' max(uh_r) = %12.5e min(uh_r) = %12.5e \n',max(uh_r),min(uh_r))
%fprintf(' max(vh_r) = %12.5e min(vh_r) = %12.5e \n',max(vh_r),min(vh_r))


%-----------------------------
% Clean concentrations so that
% we don't produce
% amazingly large velocities
%-----------------------------
epsilon = 1e-10;
h_l = (h_l>epsilon).*h_l;
h_r = (h_r>epsilon).*h_r;


jj = find(h_l>0);
u_l = zeros(1,nt);
u_l(jj) = uh_l(jj)./h_l(jj);
v_l = zeros(1,nt);
v_l(jj) = vh_l(jj)./h_l(jj);


jj = find(h_r>0);
u_r = zeros(1,nt);
u_r(jj) = uh_r(jj)./h_r(jj);
v_r = zeros(1,nt);
v_r(jj) = vh_r(jj)./h_r(jj);


%------------------------------
% Form normal and Tangential 
% Components
%------------------------------
n1 = normals(1,:);
n2 = normals(2,:);

un_l =  n1.*u_l + n2.*v_l;
ut_l = -n2.*u_l + n1.*v_l;

un_r =  n1.*u_r + n2.*v_r;
ut_r = -n2.*u_r + n1.*v_r;

%-------------------------------
% Calculate normal and tangential 
% fluxes
%-------------------------------
[f,smax] = feval(parms.riemann,h_l,un_l,ut_l,c_l, h_r,un_r,ut_r,c_r,solveops);

%------------------------------
% Form x,y Components
%------------------------------
flux = zeros(nd,nt);

flux(1,:) = f(1,:);
flux(2,:) = f(2,:).*n1 - f(3,:).*n2;
flux(3,:) = f(2,:).*n2 + f(3,:).*n1;

for j = 1:nd-4
  flux(j+3,:) = f(j+3,:);
end


