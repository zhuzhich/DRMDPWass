model=xprog('simple_dro');                    % create a model named 'simple_dro'

y=model.recourse(1,1);                        % define recourse decision y

z=model.random(1);                            % define random variable z
u=model.random(1);                            % define auxiliary variable u

y.depend(z);                                  % define dependency of y on z
y.depend(u);                                  % define dependency of y on u

model.uncertain(expect(z)==0);                % 2nd line of set G
model.uncertain(expect(u)<=1);                % 3rd line of set G

model.uncertain(z<= 2);                       % 4th line of set G
model.uncertain(z>=-2);                       % 4th line of set G
model.uncertain(z.^2<=u);                     % 4th line of set G
model.uncertain(u<=2^2);                      % 4th line of set G

Z1=model.subset(0.9);                         % Z1 is a subset of support set...
                                              % P{Z1} is 0.9
model.uncertain(z<= 1,Z1);                    % 5th line of set G
model.uncertain(z>=-1,Z1);                    % 5th line of set G
model.uncertain(z.^2<=u,Z1);                  % 5th line of set G
model.uncertain(u<=1^2,Z1);                   % 5th line of set G

Z2=model.subset([0.6 0.7],Z1);                % Z2 is a subset of Z1...
                                              % P{Z2} is between 0.6 and 0.7
model.uncertain(z<= 0.5,Z2);                  % 6th line of set G
model.uncertain(z>=-0.5,Z2);                  % 6th iine of set G
model.uncertain(z.^2<=u,Z2);                  % 6th line of set G
model.uncertain(u<=0.5^2,Z2);                 % 6th line of set G

model.min(expect(y));                         % define objective function

model.add(y>=z);                              % 1st constraint
model.add(y>=-z);                             % 2nd constraint

model.solve;                                  % solve the problem

