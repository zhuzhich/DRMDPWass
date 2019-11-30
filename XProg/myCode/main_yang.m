%main function to solve DRMDP with Wasserstein uncertainty set

function res = main_yang(sysInfo, currentT, currentS, isDistributed)
%R, U, M, N, Zs, para_theta
%R: cost function
%U: last stage value function
%M+1: # of action
%N+1: # of states
%Zs: data 

if isDistributed
    %distributed, corollary 1
    model = xprog('ro');
    model.Param.IsPrint = 1;
    % define decision
    piDec = model.decision(sysInfo.numAction);
    lbd = model.decision(1);

    %uncertain decision variable
    pMatrix = cell(sysInfo.numData, 1);
    pVector = cell(sysInfo.numData, 1);
    %dist = cell(sysInfo.numData, 1);
    axU = cell(sysInfo.numData,1);
    axV = cell(sysInfo.numData,1);

    for i = 1:sysInfo.numData
        axU{i} = model.random(sysInfo.numState*sysInfo.numState);
        axV{i} = model.random(sysInfo.numState*sysInfo.numState);
        pMatrix{i} = model.random(sysInfo.numState, sysInfo.numState);
        pVector{i} = model.random(sysInfo.numState*sysInfo.numState);
        row = 1;
        col = 1;
        %add constraint to bind pMatrix and pVector
        for j = 1:sysInfo.numState*sysInfo.numState
            model.uncertain(pMatrix{i}(row, col) == pVector{i}(j));
            col = col + 1;
            if col > sysInfo.numState
                row = row + 1;
                col = 1;
            end
        end
        %add the support for trans. prob.
        model.uncertain(pMatrix{i} >= 0);
        %model.uncertain(pVector{i} >= 0);
        model.uncertain(sum(pMatrix{i},2) == ones(sysInfo.numState,1));
    end

    %add the objective function
    objExpr = -lbd*sysInfo.theta;
    dataV = (sysInfo.output.v(currentT+1,:))';
    dataQ = squeeze(sysInfo.qMatrix(currentS,:,:));

    for i = 1:sysInfo.numData
        tmp1 = sysInfo.cost(currentS,:)*piDec + (dataQ*pMatrix{i}*dataV)'*piDec;
        tmpDataP = squeeze(sysInfo.data(i,:,:));
        tmpDataP = tmpDataP';
        tmpDataP = reshape(tmpDataP,[],1);
        %%add constraint
        %u{i} = pVector{i} - tmpDataP
        %v{i} = abs(u{i})
        model.uncertain(pVector{i} - tmpDataP == axU{i});
        model.uncertain(abs(axU{i}) <= axV{i});
        tmp2 = lbd*sum(axV{i});
        tmp = 1/sysInfo.numData*(tmp1+tmp2);
        objExpr = objExpr + tmp;
    end

    model.max(objExpr);

    % define constraint
    model.add(piDec >= 0);
    model.add(sum(piDec) == 1);
    model.add(lbd >= 0);

    model.solve;

    %res.v = model.Solution.Objective;
    res.v = model.get;
    res.pi = piDec.get;
    res.lambda = lbd.get;

else
    %centralized, corollary 2

    model = xprog('ro');
    model.Param.IsPrint = 1;
    % define decision
    piDec = model.decision(sysInfo.numAction);

    %uncertain decision variable
    pMatrix = cell(sysInfo.numData, 1);
    pVector = model.random(sysInfo.numState*sysInfo.numState, sysInfo.numData);
    %dist = cell(sysInfo.numData, 1);
    %axU = cell(sysInfo.numData,1);
    axV = model.random(sysInfo.numState*sysInfo.numState, sysInfo.numData);


    for i = 1:sysInfo.numData
        %axU{i} = model.random(sysInfo.numState*sysInfo.numState);
        pMatrix{i} = model.random(sysInfo.numState, sysInfo.numState);
        %pVector{i} = model.random(sysInfo.numState*sysInfo.numState);
        row = 1;
        col = 1;
        %add constraint to bind pMatrix and pVector
        for j = 1:sysInfo.numState*sysInfo.numState
            model.uncertain(pMatrix{i}(row, col) == pVector(j,i));
            col = col + 1;
            if col > sysInfo.numState
                row = row + 1;
                col = 1;
            end
        end
        %add the support for trans. prob.
        model.uncertain(pMatrix{i} >= 0);
        model.uncertain(pMatrix{i} <= 1);

        %model.uncertain(sum(pMatrix{i},2) == ones(sysInfo.numState,1));
        for k = 1:sysInfo.numState
            %model.uncertain(sum(pVector{i}(k*sysInfo.numState:k*sysInfo.numState-1)) == 1);
            model.uncertain(sum(pMatrix{i}(k,:)) == 1);
        end
    end
    model.uncertain(pVector >= 0);
    model.uncertain(axV >= 0);
    model.uncertain(axV <= 1);
    model.uncertain(pVector <= 1);

    %add constraint for uncertainty set
    for i = 1:sysInfo.numData
        tmpDataP = squeeze(sysInfo.data(i,:,:));
        tmpDataP = tmpDataP';
        tmpDataP = reshape(tmpDataP,[],1);
        model.uncertain(abs(pVector(:,i) - tmpDataP) <= axV(:,i));
        %model.uncertain(sum(axU{i}) == axV(i));
    end
    model.uncertain(sum(sum(axV)) <= sysInfo.numData*sysInfo.theta);

    %add the objective function
    objExpr = 0;
    dataV = (sysInfo.output.v(currentT+1,:))';
    dataQ = squeeze(sysInfo.qMatrix(currentS,:,:));

    for i = 1:sysInfo.numData
        tmp = sysInfo.cost(currentS,:)*piDec + (dataQ*pMatrix{i}*dataV)'*piDec;
        objExpr = objExpr + tmp;
    end

    model.max(1/sysInfo.numData*objExpr);

    % define constraint
    model.add(piDec >= 0);
    model.add(sum(piDec) == 1);

    model.solve;

    %res.v = model.Solution.Objective;
    res.v = model.get;
    res.pi = piDec.get;
    res.lambda = -1;		%dummy
end 
end 
