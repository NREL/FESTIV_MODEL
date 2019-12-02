%This allows for actuals data to be based on the same resolution as the RTSCED data
%Thus, when AGC is not of interest, you can almost skip it.

%{
USE: After Forecast Creation
%}
Model_Rule_Perfect1_Persistence0_VG = 0; %persistence assumes that the RTSCED is already persistence, and shifts the actuals based on that assumption.
Model_Rule_Perfect1_Persistence0_LOAD = 0; %persistence assumes that the RTSCED is already persistence, and shifts the actuals based on that assumption.
intervals_behind = 2; %2 for ten minute persistence. 1 for 5 minute persistence.
temp_actual=forecast_creation(ACTUAL_VG_FULL,size(ACTUAL_VG_FULL,2)-1,IRTD,IRTD,tRTD,1,t_AGC,0,simulation_days,0,max_data,'RT',2);
temp_actual(:,1)=[];
temp_actual(end,:)=[];
ACTUAL_VG_FULL = zeros(size(temp_actual));
ACTUAL_VG_FULL(:,1) = temp_actual(:,1);
if Model_Rule_Perfect1_Persistence0_VG
    ACTUAL_VG_FULL(:,2:end)=temp_actual(:,2:end);
else
    ACTUAL_VG_FULL(1:end-intervals_behind,2:end)=temp_actual(intervals_behind+1:end,2:end);
    ACTUAL_VG_FULL(end-intervals_behind+1:end,2:end)=temp_actual(end-intervals_behind+1:end,2:end);%last few intervals will be be perfect.
end;

temp_actual=forecast_creation(ACTUAL_LOAD_FULL,1,IRTD,IRTD,tRTD,1,t_AGC,0,simulation_days,0,inf,'RT',2);
temp_actual(:,1)=[];
temp_actual(end,:)=[];
ACTUAL_LOAD_FULL = zeros(size(temp_actual));
ACTUAL_LOAD_FULL(:,1) = temp_actual(:,1);
if Model_Rule_Perfect1_Persistence0_LOAD
    ACTUAL_LOAD_FULL(:,2:end)=temp_actual(:,2:end);
else
    ACTUAL_LOAD_FULL(1:end-intervals_behind,:,2:end)=temp_actual(intervals_behind+1:end,:,2:end);
    ACTUAL_LOAD_FULL(end-intervals_behind+1:end,:,2:end)=temp_actual(end-intervals_behind+1:end,:,2:end);%last few intervals will be be perfect.
end;
clear temp_actual;

t_AGC=round((ACTUAL_LOAD_FULL(2,1)-ACTUAL_LOAD_FULL(1,1))*60*60*24);
