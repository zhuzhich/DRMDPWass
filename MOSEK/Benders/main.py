
##Author: Zhicheng Zhu
#Email: zhicheng.zhu@ttu.edu, yisha.xiang@ttu.edu
#copyright @ 2019: Zhicheng Zhu. All right reserved.
#
#Use Benders decomposition to solve the max-min problem is distributionally robust Markov decision model
#
#Master problem: a LP
#  v_t(s)  =  \max_{\pi_s ,\lambda} - \lambda\theta^p +  \frac{1}{N}\sum_{i=1}^{N}\kappa_i \\
#          s.t. \sum_{a \in A} \pi_s(a) = 1 
#                feasibility cut
#                optimility cut: \kappa_i <= Q_i
#Subproblem: a convex program, with arbitrary norm
#   Q_i(\pi,\lambda) =  \inf_{x \in \chi_s} (\lambda d(x,\hat{x}_{s,i})^p 
#                       + \tilde{r}_s^\text{T}\pi_s+\tilde{p}_s^\text{T}V_{t+1,s}\pi_s)) 
#
#           s.t. 
#                   \sum_{s^\prime \in \mathcal{S}}\tilde{p}_{s,s^\prime}^{j} = 1, 
#                                   \forall j \in \mathcal{A}
#where
#       d(x,\hat{x}_{s,i})^p = ||x - \hat{x}_{s,i}||, arbitrary norm
#
#Solver: Mosek
#
##Last update: Nov. 08, 2019

from mosek.fusion import *
import subproblem
import math

def solve_ts_benders(sysInfo,s):
    #Using benders to solve the max-min problem given a time t and state s
    with Model("master") as MP:
        pi = MP.variable("pi", sysInfo.numAction, Domain.inRange(0.0,1.0));
        lbd = MP.variable("lbd",1,Domain.greaterThan(0.0));
        kappa = MP.variable("kappa", sysInfo.numData, Domain.inRange(-1000.0, 0))
        tmp = [1]*sysInfo.numAction;
        MP.constraint("c1", Expr.dot(tmp, pi), Domain.equalsTo(1.0));
        objExpr1 = Expr.mul(lbd,  math.pow(sysInfo.theta, sysInfo.normp));
        objExpr2 = Expr.mul(-1, objExpr1);
        tmp = [1]*sysInfo.numData;
        objExpr3 = Expr.dot(tmp, kappa);
        objExpr4 = Expr.mul(1.0/sysInfo.numData, objExpr3);
        #objExpr4 = Expr.add(objExpr4, Expr.dot(pi,sysInfo.rList[s]));
        MP.objective("obj", ObjectiveSense.Maximize, objExpr4);
        
        '''
        print ("obj",MP.primalObjValue());
        print("pi=",pi.level());
        print("lbd=", lbd.level());
        print("kappa=", kappa.level());  
        '''        
        eps = 0.01;             #master probelm and subproblem gap
        
        flag = 1;
        while flag == 1:
            flag = 0;
            MP.solve();
            mpPi = pi.level();      #master solution pi
            mpLbd = lbd.level();    #master solution lambda
            mpKappa = kappa.level();    #master solution kappa
            #print ("obj",MP.primalObjValue());
            #print("pi=",pi.level());
            #print("lbd=", lbd.level());
            #print("kappa=", kappa.level());              
            for i in range(sysInfo.numData):
                subproblem.main(sysInfo, mpPi, mpLbd, s, i);
                #mpKappa should be smaller than subproblem;
                #if mpKappa > subproblem, 
                #add cut: mpKappa <= subproblem
                if mpKappa[i] - sysInfo.subValue > eps:                                       
                    flag = 1;
                    #add benders cut
                    tmpExpr1 = Expr.mul(lbd, sysInfo.coeLambda);
                    tmpExpr2 = Expr.dot(pi, sysInfo.coePi);
                    tmpExpr3 = Expr.add(tmpExpr1, tmpExpr2);
                    MP.constraint(Expr.sub(tmpExpr3, kappa.index(i)),Domain.greaterThan(0.0));
        #converge here, save result
        print("MP.primalObjValue()", MP.primalObjValue());    
        print("pi.level()", pi.level());
        print("lbd.level()", lbd.level());
        sysInfo.currentV.append(MP.primalObjValue());
        sysInfo.currentPi.append(pi.level());
        sysInfo.currentLbd.append(lbd.level());

def main(sysInfo):
    for t in range(sysInfo.T - 1):
    #We don't need to solve the last stage value function;
    #Theoretically, it should be solved backwards.
    #It's only a counter here, and can get a equivalent result 
        sysInfo.currentV = [];
        sysInfo.currentPi = [];
        sysInfo.currentLbd = [];
        for s in range(sysInfo.numState):
            ##results are stored in 
            #sysInfo.pi = [];
            #sysInfo.currentPi = [];
            #sysInfo.v  = [];
            #sysInfo.currentV = [];
            print ("---------------");
            print("t=",t);
            print("s=",s);
            print ("---------------");
            solve_ts_benders(sysInfo,s);
        sysInfo.v.append(sysInfo.currentV);
        sysInfo.pi.append(sysInfo.currentPi);
        sysInfo.lbd.append(sysInfo.currentLbd);
            
            
    
    

    
    
    