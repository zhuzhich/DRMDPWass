mu =[1.2670 1.2062 1.2080 1.3342 1.3420 1.2970 1.3740]';
sig=[1.0590 0.9704 1.1120 1.0788 1.0560 1.0747 1.0298]';
P  =[1.0000 0.5544 0.6614 0.7154 0.7625 0.7610 0.7383;
     0.5544 1.0000 0.7016 0.6985 0.6932 0.6833 0.7248;
     0.6614 0.7016 1.0000 0.8681 0.8022 0.8276 0.7830;
     0.7154 0.6985 0.8681 1.0000 0.9179 0.8971 0.9080;
     0.7625 0.6932 0.8022 0.9179 1.0000 0.9502 0.9393;
     0.7610 0.6833 0.8276 0.8971 0.9520 1.0000 0.8911;
     0.7383 0.7248 0.7830 0.9080 0.9393 0.8911 1.0000];

% input data omitted. Please refer to example_2_4_2_winddiv.m
% mu(7*1) is the expected wind power from each site
% sig(7*1) is wind power standard deviations of each site
% Cor(7*7) is the correlation matrix 

model=xprog('Wind Div');           % create a model, named "Wind Div"

n=model.decision(7,1,2,'#Turbine');% integer decisions as no. of turbine
%a=model.decision;                  % decision variable as objective value

%Fun=square(P^(1/2)*(sig.*n));      % expression of objective by square
%model.add(a>=Fun);                 % a is the upper bound of objective
%model.min(a);                      % define objective 
model.min(square(P^(1/2)*(sig.*n)));

MeanWind=50;                       % expected total wind output 
model.add(mu'*n==MeanWind);        % add 1st constraint to model
model.add(sum(n)==40);             % add 2nd constraint to model
model.add(n>=0);                   % bound of n

model.solve                        % solve the problem

Obj=model.get;                     % get optimal objective
N  =n.get;                         % get optimal solution of n