function key = state_signature(S, withValidity, opts)
%STATE_SIGNATURE Exact canonical timed-state key.
parts = {sprintf('M:%d,',S.M),sprintf('A:%d,',find(S.ageClock>0))};
if withValidity
    parts{end+1} = ['rho:' S.rho];
    parts{end+1} = sprintf('V:%d,',find(S.valClock>0));
end
if isfield(opts,'fastCanonicalSignatures') && opts.fastCanonicalSignatures
    zoneKey=dbm.signature_closed(S.D,opts.signatureDigits,opts.tolerance);
else
    zoneKey=dbm.signature(S.D,opts.signatureDigits,opts.tolerance);
end
parts{end+1} = ['D:' zoneKey];
key = strjoin(parts,'|');
end
