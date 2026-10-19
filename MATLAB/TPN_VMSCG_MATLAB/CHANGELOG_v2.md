# v2 changes

## v2.4 reduced cyclic benchmark

- Replaced only the default FMS benchmark with a 10-place, 10-transition
  model containing one processing route, an explicit quality-rework cycle,
  and two mutually exclusive authorization routes.
- Preserved the public model function name and every core MSCG, V-MSCG,
  DBM, pruning, verification, and optimization function from v2.3.
- Changed the default scalability range to `m=1:6`.
- Added exact regression targets for the reduced benchmark: 9/10 MSCG
  vertices/edges and 57/63 V-MSCG vertices/edges for `m=1`.
- Retained the unique optimal policy `{t_auth_A,t_auth_B}` with cost 4 and
  the exact valid-policy indices 7 and 8.
- Updated the Chinese guide with the six-instance reference graph sizes and
  an exact three-file replacement procedure for existing v2.3 copies.

## v2.3 new benchmark and verified implementation optimizations

- Replaced the default experiment with a fixed 15-place, 16-transition
  secure flexible-manufacturing TPN containing two processing routes, a
  quality-rework cycle, and two mutually exclusive authorization routes.
- Parameterized only the initial number of workpiece tokens `m`; the number
  of protectable transitions and candidate policies remains fixed at 3 and 8.
- Added a compact `secretPlace` representation while retaining backward
  compatibility with exact secret-marking lists.
- Added reusable V-MSCG adjacency and secret-vertex indices.
- Avoided redundant DBM closure for already implied constraints and for
  signatures of DBMs maintained in canonical closed form.
- Added conservative fallbacks and regression tests comparing optimized and
  reference signatures/pruning, old graph sizes, and old/new optimal SPPs.
- Updated all run scripts, output names, tables, plots, and Chinese guidance
  from the old access-level parameter `n` to workpiece tokens `m`.

## v2.2 correctness fix

- Corrected the default backward-transition interval from `[1,2)` to
  `[1,3)`.  Under strong semantics, `[1,2)` makes the secret marking
  unreachable for `n>=3` because a fresh authentication plus the next
  upgrade needs at least two time units.
- Added an explicit reachable-secret check before policy enumeration, so an
  unreachable benchmark cannot be reported as a vacuously valid empty
  policy.
- Added descriptive `G_2` and `G_3` regression checks for graph sizes,
  secret reachability, optimal policy, and optimal cost.
- Increased the configurable vertex safeguard to 500000 because the
  corrected `G_8` complete V-MSCG has 270262 vertices.
- Updated the documented target to MATLAB R2024b.
- Kept the requested experiment scope to MSCG versus V-MSCG plus all pruned
  V-MSCGs and optimal SPP; no additional SCG variant is compared.

## v2.1 hotfix

- Fixed the MATLAB parser error in `+common/successors.m` by renaming the
  local variable `persistent` (a reserved MATLAB keyword) to
  `persistentTransitions`.
- Rechecked all MATLAB files for assignments to reserved keywords.
- Kept the model, MSCG/V-MSCG algorithms, SPP parameters, and outputs
  unchanged.

## v2.0

- Added a canonical timed state-class engine for the cyclic access-control family under the stated bounded timing assumptions.
- Added ordinary MSCG construction for direct comparison with V-MSCG.
- Added the parameterized (G_n) model for (n=2,ldots,8).
- Added complete V-MSCG construction with `U/Y/N` policy-selection states.
- Added construction and statistics for every pruned V-MSCG.
- Added exact time-validity verification on reachable secret zones.
- Added exhaustive minimum-cost optimal SPP search and separated timing fields.
- Added CSV, MAT, and PNG exports.
- Added centralized user-editable settings and Chinese instructions.
- Preserved the entire v1 package in `legacy_v1_source.zip`.
