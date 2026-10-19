# TPN / V-MSCG MATLAB v3.1.0-fast-backward

## 直接运行
在 MATLAB 中把当前文件夹切换到本工程根目录，然后运行：

```matlab
run_scalability_experiment
```

屏幕只打印论文表格中的 10 列：
`n, |Z_MSCG|, t_MSCG, |Z|, t_V-MSCG, sum|Z_p|, t_SPP, t_total, T_pl*, C*`。

结果同时静默保存到：
`output/scalability/paper_table.csv`。

单个 n 可运行：

```matlab
run_single_instance
```

## 本版为什么比 v3.0.x 快
v3.0.x 把 backward path 错误实现成了大量 predecessor walk 的显式枚举，循环存在时会产生组合爆炸。

本版不再枚举这些 predecessor walks。当前 MATLAB 图实现把每个有限 validity clock 作为 V-MSCG 顶点 DBM 中的显式时钟保存，因此到达 secret vertex 时，论文 backward-path 分析所需要的 timing dependency 已经被该顶点的 canonical zone 压缩保存。本版直接从 secret vertex 提取这些有限 validity clocks，并对 Proposition 3 中的 valid/expired 二元选择进行精确枚举；连续 timing constraints 用 DBM closure 精确检查。

这不是人为截断：没有 max depth，也没有 max path number。对于本 benchmark，|T_p|=3，因此每个 secret vertex 最多只有 2^3=8 个二元 validity assignments。

## 输入保持不变
Fig. 1 的 10-place / 10-transition 参数化 TPN、n=1:10、T_p={t5,t6,t7}、timeout/gamma/cost 均保持原设置不变。
