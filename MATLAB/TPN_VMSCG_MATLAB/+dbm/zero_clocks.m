function D = zero_clocks(nClocks, tol)
%ZERO_CLOCKS DBM in which every real-valued clock equals zero.
% Index 1 is the distinguished zero clock; real clocks use indices 2,...
if nargin < 2, tol = 1e-10; end
D.C = inf(nClocks + 1);
D.strict = false(nClocks + 1);
D.C(1,1) = 0;
for k = 2:nClocks+1
    D.C(k,k) = 0;
    D.C(k,1) = 0;       % x_k <= 0
    D.C(1,k) = 0;       % -x_k <= 0
end
[D, ok] = dbm.close(D, tol);
assert(ok, 'Internal error while creating the zero-clock DBM.');
end
