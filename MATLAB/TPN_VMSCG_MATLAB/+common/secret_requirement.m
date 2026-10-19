function [isSecret, requirement] = secret_requirement(G, M)
%SECRET_REQUIREMENT Evaluate either a compact place or exact-list secret.
if isfield(G,'secretPlace')
    threshold=1;
    if isfield(G,'secretMinimumTokens'), threshold=G.secretMinimumTokens; end
    isSecret=M(G.secretPlace)>=threshold;
    if isSecret, requirement=G.secretRequirement; else, requirement=0; end
    return;
end

isSecret = false;
requirement = 0;
for k = 1:size(G.secretMarkings,2)
    if isequal(M(:),G.secretMarkings(:,k))
        isSecret = true;
        requirement = G.secretRequirement(k);
        return;
    end
end
end
