%% RUN_SINGLE_INSTANCE  One-row version of the paper table.
clear; clc;
root=fileparts(mfilename('fullpath'));
addpath(root,fullfile(root,'models'));
cfg=user_settings(); opts=cfg.options; n=cfg.singleN;
G=secure_flexible_manufacturing_tpn(n,cfg.model);

timer=tic; GM=mscg.build(G,opts); tM=toc(timer);
timer=tic; GV=vmscg.build(G,opts); tV=toc(timer);
SPP=spp.evaluate_all_policies(G,GV,opts);
tS=SPP.totalSearchTime; tT=tV+tS;
sumZp=sum(SPP.summary.numVertices);

fprintf(' n | |Z_MSCG| | t_MSCG(s) |   |Z|   | t_V-MSCG(s) | sum|Z_p| | t_SPP(s) | t_total(s) | T_pl*       | C*\n');
fprintf('---+----------+-----------+---------+-------------+----------+----------+------------+-------------+---\n');
fprintf('%2d | %8d | %9.3f | %7d | %11.3f | %8d | %8.3f | %10.3f | %-11s | %g\n', ...
    n,numel(GM.vertices),tM,numel(GV.vertices),tV,sumZp,tS,tT,SPP.bestPolicyText,SPP.bestCost);
