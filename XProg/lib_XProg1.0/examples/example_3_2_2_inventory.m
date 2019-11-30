T=24;                                      % number of time steps
I=3;                                       % number of factories;
tt=1:T;
d0=1000*(1+1/2*sin(pi*((tt-1)/12)));       % vector of expected demands
c =[1;1.5;2]*(1+1/2*sin(pi*(tt-1)/12));    % matrix of production cost

P=567;                                     % production capacity
Q=13600;                                   % limitation of total products number

Vmin=500;                                  % mimimum capacity of the warehouse
Vmax=2000;                                 % maximum capacity of the warehouse
V0  =1500;                                 % initial storage of the warehouse

delta=0.2;                                 % constant indicating the deviations

% input data omitted. Please refer to example 3_2_2_inventory.m
% T=24 is the number of time step
% I=3 is the number of factories
% d0(1*T) is the vector of expected demand
% c(I*T) is the matrix of production cost coefficients
% P is the production capacity for each time step
% Q is total production capacity for the entire time horizon
% Vmin and Vmax are the minimum and maximum bound of inventory
% V0 is the initial inventory
% delta is the uncertainty level

model=xprog('inventory');          % create a model, named 'inventory'
%model.Param.DecRand=1;             % enable decompose the uncertainty set

d=model.random(1,T);               % define random demand
model.uncertain(d<=(1+delta)*d0);  % upper bound of random demand
model.uncertain(d>=(1-delta)*d0);  % lower bound of random demand

p=model.recourse(I,T);             % define recourse decision as decision rule

for t=2:T                          % define dependency in a for loop
    I_t=1:t-1;                     % standard info. basis assumption
    p(:,t).depend(d,I_t);          % dependency based on standard info. basis
end

model.min(sum(sum(c.*p)));         % define objective function

model.add(p>=0);                   % lower bound of p
model.add(p<=P);                   % upper bound of p
model.add(sum(p,2)<=Q)             % total production capacity Q
v=V0;                              % initial inventory
for t=1:T
    v=v+(sum(p(:,t))-d(t));        % update inventory v_{t+1}
    model.add(v<=Vmax);
    model.add(v>=Vmin);
end

model.solve;                       % solve the proble