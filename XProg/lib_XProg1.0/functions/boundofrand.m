function [Index_p, Index_n, BMatrix, BVector]=boundofrand(UB,LB)

Index_p=find(LB==0);
Index_n=find(UB==0);

Index_le=find(UB~=Inf&UB~=0);
Index_ge=find(LB~=-Inf&LB~=0);

NOR1=length(Index_le);
NOR2=length(Index_ge);
NOC=length(UB);

BMatrix1=spalloc(NOR1,NOC,NOR1);
if NOR1>0
    BMatrix1(:,Index_le)=speye(NOR1);
    BVector1=UB(Index_le)';
else
    BVector1=[];
end

BMatrix2=spalloc(NOR2,NOC,NOR2);
if NOR2>0
    BMatrix2(:,Index_ge)=-speye(NOR2);
    BVector2=LB(Index_ge)';
else
    BVector2=[];
end

BMatrix=[BMatrix1;BMatrix2];
BVector=[BVector1;BVector2];


end

