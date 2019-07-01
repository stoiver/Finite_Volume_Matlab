function [q0] = linearInitialConc(mesh,type)

if nargin == 1
  type = 'default1'
end

%--------------------------------
% Start Computation
%--------------------------------

switch lower(type)
   case 'circle',
      centres = [ -0.3 ; -0.3 ]; 
      centres = centres(:,ones(1,size(mesh.p,2)));
      radius2 = 0.03;
      pq = sum((mesh.p-centres).^2);
      pq = pq<radius2 + (pq<(radius2+0.02)&pq>radius2).*(0.05-radius2)/0.02;
      q0 = (pq(mesh.t(1,:))+pq(mesh.t(2,:))+pq(mesh.t(3,:)))/3.0;
   case 'default1',
     pq =  (mesh.p(1,:)>=-0.6001)&(mesh.p(1,:)<=-0.1999)...
	 &(mesh.p(2,:)>=-0.6001)&(mesh.p(2,:)<=-0.1999);
     q0 = min(min(pq(mesh.t(1,:)),pq(mesh.t(2,:))),pq(mesh.t(3,:)));
   case 'default2',
     pq =  (mesh.p(1,:)>=-0.6001)&(mesh.p(1,:)<=-0.1999)...
	 &(mesh.p(2,:)>=-0.6001)&(mesh.p(2,:)<=-0.1999);
     q0(1,:) = min(min(pq(mesh.t(1,:)),pq(mesh.t(2,:))),pq(mesh.t(3,:)));
     q0(2,:) = q0(1,:);
   case 'default3',
     pq =  (mesh.p(1,:)>=-0.6001)&(mesh.p(1,:)<=-0.1999)...
	 &(mesh.p(2,:)>=-0.6001)&(mesh.p(2,:)<=-0.1999);
     q0(1,:) = min(min(pq(mesh.t(1,:)),pq(mesh.t(2,:))),pq(mesh.t(3,:)));
     q0(2,:) = q0(1,:);     
     q0(3,:) = q0(1,:);
   otherwise
     error('type not set correctly');
end