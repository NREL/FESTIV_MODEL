figure
plot(ACE(:,ACE_time_index),ACE(:,raw_ACE_index:CPS2_ACE_index));
title('ACE levels')
legend('raw Ace','Continuous integrated ACE','CPS2 ACE')
fig1=gcf;
figure
plot(ACTUAL_GENERATION(:,1),ACTUAL_GENERATION(:,2:ngen+1) - ACTUAL_PUMP(:,2:ngen+1))
title('Actual Generation')
legend(GEN.uels','interpreter','none')
fig2=gcf;
figure
plot(DASCUCLMP(:,1),DASCUCLMP(:,2:nbus+1))
title('Day-Ahead prices')
legend(BUS.uels','interpreter','none')
fig3=gcf;
figure
plot(RTSCEDBINDINGLMP(:,1),RTSCEDBINDINGLMP(:,2:nbus+1))
title('Real-Time prices')
legend(BUS.uels','interpreter','none')
fig4=gcf;
figure
plot(RTSCEDBINDINGSCHEDULE(:,1),RTSCEDBINDINGSCHEDULE(:,2:ngen+1)-RTSCEDBINDINGPUMPSCHEDULE(:,2:ngen+1))
title('RTSCED Schedules')
legend(GEN.uels','interpreter','none')
fig5=gcf;
%{
figure
plot(RTSCUCBINDINGSCHEDULE(1:RTSCUC_binding_interval_index-1,1),RTSCUCBINDINGSCHEDULE(1:RTSCUC_binding_interval_index-1,2:ngen+1)-RTSCUCBINDINGPUMPSCHEDULE(1:RTSCUC_binding_interval_index-1,2:ngen+1))
title('RTSCUC Schedules')
legend(GEN.uels')
%}
figure
plot(DASCUCSCHEDULE(:,1),DASCUCSCHEDULE(:,2:ngen+1)-DASCUCPUMPSCHEDULE(:,2:ngen+1))
title('Day-Ahead Schedules')
legend(GEN.uels','interpreter','none')
fig6=gcf;
figure
sumgen = sum(ACTUAL_GENERATION(:,2:ngen+1)'-ACTUAL_PUMP(:,2:ngen+1)')';
plot(ACTUAL_GENERATION(:,1),sumgen);
hold('on')
line(ACTUAL_GENERATION(:,1),ACTUAL_LOAD_FULL(1:AGC_interval_index-1,2)+storelosses,'color','red');
legend('Total Generation','Total Load')
title('Generation and Load');
fig7=gcf;
pause on;
pause(0.4);
pause off;