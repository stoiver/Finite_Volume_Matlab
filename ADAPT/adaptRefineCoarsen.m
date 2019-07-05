function [qnew, meshnew]  = adaptRefineCoarsen(q,mesh,parms,indicator,tol_indicator)
%
% [q, mesh]  = adaptRefineCoarsen(q,mesh,parms,dtime,qnew)
%
% Given q, qnew and dtime, determine which triangles should be refined or 
% coarsened and then do the adaption, returning qnew interpolated to the 
% new mesh, meshnew. 


% Need to transpose to be consistent with ifem ordering
indicator = indicator';

%----------------------------------
% Determine triangles to be flagged 
% for refinement then refine and 
% interpolate to refined mesh
%----------------------------------
refineElem  = find((abs(indicator) > tol_indicator) .* ...
    (mesh.area' >= parms.init_res/64) );

fprintf('|refineElem| = %g \n',size(refineElem,1));
% disp('size refineElem')
% size(refineElem)

node = mesh.p';
elem = mesh.t';

[node,elem,~,~,tree] = bisect(node, elem, refineElem);

ntf = size(elem,1);  %number of triangles after refinement
%fprintf('refine ntf = %g \n',ntf);

qref = zeros(ntf,3);
for ii = 1:3
    qref(:,ii) = eleminterpolate(q(ii,:)',tree);
end
indicator = eleminterpolate(indicator,tree);

%----------------------------------
% Determine triangles to be flagged 
% for refinement then refine and 
% interpolate to refined mesh
%----------------------------------
coarsenElem = find(abs(indicator) < 0.5*tol_indicator);
fprintf('|coarsenElem| = %g \n',size(coarsenElem,1));

[node,elem,~,~,tree] = coarsen(node,elem, coarsenElem, []);

ntc = size(elem,1);  %number of triangles after coarsen
qnew = zeros(3,ntc);
for ii = 1:3
    qnew(ii,:) = eleminterpolate(qref(:,ii),tree)';
end
%indicator = eleminterpolate(indicator,tree);

% Create new mesh
meshnew = fvmMesh(node,elem,'radial');
meshnew.elevation = zeros(1,meshnew.np);
meshnew.friction  = zeros(1,meshnew.np);


end