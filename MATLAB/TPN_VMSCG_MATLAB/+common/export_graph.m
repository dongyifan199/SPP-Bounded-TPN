function export_graph(GSC,prefix,GP,makePng)
%EXPORT_GRAPH Export one complete or pruned graph to CSV and optional PNG.
if nargin<3 || isempty(GP)
    vertexIds=[GSC.vertices.id]; edgeIds=1:numel(GSC.edges);
else
    vertexIds=GP.vertexIds; edgeIds=GP.edgeIds;
end
if nargin<4, makePng=true; end
G=GSC.model;
if isfield(G,'paperTransitionNames'), displayNames=G.paperTransitionNames; else, displayNames=G.transitionNames; end

nV=numel(vertexIds);
vertex=zeros(nV,1); marking=strings(nV,1); rho=strings(nV,1);
ageClocks=strings(nV,1); validityClocks=strings(nV,1);
zoneSignature=strings(nV,1); isSecret=false(nV,1);
for k=1:nV
    S=GSC.vertices(vertexIds(k)+1);
    vertex(k)=S.id; marking(k)=string(common.marking_text(G,S.M));
    if GSC.withValidity, rho(k)=string(S.rho(G.protectable)); else, rho(k)="-"; end
    ageClocks(k)=string(strjoin(displayNames(S.ageClock>0),','));
    validityClocks(k)=string(strjoin(displayNames(S.valClock>0),','));
    zoneSignature(k)=string(dbm.signature(S.D, ...
        GSC.options.signatureDigits,GSC.options.tolerance));
    if isfield(GSC,'secretVertexMask')
        isSecret(k)=GSC.secretVertexMask(vertexIds(k)+1);
    else
        isSecret(k)=common.secret_requirement(G,S.M);
    end
end
VT=table(vertex,marking,rho,ageClocks,validityClocks,zoneSignature,isSecret);
writetable(VT,[prefix '_vertices.csv']);

nE=numel(edgeIds); edge=zeros(nE,1); source=zeros(nE,1); target=zeros(nE,1);
transition=strings(nE,1); kappa=zeros(nE,1);
for k=1:nE
    e=GSC.edges(edgeIds(k)); edge(k)=e.id; source(k)=e.source;
    target(k)=e.target; transition(k)=string(displayNames{e.transition});
    kappa(k)=e.kappa;
end
ET=table(edge,source,target,transition,kappa);
writetable(ET,[prefix '_edges.csv']);

if makePng && nE>0
    local=zeros(1,max(vertexIds)+1);
    for k=1:nV, local(vertexIds(k)+1)=k; end
    d=digraph(local(source+1),local(target+1),[],nV);
    f=figure('Visible','off','Color','w','Position',[100 100 1400 800]);
    p=plot(d,'Layout','layered','Direction','right','NodeLabel', ...
        compose('z%d',vertexIds),'ArrowSize',8,'LineWidth',0.8);
    p.EdgeLabel=transition;
    title(sprintf('%s: %d vertices, %d edges',GSC.type,nV,nE));
    try
        exportgraphics(f,[prefix '_graph.png'],'Resolution',180);
    catch
        saveas(f,[prefix '_graph.png']);
    end
    close(f);
end
end
