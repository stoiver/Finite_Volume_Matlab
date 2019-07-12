function [f,smax] = sweRiemannToro1(Tql,Tqr,parms)
%
% function [f,smax] = sweRiemannToro1(Tql,Tqr,parms)
%
% Approximate Riemann Solver for 2-d Shallow Water 
% equations with tracer using first order scheme 
% by Fraccarollo and Toro,
% J. Hydr. Research, 33(6), 1995, 843-864.
% Dry bed case
%
% Author SG Roberts 2001 (c)


global FVM_K

g = parms.g;
nd = parms.nd;


hl  = Tql(1,:);
uhl = Tql(2,:);
whl = Tql(3,:);

if nd > 3
    chl = Tql(4:nd,:);
else
    chl = [];
end

hr  = Tqr(1,:);
uhr = Tqr(2,:);
whr = Tqr(3,:);

if nd > 3
    chr = Tqr(4:nd,:);
else
    chr = [];
end


%-----------------------------
% Put into h,u,w, c variables
% Ensure that we don't have
% very small h values
%-----------------------------

[hl,ul,wl,cl] = swtTransformHUW(hl,uhl,whl,chl, parms);
[hr,ur,wr,cr] = swtTransformHUW(hr,uhr,whr,chr, parms);

%-----------------------------
% Calculate Shock Speeds
%-----------------------------
ustar=(ul+ur)/2.0 + sqrt(g*hl)-sqrt(g*hr);
phistar=(sqrt(g*hl) + sqrt(g*hr))/2.0 + (ul-ur)/4.0;


ww = find(hl > 0 & hr > 0 );
dw = find(hl == 0);
wd = find(hr == 0);

%------------------------
% Water everywhere
%------------------------
sl(ww)=min(ul(ww)-sqrt(g*hl(ww)),ustar(ww)-phistar(ww));
sm(ww)=ustar(ww);
sr(ww)=max(ur(ww)+sqrt(g*hr(ww)),ustar(ww)+phistar(ww));


%------------------------
% dry bed upstream
%------------------------
sl(dw)=ur(dw)-2.0*sqrt(g*hr(dw));
sr(dw)=ur(dw)+sqrt(g*hr(dw));
sm(dw)=sl(dw);

%------------------------
% dry bed downstream
%------------------------
sl(wd)=ul(wd)-sqrt(g*hl(wd));
sr(wd)=ul(wd)+2.0*sqrt(g*hl(wd));
sm(wd)=sr(wd);

%-------------------------------------
% calculate the intermediate flux
%-------------------------------------

up = find(sr <= 0.0);
dn = find(sl >= 0.0);
sb = find(sr > 0.0 & sl < 0.0);

%--------------------------
% supercritical flow upstream direction
%--------------------------
f1(up)=ur(up).*hr(up);
f2(up)=ur(up).*ur(up).*hr(up) + g*hr(up).*hr(up)/2.0;
%f3(up)=f1(up).*wr(up);

%--------------------------
% supercritical flow downstream direction
%--------------------------
f1(dn)=ul(dn).*hl(dn);
f2(dn)=ul(dn).*ul(dn).*hl(dn) + g*hl(dn).*hl(dn)/2.0;
%f3(dn)=f1(dn).*wl(dn);

%-------------------------
% subcritical flow
%------------------------
f1(sb)=(sr(sb).*ul(sb).*hl(sb) - sl(sb).*ur(sb).*hr(sb) + ...
    sl(sb).*sr(sb).*(hr(sb)-hl(sb)))./(sr(sb)-sl(sb));

f2(sb)=(sr(sb).*(ul(sb).*ul(sb).*hl(sb) + g*hl(sb).*hl(sb)/2.0) - ...
    sl(sb).*(ur(sb).*ur(sb).*hr(sb) + g.*hr(sb).*hr(sb)/2.0) + ...
    sl(sb).*sr(sb).*(ur(sb).*hr(sb) - ul(sb).*hl(sb)))./(sr(sb)-sl(sb));


%w(sb)=wl(sb);
%ws = find(ustar < 0.0 & sr > 0.0 & sl < 0.0);
%w(ws)=wr(ws);



sm0 = find(sm < 0.0);

w=wl;
w(sm0)=wr(sm0);
f3=f1.*w;

f = [f1;f2;f3];

if nd > 3
    for i=1:nd-3
      c = cl(i,:);
      c(sm0)=cr(i,sm0);
      f4 = f1.*c;
      f = [f;f4];
    end
end

if FVM_K > 0
  for i=1:nd
    fprintf(' max(f%g) = %12.5e min(f%g) = %12.5e \n', ...
        i,i,max(f(i,:)),min(f(i,:)))
  end
  
  fprintf(' max(sl) = %12.5e min(sl) = %12.5e \n',max(sl),min(sl))
  fprintf(' max(sm) = %12.5e min(sm) = %12.5e \n',max(sm),min(sm))
  fprintf(' max(sr) = %12.5e min(sr) = %12.5e \n',max(sr),min(sr))
  
end

if any(sl>sm) || any(sm>sr)
  error('sl > sm or sm > sr ')
end

smax = max(max(abs(sl),abs(sr)));

  

