function fvmPlotEvolution(g,q,pops)

if nargin < 3
  pops.dim = 1;
  pops.ptime = 1;
end

if ~isfield(pops,'ptime')
  pops.ptime = 1;
end

if ~isfield(pops,'dim')
  pops.dim = 1;
end

%--------------------------------
% Start Computation
%--------------------------------



cmap = 'default';
clf;
pq = fvmTdataToPdata(g,q(pops.dim,:));
%pdeplot(g.p,g.e,g.t,'xydata',pq','mesh','on','contour','on');
meshplot(g.p,g.e,g.t,'xydata',q(pops.dim,:),'xystyle','flat','mesh','off',...
    'contour','on');
%pdecont(p,t,q(i,:))
disp('node based q');
drawnow
