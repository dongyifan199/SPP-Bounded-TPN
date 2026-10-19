function count = count_secret_vertices(G,GSC,vertexIds)
%COUNT_SECRET_VERTICES Count reachable graph vertices with secret markings.
if nargin<3 || isempty(vertexIds)
    if isfield(GSC,'secretVertexMask')
        count=nnz(GSC.secretVertexMask);
        return;
    end
    vertexIds=0:numel(GSC.vertices)-1;
elseif isfield(GSC,'secretVertexMask')
    count=nnz(GSC.secretVertexMask(vertexIds+1));
    return;
end
count=0;
for vertexId=vertexIds
    S=GSC.vertices(vertexId+1);
    [isSecret,~]=common.secret_requirement(G,S.M);
    if isSecret, count=count+1; end
end
end
