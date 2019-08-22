function [q1, meshnew]  = adaptRefineCoarsen(q,mesh,parms,indicator,tol_indicator)
%
% [q, mesh]  = adaptRefineCoarsen(q,mesh,parms,dtime,qnew)
%
% Given q, qnew and dtime, determine which triangles should be refined or 
% coarsened and then do the adaption, returning qnew interpolated to the 
% new mesh, meshnew. 


nd = parms.nd;

% Need to transpose to be consistent with ifem ordering
indicator = indicator';

%----------------------------------
% Determine triangles to be flagged 
% for refinement then refine and 
% interpolate to refined mesh
%----------------------------------
node = mesh.p';
elem = mesh.t';
q0 = q';

for i=1:1
    mesh1 = fvmMesh(node,elem,'radial');
    
    refineElem  = find((abs(indicator) > tol_indicator) .* ...
        (mesh1.area' >= parms.init_res/parms.refine_limit) );
    
    %fprintf('|refineElem| = %g \n',size(refineElem,1));
    % disp('size refineElem')
    % size(refineElem)
    
    [node,elem,~,~,tree] = bisect(node, elem, refineElem);
    
    ntf = size(elem,1);  %number of triangles after refinement
    %fprintf('refine ntf = %g \n',ntf);
    
    q1 = zeros(ntf,nd);
    for ii = 1:nd
        q1(:,ii) = eleminterpolate(q0(:,ii),tree);
    end
    indicator = eleminterpolate(indicator,tree);
    
    q0 = q1;
end

%----------------------------------
% Determine triangles which can
% be coarsened. let's do it a couple
% of times to clear out extra triangles
%----------------------------------
for i =1:1
    mesh1 = fvmMesh(node,elem,'radial');
    
    coarsenElem = find( (abs(indicator) < parms.coarsen_factor*tol_indicator) .* ...
        (mesh1.area' <= parms.init_res*parms.coarsen_limit) );
    
    %fprintf('|coarsenElem| = %g \n',size(coarsenElem,1));
    
    [node,elem,~,~,tree] = coarsen(node,elem, coarsenElem, []);
    
    ntc = size(elem,1);  %number of triangles after coarsen
    q1 = zeros(ntc,nd);
    for ii = 1:nd
        q1(:,ii) = eleminterpolate(q0(:,ii),tree)';
    end
    indicator = eleminterpolate(indicator,tree);
    q0 = q1;
end

q1 = q1';

% Create new mesh
meshnew = fvmMesh(node,elem,'radial');
meshnew.elevation = zeros(1,meshnew.np);
meshnew.friction  = zeros(1,meshnew.np);


end