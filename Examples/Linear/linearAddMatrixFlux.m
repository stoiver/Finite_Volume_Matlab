function [A] = fvmAddMatrixFlux(A,mesh,ngh,nvel)

nt = size(mesh.t,2);

%----------------------------------
% Use concentration from the upwind
% direction of the flow (nvel)
%----------------------------------
ipos = find(nvel>0);
ii = ipos;
jj = ipos;
aa = nvel(ii);
A = A - sparse(ii,jj,aa, nt,nt);

ineg = find(nvel<0 & ngh>0);
ii = ineg;
jj = ngh(ii);
aa = nvel(ii);
A = A - sparse(ii,jj,aa, nt,nt);
