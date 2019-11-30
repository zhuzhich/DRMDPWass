%main function to solve DRMDP with Wasserstein uncertainty set
function res = main_chen(sysInfo, currentT, currentS)
%R, U, M, N, Zs, para_theta
%R: cost function
%U: last stage value function
%M+1: # of action
%N+1: # of states
%Zs: data 

model = xprog('dro');
model.Param.IsPrint = '0';
% define decision
piDec = model.decision(sysInfo.numAction);


% define uncertainty 
Ns = sysInfo.numData;
pMatrix = model.random(sysInfo.numState, sysInfo.numState);	%transition prob., in matrix form
pVector = model.random(sysInfo.numState*sysInfo.numState);	%trans. prob., in vector form
														%there are constraints to bind these two
u = model.random(1);									
w = model.random(Ns);
Un = model.random(Ns);
Unn = model.random(sysInfo.numState*sysInfo.numState, Ns);
pVectorN = model.random(sysInfo.numState*sysInfo.numState,Ns);

% define ambiguity set

% define expectation constraint
model.uncertain(expect(u) <= sysInfo.theta); % theta is the size of the Wasserstein ambiguity set
model.uncertain(expect(w) == ones(Ns,1)/Ns); % moment condition on the auxiliary RV w

%bind pMatrix and pVector
row = 1;
col = 1;
for i = 1:sysInfo.numState*sysInfo.numState
	model.uncertain(pMatrix(row, col) == pVector(i));
	col = col + 1;
	if col > sysInfo.numState
		row = row + 1;
		col = 1;
	end
end
% define support set
model.uncertain(pVector == pVectorN*ones(Ns,1));
model.uncertain(u == sum(Un));
model.uncertain(w >= 0);
model.uncertain(sum(w) == 1);
for ns = 1:Ns
    model.uncertain(pVectorN(:,ns) >= 0);
	for i = 1:sysInfo.numState
		model.uncertain(sum(pVectorN(i:i+sysInfo.numState-1)) == w(ns));
	end
	tmpData = squeeze(sysInfo.data(ns,:,:));
	tmpData = tmpData';
    model.uncertain(Unn(:,ns) >= abs(pVectorN(:,ns)-...
					(ones(sysInfo.numState*sysInfo.numState,1)*w(ns)).*...
					reshape(tmpData,[],1)));
    model.uncertain(sum(Unn(:,ns)) <= Un(ns));
end
% define objective
tmpDataQ = squeeze(sysInfo.qMatrix(currentS,:,:));
tmpDataV = (sysInfo.output.v(currentT+1,:))';
model.max(expect(sysInfo.cost(currentS,:)*piDec + ...
			(tmpDataQ*pMatrix*tmpDataV)'*piDec));

% define constraint
model.add(piDec >= 0);
model.add(sum(piDec) == 1);

model.solve;

%res.v = model.Solution.Objective;.
res.v = model.get;
res.pi = piDec.get;
res.lambda = -1;			%dummy one
end 