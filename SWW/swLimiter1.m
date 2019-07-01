function [qmid] = swLimiter1(mesh,solveops,q,qmid)
%
% function [qmid] = swLimiter1(mesh,solveops,q,qmid)
%
% Limit the qmid values so that they are limited at
% the midpoints. 

%---------------------------------------
% Check flux calculation parameters (fluxops)
%---------------------------------------

if isempty(solveops.beta)
  error('beta parameter should be passed via solveops argument');
end

%---------------------------------
% Calcuation Start
%---------------------------------
mesh = fvmNeigh(mesh,'ifnecessary');
nt = size(mesh.t,2);

n = size(q,1);
phi0 = ones(n,3,nt);

%-------------------
% Remember to Modify beta so that 
% it's affect is neglible
% for small heights
%-------------------

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
%   f = min(q(1,:)/solveops.delta,1);
   f = (atan(q(1,:)/solveops.delta)/pi*2).^2;
   f = [f;f;f];
   beta = solveops.beta*r.*f;

      
   if ~isempty(ipos)
      r(ipos) = dqmax(ipos)./dq(ipos); 
   end
   if ~isempty(ineg)
      r(ineg) = dqmin(ineg)./dq(ineg); 
   end

   phi0(:,j,:) = max(min(beta.*r,1),min(r,beta));

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
   

     

   
