function txt = policy_text(G,policy)
%POLICY_TEXT Human-readable set of protected transitions.
if isfield(G,'paperTransitionNames')
    names=G.paperTransitionNames(policy);
else
    names=G.transitionNames(policy);
end
if isempty(names), txt='{}'; else, txt=['{' strjoin(names,',') '}']; end
end
