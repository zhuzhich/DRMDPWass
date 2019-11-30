model=xprog('SP Example');         % create a model, named "SP Example"

x=model.decision(3);               % define 1st-stage decisions
y=cell(1,3);                       % create a cell for three scenarios
for s=1:3
    y{s}=model.decision(3);        % define 2nd-stage decisions for scenario s 
end

P= [0.3 0.4 0.3];                  % probability
c=-[2 4 5.2];                      % 1st-stage objective vector
q= [60 40 10];                     % recourse objective vector
Exp=0;
for s=1:3
    Exp=Exp+P(s)*q*y{s};           % expected recourse objective
end
model.max(c*x+Exp);

    
W=[8 6   1;                        % define constraint matrix
   4 2   1.5;
   2 1.5 0.5];
D=[50  150 250;                    % define random demand
   20  110 250;
   200 225 500];
for s=1:3
    model.add(W*y{s}-x<=0);        % add 1st~3rd constraints
    model.add(y{s}>=0);            % bound of y(s)
    model.add(y{s}<=D(:,s));       % demand constriants
end
model.add(x>=0)                    % bound of x

model.solve;                       % solve the program

Obj=model.get;                     % get optimal objective
X  =x.get;                         % get optimal solution of x

