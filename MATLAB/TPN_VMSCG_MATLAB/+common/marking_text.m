function txt = marking_text(G,M)
%MARKING_TEXT Compact readable marking expression.
parts={};
for p=find(M(:)'>0)
    if M(p)==1
        parts{end+1}=G.placeNames{p}; %#ok<AGROW>
    else
        parts{end+1}=sprintf('%g%s',M(p),G.placeNames{p}); %#ok<AGROW>
    end
end
if isempty(parts), txt='0'; else, txt=strjoin(parts,'+'); end
end
