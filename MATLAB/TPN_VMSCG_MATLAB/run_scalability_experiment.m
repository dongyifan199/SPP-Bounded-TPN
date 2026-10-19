%% RUN_SCALABILITY_EXPERIMENT  Table-only scalability experiment for n=1:10.
clear; clc;
root=fileparts(mfilename('fullpath'));
addpath(root,fullfile(root,'models'));
cfg=user_settings(); opts=cfg.options; nValues=cfg.nValues(:);
outDir=fullfile(root,cfg.outputFolder,'scalability');
if ~exist(outDir,'dir'), mkdir(outDir); end

N=numel(nValues);
MSCGVertices=zeros(N,1); MSCGTime=zeros(N,1);
VMSCGVertices=zeros(N,1); VMSCGTime=zeros(N,1);
sumPrunedVertices=zeros(N,1); tSPP=zeros(N,1); tTotal=zeros(N,1);
optimalPolicy=strings(N,1); optimalCost=zeros(N,1);

% Only the columns used in the paper table are printed.
fprintf(' n | |Z_MSCG| | t_MSCG(s) |   |Z|   | t_V-MSCG(s) | sum|Z_p| | t_SPP(s) | t_total(s) | T_pl*       | C*\n');
fprintf('---+----------+-----------+---------+-------------+----------+----------+------------+-------------+---\n');

for row=1:N
    n=nValues(row);
    G=secure_flexible_manufacturing_tpn(n,cfg.model);
    repeats=max(1,round(cfg.timingRepeats));
    tM=zeros(repeats,1); tV=zeros(repeats,1); tSearch=zeros(repeats,1);
    graphSizes=zeros(repeats,2);

    for rep=1:repeats
        timer=tic; GM=mscg.build(G,opts); tM(rep)=toc(timer);
        timer=tic; GV=vmscg.build(G,opts); tV(rep)=toc(timer);
        SPP=spp.evaluate_all_policies(G,GV,opts);
        tSearch(rep)=SPP.totalSearchTime;
        graphSizes(rep,:)=[numel(GM.vertices),numel(GV.vertices)];
    end

    assert(all(all(graphSizes==graphSizes(1,:))), ...
        'Repeated runs produced inconsistent graph sizes.');

    MSCGVertices(row)=numel(GM.vertices);
    MSCGTime(row)=median(tM);
    VMSCGVertices(row)=numel(GV.vertices);
    VMSCGTime(row)=median(tV);
    sumPrunedVertices(row)=sum(SPP.summary.numVertices);
    tSPP(row)=median(tSearch);
    tTotal(row)=VMSCGTime(row)+tSPP(row);
    optimalPolicy(row)=string(SPP.bestPolicyText);
    optimalCost(row)=SPP.bestCost;

    fprintf('%2d | %8d | %9.3f | %7d | %11.3f | %8d | %8.3f | %10.3f | %-11s | %g\n', ...
        n,MSCGVertices(row),MSCGTime(row),VMSCGVertices(row),VMSCGTime(row), ...
        sumPrunedVertices(row),tSPP(row),tTotal(row),char(optimalPolicy(row)),optimalCost(row));

    % Detailed policy data are saved silently for checking/reproducibility.
    writetable(SPP.summary,fullfile(outDir,sprintf('all_policies_n%d.csv',n)));

    paperTable=table(nValues(1:row),MSCGVertices(1:row),MSCGTime(1:row), ...
        VMSCGVertices(1:row),VMSCGTime(1:row),sumPrunedVertices(1:row), ...
        tSPP(1:row),tTotal(1:row),optimalPolicy(1:row),optimalCost(1:row), ...
        'VariableNames',{'n','Z_MSCG','t_MSCG','Z','t_V_MSCG','sum_Zp', ...
        't_SPP','t_total','T_pl_star','C_star'});
    writetable(paperTable,fullfile(outDir,'paper_table.csv'));
end

summary=paperTable; %#ok<NASGU>
save(fullfile(outDir,'scalability_workspace.mat'),'summary','cfg');
