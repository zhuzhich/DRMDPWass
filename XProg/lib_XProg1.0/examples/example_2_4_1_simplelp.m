model=xprog('Simple LP');          % create a model, named "Simple LP"

x=model.decision;                  % create a decision x for model
y=model.decision;                  % create a decision y for model

model.max(3*x+4*y);                % define objective function

model.add(2.5*x+y<=20);            % add the 1st constraint to model
model.add(3*x+3*y<=30);            % add the 2nd constraint to model
model.add(x+2*y<=16);              % add the 3rd constraint to model
model.add(x>=0);                   % bound of x
model.add(y>=0);                   % bound of y

model.solve;                       % solve the problem

Obj=model.get;                     % get the objective value
X  =x.get;                         % get solution x
Y  =y.get;                         % get solution y