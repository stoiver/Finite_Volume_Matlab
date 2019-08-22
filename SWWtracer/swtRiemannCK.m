function [f,smax] = swtRiemannCK(Tql,Tqr,parms)
%
% function [f,smax] = sweRiemannCK(Tql,Tqr,parms)
%
%
% Author SG Roberts 2019 (c)


global FVM_K

g = parms.g;
nd = parms.nd;

assert(nd == 4);

h_l  = Tql(1,:);
uh_l = Tql(2,:);
wh_l = Tql(3,:);
e_l  = Tql(4,:);

h_r  = Tqr(1,:);
uh_r = Tqr(2,:);
wh_r = Tqr(3,:);
e_r  = Tqr(4,:);

%-----------------------------
% Put into h,u,w variables
% Ensure that we don't have
% very small h values
%-----------------------------
[h_l,u_l,w_l,~] = swtTransformHUW(h_l,uh_l,wh_l,[], parms);
[h_r,u_r,w_r,~] = swtTransformHUW(h_r,uh_r,wh_r,[], parms);


% Compute speeds in x-direction.
soundspeed_l = sqrt(g*h_l);
soundspeed_r = sqrt(g*h_r);
s_max = max([u_l+soundspeed_l, u_r+soundspeed_r, 0.0]);
s_min = min([u_l-soundspeed_l, u_r-soundspeed_r, 0.0]);
      
% Flux formulas
flux_l_h  = h_l.*u_l;
flux_l_uh = h_l.*u_l.^2 + 0.5*g*h_l.^2;
flux_l_wh = u_l.*h_l.*w_l;

flux_r_h  = h_r.*u_r;
flux_r_uh = h_r.*u_r.^2 + 0.5*g*h_r.^2;
flux_r_wh = u_r.*h_r.*w_r;

entropy_flux_l  = (0.5*h_l.*(u_l.^2 + w_l.^2) + g*h_l.^2).*u_l;
entropy_flux_r  = (0.5*h_r.*(u_r.^2 + w_r.^2) + g*h_r.^2).*u_r;
        
% Flux computation
denom = s_max-s_min;
edgeflux_h = (s_max.*flux_l_h - s_min.*flux_r_h + s_max.*s_min.*(h_r-h_l))./ denom;
edgeflux_uh = (s_max.*flux_l_uh - s_min.*flux_r_uh + s_max.*s_min.*(flux_r_h-flux_l_h))./ denom;
edgeflux_wh = (s_max.*flux_l_wh - s_min.*flux_r_wh + s_max.*s_min.*(h_r.*w_r-h_l.*w_l))./ denom;
edgeflux_entropy = (s_max.*entropy_flux_l - s_min.*entropy_flux_r + s_max.*s_min.*(e_r-e_l))./denom;

smax = max(abs(s_max), abs(s_min));


f1 = edgeflux_h;
f2 = edgeflux_uh;
f3 = edgeflux_wh;
f4 = edgeflux_entropy;

f = [f1;f2;f3;f4];

end


  

