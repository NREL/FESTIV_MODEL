%
%Before RTSCUC
%

%Since RTSCED dispatch are ones that are binding and RTSCUC dispatch is
%esentially advisory, it makes sense to look at RTSCED when doing ramp
%constraints rather than RTSCUC. Example of Upstream Scheduling Process
%Commumnication

%This is not feasible for all parameters should work as long as IRTC is
%divisible by IRTD
LAST_GEN_SCHEDULE_VAL = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index -1,2:ngen+1)';
LAST_PUMP_SCHEDULE_VAL = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index -1,2:nESR+1)';
LAST_STATUS_VAL = zeros(ngen,1);
LAST_STATUS_VAL(abs(LAST_GEN_SCHEDULE_VAL)>0)=1;  
LAST_PUMPSTATUS_VAL = zeros(nESR,1);
LAST_PUMPSTATUS_VAL(LAST_PUMP_SCHEDULE_VAL>0)=1;  

RAMP_SLACK_UP.val = max(0,ACTUAL_GEN_OUTPUT_VAL(:,1) - (PRTC+IRTC)*GENVALUE_VAL(:,ramp_rate)...
    - (LAST_GEN_SCHEDULE_VAL(:,1) + tRTC*GENVALUE_VAL(:,ramp_rate)));
RAMP_SLACK_DOWN.val = max(0, LAST_GEN_SCHEDULE_VAL(:,1) - tRTC*GENVALUE_VAL(:,ramp_rate)...
    - (ACTUAL_GEN_OUTPUT_VAL(:,1) + (PRTC+IRTC)*GENVALUE_VAL(:,ramp_rate)));
