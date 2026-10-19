function plot_scalability(S,outDir)
%PLOT_SCALABILITY Produce publication-ready comparison figures.
if ~exist(outDir,'dir'), mkdir(outDir); end

f=figure('Visible','off','Color','w','Position',[100 100 760 520]);
plot(S.n,S.MSCGVertices,'-o','LineWidth',1.5,'MarkerSize',6); hold on;
plot(S.n,S.VMSCGVertices,'-s','LineWidth',1.5,'MarkerSize',6);
xlabel('Initial number of workpiece tokens, n'); ylabel('Number of vertices');
legend('MSCG','complete V-MSCG','Location','northwest'); grid on;
export_one(f,fullfile(outDir,'comparison_vertices.png')); close(f);

f=figure('Visible','off','Color','w','Position',[100 100 760 520]);
semilogy(S.n,max(S.MSCGTime,eps),'-o','LineWidth',1.5,'MarkerSize',6); hold on;
semilogy(S.n,max(S.VMSCGTime,eps),'-s','LineWidth',1.5,'MarkerSize',6);
xlabel('Initial number of workpiece tokens, n'); ylabel('Construction time (s)');
legend('MSCG','complete V-MSCG','Location','northwest'); grid on;
export_one(f,fullfile(outDir,'comparison_construction_time.png')); close(f);

f=figure('Visible','off','Color','w','Position',[100 100 760 520]);
semilogy(S.n,max(S.allPruningTime,eps),'-o','LineWidth',1.5); hold on;
semilogy(S.n,max(S.allVerificationTime,eps),'-s','LineWidth',1.5);
semilogy(S.n,max(S.optimalSPPSearchTime,eps),'-^','LineWidth',1.5);
semilogy(S.n,max(S.fullWorkflowTime,eps),'-d','LineWidth',1.5);
xlabel('Initial number of workpiece tokens, n'); ylabel('Time (s)');
legend('all pruning','all verification','optimal SPP search', ...
    'V-MSCG + optimal SPP','Location','northwest'); grid on;
export_one(f,fullfile(outDir,'optimal_spp_time.png')); close(f);

f=figure('Visible','off','Color','w','Position',[100 100 760 520]);
semilogy(S.n,S.numPolicies,'-o','LineWidth',1.5); hold on;
semilogy(S.n,S.sumPrunedVertices,'-s','LineWidth',1.5);
xlabel('Initial number of workpiece tokens, n'); ylabel('Count');
legend('candidate policies','sum of pruned vertices','Location','northwest');
grid on; export_one(f,fullfile(outDir,'policy_space.png')); close(f);
end

function export_one(f,fileName)
try
    exportgraphics(f,fileName,'Resolution',220);
catch
    saveas(f,fileName);
end
end
