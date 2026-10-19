function [D, feasible] = close(D, tol)
%CLOSE Floyd--Warshall canonical closure for strict/non-strict DBMs.
% D.C(i,j) is the bound in x_i-x_j <= c.  D.strict(i,j)=true
% changes the corresponding relation to x_i-x_j < c.
if nargin < 2, tol = 1e-10; end
n = size(D.C,1);
for k = 1:n
    for i = 1:n
        if isinf(D.C(i,k)), continue; end
        for j = 1:n
            if isinf(D.C(k,j)), continue; end
            c = D.C(i,k) + D.C(k,j);
            s = D.strict(i,k) || D.strict(k,j);
            if tighter(c,s,D.C(i,j),D.strict(i,j),tol)
                D.C(i,j) = c;
                D.strict(i,j) = s;
            end
        end
    end
end

feasible = true;
for i = 1:n
    if D.C(i,i) < -tol || ...
            (abs(D.C(i,i)) <= tol && D.strict(i,i))
        feasible = false;
        return;
    end
end

% Remove harmless roundoff from the diagonal.
for i = 1:n
    if abs(D.C(i,i)) <= tol
        D.C(i,i) = 0;
        D.strict(i,i) = false;
    end
end
end

function tf = tighter(c1,s1,c2,s2,tol)
if c1 < c2 - tol
    tf = true;
elseif isinf(c1) && isinf(c2)
    tf = false;
elseif abs(c1-c2) <= tol
    tf = s1 && ~s2;
else
    tf = false;
end
end
