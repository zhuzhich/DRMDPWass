##Author: Zhicheng Zhu
#Email: zhicheng.zhu@ttu.edu, yisha.xiang@ttu.edu
#copyright @ 2019: Zhicheng Zhu. All right reserved.
#
#Use Benders decomposition to solve the max-min problem is distributionally robust Markov decision model
#This file is to solve the subproblem
#
#Problem overview:
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
##Last update: Nov. 10, 2019

from mosek.fusion import *
import numpy as np


def norm_constraint(SP, x, y, normp):
    if normp < 1:
        print ("ERROR: unacceptable norm", normp);
    # x >= ||y||_normp^normp
    #support normp=1 and normp=2, the correctness of other normp is unknown, though I
    #have implemented based on my best understanding.
    if normp == 1:
        # x >= \sum_i ||y_i||
        # fusion book, p33
        u = SP.variable(y.getShape(), Domain.unbounded());
        #u_i > |x_i| \forall i   -> u_i > x_i & u_i > -x_i
        SP.constraint(Expr.add(u, y), Domain.greaterThan(0.0));
        SP.constraint(Expr.sub(u, y), Domain.greaterThan(0.0));
        #& sum u_i <= x #!!!!!Question: why it is not "=" here?
        SP.constraint(Expr.sub(x, Expr.sum(u)),  Domain.greaterThan(0.0));
    elif normp == 2:
        # x >= sum_i |y_i|^2 -> (0.5, x, y) in quadratic rot cone();
        # funsion book square or example: modelLib.py
        SP.constraint(Expr.vstack(0.5, x, y), Domain.inRotatedQCone());
    else:
        # norm > 1
        # x >= sum_i |y_i|^p -> sum u_i <= x, u_i >= |y_i|^p
        u = SP.variable(y.getShape(), Domain.unbounded());
        SP.constraint(Expr.sub(x, Expr.sum(u)),  Domain.greaterThan(0.0));
        for i in range(y.getShape()):
            SP.constraint(Expr.vstack(u.index(i), 1, y.index(i)),\
                        Domain.inPPowerCone(1.0/normp));
    
def main(sysInfo, pi, lbd, s, i):
    with Model("subproblem") as SP:        
        #==================
        #Decision variables
        #==================
        #pDec: decision variable of p with size state*state
        pDec = SP.variable("p", [sysInfo.numState,sysInfo.numState], \
                        Domain.inRange(0.0,1.0));
        #pDecReshape: in vector
        pDecReshape = SP.variable(sysInfo.numState*sysInfo.numState, Domain.inRange(0.0,1.0));
        
        ##auxilary variables:
        #ppDec = pDec - p, where p is the observed transition prob 
        ppDec = SP.variable("pp", [sysInfo.numState, sysInfo.numState],\
                            Domain.unbounded());#Domain.inRange(-1.0,1.0)); 
        #vector of ppDec
        ppDecReshape = SP.variable(sysInfo.numState*sysInfo.numState, \
                            Domain.unbounded());#Domain.inRange(-1.0,1.0));
        
        #the distance of transition prob
        aDec = SP.variable(Domain.greaterThan(0.0));   

        #============
        #constraints
        #============
        #constraint 1: link (pDec & pDecReshape), and (ppDec, ppDecReshape)
        #not sure if this is necessary
        counter = 0;
        for sFrom in range(sysInfo.numState):
            for sTo in range(sysInfo.numState):
                SP.constraint(Expr.sub(pDec.index(sFrom, sTo), \
                                        pDecReshape.index(counter)),\
                                        Domain.equalsTo(0.0));
                SP.constraint(Expr.sub(ppDec.index(sFrom, sTo), \
                                        ppDecReshape.index(counter)),\
                                        Domain.equalsTo(0.0));
                counter += 1;
        
        #constraint 2: probability sum-up is 1
        #sum(row*column, 1) -> row*1
        SP.constraint(Expr.sum(pDec, 1), Domain.equalsTo(1.0));
       
        '''
        startPos = 0;
        length = sysInfo.numState*sysInfo.numState;
        tmp = [0]*length;
        while (startPos < length):
            for s in range(sysInfo.numState):
                tmp[startPos] = 1;
                startPos += 1;
            SP.constraint(Expr.dot(tmp, pDecReshape), Domain.equalsTo(1.0));
            tmp = [0]*length;
        '''
        
        #constraint 3: ppDec = pDec - p;
        tmpExpr1 = Expr.sub(pDec, sysInfo.dataInfoAll[i].pMatrix);
        tmpExpr2 = Expr.sub(ppDec, tmpExpr1);
        SP.constraint(tmpExpr2, Domain.equalsTo(0.0));

        #constraint 4: the constraints for distance based on normp
        norm_constraint(SP, aDec, ppDecReshape, sysInfo.normp);   #aDec >= ||ppDec||_normp^normp
        
        
        if sysInfo.rIsRandom == 1:#if the cost function is random or not
            #decision variable
            rDec = SP.variable("r", sysInfo.numAction, Domain.greaterThan(0.0));
            #rrDec = rDec - r, where r is the observed cost
            rrDec = SP.variable("rr", sysInfo.numAction, Domain.greaterThan(0.0)); 
            #the distance of cost
            bDec = SP.variable(Domain.greaterThan(0.0));
            
            #constraint : rrDec = rDec -r;
            tmpExpr1 = Expr.sub(rDec, sysInfo.dataInfoAll[i].rList[s]);
            tmpExpr2 = Expr.sub(rrDec, tmpExpr1);
            SP.constraint(tmpExpr2, Domain.equalsTo(0.0));
            #constraint distance
            norm_constraint(SP, bDec, rrDec, sysInfo.normp);   #bDec >= ||rrDec||_normp^normp
            #objecctive function
            objExpr1 = Expr.dot(rDec, pi);   #r^t*pi
            objExpr2 = Expr.mul(lbd, Expr.add(aDec, bDec)); #lambda(a+b)
            objExpr3 = Expr.add(objExpr1, objExpr2); 
        else:
            piMatrix = np.matrix(pi);       #row vector    
            objExpr1 = sysInfo.rMatrix[s]*piMatrix.transpose(); #r*pi
            objExpr1 = objExpr1.tolist();
            objExpr1 = objExpr1[0][0];
            objExpr2 = Expr.mul(lbd, aDec); #lambda(a+b)
            objExpr3 = Expr.add(objExpr1, objExpr2); 
            
   
        objExpr4 = Expr.mul(sysInfo.qList[s], pDec);          #q*p 
        objExpr5 = Expr.mul(objExpr4, sysInfo.v[-1]);         #q*p*vt   
        objExpr6 = Expr.mul(Expr.transpose(objExpr5), pi);  #qpv_tpi
        objExpr7 = Expr.add(objExpr3, objExpr6);
        #objExpr8 = Expr.mul(-1, objExpr7);
                   
        SP.objective("spobj", ObjectiveSense.Minimize, objExpr7);
        SP.solve();
        print("problem status", SP.getProblemStatus());
        print("primal solution status", SP.getPrimalSolutionStatus());
        
        
        print ("obj",SP.primalObjValue());
        print("pDec=",pDec.level());
    
        sysInfo.subValue = SP.primalObjValue();
        if sysInfo.rIsRandom == 1:
            print("rDec=", rDec.level());
            sysInfo.coeLbd = aDec.level() + bDec.level();
            sysInfo.coePi = rDec.level()+sysInfo.qMatrix[s]*pDec.level()*sysInfo.v[-1];
        else:
            #get sysInfo.coeLbd into the right shape (a number)
            tmp = aDec.level();
            sysInfo.coeLbd = tmp[0];
            #get r into the right shape
            tmp1 = sysInfo.rMatrix[s]
            tmp2 = tmp1.transpose();
            #tmp2 = 0;
            #get pDec into the right shape
            tmp3 = pDec.level();
            tmp4 = np.matrix(tmp3);
            tmp5 = tmp4.reshape(sysInfo.numState, sysInfo.numState);
            #get v into the right shape
            tmp6 = sysInfo.v[-1];
            tmp7 = np.matrix(tmp6);
            tmp8 = tmp7.transpose();
            #get sysInfo.coePi into right shape (a list)
            tmp = tmp2 + sysInfo.qMatrix[s]*tmp5*tmp8;
            tmp = tmp.tolist();
            sysInfo.coePi = [];
            for i in range(sysInfo.numAction):
                sysInfo.coePi.append(tmp[i][0]);
            print("coeLbd", sysInfo.coeLbd);
            print("coePi", sysInfo.coePi);
            xx=1;
           
            
            
    