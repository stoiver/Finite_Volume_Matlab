[node,elem] = squaremesh([0 1 0 1],1/2);
p = 1:size(elem,1);
figure(1);
subplot(1,4,1); showsolution(node,elem,p,'EdgeColor','k'); view(2);

[node,elem,~,~,tree] = bisect(node,elem,[1 2]);
tree
p = eleminterpolate(p,tree);
subplot(1,4,2); showsolution(node,elem,p,'EdgeColor','k'); view(2);


[node,elem,~,~,tree] = bisect(node,elem,[1 2]);
tree
p = eleminterpolate(p,tree);
subplot(1,4,3); showsolution(node,elem,p,'EdgeColor','k'); view(2);


[node,elem,~,~,tree] = coarsen(node,elem,'all');
tree
p = eleminterpolate(p,tree);
subplot(1,4,4); showsolution(node,elem,p,'EdgeColor','k'); view(2);