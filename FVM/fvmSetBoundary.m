function [pq] = fvmSetBoundary(mesh,eqn,pq)


%---------------------------------------
% To save some time we can pass through
% some extra arrays.
% Otherwise calculate them now
%---------------------------------------
if ~isfield(mesh,'tneigh')
   mesh = fvmNeigh(mesh);
end

%---------------------------------------
% Calculation start
%---------------------------------------

nq = size(pq,1);

for i=1:3
  tbdry = find(mesh.tneigh(i,:)==0);
  if ~isempty(tbdry) 
    pbdry = [ mesh.t(mod(i,3)+1,tbdry) mesh.t(mod(i+1,3)+1,tbdry) ];
    pq(:,pbdry) = feval(eqn.dirBCFunct,mesh.p(:,pbdry),nq,0.0,'zero');
  end
end

