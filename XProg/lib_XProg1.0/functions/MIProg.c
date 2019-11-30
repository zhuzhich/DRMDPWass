#include "stdlib.h"
#include "math.h"
#include "time.h"
#include "string.h"
#include "mex.h" 
#include "cplex.h"

/* Constants */
#define DOU_MAX  1.0e+15 
#define DOU_MIN  2.2250e-308
#define MINIMIZE 1
#define MAXITR   500000000
/* Input arguments */
#define PRBM_IN  0
#define GAP_IN   1
#define INT_IN   2
#define ISPT_IN  3
#define ISEX_IN  4
#define NAME_IN  5
/* Output arguments */
#define COST_OUT 0
#define X_OUT    1
#define STAT_OUT 2

void mexFunction (int nlhs, mxArray *plhs[], int nrhs, const mxArray *prhs[])
{
    /* MATLAB memory structures */
    const mxArray *Prbm;
    //const mxArray *GAP;
    //const mxArray *INT;
    const mxArray *A;
    //const mxArray *QC;
    //const mxArray *Q;
    //const mxArray *P;
    const mxArray *Qmat;
    
    mxArray *Cost, *X;
    
    /* Return arguments */
    double *cost_out=NULL;
    double *x_out=NULL;
    double *stat_out=NULL;
    
    char *Name=NULL;
    
    /* Number */
    int RowNum=0, ColNum=0, QCRowNum=0, QCColNum=0, QCNum=0;
    int NZQ=0, NZP=0;
    
    /*Bool */
    int NoInt;
    
    /*Input Data*/
    double *Fun0, *b0, *sn, *LB, *UB, *Bin;
    double *GAPTOL, *INTTOL, *ISPRNT, *ISEX;
    double *Qmat_ptr;
    
    /* A Matrix */ 
    size_t *matind=NULL, *matbeg=NULL;
    double *matval=NULL;
    
    /* Q Matrix */
    size_t *q_ind, *q_beg;
    double *qq_val;
    double **q_val;
    
    /* P Vector */
    size_t *p_ind=NULL, *p_beg=NULL;
    double *p_val=NULL;
    
    /* d Value */
    double *d=NULL;
    
    /* String */
    char *sense=NULL, *ctype=NULL;
    
    /* Status */
    unsigned int status;
  
    /* Time */
    clock_t t0, t1, dt;
    clock_t t01, t02, t03;
    
    /* Cplex */
    CPXENVptr    env;
    CPXLPptr     lp = NULL;
    char         errorMsg[255], statstring[1023];
    
    /* Indices */
    int j=0,i=0,n=0, count=0;
    int *matbeg_int=NULL, *matcnt_int=NULL, *matind_int=NULL;
    int **q_i=NULL, **q_j=NULL;
    int *p_i=NULL;
    
    /* Assign pointers to MATLAB memory stuctures */
    Prbm = prhs[PRBM_IN];
    //GAP  = prhs[GAP_IN ];
 
    A   =mxGetField(Prbm,0,"A");
    GAPTOL=mxGetPr(prhs[GAP_IN]);
    INTTOL=mxGetPr(prhs[INT_IN]);
    ISPRNT=mxGetPr(prhs[ISPT_IN]);
    ISEX  =mxGetPr(prhs[ISEX_IN]);
    Name  =mxArrayToString(prhs[NAME_IN]);
    
    Fun0=mxGetPr(mxGetField(Prbm,0,"Fun"));
    b0  =mxGetPr(mxGetField(Prbm,0,"b"));
    LB  =mxGetPr(mxGetField(Prbm,0,"LB"));
    UB  =mxGetPr(mxGetField(Prbm,0,"UB"));
    sn  =mxGetPr(mxGetField(Prbm,0,"sense"));
    Bin =mxGetPr(mxGetField(Prbm,0,"M"));
    
    RowNum=(int)mxGetM(A);
    ColNum=(int)mxGetN(A);
    matval=mxGetPr(A);
    matbeg=(mwSize *)mxGetJc(A);
    matind=(mwSize *)mxGetIr(A);
    
    Qmat=mxGetField(Prbm,0,"Qmat");
    QCNum=(int)mxGetN(Qmat);
    
    
    sense=(char *)malloc((RowNum)*sizeof(char));
    for(i=0;i<RowNum;i++)
        if(sn[i]==0)
            sense[i]='L';
        else
            sense[i]='E';
    

    plhs[COST_OUT] = mxCreateDoubleMatrix(1     ,1,mxREAL);
    plhs[X_OUT  ]  = mxCreateDoubleMatrix(ColNum,1,mxREAL);
    plhs[STAT_OUT] = mxCreateDoubleMatrix(1     ,1,mxREAL);
    
    cost_out= mxGetPr(plhs[COST_OUT]);
    x_out   = mxGetPr(plhs[X_OUT   ]);
    stat_out= mxGetPr(plhs[STAT_OUT]);
    
    
    matbeg_int=(int *)malloc((ColNum+1)*sizeof(int));
    for(j=0;j<ColNum+1;j++)
        matbeg_int[j]=(int)matbeg[j];
    matcnt_int=(int *)malloc((ColNum)*sizeof(int));
    for(j=0;j<ColNum;j++)
        matcnt_int[j]=(int)(matbeg[j+1]-matbeg[j]);
    matind_int=(int *)malloc(matbeg_int[ColNum]*sizeof(int));
    for(i=0;i<matbeg_int[ColNum];i++)
        matind_int[i]=(int)matind[i];
    
    env = CPXopenCPLEX(&status);
    if (!env) 
    {
        printf(CPXgeterrorstring(env,status,errorMsg));
        mexErrMsgTxt("\nCould not open CPLEX environment.");
    }
    
    /* Create CPLEX Problem Space */
    lp = CPXcreateprob(env, &status, "matlab");
    if (!lp) {
        printf(CPXgeterrorstring(env,status,errorMsg));
        CPXcloseCPLEX(&env);
        mexErrMsgTxt("\nCould not create CPLEX problem.");
    }
    
    /* Copy LP into CPLEX environment */
    status = CPXcopylp(env, lp, ColNum, RowNum, MINIMIZE, Fun0, b0, sense,
		     matbeg_int, matcnt_int, matind_int, matval, LB, UB, NULL);
    
    /* Copy VARTYPE into CPLEX environment */
    NoInt=1;
    for(j=0;j<ColNum;j++)
        if(Bin[j]>0)
        {
            NoInt=0;
            break;
        }
    
    ctype=(char *)malloc((ColNum)*sizeof(char));
    for(j=0;j<ColNum;j++)
    {   
        if(Bin[j]==1)
            ctype[j]='B';
        else
            if(Bin[j]==2)
                ctype[j]='I';
            else
                ctype[j]='C';
    }
    status = CPXcopyctype(env, lp, ctype);
    if (status) 
    {
        printf(CPXgeterrorstring(env,status,errorMsg));
        CPXfreeprob(env,&lp); 
        CPXcloseCPLEX(&env);
    }
       
    
    /* Copy QC into CPLEX environment */
    q_val=(double **)malloc(sizeof(double *)*QCNum);
    q_j=(int **)malloc(sizeof(int *)*QCNum);
    
    qq_val=mxGetPr(Qmat);
    q_beg =(mwSize *)mxGetJc(Qmat);
    q_ind =(mwSize *)mxGetIr(Qmat);
    
    NZP=0;
    p_i=(int *)malloc(sizeof(int)*1);
    p_val=(double *)malloc(sizeof(double)*1);
    p_i=0;
    p_val=0;
    
    for(n=0;n<QCNum;n++)
    {
        NZQ=q_beg[n+1]-q_beg[n];
        q_j[n]=(int *)malloc(sizeof(int)*NZQ);
        q_val[n]=(double *)malloc(sizeof(double)*NZQ);
        for(j=0;j<NZQ;j++)
        {
            q_j[n][j]  =q_ind[q_beg[n]+j];
            q_val[n][j]=qq_val[q_beg[n]+j];
        }      
        CPXaddqconstr(env, lp, NZP, NZQ, 0, 'L', p_i, p_val, q_j[n], q_j[n], q_val[n], NULL);
    }
       
    status = CPXsetdblparam(env, CPX_PARAM_EPGAP, *GAPTOL);
    if (status) 
    {
        printf(CPXgeterrorstring(env,status,errorMsg));
        CPXfreeprob(env,&lp); 
        CPXcloseCPLEX(&env);
        printf("\nCould not set the dual gap.\n");
    }
    
    status = CPXsetdblparam(env, CPX_PARAM_EPINT, *INTTOL);
    if (status) 
    {
        printf(CPXgeterrorstring(env,status,errorMsg));
        CPXfreeprob(env,&lp); 
        CPXcloseCPLEX(&env);
        printf("\nCould not set the integrality.\n");
    }
    
    
    if(*ISEX==1)
    {
        status = CPXwriteprob(env, lp, Name, NULL);
        if (status) 
        {
            printf(CPXgeterrorstring(env,status,errorMsg));
            CPXfreeprob(env,&lp); 
            CPXcloseCPLEX(&env);
            printf("\nCould not export model.\n");
        }
    }
    
    t0=clock();
    
    status = CPXmipopt(env,lp);
    if (status) 
    {
        printf(CPXgeterrorstring(env,status,errorMsg));
        CPXfreeprob(env,&lp); 
        CPXcloseCPLEX(&env);
        printf("\nCould not solve the MIP problem.\n");
    }
    
    t1=clock();
    dt=t1-t0;
    
    *stat_out=(double)CPXgetstat(env,lp);
    
    
    /* get solstat string */
    CPXgetstatstring(env, (int)(*stat_out), statstring);
    
    if(*ISPRNT==1)
    {
        printf("Solution status code=%3.0f\n",*stat_out);
        printf("Solution status: %s\n",statstring);
    }
    if (status) 
    {
        printf(CPXgeterrorstring(env,status,errorMsg));
        CPXfreeprob(env,&lp); 
        CPXcloseCPLEX(&env);
    }
    
    /* Solution */
    status = CPXgetmipobjval(env,lp,cost_out);
    status = CPXgetmipx(env,lp,x_out,0,ColNum-1);
    
    
    
    free(matbeg_int);
    free(matcnt_int);
    free(matind_int);
    //free(errorMsg);
    //free(statstring);
    //return(1);
    
    if(QCNum>0)
        for(n=1;n<QCNum;n++)
        {
            free(q_val[n]);
            //free(q_i[n]);
            free(q_j[n]);
        }
       
    free(q_j);
    free(q_val);
    free(sense);
    free(ctype);
    
    /* Clear up Problem */
    CPXfreeprob(env,&lp); 
    CPXcloseCPLEX(&env);
   
    
    if(*ISPRNT==1)
        printf("Total Computing Time: %fs\n",(double)(dt)/CLOCKS_PER_SEC);
}
    