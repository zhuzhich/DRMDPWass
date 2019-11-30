N=10;
Price=[10.00 11.00 11.41 11.73 12.00 12.24 12.45 12.65 12.83 13.00]';
Cost =[2.00  2.71  3.00  3.23  3.41  3.58  3.73  3.87  4.00  4.12 ]';
mu   =[30.00 35.00 40.00 45.00 50.00 55.00 60.00 65.00 70.00 75.00]';
sig  =(30:-1.5:16.5)';
barZ =100*ones(10,1);
Psi  =100;
Gamma=500;

% input data omitted. Please refer to example 4_2_1_newsvendor.m
% N=10 is the number of products
% Price(10*1) is the vector of product selling prices
% Cost(10*1) is the vector of product ordering costs
% mu(10*1) is the vector of mean values of random variables z
% barZ(10*1)
% sig(10*1) is the vector of standard deviations of random variables z
% Psi(1*1) is expected value of the positive uncertainty of random varaibles z

model=xprog('newsvendor');                    % create a model, named 'newsvendor'

x=model.decision(N);                          % here-and-now decisions x

y=model.recourse(N);                          % define decision rule

z=model.random(N);                            % define random variables z
u=model.random(N+1);                          % define auxiliary varialbes u
v=model.random(N);                            % define auxiliary variables z

y.depend(z);                                  % define dependency of y on z
y.depend(u);                                  % define dependency of y on u
y.depend(v);                                  % define dependency of y on v

% extended ambiguity set is defined below
model.uncertain(expect(z)==mu);               % 1st line of set G
mu2 =mu.*mu;                                  % mu^2
sig2=sig.*sig;                                % sigma^2
model.uncertain(expect(u(1:N)')<=mu2+sig2);   % 2nd line of set G
model.uncertain(expect(u(N+1))<=Psi);         % 3rd line of set G

% extended support set is defined below
model.uncertain(z>=0);                        % lower bound of z
model.uncertain(z<=barZ);                     % upper bound of z
model.uncertain(z.^2<=u(1:N)');               % 2nd line of set \hat{W}
model.uncertain(u(N+1)>=Price'*v);            % 3rd line of set \hat{W} 
model.uncertain(v>=mu-z);                     % 4th line of set \hat{W} 
model.uncertain(v>=0);                        % 5th line of set \hat{W}

model.max(Price'*x-expect(Price'*y));         % define objective function

model.add(Cost'*x<=Gamma);                    % 1st constraint: budget 
model.add(x>=0);                              % 2nd constraint: nonnegtivity
model.add(y>=x-z);                            % 3rd constraint
model.add(y>=0);                              % 4th constraint

model.solve;                                  % solve the problem