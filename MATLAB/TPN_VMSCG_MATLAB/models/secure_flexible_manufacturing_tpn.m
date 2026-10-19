function G = secure_flexible_manufacturing_tpn(m,par)
%SECURE_FLEXIBLE_MANUFACTURING_TPN Reduced cyclic FMS benchmark.
% The model has 10 places, 10 transitions, one processing route with a
% quality-rework cycle, and two mutually exclusive authorization routes.
% The initial number of workpiece tokens m is the scalability parameter.
% Every firing interval is interpreted as [lower,upper).
if nargin<2, par=struct(); end
assert(isscalar(m) && m>=1 && mod(m,1)==0, ...
    'm must be a positive integer.');

par=value_or(par,'I_reg',[1 3]);
par=value_or(par,'I_in',[1 2]);
par=value_or(par,'I_proc',[1 3]);
par=value_or(par,'I_pass',[1 2]);
par=value_or(par,'I_rework',[1 2]);
par=value_or(par,'I_authA',[1 2]);
par=value_or(par,'I_authB',[1 2]);
par=value_or(par,'I_secA',[1 2]);
par=value_or(par,'I_secB',[1 2]);
par=value_or(par,'I_out',[1 2]);
par=value_or(par,'timeout_reg',6);
par=value_or(par,'timeout_authA',4);
par=value_or(par,'timeout_authB',4);
par=value_or(par,'gamma_reg',1);
par=value_or(par,'gamma_authA',1);
par=value_or(par,'gamma_authB',1);
par=value_or(par,'cost_reg',1);
par=value_or(par,'cost_authA',2);
par=value_or(par,'cost_authB',2);
par=value_or(par,'secretRequirement',1);

G.name=sprintf('Reduced secure flexible-manufacturing TPN FMS(%d)',m);
G.m=m;
G.placeNames={'p_w','p_p','p_v','p_f','q_0','q_1','q_A','q_B','q_s','q_d'};
G.transitionNames={'t_reg','t_in','t_proc','t_pass','t_rework', ...
    't_auth_A','t_auth_B','t_sec_A','t_sec_B','t_out'};
% Labels used in Fig. 1 of the paper. Internal IDs are intentionally kept
% unchanged so that the original graph construction and benchmark remain
% bit-for-bit comparable with v2.4.
G.paperTransitionNames={'t5','t1','t2','t4','t3','t6','t7','t8','t9','t10'};
G.nP=numel(G.placeNames);
G.nT=numel(G.transitionNames);

% Place identifiers.
G.id.pw=1; G.id.pp=2; G.id.pv=3; G.id.pf=4;
G.id.q0=5; G.id.q1=6; G.id.qA=7; G.id.qB=8;
G.id.qs=9; G.id.qd=10;

% Transition identifiers.
G.id.t_reg=1; G.id.t_in=2; G.id.t_proc=3; G.id.t_pass=4;
G.id.t_rework=5; G.id.t_authA=6; G.id.t_authB=7;
G.id.t_secA=8; G.id.t_secB=9; G.id.t_out=10;

G.Pre=zeros(G.nP,G.nT);
G.Post=zeros(G.nP,G.nT);

% Control token: registration enables workpiece admission.
arc(G.id.t_reg,G.id.q0,G.id.q1);

% q_1 is a read/self-loop condition for admitting workpieces.
G.Pre([G.id.pw G.id.q1],G.id.t_in)=1;
G.Post([G.id.pp G.id.q1],G.id.t_in)=1;

% Workpiece processing and the explicit rework cycle p_p -> p_v -> p_p.
arc(G.id.t_proc,G.id.pp,G.id.pv);
arc(G.id.t_pass,G.id.pv,G.id.pf);
arc(G.id.t_rework,G.id.pv,G.id.pp);

% A finished workpiece is tested but not consumed by authorization.
G.Pre([G.id.pf G.id.q1],G.id.t_authA)=1;
G.Post([G.id.pf G.id.qA],G.id.t_authA)=1;
G.Pre([G.id.pf G.id.q1],G.id.t_authB)=1;
G.Post([G.id.pf G.id.qB],G.id.t_authB)=1;
arc(G.id.t_secA,G.id.qA,G.id.qs);
arc(G.id.t_secB,G.id.qB,G.id.qs);
arc(G.id.t_out,G.id.qs,G.id.qd);

G.M0=zeros(G.nP,1);
G.M0(G.id.pw)=m;
G.M0(G.id.q0)=1;

G.lower=zeros(G.nT,1);
G.upper=zeros(G.nT,1);
set_interval(G.id.t_reg,par.I_reg);
set_interval(G.id.t_in,par.I_in);
set_interval(G.id.t_proc,par.I_proc);
set_interval(G.id.t_pass,par.I_pass);
set_interval(G.id.t_rework,par.I_rework);
set_interval(G.id.t_authA,par.I_authA);
set_interval(G.id.t_authB,par.I_authB);
set_interval(G.id.t_secA,par.I_secA);
set_interval(G.id.t_secB,par.I_secB);
set_interval(G.id.t_out,par.I_out);

G.protectable=false(1,G.nT);
G.protectable([G.id.t_reg G.id.t_authA G.id.t_authB])=true;
G.timeout=inf(1,G.nT);
G.gamma=zeros(1,G.nT);
G.cost=zeros(1,G.nT);
G.timeout(G.id.t_reg)=par.timeout_reg;
G.timeout(G.id.t_authA)=par.timeout_authA;
G.timeout(G.id.t_authB)=par.timeout_authB;
G.gamma(G.id.t_reg)=par.gamma_reg;
G.gamma(G.id.t_authA)=par.gamma_authA;
G.gamma(G.id.t_authB)=par.gamma_authB;
G.cost(G.id.t_reg)=par.cost_reg;
G.cost(G.id.t_authA)=par.cost_authA;
G.cost(G.id.t_authB)=par.cost_authB;

% Compact secret predicate: every reachable marking with M(q_s)>=1 is
% secret. This avoids enumerating the workpiece-token distributions.
G.secretPlace=G.id.qs;
G.secretMinimumTokens=1;
G.secretRequirement=par.secretRequirement;

    function arc(t,pIn,pOut)
        G.Pre(pIn,t)=G.Pre(pIn,t)+1;
        G.Post(pOut,t)=G.Post(pOut,t)+1;
    end

    function set_interval(t,I)
        assert(numel(I)==2 && I(1)>=0 && I(1)<I(2), ...
            'Every interval override must be [lower upper].');
        G.lower(t)=I(1);
        G.upper(t)=I(2);
    end
end

function s=value_or(s,name,value)
if ~isfield(s,name), s.(name)=value; end
end
