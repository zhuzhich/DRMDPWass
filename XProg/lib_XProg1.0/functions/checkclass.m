function checkclass(obj,CName)
    if ~isa(obj,CName)
        error('Incorrect input arguments.');
    end
end

