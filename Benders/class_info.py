from scipy.stats import gamma
from scipy.stats import f
#####################################
#class info
#####################################
class data_info():
    '''
	def transProb(self, stateFrom, stateTo, inspItvl):
		if stateFrom > stateTo:
			return 0;
		stepSize = self.failTsh/(self.nStates - 1); 	#step size for normal states 
		degFrom = stateFrom * stepSize;			#degradation lower bound of the state
		degToU = (stateTo + 1) * stepSize;		#degradation upper bound of the state
		degToL = stateTo * stepSize;			#degradation lower bound of the state
		if (0):
		## random effect model.
			if stateTo >= self.nStates - 1:
				deltaDeg = self.failTsh - degFrom;
				tmp = self.gammaAlpha[0]*inspItvl**self.gammaAlpha[1];
				x = deltaDeg*self.gammaBeta[0]*self.gammaBeta[1]/(tmp);
				prob = 1-f.cdf(x,2*tmp,2*self.gammaBeta[0]);
			else:
				tmp = self.gammaAlpha[0]*inspItvl**self.gammaAlpha[1];
				deltaDeg1 = degToU - degFrom;
				x1 = deltaDeg1*self.gammaBeta[0]*self.gammaBeta[1]/(tmp);
				prob1 = f.cdf(x1, 2*tmp,2*self.gammaBeta[0]);
				deltaDeg2 = degToL - degFrom;
				x2 = deltaDeg2*self.gammaBeta[0]*self.gammaBeta[1]/(tmp);
				prob2 = f.cdf(x2, 2*tmp,2*self.gammaBeta[0]);
				prob = prob1 - prob2;	
			return prob;
		if (1):
			#no random effect model
			if stateTo >= self.nStates - 1:
				deltaDeg = self.failTsh - degFrom;
				prob = 1 - gamma.cdf(deltaDeg, self.gammaAlpha*inspItvl, scale=self.gammaBeta);
			else:
				deltaDeg1 = degToU - degFrom;
				prob1 = gamma.cdf(deltaDeg1, self.gammaAlpha*inspItvl, scale=self.gammaBeta);
				deltaDeg2 = degToL - degFrom;
				prob2 = gamma.cdf(deltaDeg2, self.gammaAlpha*inspItvl, scale=self.gammaBeta);
				prob = prob1 - prob2;
			return prob;
	
	def update_currentToFail(self):
		self.currentToFail = self.transProb(self.initState, self.nStates-1, self.inspItvl);
    '''		
    def __init__(self):
        self.idx = 0;
        self.pList = [];
        self.pMatrix = [];
        self.rList = [];
        self.rMatrix = [];

		
		
#system information
#parameters
class system_info():
    def __init__(self):
        self.T = 0;
        self.numAction = 0;
        self.numState = 0;
        self.numData = 0;
        self.theta = 0;
        self.normp = 0;
        #sysInfo.vTList = [];
        #sysInfo.vTMatrix = [];
        self.qList = [];
        self.qMatrix = [];
        self.rIsRandom = 0;
        self.rList = 0;
        self.rMatrix = 0;
        self.dataInfoAll = [];
        #results;
        self.pi = [];
        self.currentPi = [];    #state * action
        self.v  = [];
        self.currentV = [];
        #running info for subproblem
        self.coeLambda = 0;
        self.coePi = 0;
        self.subValue = 0;
        
        
        
        