function configure
clear all
fprintf('Please specify the version of IBM ILOG CPLEX.\n'); 
fprintf('[1] IBM ILOG CPLEX Optimization Studio 12.6.3\n[2] IBM ILOG CPLEX Optimization Studio 12.6.2\n[3] IBM ILOG CPLEX Optimization Studio 12.6.1\n[4] Others\n')
fprintf('\n[0] None\n\n');
        
Prompt1='Your selection is:\n';
S1=input(Prompt1);

if isnumeric(S1)
    switch S1
        case 0 
            return;
        case 1
            %Cplex_dir=[RootDir '\CPLEX_Studio1263'];
            Cplex_v='1263';
        case 2
            %Cplex_dir=[RootDir '\CPLEX_Studio1262'];
            Cplex_v='1262';
        case 3 
            %Cplex_dir=[RootDir '\CPLEX_Studio1261'];
            Cplex_v='1261';
        case 4
            Cplex_v='';
        otherwise
            error('Incorrect input');
    end
else
    error('Incorrect input.');
end

S0='n';
if S1==4
    Prompt0='Please specify the version of the CPLEX solver.\n';
    S2=input(Prompt0,'s');
    if isempty(S2)
        error('The version of the CPLEX solver is unknown.\n');
    end
    Digits = regexp(S2,'\d*','Match');
    Cplex_v=[];
    for nd=1:length(Digits)
        Cplex_v=[Cplex_v Digits{nd}];
    end
else
    Prompt0=['Is CPLEX Optimization Studio ' Cplex_v ' installed in the default directory[y]/n?\n'];
    S0=input(Prompt0,'s');
    if isempty(S0)
        S0='y';
    end
end

if S0=='y'&&S1~=4
    CDir=cd;
    switch S1
        case 1
            copyfile([CDir '\functions\solvers\CPLEX1263\MIProg.mexw32'],[CDir '\functions']);
            copyfile([CDir '\functions\solvers\CPLEX1263\MIProg.mexw64'],[CDir '\functions']);
        case 2
            copyfile([CDir '\functions\solvers\CPLEX1262\MIProg.mexw32'],[CDir '\functions']);
            copyfile([CDir '\functions\solvers\CPLEX1262\MIProg.mexw64'],[CDir '\functions']);
        case 3 
            copyfile([CDir '\functions\solvers\CPLEX1261\MIProg.mexw32'],[CDir '\functions']);
            copyfile([CDir '\functions\solvers\CPLEX1261\MIProg.mexw64'],[CDir '\functions']);
    end
else
    Prompt1='Please specify the directory of IBM ILOG CPLEX solver.\n';
    S3=input(Prompt1,'s');
    Cplex_dir=S3;
    
    MEXEXT=mexext;
    if strcmp(MEXEXT,'mexw64')
        %RootDir='C:\Program Files\IBM\ILOG';
        LibVer ='x64_windows_vs2010';
    else
        LibVer ='x86_windows_vs2010';
        %RootDir='C:\Program Files (x86)\IBM\ILOG';
    end
    
    Lib=[Cplex_dir '\cplex\lib\' LibVer '\stat_mta'];
    Include=[Cplex_dir '\cplex\include\ilcplex'];
    LibFile=['cplex' Cplex_v];
    
    Tex3=['mex -largeArrayDims  ' '-L"' Lib '"  -I"' Include '"  -l"' LibFile '"  ' 'MIProg.c'];

    CDir=cd;
    cd([CDir '\functions'])
    eval(Tex3);
    cd(CDir);

    fprintf('Solvers have been compiled successfully.\n');
end

fprintf('XProg configuration completed!\n');

end

