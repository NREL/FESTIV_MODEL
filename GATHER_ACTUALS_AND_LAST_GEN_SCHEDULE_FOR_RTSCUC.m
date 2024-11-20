%This is for interval 0 initial ramping constraints
if Solving_Initial_Models
    LAST_GEN_SCHEDULE_VAL(:,1) = GENVALUE_VAL(:,initial_MW)+(DASCUCSCHEDULE(1,2:end)' - GENVALUE_VAL(:,initial_MW)).*(1-IRTC/(IDAC*60));
    ACTUAL_GEN_OUTPUT_VAL = GENVALUE_VAL(:,initial_MW); %placeholder for initial RTC
for i=1:ngen
    if STATUS(1,1+i)==1 && GENVALUE_VAL(i,initial_status)==0 
        LAST_GEN_SCHEDULE_VAL(i,1)= min(GENVALUE_VAL(i,min_gen),GENVALUE_VAL(i,min_gen)*((IDAC*60/IRTC -1)*IRTC/(60*GENVALUE_VAL(i,su_time))));
    end;
    if STATUS(1,1+i)==0 && GENVALUE_VAL(i,initial_status)==1 
        tmp_ramp_left = GENVALUE_VAL(i,initial_MW)-GENVALUE_VAL(i,ramp_rate)*(IDAC*60/IRTC -1)*IRTC;
        tmp_time_left_for_sd = (IDAC*60/IRTC -1)*IRTC - (GENVALUE_VAL(i,initial_MW)- GENVALUE_VAL(i,min_gen))/GENVALUE_VAL(i,ramp_rate);
        if tmp_ramp_left > GENVALUE_VAL(i,min_gen)
            LAST_GEN_SCHEDULE_VAL(i,1)= tmp_ramp_left;
        else
            LAST_GEN_SCHEDULE_VAL(i,1)= max(0,GENVALUE_VAL(i,min_gen) - GENVALUE_VAL(i,min_gen)*(tmp_time_left_for_sd/(ceil(GENVALUE_VAL(i,sd_time)*60))));
        end;
    end;
end;
LAST_STATUS_VAL(:,1)=0;
LAST_STATUS_VAL(LAST_GEN_SCHEDULE_VAL>0)=1;  
else
    LAST_GEN_SCHEDULE_VAL = RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index -1,2:ngen+1)';
    LAST_STATUS_VAL = STATUS(rtscucinterval_index -1,2:end)';
    if time - PRTC/60 < ACTUAL_GENERATION(1,1)
        ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(1,2:ngen+1)'; 
    else
        ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(AGC_interval_index-round(PRTC*60/t_AGC),2:ngen+1)';
    end;
end;
LAST_STATUS_ACTUAL_VAL(:,1)=0;
LAST_STATUS_ACTUAL_VAL(ACTUAL_GEN_OUTPUT_VAL>0)=1; 

if Solving_Initial_Models
for e=1:nESR
    ACTUAL_PUMP_OUTPUT_VAL = STORAGEVALUE_VAL(e,initial_pump_mw); %placeholder for initial RTC
    LAST_PUMP_SCHEDULE_VAL = STORAGEVALUE_VAL(e,initial_pump_mw); %placeholder for initial RTC   
    if PUMPSTATUS(1,storage_to_gen_index(e,1)+1)==1 && STORAGEVALUE_VAL(e,initial_pump_status)==0 
        LAST_PUMP_SCHEDULE_VAL(e,1)= min(STORAGEVALUE_VAL(e,min_pump),STORAGEVALUE_VAL(e,min_pump)*((IDAC*60/IRTC -1)*IRTC/(60*STORAGEVALUE_VAL(e,pump_su_time))));
    end;
    if PUMPSTATUS(1,storage_to_gen_index(e,1)+1)==0 && STORAGEVALUE_VAL(e,initial_pump_status)==1 
        LAST_PUMP_SCHEDULE_VAL(e,1)= min(STORAGEVALUE_VAL(e,min_pump),STORAGEVALUE_VAL(e,min_pump)*((IDAC*60/IRTC -1)/(ceil(STORAGEVALUE_VAL(e,pump_sd_time)*60/IRTC))));
    end;
    STORAGEVALUE_VAL(:,initial_storage) = DEFAULT_DATA.STORAGEVALUE.val(:,initial_storage);
end;
LAST_PUMPSTATUS_VAL(:,1)=0;
LAST_PUMPSTATUS_VAL(LAST_PUMP_SCHEDULE_VAL>0)=1;
LAST_PUMPSTATUS_ACTUAL_VAL(:,1)=0;
LAST_PUMPSTATUS_ACTUAL_VAL(ACTUAL_PUMP_OUTPUT_VAL>0)=1;
else
    LAST_PUMP_SCHEDULE_VAL = RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index -1,2:nESR+1)';
    if time - PRTC/60 < ACTUAL_PUMP(1,1)
        ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(1,2:nESR+1)';
        if time>0 %if time is 0 then you should just use the input initial storage
            STORAGEVALUE_VAL(:,initial_storage) = min(STORAGEVALUE_VAL(:,initial_storage),max(0,STORAGEVALUE_VAL(:,initial_storage) + LAST_PUMP_SCHEDULE_VAL.*STORAGEVALUE_VAL(:,efficiency).*tRTD./60 - LAST_GEN_SCHEDULE_VAL(storage_to_gen_index).*tRTD./60));
        else
            STORAGEVALUE_VAL(:,initial_storage) = min(STORAGEVALUE_VAL(:,initial_storage),max(0,DEFAULT_DATA.STORAGEVALUE.val(:,initial_storage)));
        end
    else
        ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(AGC_interval_index-round(PRTC*60/t_AGC),2:nESR+1)';
        STORAGEVALUE_VAL(:,initial_storage) = min(STORAGEVALUE_VAL(:,initial_storage),max(0,ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRTC*60/t_AGC),2:1+nESR)' + LAST_PUMP_SCHEDULE_VAL.*STORAGEVALUE_VAL(:,efficiency).*tRTC./60 - LAST_GEN_SCHEDULE_VAL(storage_to_gen_index).*tRTC./60));
    end; 
    LAST_PUMPSTATUS_VAL=PUMPSTATUS(rtscucinterval_index-1,storage_to_gen_index+1);
    LAST_PUMPSTATUS_ACTUAL_VAL(:,1)=0;
    LAST_PUMPSTATUS_ACTUAL_VAL(ACTUAL_PUMP_OUTPUT_VAL>0)=1;
end;
for i=1:ngen
    RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTC+IRTC)*GENVALUE_VAL(i,ramp_rate)...
        - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTC*GENVALUE_VAL(i,ramp_rate)));
    RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTC*GENVALUE_VAL(i,ramp_rate)...
        - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTC+IRTC)*GENVALUE_VAL(i,ramp_rate)));
end;
