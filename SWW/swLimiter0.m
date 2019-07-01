function [qmid] = swLimiter0(mesh,solveops,q,qmid)
%
% function [qmid] = swLimiter0(mesh,solveops,q,qmid)
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
   

     

   
