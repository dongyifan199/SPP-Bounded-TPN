function [D, newIndex] = add_zero_clock(D, tol)
%ADD_ZERO_CLOCK Append a new clock and constrain it to zero.
if nargin < 2, tol = 1e-10; end
[D, ok] = dbm.close(D, tol);
assert(ok, 'Cannot extend an infeasible DBM.');
n = size(D.C,1);
newIndex = n + 1;
C = inf(newIndex); C(1:n,1:n) = D.C;
S = false(newIndex); S(1:n,1:n) = D.strict;
D.C = C; D.strict = S;
D.C(newIndex,newIndex) = 0;
% x_new=0: its row/column equal those of the distinguished zero clock.
D.C(newIndex,1:n) = D.C(1,1:n);
D.strict(newIndex,1:n) = D.strict(1,1:n);
D.C(1:n,newIndex) = D.C(1:n,1);
D.strict(1:n,newIndex) = D.strict(1:n,1);
[D, ok] = dbm.close(D, tol);
assert(ok, 'Adding a zero clock unexpectedly made the DBM infeasible.');
end
