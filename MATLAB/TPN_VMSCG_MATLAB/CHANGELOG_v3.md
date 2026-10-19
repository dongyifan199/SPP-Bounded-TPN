# v3.0.1 hotfix

- Fixed `+spp/backward_paths.m` scalar-assignment failure in `certified_depth_bound` when `G.lower` is a column vector.
- Transition-index sets are normalized to row vectors and `Q_t` is now computed by a scalar vectorized sum.
- No model, experiment, MILP formulation, or reported benchmark parameter was changed.

# v3.0 backward-path revision

- Kept the original Fig. 1 benchmark, timing inputs, protectable transitions, MSCG/V-MSCG builders, and policy enumeration.
- Replaced the old direct policy-verification entry point with finite backward-path generation and Proposition-3-style MILPs.
- Every edge traversal has a fresh delay variable, including repeated traversals of the same edge.
- Removed any need for representative-path/cycle-once reasoning in the revised verifier.
- Removed big-M/LA from the revised MILP; strict bounds use the maximized auxiliary epsilon.
- Added a DBM reference verifier only for regression testing.
- Added backward-path and MILP counts to CSV outputs.
- Paper-facing transition labels are t1,...,t10; optimal policy output is expected in the form {t6,t7} if the revised verifier agrees with the v2.4 reference.
