function objmatchobj(Obj1,Obj2)
    if size(Obj1,1)~=size(Obj2,1)||size(Obj1,2)~=size(Obj2,2)
        error('Expression dimensions mismatch.');
    end
end

