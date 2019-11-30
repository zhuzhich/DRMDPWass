function A= setsblock(A,Ab,Index_r,Index_c)

[NOBR,NOBC]=size(Ab);
[NOAR,NOAC]=size(A);

NOR=NOAR/NOBR;
%NOC=NOAC/NOBC;

if nargin<4
    Index_r1=mod(Index_r-1,NOR)+1;
    Index_c1=(Index_r-Index_r1)/NOR+1;
elseif nargin==4
    Index_r1=Index_r;
    Index_c1=Index_c;
else
    error('Too many input arguments.');
end
    
Index_br=(Index_r1-1)*NOBR+(1:NOBR);
Index_bc=(Index_c1-1)*NOBC+(1:NOBC);
if max(Index_br)>NOAR||max(Index_bc>NOAC)
    error('Index exceeds matrix dimensions.');
end

A(Index_br,Index_bc)=Ab;


end

