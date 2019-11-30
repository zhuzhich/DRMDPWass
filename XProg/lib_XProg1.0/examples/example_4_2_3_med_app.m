N=8;
gamma=2;
%mu=30+30*rand(N,1);
mu=45*ones(N,1);
%eps=0.3*rand(1,1);
eps=0.3;
sig=mu*eps;

phi2=sum(sig.^2);
T=sum(mu)+0.5*sqrt(sum(sig.^2));

% input data omitted. Please refer to example 4_2_3_med_app.m
% N=8 is the number of patients
% gamma is the overtime cost of per unit delay
% mu(N*1) represents the mean value of uncertain consultation time z
% sig(N*1) represents the standard deviation of uncertain sonsultation time z
% phi2 is the constant of phi^2

model=xprog('MA Scheduling');                     % create a model, named 'MA Scheduling'

x=model.decision(N);                              % here-and-now decision

y=model.recourse(N+1);                            % define decision rule

z=model.random(N);                                % define random varaibles
u=model.random(N+1);                              % define auxiliary variables

y.depend(z);                                      % define dependency of y on z
y.depend(u);                                      % define dependency of y on u

% extended ambiguity set is defined below
model.uncertain(expect(z)==mu);                   % first line of G
model.uncertain(expect(u(1:N)')<=sig.^2);         % second line of G
model.uncertain(expect(u(N+1))<=phi2);            % third line of G

% extended support set is defined below
model.uncertain(z>=0);                            % first line of \hat{W}
model.uncertain((z-mu).^2<=u(1:N)');              % second line of \hat{W}
model.uncertain(square(sum(z)-sum(mu))<=u(N+1));  % third line of \hat{W}

model.min(expect(sum(y(1:N))+gamma*y(N+1)));      % define objective function

for n=1:N
    model.add(y(n+1)-y(n)+x(n)>=z(n));            % 1st constraint
end

model.add(y>=0);                                  % 2nd constraint
model.add(sum(x)<=T);                             % 3rd constraint
model.add(x>=0);                                  % 3rd constraint

model.solve;                                      % solve the problem