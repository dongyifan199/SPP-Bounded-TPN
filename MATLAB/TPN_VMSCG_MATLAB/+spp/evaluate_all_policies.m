function result = evaluate_all_policies(G,GV,opts)
%EVALUATE_ALL_POLICIES Prune the complete V-MSCG and solve the optimal SPP.
if nargin<3, opts=common.default_options(); end
if ~isfield(opts,'requireReachableSecret'), opts.requireReachableSecret=true; end
if opts.requireReachableSecret && common.count_secret_vertices(G,GV)==0
    error(['No secret marking is reachable in the complete V-MSCG. ' ...
        'Check the TPN firing intervals before evaluating policies.']);
end

protectableIds=find(G.protectable);
nProtectable=numel(protectableIds);
nPolicies=2^nProtectable;
assert(nPolicies<=opts.maxPolicies, ...
    'The model has %d policies, above maxPolicies=%d.',nPolicies,opts.maxPolicies);

policyIndex=(0:nPolicies-1)';
policyText=strings(nPolicies,1);
policyCost=zeros(nPolicies,1);
numVertices=zeros(nPolicies,1);
numEdges=zeros(nPolicies,1);
numSecretVertices=zeros(nPolicies,1);
numDependencyChecks=zeros(nPolicies,1);
pruneTime=zeros(nPolicies,1);
verifyTime=zeros(nPolicies,1);
timeValid=false(nPolicies,1);

bestCost=inf; bestPolicy=false(1,G.nT); bestIndex=NaN;
bestPruned=[]; bestVerification=[];
searchTimer=tic;

for row=1:nPolicies
    mask=row-1;
    policy=false(1,G.nT);
    for j=1:nProtectable
        policy(protectableIds(j))=bitget(mask,j)>0;
    end
    policyText(row)=string(spp.policy_text(G,policy));
    policyCost(row)=sum(G.cost(policy));

    timer=tic;
    GP=spp.prune_policy(GV,policy);
    pruneTime(row)=toc(timer);

    timer=tic;
    R=spp.verify_policy(G,GV,GP,policy,opts);
    verifyTime(row)=toc(timer);

    numVertices(row)=numel(GP.vertexIds);
    numEdges(row)=numel(GP.edgeIds);
    numSecretVertices(row)=R.numSecretVertices;
    numDependencyChecks(row)=R.numDependencyChecks;
    timeValid(row)=R.timeValid;

    if R.timeValid && policyCost(row)<bestCost
        bestCost=policyCost(row);
        bestPolicy=policy;
        bestIndex=row;
        bestPruned=GP;
        bestVerification=R;
    end
end

totalSearchTime=toc(searchTimer);
summary=table(policyIndex,policyText,policyCost,numVertices,numEdges, ...
    numSecretVertices,numDependencyChecks,pruneTime,verifyTime,timeValid);

result.summary=summary;
result.numPolicies=nPolicies;
result.totalPruneTime=sum(pruneTime);
result.totalVerifyTime=sum(verifyTime);
result.totalSearchTime=totalSearchTime;
result.numTimeValid=nnz(timeValid);
result.totalDependencyChecks=sum(numDependencyChecks);
result.bestPolicy=bestPolicy;
result.hasSolution=isfinite(bestCost);
if result.hasSolution
    result.bestPolicyText=spp.policy_text(G,bestPolicy);
else
    result.bestPolicyText='NO TIME-VALID POLICY';
end
result.bestCost=bestCost;
result.bestIndex=bestIndex;
result.bestPruned=bestPruned;
result.bestVerification=bestVerification;
end
