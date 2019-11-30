function h=showsparse(A)

[i,j]=find(A);
[NumOfRow, NumOfCol]=size(A);
hd=plot([1 NumOfCol NumOfCol 1 1],[1 1 NumOfRow NumOfRow 1],'--');
hold on;
h=plot(j,i,'bo');
set(h,'MarkerSize',4,'LineWidth',1.5);
set(hd,'LineWidth',1,'Color','k');
axis([1-NumOfCol*0.1 NumOfCol*1.1 1-NumOfRow*0.2 NumOfRow*1.1]);
set(gca,'YDir','Reverse');
hold off;

xlabel('Column');
ylabel('Row');

grid on;

end