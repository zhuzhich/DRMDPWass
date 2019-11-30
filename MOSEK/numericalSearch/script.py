import class_info
import numpy as np
import copy
import main
import mainConcave
import time
#####################
#system information
#####################
sysInfo = class_info.system_info();

sysInfo.T = 3;          #planning horizon
sysInfo.numAction = 3;  #size of action space
sysInfo.numState = 5;   #size of state space
sysInfo.theta = 3;      #wasserstein radius
sysInfo.normp = 1;      #distance metric
                        # support normp = 1, 2. General case normp > 1 is implemented, but 
                        # not 100% sure is correct.
sysInfo.numData = 3;    #number of data

sysInfo.v.append([-1, -3, -5, -7, -80]);
#tmp = np.matrix(sysInfo.vTList);
#sysInfo.vTMatrix = tmp.transpose();     #make it a column vector'

sysInfo.qList = [];     #The mx effects list. For each from_state, it's a 
                        #2-dimensional list: action * to_state.
sysInfo.qMatrix = [];   #The mx effects matrix. For each from_state, it's a 
                        #2-dimensional matrix: action * to_state.
                       
##
#fill the qList and qMatrix
##
#
#from state 1
#-------------
tmp = [[1, 0, 0, 0, 0],     #action 1
        [1, 0, 0, 0, 0],    #action 2
        [1, 0, 0, 0, 0]     #action 3
        ];
sysInfo.qList.append(tmp);
sysInfo.qMatrix.append(np.matrix(tmp));

#from state 2
#-------------
tmp = [[0, 1, 0, 0, 0],     #action 1
        [1, 0, 0, 0, 0],    #action 2
        [1, 0, 0, 0, 0]     #action 3
        ];
sysInfo.qList.append(tmp);
sysInfo.qMatrix.append(np.matrix(tmp));

#from state 3
#-------------
tmp = [[0, 0, 1, 0, 0],         #action 1
        [0.4, 0.6, 0, 0, 0],    #action 2
        [1, 0, 0, 0, 0]         #action 3
        ];
sysInfo.qList.append(tmp);
sysInfo.qMatrix.append(np.matrix(tmp));

#from state 4
#-------------
tmp = [[0, 0, 0, 1, 0],         #action 1
        [0.3, 0.3, 0.4, 0, 0],    #action 2
        [1, 0, 0, 0, 0]         #action 3
        ];
sysInfo.qList.append(tmp);
sysInfo.qMatrix.append(np.matrix(tmp));

#from state 5
#-------------
tmp = [[0, 0, 0, 0, 1],         #action 1
        [0, 0, 0, 0, 1],        #action 2
        [1, 0, 0, 0, 0]         #action 3
        ];
sysInfo.qList.append(tmp);
sysInfo.qMatrix.append(np.matrix(tmp));

#fill r if r is fix
sysInfo.rIsRandom = 0;                      #r is not random, use following fixed r
sysInfo.rList = [[0, -1, -10],               #state 1
                    [0, -2, -20],             #state 2
                    [0, -3, -30],             #state 3
                    [0, -4, -40],             #state 4
                    [-100000, -100000, -50],   #state 5
                    ];  
sysInfo.rMatrix = np.matrix(sysInfo.rList);


##############################################################################
## data information, including transition probability matrix and cost function
##############################################################################
# ------
# data 1
# ------
dataIdx = 1;
dataInfo = class_info.data_info();
dataInfo.idx = dataIdx;
# -----------------------------------------
# data 1: transition probability information
# ------------------------------------------
#state(post action at time t) to state(before action at time t+1)
#transition probability matrix
#state * state
dataInfo.pList = [[0.4, 0.3, 0.2, 0.1, 0],
                    [0, 0.4, 0.3, 0.2, 0.1],
                    [0, 0, 0.4, 0.4, 0.2],
                    [0, 0, 0, 0.5, 0.5],
                    [0, 0, 0, 0, 1]
                ];
dataInfo.pMatrix = np.matrix(dataInfo.pList);
# -----------------------------------------
# data 1: cost function information
# ------------------------------------------
#states*action 
dataInfo.rList = [[0, -1, -10],               #state 1
                    [0, -2, -20],             #state 2
                    [0, -3, -30],             #state 3
                    [0, -4, -40],             #state 4
                    [-100000, -100000, -50],   #state 5
                    ];                  

dataInfo.rMatrix =  np.matrix(dataInfo.rList);
sysInfo.dataInfoAll.append(dataInfo);

##############################################
# ------
# data 2
# ------
dataIdx += 1;
dataInfo = class_info.data_info();
dataInfo.idx = dataIdx;
# -----------------------------------------
# data 2: transition probability information
# ------------------------------------------
#state(post action at time t) to state(before action at time t+1)
#transition probability matrix
#state * state
dataInfo.pList = [[0.3, 0.4, 0.2, 0.1, 0],
                    [0, 0.3, 0.4, 0.2, 0.1],
                    [0, 0, 0.3, 0.5, 0.2],
                    [0, 0, 0, 0.6, 0.4],
                    [0, 0, 0, 0, 1]
                ];
dataInfo.pMatrix = np.matrix(dataInfo.pList);
# -----------------------------------------
# data 2: cost function information
# ------------------------------------------
#states * action 
dataInfo.rList = [[0, -1.5, -15],             #state 1
                    [0, -2, -23],             #state 2
                    [0, -4, -37],             #state 3
                    [0, -7, -48],             #state 4
                    [-100000, -100000, -70],   #state 5
                    ]; 

dataInfo.rMatrix =  np.matrix(dataInfo.rList);
sysInfo.dataInfoAll.append(dataInfo);

##############################################
# ------
# data 3
# ------
dataIdx += 1;
dataInfo = class_info.data_info();
dataInfo.idx = dataIdx;
# -----------------------------------------
# data 3: transition probability information
# ------------------------------------------
#state(post action at time t) to state(before action at time t+1)
#transition probability matrix
#state * state
dataInfo.pList = [[0.5, 0.4, 0.05, 0.03, 0.02],
                    [0, 0.6, 0.25, 0.1, 0.05],
                    [0, 0, 0.3, 0.65, 0.05],
                    [0, 0, 0, 0.8, 0.2],
                    [0, 0, 0, 0, 1]
                ];
dataInfo.pMatrix = np.matrix(dataInfo.pList);
# -----------------------------------------
# data 3: cost function information
# ------------------------------------------
#action * states
dataInfo.rList = [[0, -0.7, -11],               #state 1
                    [0, -2.8, -20],             #state 2
                    [0, -5.5, -40],             #state 3
                    [0, -7.9, -60],             #state 4
                    [-100000, -100000, -80],     #state 5
                    ]; 

dataInfo.rMatrix =  np.matrix(dataInfo.rList);
sysInfo.dataInfoAll.append(dataInfo);

###
#run the problem
##
sysInfo1 = copy.deepcopy(sysInfo);
sysInfo2 = copy.deepcopy(sysInfo);
if 0:
    print ("======================");
    print("in main!!!!!");
    timeS = time.clock();
    main.main(sysInfo1);
    timeE = time.clock();
    print("time elapsed in main is ", timeE-timeS);
    print ("======================");
else:
    print ("======================");
    print("in mainConcave!!!!!");
    timeS = time.clock();
    mainConcave.main(sysInfo2);
    timeE = time.clock();
    print("time elapsed in mainConcave is ", timeE-timeS);












