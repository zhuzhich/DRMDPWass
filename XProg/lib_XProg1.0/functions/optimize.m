function [cost,x,flag] = optimize(Problem,MIPGAP,ISPRNT)

A0=Problem.A;
b0=Problem.b;

Iseq =(Problem.sense==1);

lb=Problem.LB;
ub=Problem.UB;

QC=Problem.QC;
NumOfQC=length(QC);
qc.sense='L';
qc.a=[];
qc.rhs=[];
qc.Q=[];
qc=repmat(qc,1,NumOfQC);
for n=1:NumOfQC
    qc(n).Q=QC(n).Q;
    qc(n).a=QC(n).P;
    qc(n).rhs=QC(n).d;
end

[NumOfCon,NumOfVar]=size(A0);

Opt=Cplex();
Opt.Model.A=A0;
Opt.Model.rhs=b0;
Opt.Model.lhs=-Inf*ones(NumOfCon,1);
Opt.Model.lhs(Iseq)=b0(Iseq);
Opt.Model.obj=Problem.Fun';
Opt.Model.ub=ub;
Opt.Model.lb=lb;

if sum(Problem.M)>0
    IsMIP=1;
    ctype=repmat('C',1,NumOfVar);
    ctype(Problem.M==1)='B';
    Opt.Model.ctype=ctype;
else
    IsMIP=0;
end
Opt.Model.qc=qc;

Opt.Param.mip.tolerances.mipgap.Cur=MIPGAP;

Opt.solve;

flag=Opt.Solution.status;
if ((flag==101||flag==102)&&IsMIP==1)||((flag==1)&&IsMIP==0)
    x   =Opt.Solution.x;
    cost=Opt.Solution.objval;
else
    x   =[];
    cost=[];
end

%flag=output.cplexstatus;

if ISPRNT==1
    fprintf(['status=' num2str(flag) '.\n']);
    fprintf(['Solution time:' num2str(Opt.Solution.time) 's.\n']);
end

end

