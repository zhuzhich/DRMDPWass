%% Generate R_{s}
function output = gen_R (index, M, c, b, h, s_min)
temp = zeros(M+1,1);
for j = 1 : M+1
    temp (j) = c*(j-1) + max(h*stock(index,s_min), b*(-stock(index,s_min)));
end
output = temp;
end
