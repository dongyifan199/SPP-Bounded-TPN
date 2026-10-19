function D = time_elapse(D)
%TIME_ELAPSE Let all real clocks advance by the same nonnegative delay.
% Pairwise clock differences and lower bounds are preserved; absolute
% upper bounds relative to the zero clock are removed.
for k = 2:size(D.C,1)
    D.C(k,1) = inf;
    D.strict(k,1) = false;
end
end
