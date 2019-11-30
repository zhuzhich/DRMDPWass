function [K,b]= pwisefun(X,Y)

K=(Y(:,2:end)-Y(:,1:end-1))./(X(:,2:end)-X(:,1:end-1));
b=Y(:,1:end-1)-K.*X(:,1:end-1);

K=K;
b=b;

end

