function run_all_tests()
%RUN_ALL_TESTS Lightweight regression tests for v3.1 fast verifier.
root=fileparts(fileparts(mfilename('fullpath')));
addpath(root,fullfile(root,'models'));
cfg=user_settings(); opts=cfg.options;

for n=[1 2]
    G=secure_flexible_manufacturing_tpn(n,cfg.model);
    GV=vmscg.build(G,opts);
    ids=find(G.protectable);
    for mask=0:(2^numel(ids)-1)
        policy=false(1,G.nT);
        for j=1:numel(ids), policy(ids(j))=bitget(mask,j)>0; end
        GP=spp.prune_policy(GV,policy);
        A=spp.verify_policy(G,GV,GP,policy,opts);
        B=spp.verify_policy_dbm_reference(G,GV,GP,policy,opts);
        assert(A.timeValid==B.timeValid, ...
            'Fast verifier/reference mismatch for n=%d, policy=%s.', ...
            n,spp.policy_text(G,policy));
    end
end
fprintf('All v3.1 regression tests passed.\n');
end
