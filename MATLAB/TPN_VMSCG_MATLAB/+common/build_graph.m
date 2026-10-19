function GSC = build_graph(G, withValidity, opts)
%BUILD_GRAPH Shared FIFO construction of the canonical MSCG or V-MSCG.
if nargin < 3, opts = common.default_options(); end
common.validate_model(G);

S0 = common.initial_state(G,withValidity,opts);
vertices = S0;
edges = struct('id',{},'source',{},'target',{},'transition',{},'kappa',{});
seen = containers.Map('KeyType','char','ValueType','double');
seen(common.state_signature(S0,withValidity,opts)) = 1;
queue = zeros(1,min(opts.maxVertices,10000));
queue(1)=1; head=1; tail=1;

while head<=tail
    sourceIndex=queue(head); head=head+1;
    current=vertices(sourceIndex);
    for fired=find(current.enabled)
        [branches,kappas,ok]=common.successors( ...
            G,current,fired,withValidity,opts);
        if ~ok, continue; end
        for q=1:numel(branches)
            next=branches(q);
            key=common.state_signature(next,withValidity,opts);
            if isKey(seen,key)
                targetIndex=seen(key);
            else
                assert(numel(vertices)<opts.maxVertices, ...
                    ['Maximum vertex limit (%d) reached. Increase ' ...
                    'cfg.options.maxVertices only after checking the model.'], ...
                    opts.maxVertices);
                next.id=numel(vertices);
                vertices(end+1)=next; %#ok<AGROW>
                targetIndex=numel(vertices);
                seen(key)=targetIndex;
                tail=tail+1;
                if tail>numel(queue), queue=[queue zeros(1,numel(queue))]; end %#ok<AGROW>
                queue(tail)=targetIndex;
            end
            e.id=numel(edges)+1;
            e.source=current.id;
            e.target=vertices(targetIndex).id;
            e.transition=fired;
            e.kappa=kappas(q);
            edges(end+1)=e; %#ok<AGROW>
        end
    end
    if opts.verbose && mod(head-1,opts.progressEvery)==0
        fprintf('  explored %d; discovered %d vertices\n', ...
            head-1,numel(vertices));
    end
end

GSC.model=G;
GSC.vertices=vertices;
GSC.edges=edges;
GSC.initialVertex=0;
GSC.withValidity=withValidity;
GSC.options=opts;

% Read-only indices used by every policy.  They are needed only for the
% V-MSCG; ordinary MSCG timing does not include this SPP-specific work.
if withValidity
    GSC.edgeSource=[edges.source];
    GSC.edgeTarget=[edges.target];
    GSC.edgeTransition=[edges.transition];
    GSC.edgeKappa=[edges.kappa];
    GSC.outgoingEdgeIds=cell(1,numel(vertices));
    for edgeId=1:numel(edges)
        sourceIndex=GSC.edgeSource(edgeId)+1;
        GSC.outgoingEdgeIds{sourceIndex}(end+1)=edgeId;
    end
    GSC.secretVertexMask=false(1,numel(vertices));
    GSC.secretRequirementByVertex=zeros(1,numel(vertices));
    for vertexIndex=1:numel(vertices)
        [isSecret,requirement]=common.secret_requirement(G,vertices(vertexIndex).M);
        GSC.secretVertexMask(vertexIndex)=isSecret;
        GSC.secretRequirementByVertex(vertexIndex)=requirement;
    end
end
end
