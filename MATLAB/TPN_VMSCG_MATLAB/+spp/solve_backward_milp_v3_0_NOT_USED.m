function R = solve_backward_milp(G,GV,policy,path,requirement,opts)
%SOLVE_BACKWARD_MILP Proposition-3-style MILP for one backward path.
%
% Each traversal has a fresh delay variable delta_i.  The DBM at the
% first vertex summarizes the already-reachable prefix.  From that source
% class the transition sequence of the backward path is unfolded with
% fresh delays.  Right-open timing bounds and clearance expiration are
% encoded with the common auxiliary variable epsilon, 0<=epsilon<=1.
%
% The function requires Optimization Toolbox (intlinprog).

if nargin<6, opts=common.default_options(); end
if exist('intlinprog','file')~=2
    error(['Optimization Toolbox is required: intlinprog was not found. ' ...
        'Install/enable Optimization Toolbox and rerun.']);
end

policyIds=find(policy);
assert(all(abs(G.gamma(policyIds)-round(G.gamma(policyIds)))<=opts.tolerance), ...
    'The revised (b6) formulation requires integer clearance values gamma(t).');
assert(abs(requirement-round(requirement))<=opts.tolerance, ...
    'The revised (b6) formulation requires an integer secret requirement.');
secretId=path.secretVertexId;
Ssecret=GV.vertices(secretId+1);

% A zero-edge backward path contains no timing dependency.  All selected
% clearances are guaranteed expired at the secret vertex by construction.
if isempty(path.edgeIds)
    clearance=0;
    R.feasibleViolation=(clearance < requirement);
    R.exitflag=double(R.feasibleViolation);
    R.epsilonStar=double(R.feasibleViolation);
    R.solution=[];
    R.numContinuous=1; % epsilon only conceptually
    R.numBinary=numel(policyIds);
    R.numConstraints=1;
    R.message='zero-edge backward path';
    return;
end

startId=path.startVertexId;
S0=GV.vertices(startId+1);
nSource=size(S0.D.C,1)-1;
nDelay=numel(path.edgeIds);
nY=numel(policyIds);
idxSource=1:nSource;
idxDelay=nSource+(1:nDelay);
idxY=nSource+nDelay+(1:nY);
idxEps=nSource+nDelay+nY+1;
nVar=idxEps;

% Variable bounds.  DBM constraints impose the source-zone bounds.
lb=-inf(nVar,1); ub=inf(nVar,1);
if nSource>0, lb(idxSource)=0; end
lb(idxDelay)=0;
lb(idxY)=0; ub(idxY)=1;
lb(idxEps)=0; ub(idxEps)=1;
intcon=idxY;

A=zeros(0,nVar); b=zeros(0,1);
Aeq=zeros(0,nVar); beq=zeros(0,1);

% Source DBM: x_i-x_j <= c; strict constraints become +epsilon <= c.
D=S0.D;
for i=1:size(D.C,1)
    for j=1:size(D.C,2)
        c=D.C(i,j);
        if isinf(c) || (i==j && abs(c)<=opts.tolerance && ~D.strict(i,j))
            continue;
        end
        row=zeros(1,nVar);
        if i>1, row(idxSource(i-1))=row(idxSource(i-1))+1; end
        if j>1, row(idxSource(j-1))=row(idxSource(j-1))-1; end
        if D.strict(i,j), row(idxEps)=row(idxEps)+1; end
        [A,b]=append_ineq(A,b,row,c); %#ok<AGROW>
    end
end

% Affine age/validity expressions in the MILP variables.
age=cell(1,G.nT);
for t=find(S0.enabled)
    q=S0.ageClock(t);
    assert(q>1,'Enabled transition lacks an age clock.');
    row=zeros(1,nVar); row(idxSource(q-1))=1; age{t}=row;
end
val=cell(1,G.nT);
expired=true(1,G.nT);
for t=policyIds
    if S0.valClock(t)>0
        q=S0.valClock(t);
        row=zeros(1,nVar); row(idxSource(q-1))=1;
        val{t}=row; expired(t)=false;
    end
end

M=S0.M;
currentVertex=startId;
for k=1:nDelay
    eid=path.edgeIds(k); e=GV.edges(eid);
    assert(e.source==currentVertex,'Backward-path edge sequence is inconsistent.');
    fired=e.transition;
    enabled=common.enabled_transitions(G,M);
    assert(enabled(fired),'Path transition is not enabled in reconstructed marking.');
    d=idxDelay(k);

    % (b2): all enabled transitions remain below their right-open upper bound.
    for t=find(enabled)
        if isfinite(G.upper(t))
            row=age{t}; row(d)=row(d)+1; row(idxEps)=row(idxEps)+1;
            [A,b]=append_ineq(A,b,row,G.upper(t)); %#ok<AGROW>
        end
    end
    % (b1): the selected transition reaches its closed lower bound.
    row=-(age{fired}); row(d)=row(d)-1;
    [A,b]=append_ineq(A,b,row,-G.lower(fired)); %#ok<AGROW>

    % Time elapse for finite validity clocks before the firing.
    for t=policyIds
        if ~expired(t)
            val{t}(d)=val{t}(d)+1;
        end
    end

    Mminus=M-G.Pre(:,fired);
    M2=Mminus+G.Post(:,fired);
    enabled2=common.enabled_transitions(G,M2);
    newly=false(1,G.nT);
    for t=find(enabled2)
        newly(t)=(t==fired) || ...
            (~all(Mminus>=G.Pre(:,t)) && all(M2>=G.Pre(:,t)));
    end

    age2=cell(1,G.nT);
    for t=find(enabled2)
        if newly(t)
            age2{t}=zeros(1,nVar);
        else
            row=age{t}; row(d)=row(d)+1; age2{t}=row;
        end
    end
    age=age2;

    % A protected occurrence resets the corresponding validity clock.
    if policy(fired) && e.kappa==1
        val{fired}=zeros(1,nVar);
        expired(fired)=false;
    end

    % If the retained target vertex guarantees expiration, use +infinity
    % semantics from this point onward.  A later protected firing can reset it.
    Starget=GV.vertices(e.target+1);
    for t=policyIds
        if Starget.valClock(t)==0
            val{t}=[]; expired(t)=true;
        end
    end

    M=M2;
    currentVertex=e.target;
end
assert(currentVertex==secretId,'Reconstructed path does not reach the secret vertex.');
assert(isequal(M,Ssecret.M),'Reconstructed terminal marking disagrees with V-MSCG vertex.');

% Binary clearance variables and timeout constraints (b3)--(b5).
for j=1:nY
    t=policyIds(j); y=idxY(j);
    if Ssecret.valClock(t)==0
        ub(y)=0; % (b5): guaranteed expired => y_t=0.
    else
        if expired(t) || isempty(val{t})
            error(['Internal backward-path inconsistency for transition %s at secret vertex %d: ' ...
                'the terminal validity clock is finite but its reset dependency was not reconstructed.'], ...
                display_name(G,t),secretId);
        end
        % (b4): nu - timeout >= epsilon - (timeout+1)*y.
        row=-val{t};
        row(idxEps)=row(idxEps)+1;
        row(y)=row(y)-(G.timeout(t)+1);
        [A,b]=append_ineq(A,b,row,-G.timeout(t)); %#ok<AGROW>
    end
end

% (b6): modeled accumulated valid clearance is below the requirement.
row=zeros(1,nVar);
for j=1:nY
    row(idxY(j))=G.gamma(policyIds(j));
end
[A,b]=append_ineq(A,b,row,requirement-1);

% Max epsilon <=> min -epsilon.
f=zeros(nVar,1); f(idxEps)=-1;
options=optimoptions('intlinprog','Display','off');
[x,~,exitflag,output]=intlinprog(f,intcon,A,b,Aeq,beq,lb,ub,options); %#ok<ASGLU>
if exitflag>0 && ~isempty(x)
    epsStar=x(idxEps);
else
    epsStar=NaN;
end
R.exitflag=exitflag;
R.epsilonStar=epsStar;
R.feasibleViolation=(exitflag>0 && epsStar>opts.milpEpsilonTolerance);
R.solution=x;
R.numContinuous=nSource+nDelay+1;
R.numBinary=nY;
R.numConstraints=size(A,1)+size(Aeq,1);
if isfield(output,'message'), R.message=output.message; else, R.message=''; end
end

function [A,b]=append_ineq(A,b,row,rhs)
A(end+1,:)=row; %#ok<AGROW>
b(end+1,1)=rhs; %#ok<AGROW>
end

function name=display_name(G,t)
if isfield(G,'paperTransitionNames')
    name=G.paperTransitionNames{t};
else
    name=G.transitionNames{t};
end
end
