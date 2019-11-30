start_xprog;

for instanceNum = 1:1000 
% parameter initialization
T = 5;
s_min = 5; % # of backorders
s_max = 10; % warehouse space limitation
K = s_min+s_max+1; % |S|: number of states
x_max = 4; % order upper bound
M = x_max; % number of actions, order quantity x: 0,1,...,M
c = 1; % unit order cost
h = 2; % unit holding cost
b = 3; % unit backorder cost 

% discrete distribution of the demand
d_max = 4;
N = d_max; % number of demands, demand realization d: 0,1,...,N
d_p = [0.05;0.4;0.1;0.4;0.05];

% learning sample
no_sample_per = 8*T;
no_sample = 2*T;
d_s = zeros(length(d_p),no_sample);

for i = 1 : no_sample
    temp_1 = gendist(d_p',1,no_sample_per);
    temp_2 = tabulate(temp_1);
    temp_max = max(temp_2(:,1));
    d_s(1:temp_max,i) = temp_2(:,3)/100;
end

% testing sample
initial_state = s_min + 1; % start at the zero-stock state
d_r(1,:) = gendist(d_p',1,T-1) - 1; % out sample test data

% save policy
para_theta = (horzcat(0:0.01:0.1,0.12:0.02:0.2,0.25:0.05:0.5,0.7,1,1.5,2))';
a_mat = cell(length(para_theta),1); % action table for different theta
v_mat = cell(length(para_theta),1); % value table for different theta

% save out sample performation & out sample policy
cr = zeros(length(para_theta),1); % cumulative reward for different theta
order = zeros(length(para_theta),T-1); % order quantity for different theta

% solve policy for different theta & test performation for different theta
for numtheta = 1:length(para_theta)
% last stage
for k = 1 : K
    v_mat{numtheta,1}(k,T) = max(h*stock(k,s_min), -b*stock(k,s_min));
end  

for t = T-1 : -1 : 1
    v_temp = v_mat{numtheta,1}(:,t+1);
    for k = 1 : K
        R_temp = gen_R(k, M, c, b, h, s_min);
        U_temp = gen_U(v_temp, k, M, N, s_min, s_max);
        [a_mat{numtheta,1}{t,1}(k,:), v_mat{numtheta,1}(k,t)] = model_wass(R_temp, U_temp, M, N, d_s, para_theta(numtheta,1));
    end
end
clear v_temp R_temp U_temp

[cr(numtheta,1), order(numtheta,:)] = out_eval(initial_state, a_mat{numtheta,1}, d_r(1,:), T, c, h, b, s_min, s_max);
end % end for one instance;
eval(['save ' 'Data_' num2str(instanceNum) '_.mat']);
clearvars -except instanceNum 
end
