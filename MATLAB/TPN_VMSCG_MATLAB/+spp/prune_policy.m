function GP = prune_policy(GV,policy)
%PRUNE_POLICY Retain reachable V-MSCG branches consistent with one policy.
G=GV.model;
assert(GV.withValidity,'Policy pruning requires a V-MSCG.');
assert(islogical(policy) && numel(policy)==G.nT, ...
    'policy must be a logical vector of length nT.');
assert(~any(policy & ~G.protectable), ...
    'A policy may contain only protectable transitions.');

% v2.3 graphs contain a reusable adjacency index.  The fallback preserves
% compatibility with V-MSCGs loaded from v2.2 MAT files.
if isfield(GV,'outgoingEdgeIds')
    outgoing=GV.outgoingEdgeIds;
else
    outgoing=cell(1,numel(GV.vertices));
    for edgeId=1:numel(GV.edges)
        outgoing{GV.edges(edgeId).source+1}(end+1)=edgeId;
    end
end
hasNumericIndex=isfield(GV,'edgeTransition');

reachable=false(1,numel(GV.vertices));
reachable(1)=true;
keep=false(1,numel(GV.edges));
queue=zeros(1,numel(GV.vertices));
queue(1)=0; head=1; tail=1;
while head<=tail
    v=queue(head); head=head+1;
    for edgeId=outgoing{v+1}
        if hasNumericIndex
            t=GV.edgeTransition(edgeId);
            kappa=GV.edgeKappa(edgeId);
            w=GV.edgeTarget(edgeId);
        else
            e=GV.edges(edgeId);
            t=e.transition; kappa=e.kappa; w=e.target;
        end
        eligible=(~G.protectable(t) && kappa==0) || ...
            (G.protectable(t) && policy(t) && kappa==1) || ...
            (G.protectable(t) && ~policy(t) && kappa==2);
        if ~eligible, continue; end
        keep(edgeId)=true;
        if ~reachable(w+1)
            reachable(w+1)=true;
            tail=tail+1; queue(tail)=w;
        end
    end
end

GP.policy=policy;
GP.vertexIds=find(reachable)-1;
GP.edgeIds=find(keep);
GP.initialVertex=0;
end
