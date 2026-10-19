function paths = backward_paths(G,GV,GP,policy,secretVertexId,opts)
%BACKWARD_PATHS Compute finite backward paths for one reachable secret vertex.
%
% A path is traced backward until the most recent protected firing has
% been found for every protected transition whose validity clock is finite
% at the secret vertex.  This is the dependency needed to reconstruct the
% validity-clock expressions used by the MILP.  If all selected clearances
% are already guaranteed expired at the secret vertex, the unique backward
% path has zero edges and consists only of the secret vertex.
%
% The routine never truncates silently.  If a safeguard is reached it
% throws an error so that incomplete paths cannot be used as paper results.

if nargin<6, opts=common.default_options(); end
assert(any(GP.vertexIds==secretVertexId), ...
    'Secret vertex %d is not reachable in the pruned V-MSCG.',secretVertexId);
S=GV.vertices(secretVertexId+1);
needed=false(1,G.nT);
needed(policy & S.valClock>0)=true;

if ~any(needed)
    paths=make_path([],secretVertexId,GV);
    return;
end

incoming=cell(1,numel(GV.vertices));
for eid=GP.edgeIds
    e=GV.edges(eid);
    incoming{e.target+1}(end+1)=eid; %#ok<AGROW>
end

theoryDepth=certified_depth_bound(G,GV,GP,needed,opts);
if theoryDepth>opts.maxBackwardDepth
    error(['The certified backward depth bound is %d, above the safety limit ' ...
        'opts.maxBackwardDepth=%d. Increase the safety limit and rerun; no truncated result is returned.'], ...
        theoryDepth,opts.maxBackwardDepth);
end
maxDepth=theoryDepth;
maxPaths=opts.maxBackwardPathsPerSecret;
collected=cell(0,1);

trace(secretVertexId,needed,zeros(1,0),0);
if isempty(collected)
    error(['No complete backward path was found for secret vertex %d. ' ...
        'Increase opts.maxBackwardDepth only after checking Assumptions A1--A2.'], ...
        secretVertexId);
end

% Remove accidental duplicates while preserving deterministic order.
keys=cellfun(@(x) sprintf('%d,',x),collected,'UniformOutput',false);
[~,ia]=unique(keys,'stable');
collected=collected(sort(ia));
paths=repmat(make_path([],secretVertexId,GV),1,numel(collected));
for k=1:numel(collected)
    paths(k)=make_path(collected{k},secretVertexId,GV);
end

    function trace(v,unresolved,revEdges,depth)
        if ~any(unresolved)
            collected{end+1}=fliplr(revEdges); %#ok<AGROW>
            if numel(collected)>maxPaths
                error(['More than %d backward paths were generated for secret vertex %d. ' ...
                    'Increase opts.maxBackwardPathsPerSecret only after inspecting the model.'], ...
                    maxPaths,secretVertexId);
            end
            return;
        end
        if depth>=maxDepth
            error(['Backward tracing reached opts.maxBackwardDepth=%d before resolving all ' ...
                'validity dependencies at secret vertex %d. No truncated result is returned.'], ...
                maxDepth,secretVertexId);
        end
        pred=incoming{v+1};
        if isempty(pred)
            return;
        end
        for eid=pred
            e=GV.edges(eid);
            nextUnresolved=unresolved;
            t=e.transition;
            if nextUnresolved(t) && policy(t) && e.kappa==1
                nextUnresolved(t)=false;
            end
            trace(e.source,nextUnresolved,[revEdges eid],depth+1); %#ok<AGROW>
        end
    end
end

function depth=certified_depth_bound(G,GV,GP,needed,opts)
% Proposition-1-style finite horizon.  B_t bounds firings after the most
% recent reset while the clearance can still be finite.  The backward
% path additionally contains the reset edge itself.
% Force transition-index sets to row vectors.  G.lower is stored as a
% column vector, and MATLAB iterates a FOR loop over columns; without this
% normalization, ``for s=Tplus`` treats the whole column as one iteration.
% The vectorized formula below also guarantees that Q is a scalar.
T0=find(G.lower<=opts.tolerance).';
Tplus=find(G.lower>opts.tolerance).';
if isempty(T0)
    r0=0;
else
    r0=longest_zero_lower_run(G,GV,GP,T0);
end
ids=find(needed);
B=zeros(size(ids));
for k=1:numel(ids)
    t=ids(k); H=G.timeout(t);
    if isempty(Tplus)
        Q=0;
    else
        Q=sum(1 + floor(H./G.lower(Tplus)));
    end
    B(k)=(r0+1)*Q+r0;
end
depth=max(B)+1;
depth=max(depth,1);
end

function r0=longest_zero_lower_run(G,GV,GP,T0)
% Longest path in the zero-lower-bound edge subgraph.  A directed cycle
% means the current graph does not certify revised Assumption A2.
V=GP.vertexIds; nV=numel(V);
loc=-ones(1,numel(GV.vertices)); loc(V+1)=1:nV;
adj=cell(1,nV); indeg=zeros(1,nV);
for eid=GP.edgeIds
    e=GV.edges(eid);
    if ~ismember(e.transition,T0), continue; end
    u=loc(e.source+1); v=loc(e.target+1);
    if u<1 || v<1, continue; end
    adj{u}(end+1)=v; %#ok<AGROW>
    indeg(v)=indeg(v)+1;
end
q=find(indeg==0); head=1; order=zeros(1,nV); nOrder=0;
while head<=numel(q)
    u=q(head); head=head+1; nOrder=nOrder+1; order(nOrder)=u;
    for v=adj{u}
        indeg(v)=indeg(v)-1;
        if indeg(v)==0, q(end+1)=v; end %#ok<AGROW>
    end
end
if nOrder<nV
    error(['The pruned V-MSCG contains a cycle consisting only of transitions ' ...
        'with zero lower firing-time bounds. Revised Assumption A2 is not certified.']);
end
dist=zeros(1,nV);
for kk=1:nOrder
    u=order(kk);
    for v=adj{u}, dist(v)=max(dist(v),dist(u)+1); end
end
r0=max(dist);
end

function P=make_path(edgeIds,secretVertexId,GV)
P.edgeIds=edgeIds;
P.length=numel(edgeIds);
P.secretVertexId=secretVertexId;
if isempty(edgeIds)
    P.vertexIds=secretVertexId;
    P.startVertexId=secretVertexId;
else
    vertices=zeros(1,numel(edgeIds)+1);
    vertices(1)=GV.edges(edgeIds(1)).source;
    for i=1:numel(edgeIds)
        e=GV.edges(edgeIds(i));
        if i>1
            assert(e.source==vertices(i),'Edge sequence is not a path.');
        end
        vertices(i+1)=e.target;
    end
    assert(vertices(end)==secretVertexId,'Backward path does not end at requested secret vertex.');
    P.vertexIds=vertices;
    P.startVertexId=vertices(1);
end
end
