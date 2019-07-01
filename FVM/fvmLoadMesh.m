function [mesh,q] = fvmLoadMesh(parms)

%load function mesh q;
[mesh,q] = feval(parms.initialMesh,parms);

return
