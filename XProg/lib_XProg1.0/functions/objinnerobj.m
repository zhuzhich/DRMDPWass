function objinnerobj(Obj1,Obj2)
    if size(Obj1,2)~=size(Obj2,1)
        error('Inner matrix dimensions must agree.');
    end
end

