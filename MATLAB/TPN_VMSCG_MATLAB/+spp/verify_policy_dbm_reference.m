function R = verify_policy_dbm_reference(G,GV,GP,policy,opts)
%VERIFY_POLICY_DBM_REFERENCE Independent direct-zone reference verifier.
% Retained only for regression tests; paper experiments use verify_policy.
if nargin<5, opts=common.default_options(); end
R.timeValid=true; R.numSecretVertices=0; R.numFeasibilityChecks=0; R.counterexample=[];
hasSecretIndex=isfield(GV,'secretVertexMask');
for vertexId=GP.vertexIds
    S=GV.vertices(vertexId+1);
    if hasSecretIndex
        isSecret=GV.secretVertexMask(vertexId+1);
        requirement=GV.secretRequirementByVertex(vertexId+1);
    else
        [isSecret,requirement]=common.secret_requirement(G,S.M);
    end
    if ~isSecret, continue; end
    R.numSecretVertices=R.numSecretVertices+1;
    active=find(policy & S.valClock>0);
    for mask=0:(2^numel(active)-1)
        valid=false(1,G.nT);
        for j=1:numel(active), valid(active(j))=bitget(mask,j)>0; end
        if sum(G.gamma(valid))>=requirement, continue; end
        D=S.D; feasible=true;
        for t=active
            if valid(t)
                [D,feasible]=dbm.constrain(D,S.valClock(t),1,G.timeout(t),false,opts.tolerance);
            else
                [D,feasible]=dbm.constrain(D,1,S.valClock(t),-G.timeout(t),true,opts.tolerance);
            end
            if ~feasible, break; end
        end
        R.numFeasibilityChecks=R.numFeasibilityChecks+1;
        if feasible
            R.timeValid=false;
            R.counterexample.vertexId=vertexId;
            if opts.stopOnFirstInvalidWitness, return; end
        end
    end
end
end
