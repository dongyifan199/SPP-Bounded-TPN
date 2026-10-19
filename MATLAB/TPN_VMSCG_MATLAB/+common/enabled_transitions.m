function enabled = enabled_transitions(G, M)
%ENABLED_TRANSITIONS Logical row vector for En(M).
enabled = all(M(:) >= G.Pre, 1);
end
