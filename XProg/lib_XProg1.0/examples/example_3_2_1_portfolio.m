n  = 150;                                % Number of stocks 
p  = 1.15+ 0.05/150*(1:n)';              % Mean return
sigma = 0.05/450*sqrt(2*n*(n+1)*(1:n)'); % Deviation
Gamma = 5;

% input data omitted. Please refer to example 3_2_1_portfolio.m
% stock number n=150
% p(1*n) is the expected return of each stock
% sigma(1*n) is the uncertain range of random stock returns
% Gamma=5 is the budget of uncertainty

model=xprog('portfolio');           % create a model

x=model.decision(n);                % decisions as fraction of investment
%a=model.decision;                  % decision variable as objective value

% random variables and the uncertainty set
z=model.random(n);                  % random deviations from the expected returns
u=model.random(n);                  % absolute value of z
model.uncertain(abs(z)<=1);         % norm_inf(z)<=1
model.uncertain(abs(z)<=u);         % expressing the absolute value of z
model.uncertain(sum(u)<=Gamma);     % norm(z)<=Gamma

r = p + sigma.*z;                   % random return of stocks
model.max(r'*x)                     % define objective
%model.add(a<=r'*x);                % a is the lower bound of objective
model.add(sum(x)==1);               % constraint of x
model.add(x>=0);                    % bound of x

model.solve;                        % solve the problem
