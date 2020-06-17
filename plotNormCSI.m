function plotNormCSI(Y,Title,Trace,color,snr)
    y = cell2mat(Y);
    figure('Name',strcat('CSI Diagram LEO_Track_',num2str(Trace),'_SNR_',num2str(snr)));
    plot(1:size(y,1)/2,y(1:2:end),color(1),'LineWidth',1); hold on;
    plot(1:size(y,1)/2,y(2:2:end),color(2),'LineWidth',1); hold off;
%     plot(1:size(y,1)/2,y(1:2:end),'color',[0 0.4470 0.7410],'LineWidth',1); hold on;
%     plot(1:size(y,1)/2,y(2:2:end),'color',[0.8500 0.3250 0.0980],'LineWidth',1); hold off;
    title(strcat(Title,{' '},'of LEO Trace',{' '},num2str(Trace)));
    xlabel('Time(ms)');
    ylabel('CSI Value');
    legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
    legend('boxoff');
