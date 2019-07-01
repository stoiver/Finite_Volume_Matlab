function mesh=fvmSquareMesh50(n1,n2)

if nargin == 1
  n2 = n1;
end

len = 50;
x = (0:1/n1:1)*len;
y = (1:-1/n2:0)*len;

[xx,yy] = meshgrid(x,y);

xx = xx(:);
yy = yy(:);
p = [ xx' ; yy'];


[nx ny] = meshgrid(0:n1,1:n2+1);

nn = ny + nx*(n2+1);

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
mesh.geometry = 'squaremesh50';

mesh = fvmDiameters(mesh);

