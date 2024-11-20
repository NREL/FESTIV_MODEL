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
LAST_STATUS_VAL = zeros(ngen,1);
LAST_STATUS_ACTUAL_VAL = zeros(ngen,1);
LAST_STATUS_VAL(abs(LAST_GEN_SCHEDULE_VAL)>0)=1;  
LAST_STATUS_ACTUAL_VAL(abs(ACTUAL_GEN_OUTPUT_VAL)>0)=1; 

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
    STORAGEVALUE_VAL(:,initial_storage) = DEFAULT_DATA.STORAGEVALUE.val(:,initial_storage);
else
    LAST_PUMP_SCHEDULE_VAL = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index -1,2:1+nESR)';
    STORAGEVALUE_VAL(:,initial_storage) = RTSCEDSTORAGELEVEL(RTSCED_binding_interval_index -1,2:1+nESR)';
    if time - PRTD/60 < ACTUAL_GENERATION(1,1)
        ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(1,2:nESR+1)'; 
        if time>0 %if time is 0 then you should just use the input initial storage
            STORAGEVALUE_VAL(:,initial_storage) = min(STORAGEVALUE_VAL(:,initial_storage),max(0,STORAGEVALUE_VAL(:,initial_storage) + LAST_PUMP_SCHEDULE_VAL.*STORAGEVALUE_VAL(:,efficiency).*tRTD./60 - LAST_GEN_SCHEDULE_VAL(storage_to_gen_index).*tRTD./60));
        else
            STORAGEVALUE_VAL(:,initial_storage) = min(STORAGEVALUE_VAL(:,initial_storage),max(0,DEFAULT_DATA.STORAGEVALUE.val(:,initial_storage)));
        end
    else
        ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(AGC_interval_index-round(PRTD*60/t_AGC),2:nESR+1)';
        STORAGEVALUE_VAL(:,initial_storage) = min(STORAGEVALUE_VAL(:,initial_storage),max(0,ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRTD*60/t_AGC),2:1+nESR)' + LAST_PUMP_SCHEDULE_VAL.*STORAGEVALUE_VAL(:,efficiency).*tRTD./60 - LAST_GEN_SCHEDULE_VAL(storage_to_gen_index).*tRTD./60));
   end;
end;
LAST_PUMPSTATUS_VAL = zeros(nESR,1);
LAST_PUMPSTATUS_ACTUAL_VAL = zeros(nESR,1);
LAST_PUMPSTATUS_VAL(LAST_PUMP_SCHEDULE_VAL>0)=1;  
LAST_PUMPSTATUS_ACTUAL_VAL(ACTUAL_PUMP_OUTPUT_VAL>0)=1; 
UNIT_PUMPINGUP_ACTUAL_VAL=zeros(nESR,1);
UNIT_STARTINGUP_ACTUAL_VAL=zeros(ngen,1);
for e=1:nESR
    if ACTUAL_PUMP_OUTPUT_VAL(e,1)<STORAGEVALUE_VAL(e,min_pump) && LAST_PUMP_SCHEDULE_VAL(e,1)>=STORAGEVALUE_VAL(e,min_pump)
        UNIT_PUMPINGUP_ACTUAL_VAL(e,1)=1;
    end
end
for i=1:ngen
    if ACTUAL_GEN_OUTPUT_VAL(i,1)<GENVALUE_VAL(i,min_gen) && LAST_GEN_SCHEDULE_VAL(i,1)>=GENVALUE_VAL(i,min_gen)
        UNIT_STARTINGUP_ACTUAL_VAL(i,1)=1;
    end
end

for i=1:ngen
    RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTD+IRTD)*GENVALUE_VAL(i,ramp_rate) ...
        - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTD*GENVALUE_VAL(i,ramp_rate)));
    RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTD*GENVALUE_VAL(i,ramp_rate) ...
        - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTD+IRTD)*GENVALUE_VAL(i,ramp_rate)));
end;
