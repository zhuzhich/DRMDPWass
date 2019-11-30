function Ab= getsblock(A,BDimension,Index_r,Index_c)

NOBR=BDimension(1);
NOBC=BDimension(2);
if nargin<4
    NOR=size(A,1)/NOBR;
    Tmp_r=[Index_r(1) Index_r(end)];
    Index_r1=mod(Tmp_r-1,NOR)+1;
    Index_c1=(Tmp_r-Index_r1)/NOR+1;
elseif nargin==4
    Index_r1=[Index_r(1) Index_r(end)];
    Index_c1=[Index_c(1) Index_c(end)];
else
    error('Too many input arguments');
end
    
Index_br=(Index_r1-1)*NOBR+[1 NOBR];
Index_bc=(Index_c1-1)*NOBC+[1 NOBC];

%Ab=A(Index_br,Index_bc);
Ab=thisblock(A,Index_br,Index_bc);

end

