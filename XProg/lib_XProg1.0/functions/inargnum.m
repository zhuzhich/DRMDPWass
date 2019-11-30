function inargnum(N,Min,Max)
    if N>Max
        error('Too many input arguments.');
    elseif N<Min
        error('Not enough input argments.');
    end
end

