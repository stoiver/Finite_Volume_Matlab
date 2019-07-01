function [qr] = swBoundaryConc(ql,normals,flags)
%
% function [qr] = swBoundaryConc(ql,normals,flags)
%
% Set up fictious right hand concentrations to enforce
% boundary condition set by flag


Tql = swRotate(ql,normals);


Tqr = zeros(size(ql));

%--------------------------
% Reflective BC flag == 0
%--------------------------
ii = find(flags == 0);
if ~isempty(ii)
  %disp('ref')
  Tqr(1,ii) = Tql(1,ii);
  Tqr(2,ii) = -Tql(2,ii);
  Tqr(3,ii) = Tql(3,ii);
end

%--------------------------
% Transmissive BC flag == -1
%--------------------------
ii = find(flags == -1);
if ~isempty(ii)
  %disp('tans')
  Tqr(1,ii) = Tql(1,ii);
  Tqr(2,ii) = Tql(2,ii);
  Tqr(3,ii) = Tql(3,ii);
end

ii = find(flags < -1);
if ~isempty(ii)
  error('Can only deal with Transmissive and Reflective Boundaries')
end


%---------------------------
%  Transform back to xy coords
%---------------------------
qr = swInvRotate(Tqr,normals);

