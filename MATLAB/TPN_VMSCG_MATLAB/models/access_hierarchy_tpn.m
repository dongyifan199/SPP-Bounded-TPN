function G = access_hierarchy_tpn(n,par)
%ACCESS_HIERARCHY_TPN Parameterized G_n and SPP instance, n=2,...
% One additional access level adds one place, one forward transition, and
% one backward transition.  All firing intervals are [lower,upper).
if nargin<2, par=struct(); end
assert(isscalar(n) && n>=2 && mod(n,1)==0,'n must be an integer >= 2.');

par=value_or(par,'I_auth',[1 2]);
par=value_or(par,'I_expire',[2 3]);
par=value_or(par,'I_login',[1 2]);
par=value_or(par,'I_upgrade',[1 3]);
% The open upper bound must exceed the minimum time needed to acquire a
% fresh credential and fire the next upgrade.  With [1,2), G_n for n>=3
% cannot reach p_n under strong semantics.
par=value_or(par,'I_backward',[1 3]);
par=value_or(par,'I_secret',[1 2]);
par=value_or(par,'I_return',[1 2]);
par=value_or(par,'timeout_login',6);
par=value_or(par,'timeout_upgrade',4);
par=value_or(par,'timeout_secret',2);
par=value_or(par,'gamma_login',1);
par=value_or(par,'gamma_upgrade',1);
par=value_or(par,'gamma_secret',1);
par=value_or(par,'cost_login',1);
par=value_or(par,'cost_upgrade',1);
par=value_or(par,'cost_secret',2);
par=value_or(par,'secretRequirement',2);

G.name=sprintf('Hierarchical access-control TPN G_%d',n);
G.n=n;
G.placeNames=[{'p0'},arrayfun(@(i)sprintf('p%d',i),1:n, ...
    'UniformOutput',false),{'ps','q0','q1'}];
G.nP=n+4;

names={'ta','te','t0'};
plusIds=zeros(1,n-1); minusIds=zeros(1,n-1);
for i=1:n-1
    plusIds(i)=numel(names)+1; names{end+1}=sprintf('t%d_plus',i); %#ok<AGROW>
    minusIds(i)=numel(names)+1; names{end+1}=sprintf('t%d_minus',i); %#ok<AGROW>
end
ts=numel(names)+1; names{end+1}='ts';
tr=numel(names)+1; names{end+1}='tr';
G.transitionNames=names;
G.nT=numel(names);
G.id=struct('ta',1,'te',2,'t0',3,'plus',plusIds, ...
    'minus',minusIds,'ts',ts,'tr',tr);

G.Pre=zeros(G.nP,G.nT); G.Post=zeros(G.nP,G.nT);
p0=1; ps=n+2; q0=n+3; q1=n+4;
G.Pre(q0,G.id.ta)=1; G.Post(q1,G.id.ta)=1;
G.Pre(q1,G.id.te)=1; G.Post(q0,G.id.te)=1;
G.Pre([p0 q1],G.id.t0)=1; G.Post([2 q0],G.id.t0)=1;
for i=1:n-1
    pi=i+1; pnext=i+2;
    G.Pre([pi q1],plusIds(i))=1;
    G.Post([pnext q0],plusIds(i))=1;
    G.Pre(pnext,minusIds(i))=1;
    G.Post(pi,minusIds(i))=1;
end
G.Pre(n+1,ts)=1; G.Post(ps,ts)=1;
G.Pre(ps,tr)=1; G.Post(p0,tr)=1;

G.M0=zeros(G.nP,1); G.M0(p0)=1; G.M0(q0)=1;
G.lower=zeros(G.nT,1); G.upper=zeros(G.nT,1);
set_interval(G.id.ta,par.I_auth);
set_interval(G.id.te,par.I_expire);
set_interval(G.id.t0,par.I_login);
for i=1:n-1
    set_interval(plusIds(i),par.I_upgrade);
    set_interval(minusIds(i),par.I_backward);
end
set_interval(ts,par.I_secret); set_interval(tr,par.I_return);

G.protectable=false(1,G.nT);
G.protectable([G.id.t0 plusIds ts])=true;
G.timeout=inf(1,G.nT); G.gamma=zeros(1,G.nT); G.cost=zeros(1,G.nT);
G.timeout(G.id.t0)=par.timeout_login;
G.timeout(plusIds)=par.timeout_upgrade;
G.timeout(ts)=par.timeout_secret;
G.gamma(G.id.t0)=par.gamma_login;
G.gamma(plusIds)=par.gamma_upgrade;
G.gamma(ts)=par.gamma_secret;
G.cost(G.id.t0)=par.cost_login;
G.cost(plusIds)=par.cost_upgrade;
G.cost(ts)=par.cost_secret;

% Secret marking columns ps+q0 and ps+q1.
G.secretMarkings=zeros(G.nP,2);
G.secretMarkings(ps,:)=1;
G.secretMarkings(q0,1)=1; G.secretMarkings(q1,2)=1;
G.secretRequirement=[par.secretRequirement par.secretRequirement];

    function set_interval(t,I)
        assert(numel(I)==2 && I(1)>=0 && I(1)<I(2), ...
            'Every interval override must be [lower upper].');
        G.lower(t)=I(1); G.upper(t)=I(2);
    end
end

function s=value_or(s,name,value)
if ~isfield(s,name), s.(name)=value; end
end
