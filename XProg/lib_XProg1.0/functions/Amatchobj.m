function A1=Amatchobj(A0,Obj)
    if (size(Obj,1)~=size(A0,1)||size(Obj,2)~=size(A0,2))&&(size(A0,1)~=1||size(A0,2)~=1)
        error('Inner matrix dimensions must agree.');
    elseif (size(A0,1)==1&&size(A0,2)==1)
        A1=ones(Obj.Dimension(1),Obj.Dimension(2))*A0;
    else
        A1=A0;
    end
end

