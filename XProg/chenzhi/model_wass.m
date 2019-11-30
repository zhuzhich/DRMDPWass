function [action, value] = model_wass(R, U, M, N, Zs, para_theta)
model = xprog('dro');
model.Param.IsPrint = '0';
% define decision
x = model.decision(M+1);

% define uncertainty 
Ns = size(Zs, 2); % Size of Zs is (N, Ns) N is dimension of the uncertainty, Ns is number of past realization
z = model.random(N+1);
u = model.random(1);
w = model.random(Ns);
Un = model.random(Ns);
Unn = model.random(N+1, Ns);
Zn = model.random(N+1,Ns);

% define ambiguity set

% define expectation constraint
model.uncertain(expect(u) <= para_theta); % para_theta is the size of the Wasserstein ambiguity set
model.uncertain(expect(w) == ones(Ns,1)/Ns); % moment condition on the auxiliary RV w

% define support set
model.uncertain(z == Zn*ones(Ns,1));
model.uncertain(u == sum(Un));
model.uncertain(w >= 0);
model.uncertain(sum(w) == 1);
for ns = 1:Ns
    model.uncertain(Zn(:,ns) >= 0);
    model.uncertain(sum(Zn(:,ns)) == w(ns));
    model.uncertain(Unn(:,ns) >= abs(Zn(:,ns)-(ones(N+1,1)*w(ns)).*Zs(:,ns)));
    model.uncertain(sum(Unn(:,ns)) <= Un(ns));
end
% define objective
model.min(expect(x'*R + x'*U*z));

% define constraint
model.add(x >= 0);
model.add(sum(x) == 1);

model.solve;

% optimal random strategy
action = x.get;
% optimal value function
value = model.Solution.Objective;

end