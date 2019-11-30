% outsample evaluation of a given strategy (i.e., action_table), given an
% initial state and a series of demand realizations
function [c_r, order] = out_eval(initial_state, action_table, d_realization, T, c, h, b, s_min, s_max)
c_r = 0; % cummulative reward (i.e., cost in this example)
current_state_saa = initial_state;
for t = 1 : T-1
    order(1,t) = gendist(action_table{t}(current_state_saa,:),1,1) - 1;
    next_state_saa = nextstate(current_state_saa,order(1,t),s_min,s_max,d_realization(1,t));
    c_r = c_r + cost(c,order(1,t),h,b,stock(current_state_saa,s_min));
    current_state_saa = next_state_saa;
end
c_r = c_r + max(h*stock(current_state_saa,s_min),-b*stock(current_state_saa,s_min)); % last stage cost
end