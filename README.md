# Secret Protection in Bounded Time Petri Nets Under the Indicator Semantics

This repository provides the supplementary material and MATLAB implementation associated with the paper:

**Y. Dong, J. Večeřa, T. Masopust, and Z. Li,  
"Secret Protection in Bounded Time Petri Nets Under the Indicator Semantics."**

The repository is intended to provide additional technical details and computational resources for reproducing the results reported in the paper.

## Repository Contents

The repository contains the following materials:

- **`Supplementary_Material.pdf`**  
  Supplementary material for the paper. It includes:
  - the computational complexity analysis of the proposed method;
  - the soundness and completeness proof of Algorithm 1;
  - the parameterized case study and additional computational results.

- **`MATLAB/`**  
  MATLAB source files used to implement the proposed method and perform the computational experiments reported in the paper.

## MATLAB Implementation

The MATLAB implementation includes the procedures required for the computational study, including the construction and analysis of the state-class graphs, evaluation of candidate protection policies, backward-path computation, and MILP-based time-validity verification.

The mixed-integer linear programs (MILPs) are solved using `intlinprog` from the MATLAB Optimization Toolbox.

### Requirements

- MATLAB
- MATLAB Optimization Toolbox

All MATLAB source files required for reproducing the reported computational results are provided in the `MATLAB/` directory.

## Supplementary Material

The file `Supplementary_Material.pdf` provides additional theoretical and numerical results that complement the main paper.

In particular, it contains:

1. a detailed computational complexity analysis of the complete solution procedure;
2. a proof of the soundness and completeness of Algorithm 1;
3. a parameterized case study for evaluating the scalability of the proposed approach.

## Reproducibility

The MATLAB files in this repository are provided to facilitate reproduction of the computational results presented in the paper.

The parameterized benchmark considers instances with the scale parameter ranging from \(n=1\) to \(n=10\). For each instance, the MATLAB implementation constructs the MSCG and the complete V-MSCG, evaluates the candidate protection policies, computes the relevant backward paths, and performs MILP-based time-validity verification.


