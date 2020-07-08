function plotCSI(Y,Title,Trace,color,snr)

    figure('Name',strcat('CSI Diagram LEO_Track_',num2str(Trace),'_SNR_',num2str(snr)));
    
    plot(1:size(real(Y)),real(Y),'color',color(1),'LineWidth',1); hold on;
    plot(1:size(imag(Y)),imag(Y),'color',color(2),'LineWidth',1); hold on;
%    plot(1:size(real(Y)),real(Y),'color',[0 0.4470 0.7410],'LineWidth',1); hold on;
%    plot(1:size(imag(Y)),imag(Y),'color',[0.8500 0.3250 0.0980],'LineWidth',1); hold off;

    title(strcat(Title,{' '},'of LEO Track',{' '},num2str(Trace)),'Interpreter','latex');
%     title(strcat(Title,{' '},'of Rainy Condition'),'Interpreter','latex');
%     title(strcat(Title,{' '},'of Channel Gain',{' '},num2str(H),{' '},num2str(abs(H)),{' '},num2str(sign(real(H))),{' '},num2str(sign(imag(H)))),'Interpreter','latex');

%     [M, I] = max(real(Y)); % find largest point
%     rPoint = [I M];
%     [M, I] = min(real(Y)); % find lowest point
%     rPoint = [rPoint; I M];
%     [M, I] = min(abs(real(Y))); % find the point nearest to zero
%     rPoint = [rPoint; I M];
%     plot(rPoint(:,1),rPoint(:,2),'s','MarkerSize',10,'MarkerFaceColor',color(1));
%     text(rPoint(:,1),rPoint(:,2),strcat({'  '},num2str(rPoint(:,1))));
%     
%     [M, I] = max(imag(Y)); 
%     iPoint = [I M];
%     [M, I] = min(imag(Y));
%     iPoint = [iPoint; I M];
%     [M, I] = min(abs(imag(Y))); % find the point nearest to zero
%     iPoint = [iPoint; I M];
%     plot(iPoint(:,1),iPoint(:,2),'s','MarkerSize',10,'MarkerFaceColor',color(2));
%     text(iPoint(:,1),iPoint(:,2),strcat({'  '},num2str(iPoint(:,1)))); hold off;
    
    legend('Max Real $(h)$','Max Imag $(h)$','Interpreter','latex');
    xlabel('Time (ms)','Interpreter','latex');
    ylabel('CSI Value $(h)$','Interpreter','latex');
    legend('Real $(h)$','Imag $(h)$','Interpreter','latex','Location','southwest');
    legend('boxoff');
    
    
end