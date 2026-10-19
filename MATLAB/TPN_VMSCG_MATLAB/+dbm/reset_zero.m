function D = reset_zero(D, index, tol)
%RESET_ZERO Reset an existing clock to zero.
if nargin < 3, tol = 1e-10; end
[D, ok] = dbm.close(D, tol);
assert(ok, 'Cannot reset a clock in an infeasible DBM.');
n = size(D.C,1);
D.C(index,1:n) = D.C(1,1:n);
D.strict(index,1:n) = D.strict(1,1:n);
D.C(1:n,index) = D.C(1:n,1);
D.strict(1:n,index) = D.strict(1:n,1);
D.C(index,index) = 0;
D.strict(index,index) = false;
[D, ok] = dbm.close(D, tol);
assert(ok, 'Clock reset unexpectedly made the DBM infeasible.');
end
