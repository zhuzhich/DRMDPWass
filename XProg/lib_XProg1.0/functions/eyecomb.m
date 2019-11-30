function NewEye = eyecomb(A,NOE)

[NOR,NOC]=size(A);
NewEye=spalloc(0,NOC*NOE,0);
for r=1:NOR
    NewEye_r=spalloc(NOE,0,0);
    for c=1:NOC
        NewEye_r=columncomb(NewEye_r,A(r,c)*speye(NOE));  
    end
    NewEye=rowcomb(NewEye,NewEye_r);
end


end

