function plotCSI(Y,Title,Trace,color)
    figure('Name',strcat('CSI Diagram LEO_Trace_',num2str(Trace)));
    plot(1:size(real(Y)),real(Y),color(1),'LineWidth',1); hold on;
    plot(1:size(imag(Y)),imag(Y),color(2),'LineWidth',1); hold off;
    title(strcat(Title,{' '},'of LEO Trace',{' '},num2str(Trace)));
    xlabel('Time');
    ylabel('CSI Value');
    legend({'Real (CSI)','Imag (CSI)'},'Location','southwest');
    legend('boxoff');
end