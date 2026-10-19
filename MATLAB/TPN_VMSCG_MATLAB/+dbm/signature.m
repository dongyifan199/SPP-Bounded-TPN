function key = signature(D, digits, tol)
%SIGNATURE Stable text key for a canonical DBM.
if nargin < 2, digits = 12; end
if nargin < 3, tol = 1e-10; end
[D, ok] = dbm.close(D, tol);
assert(ok, 'An infeasible DBM cannot be used as a state signature.');
key = dbm.signature_closed(D,digits,tol);
end
