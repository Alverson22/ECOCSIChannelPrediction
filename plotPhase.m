function plotPhase(phase)
    figure();
    plot(1:size(phase,2),real(phase),'color',[0.8500 0.3250 0.0980],'LineWidth',1); hold on;
    plot(1:size(phase,2),imag(phase),'color',[0 0.4470 0.7410],'LineWidth',1); hold off;
    title("phase shift after bassel funtion");
    xlabel('sample index','Interpreter','latex');
    ylabel('bessel function value','Interpreter','latex');
    legend('Real Phase','Imag Phase','Interpreter','latex','Location','southeast');
    legend('boxoff');
end