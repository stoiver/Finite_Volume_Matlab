function [qmid, qv] = fvmLimiter(mesh,solveops,q,qmid)
%
% function [qmid, qv] = fvmLimiter(mesh,solveops,q,qmid)
%
% Limit the qmid values so that they are limited at
% the midpoints. 

%---------------------------------------
% Check flux calculation parameters (fluxops)
%---------------------------------------

if ~isfield(solveops,'beta')
  error('beta parameter should be passed via fluxops argument');
end

%---------------------------------
% Calcuation Start
%---------------------------------
mesh = fvmNeigh(mesh,'ifnecessary');
nt = size(mesh.t,2);

n = size(q,1);
phi0 = ones(n,3,nt);


for j=1:3
   ip = find(mesh.tneigh(j,:)>0);
   qn = zeros(size(q));
   if ~isempty(ip)
      qn(:,ip) = q(:,mesh.tneigh(j,ip));
   end

   qj = reshape(qmid(:,j,:),n,nt);

   qmax = max(q,qn);
   qmin = min(q,qn);
   dq = qj-q;
   dqmax = qmax - q;
   dqmin = qmin - q;
      
   ipos = find(dq>0);
   ineg = find(dq<0);
   r = ones(size(q));
      
   if ~isempty(ipos)
      r(ipos) = dqmax(ipos)./dq(ipos); 
   end
   if ~isempty(ineg)
      r(ineg) = dqmin(ineg)./dq(ineg); 
   end

   phi0(:,j,:) = max(min(solveops.beta*r,1),min(r,solveops.beta));

end

phi = reshape(min(phi0,[],2),n,nt);


for j=1:3
  qmid(:,j,:) = q + phi.*(reshape(qmid(:,j,:),n,nt)-q);
end


%-----------------------------------
% test that first coordinate is >= 0
%-----------------------------------


[ii, jj] = find(squeeze(qmid(1,:,:)<0));
if ~isempty(ii)
  for j = 1:size(ii,1)
%    qmid(1,ii(j),jj(j)), q(1,jj(j))
%    keyboard
    qmid(1,ii(j),jj(j)) = 0.0;
  end
end
   

if nargout>1
  qv = zeros(size(qmid));
  for j=1:3
    j1 = rem(j,3)+1;
    j2 = rem(j+1,3)+1;
    qv(:,j,:) = (qmid(:,j2,:)-qmid(:,j,:)+qmid(:,j1,:));
  end
end   

   
