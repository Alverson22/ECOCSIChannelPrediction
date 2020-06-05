function plotNormCSI(Y,Title,Trace,color)
    y = cell2mat(Y);
    figure('Name',strcat('CSI Diagram LEO_Trace_',num2str(Trace)));
    plot(1:size(y,1)/2,y(1:2:end),color(1),'LineWidth',1); hold on;
    plot(1:size(y,1)/2,y(2:2:end),color(2),'LineWidth',1); hold off;
    title(strcat(Title,{' '},'of LEO Trace',{' '},num2str(Trace)));
    xlabel('Time(ms)');
    ylabel('CSI Value');
    legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
    legend('boxoff');
