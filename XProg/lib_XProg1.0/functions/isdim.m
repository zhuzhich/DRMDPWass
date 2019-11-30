function Bool=isdim(Dim)
    Bool=isnumeric(Dim)&&isreal(Dim)&&size(Dim,1)==1&&size(Dim,2)==1&&(Dim>0);
end

