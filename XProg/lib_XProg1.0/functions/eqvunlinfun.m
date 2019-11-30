function UnLinFun = eqvunlinfun(Fun)
    if isprogram(Fun)
        NOR=size(Fun,1);
        NOC=size(Fun,2);
        NOE=NOR*NOC;
        %NODV=Fun.Model.Dimension(2);
        %NORV=Fun.Model.XProg.Uncertain.Dimension(2);
        NOPV=Fun.Model.XProg.NumOfPrim;
        NORV=Fun.Model.XProg.NumOfRand;
        if isa(Fun,'variable')
            Fun=speye(NOR)*Fun;
        end
        checkclass(Fun,'linfun');
        NewRandMat=spalloc(NOR*NORV,NOC*NOPV,0);
        NewRandVec=spalloc(NORV,NOE,0);
        UnLinFun=unlinfun(Fun.Model.XProg,Fun.Dimension,NewRandMat,Fun.getmatrix,NewRandVec,Fun.getconstant);
    elseif isuncertain(Fun)
        NOR=size(Fun,1);
        NOC=size(Fun,2);
        NOE=NOR*NOC;
        %NODV=Fun.Model.XProg.Program.Dimension(2);
        %NORV=Fun.Model.Dimension(2);
        NOPV=Fun.Model.XProg.NumOfPrim;
        NORV=Fun.Model.XProg.NumOfRand;
        if isa(Fun,'variable')
            Fun=speye(NOR)*Fun;
        end
        NewRandMat=spalloc(NOR*NORV,NOC*NOPV,0);
        NewRandVec=Fun.getmatrix;
        NewRandVec=NewRandVec';
        NewMatrix=spalloc(NOE,NOPV,0);
        UnLinFun=unlinfun(Fun.Model.XProg,Fun.Dimension,NewRandMat,NewMatrix,NewRandVec,Fun.getconstant);
    else
        error('Incorrect input arguments.');
    end
end

