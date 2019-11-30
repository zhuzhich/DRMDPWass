function [cost,x,flag] = optimize(Problem,MIPGAP,ISPRNT)

A0=Problem.A;
b0=Problem.b;

Iseq =(Problem.sense==1);
Isle =(Problem.sense==0);

Aeq  =A0(Iseq,:);
Aineq=A0(Isle,:);
beq  =b0(Iseq);
bineq=b0(Isle);

lb=Problem.LB;
ub=Problem.UB;

QC=Problem.QC;
l=full([QC.P]);
NumOfQC=length(QC);
Q=cell(1,NumOfQC);
for n=1:NumOfQC
    Q{n}=QC(n).Q;
end
r=[QC.d];

NumOfVar=size(Aeq,2);
ctype=repmat('C',1,NumOfVar);
ctype(Problem.M==1)='B';

options=cplexoptimset;
options.display='off';
%[x,cost,~,output]=cplexmiqcp([],Problem.Fun,Aineq,bineq,Aeq,beq,l,Q,r,[],[],[],lb,ub,[],[],options);
[x,cost,~,output]   =cplexqcp([],Problem.Fun,Aineq,bineq,Aeq,beq,l,Q,r,lb,ub,[],options);
flag=output.cplexstatus;

if ISPRNT==1
    fprintf(['status=' num2str(flag) '.\n']);
    fprintf(['Solution time:' num2str(output.time) 's.\n']);
end

end

