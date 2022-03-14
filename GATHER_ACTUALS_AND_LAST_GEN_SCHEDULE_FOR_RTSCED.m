if Solving_Initial_Models 
    LAST_GEN_SCHEDULE_VAL = GENVALUE_VAL(:,initial_MW); 
    ACTUAL_GEN_OUTPUT_VAL = GENVALUE_VAL(:,initial_MW); %placeholder for initial RTC
for i=1:ngen
    if STATUS(1,1+i)==1 && GENVALUE_VAL(i,initial_status)==0 
        LAST_GEN_SCHEDULE_VAL(i,1)= min(GENVALUE_VAL(i,min_gen),GENVALUE_VAL(i,min_gen)*((IDAC*60/IRTD -1)*IRTD/(60*GENVALUE_VAL(i,su_time))));
    end;
    if STATUS(1,1+i)==0 && GENVALUE_VAL(i,initial_status)==1 
        tmp_ramp_left = GENVALUE_VAL(i,initial_MW)-GENVALUE_VAL(i,ramp_rate)*(IDAC*60/IRTD -1)*IRTD;
        tmp_time_left_for_sd = (IDAC*60/IRTD -1)*IRTD - (GENVALUE_VAL(i,initial_MW)- GENVALUE_VAL(i,min_gen))/GENVALUE_VAL(i,ramp_rate);
        if tmp_ramp_left > GENVALUE_VAL(i,min_gen)
            LAST_GEN_SCHEDULE_VAL(i,1)= tmp_ramp_left;
        else
            LAST_GEN_SCHEDULE_VAL(i,1)= max(0,GENVALUE_VAL(i,min_gen) - GENVALUE_VAL(i,min_gen)*(tmp_time_left_for_sd/(ceil(GENVALUE_VAL(i,sd_time)*60))));
        end;
    end;
end;
else
    LAST_GEN_SCHEDULE_VAL = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index -1,2:1+ngen)';
    if time - PRTD/60 < ACTUAL_GENERATION(1,1)
        ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(1,2:ngen+1)'; 
    else
        ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(AGC_interval_index-round(PRTD*60/t_AGC),2:ngen+1)';
    end;
end;

if Solving_Initial_Models 
    for e=1:nESR
        LAST_PUMP_SCHEDULE_VAL(e,1) = STORAGEVALUE_VAL(e,initial_pump_mw);
        ACTUAL_PUMP_OUTPUT_VAL(e,1) = STORAGEVALUE_VAL(e,initial_pump_mw); 
        if PUMPSTATUS(1,1+storage_to_gen_index(e,1))==1 && STORAGEVALUE_VAL(e,initial_pump_status)==0 
            LAST_PUMP_SCHEDULE_VAL(e,1)= min(STORAGEVALUE_VAL(e,min_pump),STORAGEVALUE_VAL(e,min_pump)*((IDAC*60/IRTD -1)*IRTD/(60*STORAGEVALUE_VAL(e,pump_su_time))));
        end;
        if PUMPSTATUS(1,1+storage_to_gen_index(e,1))==0 && STORAGEVALUE_VAL(e,initial_pump_status)==1 
            LAST_PUMP_SCHEDULE_VAL(e,1)= min(STORAGEVALUE_VAL(e,min_pump),STORAGEVALUE_VAL(e,min_pump)*((IDAC*60/IRTD -1)/(ceil(STORAGEVALUE_VAL(e,pump_sd_time)*60/IRTD))));
        end;
    end;
else
    LAST_PUMP_SCHEDULE_VAL = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index -1,2:1+nESR)';
    STORAGEVALUE_VAL(:,initial_storage) = RTSCEDSTORAGELEVEL(RTSCED_binding_interval_index -1,2:1+nESR)';
    if time - PRTD/60 < ACTUAL_GENERATION(1,1)
        ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(1,2:nESR+1)'; 
    else
        ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(AGC_interval_index-round(PRTD*60/t_AGC),2:nESR+1)';
    end;
end;

for i=1:ngen
    RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTD+IRTD)*GENVALUE_VAL(i,ramp_rate) ...
        - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTD*GENVALUE_VAL(i,ramp_rate)));
    RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTD*GENVALUE_VAL(i,ramp_rate) ...
        - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTD+IRTD)*GENVALUE_VAL(i,ramp_rate)));
end;
