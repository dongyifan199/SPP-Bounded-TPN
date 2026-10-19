function GV = build(G,opts)
%BUILD Construct the complete canonical validity-aware MSCG (V-MSCG).
if nargin<2, opts=common.default_options(); end
GV=common.build_graph(G,true,opts);
GV.type='V-MSCG';
end
