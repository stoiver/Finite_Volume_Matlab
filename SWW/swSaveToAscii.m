function swSaveToAscii(r,m,qT,filename)
%
% function swSaveToAscii(r,m,qT,filename)
%
% Save to Ascii file, the evolution defined by r,m,qT
% as created by fvm main program
%

fid = fopen(filename,'w');

if ~fid
  error('opening file'+filename)
end

%---------------------------
% Print out mesh information
%---------------------------
fprintf(fid,'# Number of vertices \n');
fprintf(fid,'%g\n',size(m.p,2));
fprintf(fid,'# vertex coordinates \n');
fprintf(fid,'%g %g %g \n',[m.p ; m.elevation]);
fprintf(fid,'# Number of polygons \n');
fprintf(fid,'%g\n',size(m.t,2));
fprintf(fid,'# polygon definitions \n');
fprintf(fid,'%g %g %g \n',m.t);

%---------------------------
% Print out height, ux and uy
% at nodes, for each timestep
%---------------------------
maxinc = r.inc;

fprintf(fid,'# number of timesteps \n');
fprintf(fid,'%g\n',maxinc);

for inc = 1:maxinc
  q = qT{inc};
  fprintf('%g ',inc);
  time = (inc-1)*r.DT;

  fprintf(fid,'# Increment, Time \n');
  fprintf(fid,'%g %g \n',inc,time);

  qmid = fvmPWL2(m,r,q);
  parms.beta = 1;
  [qmid, qv] = swLimiter2(m,parms,q,qmid);
  
  h =  squeeze(qv(1,:,:));
  uh = squeeze(qv(2,:,:));
  wh = squeeze(qv(3,:,:));
  
  %h = q(1,:);
  %uh = q(2,:);
  %wh = q(3,:);
  
  hq = fvmTdataToPdata(m,q(1,:));
  uhq = fvmTdataToPdata(m,q(2,:));
  whq = fvmTdataToPdata(m,q(3,:));
  
  %hc  =  [hq(m.t(1,:)) ; hq(m.t(2,:)) ; hq(m.t(3,:))];
  %uhc =  [uhq(m.t(1,:)) ; uhq(m.t(2,:)) ; uhq(m.t(3,:))];
  %whc =  [whq(m.t(1,:)) ; whq(m.t(2,:)) ; whq(m.t(3,:))];
  
  %  size(squeeze(h))
  %  size(hq(m.t(1,:)))
  
  %sum(sum(abs(h - [hq(m.t(1,:)) ; hq(m.t(2,:)) ; hq(m.t(3,:))]) >0.5))
  %min(min(abs(h - [hq(m.t(1,:)) ; hq(m.t(2,:)) ; hq(m.t(3,:))])))
  
  [h,u,w] = swTransformHUW(h(:)',uh(:)',wh(:)',r);
  fprintf(fid,'# (h u w) at vertices of a triangle \n');
  fprintf(fid,'%g %g %g %g %g %g %g %g %g\n',[h(:)'; u(:)' ; w(:)'] );
  
  [h,u,w] = swTransformHUW(hq(:)',uhq(:)',whq(:)',r);
  fprintf(fid,'# smoothed (h u w) at a vertex \n');
  fprintf(fid,'%g %g %g \n',[ h(:)'; u(:)' ; w(:)' ]);
      
end

fprintf('\n')

fclose(fid);

return
