%This is for interval 0 initial ramping constraints
ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2:ngen+1)'; 
LAST_GEN_SCHEDULE_VAL = DISPATCH(RTSCED_binding_interval_index-1,2:ngen+1)';
ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2:nESR+1)'; 
LAST_PUMP_SCHEDULE_VAL = PUMPDISPATCH(RTSCED_binding_interval_index-1,2:nESR+1)';
for i=1:ngen
    if abs(LAST_GEN_SCHEDULE_VAL(i,1)) > 0
        LAST_STATUS_VAL(i,1) = 1;
    else
        LAST_STATUS_VAL(i,1) = 0;
    end;
    if abs(ACTUAL_GEN_OUTPUT_VAL(i,1)) > 0
        LAST_STATUS_ACTUAL_VAL(i,1) = 1;
    else
        LAST_STATUS_ACTUAL_VAL(i,1) = 0;
    end;
end;
for e=1:nESR
    if LAST_PUMP_SCHEDULE_VAL(e,1) > 0
        LAST_PUMPSTATUS_VAL (e,1) = 1;
    else
        LAST_PUMPSTATUS_VAL (e,1) = 0;
    end;
    if ACTUAL_PUMP_OUTPUT_VAL(e,1) > 0
        LAST_PUMPSTATUS_ACTUAL_VAL(e,1) = 1;
    else
        LAST_PUMPSTATUS_ACTUAL_VAL(e,1) = 0;
    end;
end;
for i=1:ngen
    RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRPU+IRPU)*GENVALUE_VAL(i,ramp_rate)...
        - (LAST_GEN_SCHEDULE_VAL(i,1) + mod(time,tRTD)*GENVALUE_VAL(i,ramp_rate)));
    RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) -  mod(time,tRTD)*GENVALUE_VAL(i,ramp_rate)...
        - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRPU+IRPU)*GENVALUE_VAL(i,ramp_rate)));
end;
