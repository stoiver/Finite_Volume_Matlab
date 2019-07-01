function tvel = fvmInitialVel(mesh,type)

if nargin == 1
  type = 'default'
end

%--------------------------------
% Start Computation
%--------------------------------

switch lower(type)
   case '11',
      tvel = ones(1,size(mesh.t,2));
      tvel = [tvel ; tvel];
   case '12',
      tvel = ones(1,size(mesh.t,2));
      tvel = [tvel ; 2*tvel];
   case '21'      
      tvel = ones(1,size(mesh.t,2));
      tvel = [2*tvel ; tvel];
   case 'rotate'
      c = fvmCentroid(mesh);
      tvel = [ -c(2,:) ; c(1,:) ];
   otherwise ,
      error('Initial Velocity type not set')
end

      
