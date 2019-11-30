% next state --- return the location of the stock
function next_state = nextstate(state,x,s_min,s_max,d)

% d_rand = d(find(rand<=cumsum(d_p),1,'first'));
% d_rand = gendist(d_p',1,1) - 1;

next_state = phi(stock(state,s_min)+x-d,s_min,s_max)+s_min+1;

end
