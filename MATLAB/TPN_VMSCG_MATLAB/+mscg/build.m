function GM = build(G,opts)
%BUILD Construct the canonical Modified State-Class Graph (MSCG).
if nargin<2, opts=common.default_options(); end
GM=common.build_graph(G,false,opts);
GM.type='MSCG';
end
