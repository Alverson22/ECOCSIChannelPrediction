function plotCompare(LS,GRU,Title,color,snr,n)
    load('EAngle.mat');
    load('EstChanLSTM.mat');
    EAngle = cell2mat(EAngle(n));
%     LSStart = size(LS) - size(EstChanLSTM);
%     GRUStart = size(GRU) - size(EstChanLSTM);
    LSStart = size(LS) - size(GRU);
    GRUStart = 0;

    figure('Name',strcat('CSI Diagram LEO_Track_',num2str(n),'_SNR_',num2str(snr)));
    % plot(1:size(real(EstChanLSTM)),real(EstChanLSTM),'color',[1 0 0],'LineStyle','-','LineWidth',1); hold on;
    % plot(1:size(imag(EstChanLSTM)),imag(EstChanLSTM),'color',[1 0.5 0.5],'LineStyle','--','LineWidth',1); hold on;
    plot(GRUStart+1:size(real(GRU)),real(GRU(GRUStart+1:end)),'color',color(3,:),'LineStyle','-','LineWidth',1); hold on;
    % plot(GRUStart+1:size(imag(GRU)),imag(GRU(GRUStart+1:end)),'color',color(4,:),'LineStyle','--','LineWidth',1); hold on;
    plot(LSStart+1:size(real(LS)),real(LS(LSStart+1:end)),'color',color(1,:),'LineStyle','-','LineWidth',1); hold on;
    % plot(LSStart+1:size(imag(LS)),imag(LS(LSStart+1:end)),'color',color(2,:),'LineStyle','--','LineWidth',1); hold on;

    set(gca,'xtick',1:floor(size(GRU)/8):size(GRU),'xticklabel',round(EAngle(1:floor(size(GRU)/8):size(GRU))));

%    title(strcat(n,{' '},'of LEO Track',{' '},num2str(n)),'Interpreter','latex');    
    
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
%     text(iPoint(:,1),iPoint(:,2),strcat({'  '},num2str(iPoint(:,1))));
    
%    legend('Max Real $(h)$','Max Imag $(h)$','Interpreter','latex');
    xlabel('Elevation Angle (deg)','Interpreter','latex');
    ylabel('CSI Value $(h)$','Interpreter','latex');
%    legend('Ground Truth Real $(h)$','Ground Truth Imag $(h)$','APF-RNS Real $(h)$','APF-RNS Imag $(h)$','GRU Real $(h)$','GRU Imag $(h)$','Interpreter','latex','Location','Northwest');
    legend('GRU Real $(h)$','Ground Truth Real $(h)$','Interpreter','latex','Location','Northwest');
%     legend('Real $(h)$','Interpreter','latex','Location','southwest');
    legend('boxoff');
    
end