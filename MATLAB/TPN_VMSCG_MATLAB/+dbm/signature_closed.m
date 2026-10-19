function key = signature_closed(D, digits, tol)
%SIGNATURE_CLOSED Stable key for a DBM already in canonical closed form.
% This function deliberately does not close D.  The graph engine calls it
% only for DBMs produced by zero_clocks, constrain, subset, add_zero_clock,
% or reset_zero, all of which preserve the closed-form invariant.
if nargin < 2, digits = 12; end
if nargin < 3, tol = 1e-10; end
fmt = sprintf('%%.%dg',digits);
parts = cell(1,numel(D.C));
q = 0;
for i = 1:size(D.C,1)
    for j = 1:size(D.C,2)
        q = q + 1;
        if isinf(D.C(i,j))
            value = 'Inf';
        elseif abs(D.C(i,j)) <= tol
            value = '0';
        else
            value = sprintf(fmt,D.C(i,j));
        end
        if D.strict(i,j), relation = '<'; else, relation = '<='; end
        parts{q} = [value relation];
    end
end
key = strjoin(parts,',');
end
