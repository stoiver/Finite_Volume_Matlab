function [qmid, gradq] = fvmPWL0(mesh,eqn,q)
%
% function [qmid, gradq] = fvmPWL0(mesh,eqn,q)
%

%----------------------------------
% Calculation start
%----------------------------------
gradq = zeros(2,size(q,2));

qmid = zeros(size(q,1),3,size(q,2));
for i=1:3
  qmid(:,i,:) = q;
end

