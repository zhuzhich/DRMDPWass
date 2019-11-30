% the cost per period

function [output] = cost(c,x,h,b,inventory)
output = c*x + max(h*inventory , -b*inventory);
end