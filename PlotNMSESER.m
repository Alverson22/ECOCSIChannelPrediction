data = readtable('C:\Users\Kai\Desktop\NCU_HSCC\5G\論文\Simulation FIG\Performance Analysis.xlsx');

NumTest = 4;
NumFeature = 3;
NumData = size(data,1);

x = zeros(NumTest,NumData/NumTest);
y = zeros(NumTest,NumData/NumTest);

for n = 1:NumTest
   
    x(n,:) = data.TrainingNUM((n-1)*3+1:(n-1)*3+3);
    y(n,:) = data.NMSE((n-1)*3+1:(n-1)*3+3);
    % y(n,:) = data.SER((n-1)*3+1:(n-1)*3+3);
   
end

figure();
semilogy(x(1,:),y(1,:),'r-o','LineWidth',1,'MarkerSize',8); hold on;
semilogy(x(2,:),y(2,:),'g-o','LineWidth',1,'MarkerSize',8); hold on;
semilogy(x(3,:),y(3,:),'b-o','LineWidth',1,'MarkerSize',8); hold on;
semilogy(x(4,:),y(4,:),'k-o','LineWidth',1,'MarkerSize',8); hold off;
legend('8','16','32','64','Interpreter','latex');
xlabel('Number of Training Data');
ylabel('NMSE');
% ylabel('SER');