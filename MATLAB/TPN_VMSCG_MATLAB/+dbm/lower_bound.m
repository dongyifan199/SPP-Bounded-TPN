function [value, isStrict] = lower_bound(D, index)
%LOWER_BOUND Return x_index >= value, with strictness information.
% D(1,index) encodes -x_index <= c, hence x_index >= -c.
value = -D.C(1,index);
isStrict = D.strict(1,index);
end
