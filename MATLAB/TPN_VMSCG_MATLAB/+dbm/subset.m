function D2 = subset(D, indices, tol)
%SUBSET Exact existential projection of a closed DBM onto selected clocks.
% indices must include the zero-clock index 1.
if nargin < 3, tol = 1e-10; end
[D, ok] = dbm.close(D, tol);
assert(ok, 'Cannot project an infeasible DBM.');
D2.C = D.C(indices,indices);
D2.strict = D.strict(indices,indices);
[D2, ok] = dbm.close(D2, tol);
assert(ok, 'Projection unexpectedly produced an infeasible DBM.');
end
