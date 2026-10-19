function S = initial_state(G, withValidity, opts)
%INITIAL_STATE Initial canonical state class for MSCG or V-MSCG.
S.M = G.M0(:);
S.enabled = common.enabled_transitions(G,S.M);
S.ageClock = zeros(1,G.nT);
S.valClock = zeros(1,G.nT);
enabledIds = find(S.enabled);
S.D = dbm.zero_clocks(numel(enabledIds),opts.tolerance);
for k = 1:numel(enabledIds)
    S.ageClock(enabledIds(k)) = k + 1;
end
S.rho = repmat('-',1,G.nT);
if withValidity
    S.rho(G.protectable) = 'U';
end
S.id = 0;
end
