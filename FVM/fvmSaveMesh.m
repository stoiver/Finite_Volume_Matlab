function fvmSaveMesh(fun)

[mesh,q] = feval(fun);
  
save fun mesh q;

return
