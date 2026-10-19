function cfg = user_settings()
%USER_SETTINGS The only file a normal user needs to edit.

% ---------- Which instance(s) to run ----------
cfg.singleN = 1;
cfg.nValues = 1:10;
cfg.singleM = cfg.singleN;
cfg.mValues = cfg.nValues;

% ---------- Model timing: all intervals are [lower,upper) ----------
% Mapping to Fig. 1: I_in=t1, I_proc=t2, I_rework=t3, I_pass=t4,
% I_reg=t5, I_authA=t6, I_authB=t7, I_secA=t8, I_secB=t9, I_out=t10.
cfg.model.I_reg     = [1 3];
cfg.model.I_in      = [1 2];
cfg.model.I_proc    = [1 3];
cfg.model.I_pass    = [1 2];
cfg.model.I_rework  = [1 2];
cfg.model.I_authA   = [1 2];
cfg.model.I_authB   = [1 2];
cfg.model.I_secA    = [1 2];
cfg.model.I_secB    = [1 2];
cfg.model.I_out     = [1 2];

% ---------- SPP parameters ----------
% Protectable transitions in Fig. 1 are t5, t6 and t7.
cfg.model.timeout_reg   = 6;
cfg.model.timeout_authA = 4;
cfg.model.timeout_authB = 4;
cfg.model.gamma_reg     = 1;
cfg.model.gamma_authA   = 1;
cfg.model.gamma_authB   = 1;
cfg.model.cost_reg      = 1;
cfg.model.cost_authA    = 2;
cfg.model.cost_authB    = 2;
cfg.model.secretRequirement = 1;

% ---------- Output/timing ----------
cfg.outputFolder = 'output';
cfg.timingRepeats = 1; % Set 3 or 5 for final median timing measurements.

% ---------- Algorithm safeguards ----------
cfg.options = common.default_options();
cfg.options.verbose = false;
cfg.options.maxVertices = 500000;
cfg.options.maxPolicies = 100000;
cfg.options.fastCanonicalSignatures = true;
end
