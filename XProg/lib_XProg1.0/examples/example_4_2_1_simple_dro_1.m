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

model.min(expect(y));                         % define objective function

model.add(y>=z);                              % 1st constraint
model.add(y>=-z);                             % 2nd constraint

model.solve;                                  % solve the problem

