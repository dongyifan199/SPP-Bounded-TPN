function dep = collect_backward_dependencies(G,GV,policy,secretVertexId)
%COLLECT_BACKWARD_DEPENDENCIES Compressed timing dependencies at a secret vertex.
%
% The paper describes these dependencies through finite backward paths.
% This MATLAB implementation stores every finite validity clock explicitly
% in the canonical DBM of each V-MSCG vertex.  Hence the dependency
% information needed at a secret vertex is already summarized by that
% vertex's zone; no predecessor-walk enumeration is necessary.
%
% dep.activeTransitions are the protected transitions whose validity
% clocks are still finite at the secret vertex.  Protected transitions not
% listed here have already been proved expired by the V-MSCG construction.

S = GV.vertices(secretVertexId+1);
active = find(policy & S.valClock>0);
dep.vertexId = secretVertexId;
dep.activeTransitions = active;
dep.clockIndices = S.valClock(active);
dep.zone = S.D;
end
