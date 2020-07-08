function plotPhase(phase)
%     load('EAngle.mat');
%     EAngle = cell2mat(EAngle(1));
    figure();
    plot(1:size(phase,2),real(phase),'color',[0.8500 0.3250 0.0980],'LineWidth',1); hold on;
    plot(1:size(phase,2),imag(phase),'color',[0 0.4470 0.7410],'LineWidth',1); hold off;
%    set(gca,'xtick',1:floor(size(phase,2)/8):size(phase,2),'xticklabel',round(EAngle(1:floor(size(phase,2)/8):size(phase,2))));
    % title("phase shift after bassel funtion");
    title("Phase shift after Euler's formula from South to North",'Interpreter','latex');
%     xlabel('Elevation Angle (deg)','Interpreter','latex');
    xlabel('time (ms)','Interpreter','latex');
    ylabel('bessel function value','Interpreter','latex');
    legend('Real Phase','Imag Phase','Interpreter','latex','Location','southeast');
    legend('boxoff');
end