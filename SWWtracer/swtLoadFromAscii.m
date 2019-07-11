function [r,m,qT] = swLoadFromAscii(filename)
%
% function [r,m,qT] = swSaveToAscii(filename)
%
% Load from Ascii file, the evolution defined by r,m,qT.
%

fid = fopen(filename,'r');

if ~fid
  error('opening file'+filename)
end

m = fvmSetMeshStruct;

%---------------------------
% Print out mesh information
%---------------------------
line = fgetl(fid); %fscanf(fid,'# Number of vertices \n');
nv = fscanf(fid,'%g');
line = fgetl(fid); %fprintf(fid,'# vertex coordinates \n');
p = fscanf(fid,'%g',nv*3);
line =  fgetl(fid);
p = reshape(p,3,nv);
m.p = p(1:2,:);
m.elevation = p(3,:);

line = fgetl(fid); %fprintf(fid,'# Number of polygons \n');
nt = fscanf(fid,'%g');
line = fgetl(fid); %fprintf(fid,'# polygon definitions \n');
t = fscanf(fid,'%g',3*nt);
line = fgetl(fid);
m.t = reshape(t,3,nt);

%---------------------------
% Read in height, ux and uy
% at nodes, for each timestep
%---------------------------
%maxinc = r.inc;

line = fgetl(fid); %fprintf(fid,'# number of timesteps \n');
maxinc = fscanf(fid,'%g');

for inc = 1:maxinc
  fprintf('%g ',inc);

  line = fgetl(fid); % fprintf(fid,'# Increment Time \n');
  a = fscanf(fid,'%g',2);
  line = fgetl(fid);
  inc = a(1);
  time = a(2);

  if inc==2
    DT = time;
  end
  
  %hq = fvmTdataToPdata(m,q(1,:));
  %uhq = fvmTdataToPdata(m,q(2,:));
  %whq = fvmTdataToPdata(m,q(3,:));
  
  %[hq,uq,wq] = swTransformHUW(hq,uhq,whq,r);
  line = fgetl(fid); % fprintf(fid,'# h u w \n');
  a = fscanf(fid,'%g',9*nt);
  line = fgetl(fid);
  a = reshape(a,9,nt);
  h = (a(1,:)+a(4,:)+a(7,:))/3.0;
  u = (a(2,:)+a(5,:)+a(8,:))/3.0;
  w = (a(3,:)+a(6,:)+a(9,:))/3.0;
  uh = u.*h;
  wh = w.*h;
  qT{inc} = [h;uh;wh];

end

fprintf('\n');
fclose(fid);

r = fvmSetParmsStruct;

r.inc = maxinc;
r.DT = DT; 


return
