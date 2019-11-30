clear all;
close all;

start_xprog
%%
%fill the parameters and data
%%
%define system information
sysInfo.T = 3;				%decision stages
sysInfo.numAction = 3;		%number of actions
sysInfo.numState = 5;		%number of states
sysInfo.theta = 3;			%theta for wasserstein distance
sysInfo.normp = 1;			%wassertein distance metric norm
sysInfo.numData = 3;		%the number of data
sysInfo.cost = zeros(sysInfo.numState, sysInfo.numAction);	%cost function

%fill the cost matrix
sysInfo.cost = -1*[0 1 10;...				%state 1
				0 2 20;...				%state 2
				0 3 30;...				%state 3
				0 4 40;...				%state 4
				100000, 100000 50];		%state 5

%qMatrix: maintenance effect matrix, state_from*action*state_to
sysInfo.qMatrix = zeros(sysInfo.numState, ...
					sysInfo.numAction, sysInfo.numState);
							
%fill q matrix
%from state 1
sysInfo.qMatrix(1,:,:) = [1, 0, 0, 0, 0;...		%action 1
					1, 0, 0, 0, 0;...		%action 2
					1, 0, 0, 0, 0];     	%action 3
%from state 2
sysInfo.qMatrix(2,:,:) = [0, 1, 0, 0, 0;...		%action 1
					1, 0, 0, 0, 0;...		%action 2
					1, 0, 0, 0, 0];     	%action 3

%from state 3
sysInfo.qMatrix(3,:,:) = [0, 0, 1, 0, 0;...		%action 1
					0.4, 0.6, 0, 0, 0;...	%action 2
					1, 0, 0, 0, 0];     	%action 3
					
%from state 4
sysInfo.qMatrix(4,:,:) = [0, 0, 0, 1, 0;...		%action 1
					0.3, 0.3, 0.4, 0, 0;...	%action 2
					1, 0, 0, 0, 0];     	%action 3

%from state 5
sysInfo.qMatrix(5,:,:) = [0, 0, 0, 0, 1;...		%action 1
					0, 0, 0, 0, 1;...		%action 2
					1, 0, 0, 0, 0];     	%action 3
					

sysInfo.data = zeros(sysInfo.numData, sysInfo.numState, sysInfo.numState);	%Input data

sysInfo.data(1,:,:) = [0.4, 0.3, 0.2, 0.1, 0;...
                    0, 0.4, 0.3, 0.2, 0.1;...
                    0, 0, 0.4, 0.4, 0.2;...
                    0, 0, 0, 0.5, 0.5;...
                    0, 0, 0, 0, 1];
sysInfo.data(2,:,:) = 	[0.3, 0.4, 0.2, 0.1, 0;...
                    0, 0.3, 0.4, 0.2, 0.1;...
                    0, 0, 0.3, 0.5, 0.2;...
                    0, 0, 0, 0.6, 0.4;...
                    0, 0, 0, 0, 1];
sysInfo.data(3,:,:) = 	[0.5, 0.4, 0.05, 0.03, 0.02;...
                    0, 0.6, 0.25, 0.1, 0.05;...
                    0, 0, 0.3, 0.65, 0.05;...
                    0, 0, 0, 0.8, 0.2;...
                    0, 0, 0, 0, 1];
%output information
sysInfo.output.v = zeros(sysInfo.T, sysInfo.numState);						%optimal value
sysInfo.output.pi = zeros(sysInfo.T-1, sysInfo.numState, sysInfo.numAction);	%optimal pi	
sysInfo.output.lambda = zeros(sysInfo.T-1, sysInfo.numState);									%optimal lambda 
%sysInfo.output.p = zeros(sysInfo.T-1, sysInfo.numState, ...
%					sysInfo.numData,...
%					sysInfo.numState, sysInfo.numState);	%optimal probability matrix

%fill the last stage value vector
sysInfo.output.v(sysInfo.T, :) = -1*[1 3 5 7 80];
for t = sysInfo.T-1: -1: 1
	for s = 1:sysInfo.numState
		%sysInfo does not change within the function
		res = main_chen(sysInfo, t, s);
        isDistributed = 0;              %1: distributed formulation (Corollary 1) of Yang's fomulation
                                        %0: centralized formulation (Corollary 2)
		%res = main_yang(sysInfo, t, s, isDistributed);
		sysInfo.output.v(t, s) = res.v;
		sysInfo.output.pi(t, s,:) = res.pi;
		sysInfo.output.lambda(t, s) = res.lambda;
	end
	%sysInfo.output.p(t, s) = res.p;
end
			





