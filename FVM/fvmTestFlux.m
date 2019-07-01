function fvmTestFlux(q,mesh,testflux)

diffflux = zeros(size(testflux));

size(testflux)
size(diffflux)
nt = size(testflux,3);
for i = 1:nt
  for k = 1:3
    jj = mesh.tneigh(k,i);
    if jj>0
      for kk = 1:3
	if mesh.tneigh(kk,jj) == i
	  diffflux(:,k,i) = testflux(:,k,i) + testflux(:,kk,jj);
	end
      end
    end
  end
end

keyboard
return
