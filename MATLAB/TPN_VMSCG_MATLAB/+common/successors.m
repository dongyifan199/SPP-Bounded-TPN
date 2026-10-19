function [branches, kappas, feasible] = successors(G, S, fired, withValidity, opts)
%SUCCESSORS Canonical timed state-class evolution under strong semantics.
% Nodes represent clock zones immediately after a discrete firing.  To fire
% transition fired, all clocks first advance by one common delay; the open
% latest-firing bounds of all enabled transitions are enforced.

assert(S.enabled(fired),'Transition %d is not enabled.',fired);
D = dbm.time_elapse(S.D);

% Strong semantics: every enabled transition remains strictly below its
% open upper endpoint while the selected transition reaches its lower bound.
for t = find(S.enabled)
    if isfinite(G.upper(t))
        [D, feasible] = dbm.constrain(D,S.ageClock(t),1, ...
            G.upper(t),true,opts.tolerance);
        if ~feasible, branches=[]; kappas=[]; return; end
    end
end
[D, feasible] = dbm.constrain(D,1,S.ageClock(fired), ...
    -G.lower(fired),false,opts.tolerance);
if ~feasible, branches=[]; kappas=[]; return; end

Mminus = S.M - G.Pre(:,fired);
M2 = Mminus + G.Post(:,fired);
enabled2 = common.enabled_transitions(G,M2);
newly = false(1,G.nT);
for t = find(enabled2)
    newly(t) = (t==fired) || ...
        (~all(Mminus>=G.Pre(:,t)) && all(M2>=G.Pre(:,t)));
end

% Project away disabled/newly-enabled transition clocks.  Validity clocks
% are retained because they record elapsed time since a protected firing.
persistentTransitions = find(enabled2 & ~newly);
activeVal = find(S.valClock>0);
keep = 1;
for t = persistentTransitions, keep(end+1)=S.ageClock(t); end %#ok<AGROW>
for t = activeVal, keep(end+1)=S.valClock(t); end %#ok<AGROW>
D2 = dbm.subset(D,keep,opts.tolerance);

B = S;
B.M = M2;
B.enabled = enabled2;
B.D = D2;
B.ageClock = zeros(1,G.nT);
B.valClock = zeros(1,G.nT);
nextIndex = 2;
for t = persistentTransitions
    B.ageClock(t) = nextIndex;
    nextIndex = nextIndex + 1;
end
for t = activeVal
    B.valClock(t) = nextIndex;
    nextIndex = nextIndex + 1;
end

for t = find(enabled2 & newly)
    [B.D,idx] = dbm.add_zero_clock(B.D,opts.tolerance);
    B.ageClock(t) = idx;
end
B = canonical_order(B,opts);

if ~withValidity
    branches = B;
    kappas = 0;
elseif ~G.protectable(fired)
    branches = drop_expired(G,B,opts);
    kappas = 0;
elseif S.rho(fired)=='U'
    yes = set_yes(B,fired,opts);
    no = B; no.rho(fired)='N';
    branches = [drop_expired(G,yes,opts),drop_expired(G,no,opts)];
    kappas = [1 2];
elseif S.rho(fired)=='Y'
    branches = drop_expired(G,set_yes(B,fired,opts),opts);
    kappas = 1;
else
    branches = drop_expired(G,B,opts);
    kappas = 2;
end

if withValidity
    for k = 1:numel(branches)
        branches(k) = canonical_order(branches(k),opts);
    end
end
feasible = true;
end

function S = set_yes(S,t,opts)
S.rho(t) = 'Y';
if S.valClock(t)==0
    [S.D,S.valClock(t)] = dbm.add_zero_clock(S.D,opts.tolerance);
else
    S.D = dbm.reset_zero(S.D,S.valClock(t),opts.tolerance);
end
end

function S = drop_expired(G,S,opts)
drop = false(1,G.nT);
for t = find(S.valClock>0)
    [lb,isStrict] = dbm.lower_bound(S.D,S.valClock(t));
    drop(t) = lb > G.timeout(t)+opts.tolerance || ...
        (abs(lb-G.timeout(t))<=opts.tolerance && isStrict);
end
if ~any(drop), return; end
% Build the keep list explicitly in semantic order.
keep = 1;
for t = find(S.ageClock>0), keep(end+1)=S.ageClock(t); end %#ok<AGROW>
for t = find(S.valClock>0 & ~drop), keep(end+1)=S.valClock(t); end %#ok<AGROW>
S.D = dbm.subset(S.D,keep,opts.tolerance);
S.valClock(drop)=0;
S = remap_after_semantic_subset(S);
end

function S = canonical_order(S,opts)
order = 1;
for t = find(S.ageClock>0), order(end+1)=S.ageClock(t); end %#ok<AGROW>
for t = find(S.valClock>0), order(end+1)=S.valClock(t); end %#ok<AGROW>
S.D = dbm.subset(S.D,order,opts.tolerance);
S = remap_after_semantic_subset(S);
end

function S = remap_after_semantic_subset(S)
ageIds = find(S.ageClock>0);
valIds = find(S.valClock>0);
S.ageClock(:)=0; S.valClock(:)=0;
q=2;
for t=ageIds, S.ageClock(t)=q; q=q+1; end
for t=valIds, S.valClock(t)=q; q=q+1; end
end
