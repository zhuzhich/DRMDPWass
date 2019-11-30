%% Generate U_{s}^{t+1}

function output  = gen_U (v, index, M, N, s_min, s_max)

temp = zeros(M+1,N+1);

for j = 1 : M+1
    for  i = 1 : N+1
        temp(j,i) = v(phi(stock(index,s_min)+j-i,s_min,s_max)+s_min+1);
    end
end

output = temp;

end