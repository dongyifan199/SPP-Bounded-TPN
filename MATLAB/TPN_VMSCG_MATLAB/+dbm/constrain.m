function [D, feasible] = constrain(D, i, j, bound, isStrict, tol)
%CONSTRAIN Intersect a DBM with x_i-x_j <= bound (or < when strict).
if nargin < 6, tol = 1e-10; end
old = D.C(i,j); oldStrict = D.strict(i,j);
isTighter = bound < old - tol || ...
    (abs(bound-old) <= tol && isStrict && ~oldStrict);
% If the canonical DBM already implies this constraint, the intersection
% changes nothing and another O(n^3) closure is unnecessary.
if ~isTighter
    feasible = true;
    return;
end
D.C(i,j) = bound;
D.strict(i,j) = logical(isStrict);
[D, feasible] = dbm.close(D, tol);
end
