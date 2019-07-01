function [m,varargout] = fvmRefineMesh(mesh,varargin)

p = mesh.p;
t = mesh.t;

np = size(p,2);
nt = size(t,2);

ii = t(1,:)';
jj = t(2,:)';
kk = t(3,:)';

kkk = min(ii,jj)+np*(max(ii,jj)-1);
iii = min(jj,kk)+np*(max(jj,kk)-1);
jjj = min(kk,ii)+np*(max(kk,ii)-1); 

nm = sparse(np,np);

nm(kkk) = ones(nt,1);
nm(iii) = ones(nt,1);
nm(jjj) = ones(nt,1);


[in,jn,sn] = find(nm);

nn = (np+1:np+nnz(nm))';
nm = sparse(in,jn,nn,np,np);

pp = [ p 0.5*(p(:,in)+p(:,jn)) ]; 

%       ii
%     / 2 \
%kkk /-----\ jjj
%   /3\ 1 /4\
%  jj-------kk
%      iii

iii = full(nm(iii))';
jjj = full(nm(jjj))';
kkk = full(nm(kkk))';

t1 = [iii; jjj; kkk];
t2 = [ii'; kkk; jjj];
t3 = [jj'; iii; kkk];
t4 = [kk'; jjj; iii];
  
tt = [t1 t2 t3 t4];

%-------------------------------
% form the new mesh
%-------------------------------

m = fvmSetMeshStruct;
m.p = pp;
m.t = tt;
m.e = [];

%------------------------------
% Let's do the tneigh structure
% if necessary. Remember boundary
% condition are encoded into tneigh
%------------------------------
if ~isempty(mesh.tneigh)
  m = fvmNeigh(m);
  ii = find(mesh.tneigh(1,:)<0);
  if ~isempty(ii)
    m.tneigh(3,ii+2*nt) = mesh.tneigh(1,ii);
    m.tneigh(2,ii+3*nt) = mesh.tneigh(1,ii);
  end
  
  ii = find(mesh.tneigh(2,:)<0);
  if ~isempty(ii)
    m.tneigh(2,ii+nt)   = mesh.tneigh(2,ii);
    m.tneigh(3,ii+3*nt) = mesh.tneigh(2,ii);
  end
  
  ii = find(mesh.tneigh(3,:)<0);
  if ~isempty(ii)
    m.tneigh(3,ii+nt)   = mesh.tneigh(3,ii);
    m.tneigh(2,ii+2*nt) = mesh.tneigh(3,ii);
  end
end    

%------------------------------
% Let's do standard node structures
%------------------------------
if ~isempty(mesh.elevation)
  el = mesh.elevation;
  m.elevation = [ el 0.5*(el(in)+el(jn)) ];
end

if ~isempty(mesh.friction)
  el = mesh.friction;
  m.friction = [ el 0.5*(el(in)+el(jn)) ];
end

%-------------------------------
% Let's do the other input arguments
%-------------------------------
n = min(size(varargin,2),max(nargout,1)-1);

for i = 1:n
  dd = varargin{i};
  ndd = size(dd,2);
  switch ndd
    case nt,
      % Triangle based data
      rdd = [ dd dd dd dd ];
      varargout(i) = {rdd};
    case np,
      % Node based data
      rdd = [ dd 0.5*(dd(:,in)+dd(:,jn)) ];
      varargout(i) = {rdd};      
    otherwise,
      msg1 = sprintf('Input argument %g is neither triangle nor node based.',i+1);
      
      error(msg1)
  end
end

return
