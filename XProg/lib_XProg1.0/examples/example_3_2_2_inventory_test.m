S=100;                             % number of samples

Cost=zeros(1,S);                   
for s=1:S
    R=rand(1,T);                   % uniformly distributed random numbers 
    randD=d0.*(1-delta+2*delta*R); % sample of random demand
    P_dr=p.test(randD);            % decision rule policy
    Cost(s)=sum(sum(c.*P_dr));     % total cost for this sample
end