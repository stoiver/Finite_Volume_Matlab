function mesh=fvmSquareMesh(n1,n2)

if nargin == 1
  n2 = n1;
end

x = -1:1/n1:1;
y = 1:-1/n2:-1;

[xx,yy] = meshgrid(x,y);

xx = xx(:);
yy = yy(:);
p = [ xx' ; yy'];


[nx ny] = meshgrid(0:2*n1,1:2*n2+1);

nn = ny + nx*(2*n2+1);

t1 = nn(2:end,1:end-1);
t2 = nn(2:end,2:end);
t3 = nn(1:end-1,2:end);

t = [ t1(:)' ; t2(:)' ; t3(:)'];

%t1 = nn(2:end,1:end-1);
t2 = nn(1:end-1,2:end);
t3 = nn(1:end-1,1:end-1);

tt = [ t1(:)' ; t2(:)' ; t3(:)'];
  
t = [ t , tt];


e = [];

mesh.p = p;
mesh.t = t;
mesh.e = e;
mesh.geometry = 'squaremesh';
