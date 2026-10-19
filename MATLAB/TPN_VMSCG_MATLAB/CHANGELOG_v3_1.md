# v3.1.0-fast-backward

- Removed the explicit predecessor-walk enumeration used in v3.0.x.
- Added compressed backward-dependency extraction from the canonical V-MSCG DBM at each secret vertex.
- Exact binary validity assignments are enumerated; continuous timing feasibility is checked by DBM closure.
- No depth cutoff, path cutoff, big-M constant, or silent truncation is used.
- Scalability runner prints only the ten columns appearing in the paper table.
- Fig. 1 model, n=1:10, protection parameters, MSCG/V-MSCG construction, and all 8 candidate policies are unchanged.
