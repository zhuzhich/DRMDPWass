import mosek
from mosek.fusion import *
import sys
class system_info():
	def __init__(self,n, m, k, mu, sig, gamma1, gamma2,a, b):
		self.numDecVar = n;
		self.sampleSize = m;
		self.numPiece = k;
		self.mu = Matrix.dense(mu);
		self.sig = Matrix.dense(sig);
		self.gamma1 = gamma1;
		self.gamma2 = gamma2;
		self.a = a;
		self.b = b;

def main(sysInfo):
	with Model("sdo1") as M:
	
		M.setLogHandler(sys.stdout);

		#decision variable
		#matrix[P, p;pT, s];
		Z1 = M.variable("Z1", Domain.inPSDCone(sysInfo.numDecVar+1));
		Pu = Z1.slice([0,0],[sysInfo.numDecVar,sysInfo.numDecVar]);
		Pl = Z1.slice([0,sysInfo.numDecVar],[sysInfo.numDecVar,sysInfo.numDecVar+1]);
		s = Z1.slice([sysInfo.numDecVar,sysInfo.numDecVar],[sysInfo.numDecVar+1,sysInfo.numDecVar+1]);
		
		#variable x
		x = M.variable("x", sysInfo.numDecVar, Domain.greaterThan(0));
		
		#variable q
		q = M.variable("q", sysInfo.numDecVar);
		
		#matrix Q
		Q = M.variable("Q", Domain.inPSDCone(sysInfo.numDecVar));
		
		#variable r
		r = M.variable();
		
		#parameters:
		mu = sysInfo.mu;
		sig = sysInfo.sig;
		gamma1 = sysInfo.gamma1;
		gamma2 = sysInfo.gamma2;
		ak = sysInfo.a;
		bk = sysInfo.b;
		
		#objective:
		tmpExpr1 = Expr.mul(gamma2, Q);
		tmpExpr2 = Expr.dot(sig, tmpExpr1);
		tmpExpr3 = Expr.mul(mu.transpose(), Q);
		tmpExpr4 = Expr.mul(tmpExpr3, mu);
		tmpExpr5 = Expr.sub(tmpExpr2, tmpExpr4);
		tmpExpr6 = Expr.add(tmpExpr5, r);
		tmpExpr7 = Expr.add(tmpExpr6, Expr.dot(sig, Pu));
		tmpExpr8 = Expr.mul(2, Pl);
		tmpExpr9 = Expr.mul(mu.transpose(), tmpExpr8);
		tmpExpr10 = Expr.sub(tmpExpr7, tmpExpr9);
		tmpExpr11 = Expr.add(tmpExpr10, Expr.mul(gamma1, s));
		
		M.objective(ObjectiveSense.Minimize, tmpExpr11);
		
		#constraints:
		tmpExpr1 = Expr.mul(0.5, q);
		tmpExpr2 = Expr.mul(Q, mu);
		tmpExpr3 = Expr.add(Pl,tmpExpr1);
		tmpExpr4 = Expr.add(tmpExpr3, tmpExpr2);
		M.constraint("c1", tmpExpr4, Domain.equalsTo(0));
		
		
		for i in range(len(ak)):
			tmpExpr1 = Expr.mul(0.5, q);
			tmpExpr2 = Expr.mul(0.5*ak[i], x);
			tmpExpr3 = Expr.hstack(Q, Expr.add(tmpExpr1, tmpExpr2));
			tmpExpr4 = Expr.mul(0.5, q.transpose());
			tmpExpr5 = Expr.mul(0.5*ak[i], x.transpose());
			tmpExpr6 = Expr.hstack(tmpExpr5, Expr.add(r, bk[i]));
			tmpExpr7 = Expr.vstack(tmpExpr3, tmpExpr6);
			M.constraint("c2"+str(i), tmpExpr7, Domain.inPSDCone());
		
		M.constraint("cx", Expr.sum(x), Domain.equalsTo(1));
		
		'''
		#parameters
		C = Matrix.dense([[2, 1, 0],
						[1, 2, 1],
						[0,1,2]])
		
		A1 = Matrix.eye(3)
		A2 = Matrix.ones(3,3)
		
		#objective
		M.objective(ObjectiveSense.Minimize, Expr.add(Expr.dot(C,X), x.index(0)));
		
		#constraints
		M.constraint("c1", Expr.add(Expr.dot(A1,X), x.index(0)), Domain.equalsTo(1.0))
		M.constraint("c2", Expr.add(Expr.dot(A2,X), Expr.sum(x.slice(1,3))), Domain.equalsTo(0.5));
		'''
		#solve the model
		M.solve();
		#M.writeTask("a.opf")
		#print ("obj",M.primalObjValue());
		print("x=",x.level());
		print("Q=",Q.level());
		print("r=",r.level());
		print("P=",Pu.level());
		print("p=",Pl.level());
		print("s=",s.level());
		
numDecisionVar = 3;
sampleSize = 30;		
numPiece = 2;
mu = [[0.1073],
	  [0.0737],
	  [0.0627]];
sig = [[0.02778, 0.00387, 0.00021],
		[0.00387, 0.01112, -0.00020],
		[0.00021, -0.00020, 0.00115]];
gamma1 = 1.35;
gamma2 = 6.32;
av = [2,1];
bv = [0,0.5];
sysInfo = system_info(numDecisionVar, sampleSize, numPiece, mu, sig, gamma1, gamma2, av, bv);
main(sysInfo);