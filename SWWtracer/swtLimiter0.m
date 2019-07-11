function [qmid, qv] = swLimiter0(mesh,solveops,q,qmid)
%
% function [qmid, qv] = swLimiter0(mesh,solveops,q,qmid)
%
% Limits qmid back to centroid q values
%

%---------------------------------------
% Check flux calculation parameters (fluxops)
%---------------------------------------

if isempty(solveops.beta)
  error('beta parameter should be passed via solveops argument');
end

%---------------------------------
% Calculation Start
%---------------------------------

for j=1:3
  qmid(:,j,:) = q;
end


if nargout>1
  qv = zeros(size(qmid));
  for j=1:3
    j1 = rem(j,3)+1;
    j2 = rem(j+1,3)+1;
    qv(:,j,:) = (qmid(:,j2,:)-qmid(:,j,:)+qmid(:,j1,:));
  end
end
   

     

   
