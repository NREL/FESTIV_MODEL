%{
FESTIVhelper Custom Helper
%}
%Right now only for DASCUC reserve

CASE1DATA.r=1;
while CASE1DATA.r<=CASE1DATA.nreserve
    figure
    plot(CASE1DATA.RTD_RESERVE_FULL(:,2).*24,CASE1DATA.RTD_RESERVE_FULL(:,CASE1DATA.r+2));
    hold
try
    plot(CASE2DATA.RTD_RESERVE_FULL(:,2).*24,CASE2DATA.RTD_RESERVE_FULL(:,CASE1DATA.r+2));
catch;end;
legend(selectedNames,'interpreter','none','FontSize',14);
xlabel('Time [hr]','FontSize',14);
ylabel('Reserve [MW]','FontSize',14);
title('Reserve Comparison');
    text(0.4,0.12,sprintf('Reserve Case 1 %s',CASE1DATA.DAC_RESERVE_FIELD{CASE1DATA.r+2}))
%    text(0.4,0.09,sprintf('Reserve Case 1 = %0.2f  ',100*(sum(CASE1DATA.HECO_HeadRoom_Risk_Factor(:,2))/(CASE1DATA.AGC_interval_index-1))),'units','normalized')
try        
    text(0.4,0.04,sprintf('Reserve Case 2 %s',CASE2DATA.DAC_RESERVE_FIELD{CASE1DATA.r+2}))
    %text(0.4,0.04,sprintf('Head Room Case 2 = %0.2f Percent ',100*(sum(CASE2DATA.HECO_HeadRoom_Risk_Factor(:,2))/(CASE2DATA.AGC_interval_index-1))),'units','normalized')
catch;end;
CASE1DATA.r=CASE1DATA.r+1;
end;