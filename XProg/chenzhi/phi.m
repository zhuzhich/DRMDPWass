function [output] = phi(stock,s_min,s_max)

if stock <= 0
    output = max (stock, -s_min);
else
    output = min (stock, s_max);
end