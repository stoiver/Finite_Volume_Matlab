function [q, grad] = swExact(c,dim,time,type)

if nargin<3
   time = 0.0;
end

if nargin<4
  type(1,:) = 'step11'
end

if size(type,1) ~= dim
  for i = 1:dim
    type(i,:) = type(1,:);
  end
end

%-------------------------------
% Computation start
%-------------------------------

grad = zeros(dim,2,size(c,2));
q = zeros(dim,size(c,2));

for i = 1:dim
  switch type(i,:)
    case 'step11',
      neg = find(c(1,:)+c(2,:)<1.0);
      q(i,neg) = 1.0;
    case 'x+y',
      q(i,:) = c(1,:)+c(2,:);
      grad(i,1,:) = 3*c(1,:).^2;
      grad(i,2,:) = 2*c(2,:);
    case 'zero',
      q(i,:) = zeros(1,size(c,2));
    otherwise ,
      error('No type of exact solution specified');
  end
end

