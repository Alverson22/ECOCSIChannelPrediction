function plotCSI(Y,Title,Trace,color,snr)
    figure('Name',strcat('CSI Diagram LEO_Track_',num2str(Trace),'_SNR_',num2str(snr)));
    plot(1:size(real(Y)),real(Y),'color',color(1),'LineWidth',1); hold on;
    plot(1:size(imag(Y)),imag(Y),'color',color(2),'LineWidth',1); hold off;
%     plot(1:size(real(Y)),real(Y),'color',[0 0.4470 0.7410],'LineWidth',1); hold on;
%     plot(1:size(imag(Y)),imag(Y),'color',[0.8500 0.3250 0.0980],'LineWidth',1); hold off;
    title(strcat(Title,{' '},'of LEO Trace',{' '},num2str(Trace)));
    xlabel('Time');
    ylabel('CSI Value');
    legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
    legend('boxoff');
end