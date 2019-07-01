function fvmSetPlot()

global gscale

if isempty(gscale)
  gscale = [0.0, 10.0];
end

caxis(gscale);

%b = flipud(bone(64));
b = jet(128);
%for i = 1:10:128
%  b(i,:) = [1 1 1];
%end
b(1,:) = [0.75,0.75 0.75];
k = floor(128*0.03);
b(k,:) = [0.75,0.75 0.75];
%b = prism(40);
%b = b(1:end-20,:);
%b = hsv(64);
%b = [ones(64,2) zeros(64,1)];
%b = hsv(40);
%b = jet(64);
colormap(b);
colorbar;

%global aview
%view(aview);
fvmView

