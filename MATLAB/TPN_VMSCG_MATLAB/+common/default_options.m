function opts = default_options()
%DEFAULT_OPTIONS Shared settings for MSCG/V-MSCG and SPP verification.
opts.tolerance = 1e-10;
opts.signatureDigits = 12;
opts.maxVertices = 500000;
opts.maxPolicies = 100000;
opts.verbose = false;
opts.progressEvery = 500;
opts.stopOnFirstInvalidWitness = true;
opts.requireReachableSecret = true;
opts.fastCanonicalSignatures = true;
end
