function plotPredAndValidCSI(YPred,YValid,Trace,snr)
    y = cell2mat(YPred);
    figure('Name',strcat('CSI Diagram SNR_',num2str(snr)));
    set(gcf, 'Position', [300, 300, 1000, 400]);
    subplot(1,2,1);
    plot(1:size(y,1)/2,y(1:2:end),'r','LineWidth',1); hold on;
    plot(1:size(y,1)/2,y(2:2:end),'b','LineWidth',1); hold off;
    title(strcat('CSI Channel Prediction of LEO Trace',{' '},num2str(Trace)));
    xlabel('Time(ms)');
    ylabel('CSI Value');
    legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
    legend('boxoff');

    y = cell2mat(YValid);
    subplot(1,2,2);
    plot(1:size(y,1)/2,y(1:2:end),'m','LineWidth',1); hold on;
    plot(1:size(y,1)/2,y(2:2:end),'c','LineWidth',1); hold off;
    title(strcat('CSI Ground Truth of LEO Trace',{' '},num2str(Trace)));
    xlabel('Time(ms)');
    ylabel('CSI Value');
    legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
    legend('boxoff');
end