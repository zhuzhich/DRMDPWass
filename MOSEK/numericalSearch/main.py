
##Author: Zhicheng Zhu
#Email: zhicheng.zhu@ttu.edu, yisha.xiang@ttu.edu
#copyright @ 2019: Zhicheng Zhu. All right reserved.
#
#Use numerical way to solve the max-min problem is distributionally robust Markov decision model
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
import numpy as np
import math

def solve_ts_num(sysInfo,s):
    #Using numerical way to solve the max-min problem given a time t and state s
    #decision variable: lambda & pi
    
    #only works for 3 actions!!!
    lbd = -0.1;
    bestLbd = lbd;
    bestObjLbd = -10000;
    newObjLbd = bestObjLbd + 1;
    bestLbdPi = [];
    bestPi = [];
    flagUp = 0;
    while (lbd < 30):#(newObjLbd > bestObjLbd):      
        if newObjLbd > bestObjLbd:
            flagUp = 1;
            bestObjLbd = newObjLbd;
            bestLbd = lbd;
            bestLbdPi = bestPi;
        elif flagUp == 1:
            flagUp = 0;
            print("FROM UP TO DOWN!");
            #print ("bestLbd",bestLbd);
        #print ("lbd", lbd);
        #print ("bestLbd",bestLbd);
        #print ("bestLbdPi",bestLbdPi);
        #print ("newObjLbd",newObjLbd);
        #print ("bestObjLbd",bestObjLbd);       
        lbd += 0.1;
        bestObjPi = -10000;
        bestPi = [];
        for i1 in np.arange(0,1+0.05,0.05):
            for i2 in np.arange(0,1+0.05,0.05):
                i3 = 1 - i1 - i2;
                if i3 >= 0:
                    mpPi = [i1, i2, i3];
                    mpLbd = lbd;
                    currentObjPi = -mpLbd*math.pow(sysInfo.theta, sysInfo.normp);
                    tmpObj = 0;
                    for i in  range(sysInfo.numData):
                        subproblem.main(sysInfo, mpPi, mpLbd, s, i);
                        tmpObj += sysInfo.subValue;
                    currentObjPi = currentObjPi + tmpObj/sysInfo.numData;
                    if currentObjPi > bestObjPi:
                        bestPi = mpPi;
                        bestObjPi = currentObjPi;
        #print ("bestPi",bestPi);
        newObjLbd = bestObjPi;
        
    print("bestObjLbd", bestObjLbd);    
    print("bestLbdPi", bestLbdPi);
    print("bestLbd", bestLbd);
    sysInfo.currentV.append(bestObjLbd);
    sysInfo.currentPi.append(bestLbdPi);
    sysInfo.currentLbd.append(bestLbd);

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
            solve_ts_num(sysInfo,s);
        sysInfo.v.append(sysInfo.currentV);
        sysInfo.pi.append(sysInfo.currentPi);
        sysInfo.lbd.append(sysInfo.currentLbd);
            
            
    
    

    
    
    