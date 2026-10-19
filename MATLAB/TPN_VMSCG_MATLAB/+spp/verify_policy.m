function R = verify_policy(G,GV,GP,policy,opts)
%VERIFY_POLICY Fast exact verification using compressed backward dependencies.
%
% The theoretical paper reconstructs timing dependencies by finite backward
% paths.  In this implementation, those dependencies are retained directly
% as validity clocks in the canonical DBM of every V-MSCG vertex.  Therefore
% explicit enumeration of predecessor walks is unnecessary: for each
% reachable secret vertex we extract the finite validity clocks and solve
% the same valid/expired alternatives directly on the stored zone.
%
% The binary variables y_t of Proposition 3 are solved by exact enumeration
% (at most 2^|T_p| combinations; the benchmark has |T_p|=3), while the
% continuous difference constraints are checked by DBM closure.  This is an
% exact specialized solver for the mixed feasibility condition and contains
% no depth/path truncation and no big-M constant.

if nargin<5, opts=common.default_options(); end
R.timeValid=true;
R.numSecretVertices=0;
R.numDependencyChecks=0;
R.counterexample=[];
hasSecretIndex=isfield(GV,'secretVertexMask');

for vertexId=GP.vertexIds
    S=GV.vertices(vertexId+1);
    if hasSecretIndex
        isSecret=GV.secretVertexMask(vertexId+1);
        requirement=GV.secretRequirementByVertex(vertexId+1);
    else
        [isSecret,requirement]=common.secret_requirement(G,S.M);
    end
    if ~isSecret, continue; end

    R.numSecretVertices=R.numSecretVertices+1;
    dep=spp.collect_backward_dependencies(G,GV,policy,vertexId);
    active=dep.activeTransitions;

    % Enumerate the binary validity assignment y_t only for clearances whose
    % clocks are finite.  Clearances already represented by +infinity are
    % fixed to y_t=0 and need no additional constraint.
    for mask=0:(2^numel(active)-1)
        valid=false(1,G.nT);
        for j=1:numel(active)
            valid(active(j))=bitget(mask,j)>0;
        end

        % (b6): only assignments with insufficient accumulated clearance
        % can witness a violation.
        if sum(G.gamma(valid))>=requirement
            continue;
        end

        D=dep.zone;
        feasible=true;
        for t=active
            if valid(t)
                % y_t=1: nu(t) <= te_out(t), closed at the timeout.
                [D,feasible]=dbm.constrain(D,S.valClock(t),1, ...
                    G.timeout(t),false,opts.tolerance);
            else
                % y_t=0: nu(t) > te_out(t), i.e. -nu(t) < -te_out(t).
                [D,feasible]=dbm.constrain(D,1,S.valClock(t), ...
                    -G.timeout(t),true,opts.tolerance);
            end
            if ~feasible, break; end
        end

        R.numDependencyChecks=R.numDependencyChecks+1;
        if feasible
            R.timeValid=false;
            R.counterexample.vertexId=vertexId;
            R.counterexample.validProtectedTransitions=find(valid);
            R.counterexample.requirement=requirement;
            R.counterexample.clearance=sum(G.gamma(valid));
            if opts.stopOnFirstInvalidWitness, return; end
        end
    end
end
end
