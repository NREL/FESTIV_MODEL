%Default
%
figure
plot(sum(CASE1DATA.Cost_Result')')
hold
try
plot(sum(CASE2DATA.Cost_Result')')
catch;end;
legend(selectedNames,'interpreter','none','FontSize',14);
xlabel('Time [hr]','FontSize',14);
ylabel('Cost by hour [$/h]','FontSize',14);
title('Cost Comparison');
%
%HECO
%{
figure
plot(sum(CASE1DATA.Cost_Result_NL')')
hold
plot(sum(CASE2DATA.Cost_Result_NL')')
legend(selectedNames,'interpreter','none','FontSize',14);
xlabel('Time [hr]','FontSize',14);
ylabel('Cost by hour [$/MWh]','FontSize',14);
title('Cost Comparison');
%}
