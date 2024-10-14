
for i=1:ngen
    STARTUP_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE_VAL(i,su_time)*60/IRTC));
    SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE_VAL(i,sd_time)*60/IRTC));
    PREVIOUS_UNIT_STARTUP_VAL(i,1) = 0;
    INTERVALS_STARTED_AGO_VAL(i,1) = 0;
    STARTUP_MINGEN_HELPER_VAL(i,1) = 0;
    startup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-STARTUP_PERIOD_VAL(i,1)+1));
    for startup_period_check_time = startup_period_check_end:RTSCUC_binding_interval_index-1
       if startup_period_check_time <=1
           Initial_RTC_last_startup_check = GENVALUE_VAL(i,initial_status);
       else
           Initial_RTC_last_startup_check = STATUS(startup_period_check_time-1,1+i);
       end;
       if STATUS(startup_period_check_time,1+i)-Initial_RTC_last_startup_check == 1  && 60*GENVALUE_VAL(i,su_time) >= IRTC
           if startup_period_check_time <=1
               if GENVALUE_VAL(i,su_time) >= IDAC + time
                   PREVIOUS_UNIT_STARTUP_VAL(i,1) =  1;
                   INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index + IDAC*60/IRTC-2;
                   STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE_VAL(i,min_gen)*((time-Solving_Initial_Models*IRTC/60) + IRTC/60 - ...
                       -1*IDAC)/GENVALUE_VAL(i,su_time);
               else
                   INTERVALS_STARTED_AGO_VAL(i,1) = 0;
                   PREVIOUS_UNIT_STARTUP_VAL(i,1) = 0;
               end;
           else
               PREVIOUS_UNIT_STARTUP_VAL(i,1) =  1;
               INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index - startup_period_check_time;
               STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE_VAL(i,min_gen)*(time + IRTC/60 - ...
                   RTSCUCBINDINGSTARTUP(startup_period_check_time,1))/GENVALUE_VAL(i,su_time);
           end;
       end;
    end;
end;

if rpu_running
    STARTUP_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE_VAL(i,su_time)*60/IRPU));
    SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE_VAL(i,sd_time)*60/IRPU));
end

for e=1:nESR
    PUMPUP_PERIOD_VAL(e,1) = max(0,ceil(STORAGEVALUE_VAL(e,pump_su_time)*60/IRTC));
    PUMPDOWN_PERIOD_VAL(e,1) = max(0,ceil(STORAGEVALUE_VAL(e,pump_sd_time)*60/IRTC));
    PREVIOUS_UNIT_PUMPUP_VAL(e,1) = 0;
    INTERVALS_PUMPUP_AGO_VAL(e,1) = 0;
    pumpup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-(PUMPUP_PERIOD_VAL(e,1)+1)));
    PUMPUP_MINGEN_HELPER_VAL(e,1) = 0;
    for pumpup_period_check_time = pumpup_period_check_end:RTSCUC_binding_interval_index-1
       if pumpup_period_check_time <=1
           Initial_RTC_last_pumpup_check = STORAGEVALUE_VAL(e,initial_pump_status);
       else
           Initial_RTC_last_pumpup_check = PUMPSTATUS(pumpup_period_check_time-1,1+storage_to_gen_index(e,1));
       end;
       if (PUMPSTATUS(pumpup_period_check_time,1+storage_to_gen_index(e,1))-Initial_RTC_last_pumpup_check) == 1 && STORAGEVALUE_VAL(e,pump_su_time) >= IDAC
           if pumpup_period_check_time <=1
               if STORAGEVALUE_VAL(e,pump_su_time) >= IDAC + time
                   PREVIOUS_UNIT_PUMPUP_VAL(e,1) = 1;
                   INTERVALS_PUMPUP_AGO_VAL(e,1) = RTSCUC_binding_interval_index + IDAC*60/IRTC-2;
                   PUMPUP_MINGEN_HELPER_VAL(e,1) = STORAGEVALUE_VAL(e,min_pump)*((time-Solving_Initial_Models*IRC/60) + IRTC/60 - ...
                       -1*IDAC)/STORAGEVALUE_VAL(e,pump_su_time);
               else
                   INTERVALS_PUMPUP_AGO_VAL(e,1) = 0;
                   PREVIOUS_UNIT_PUMPUP_VAL(e,1) = 0;
               end;
           else
               PREVIOUS_UNIT_PUMPUP_VAL(e,1) = 1;
               INTERVALS_PUMPUP_AGO_VAL(e,1) = RTSCUC_binding_interval_index - pumpup_period_check_time;
               PUMPUP_MINGEN_HELPER_VAL(e,1) = STORAGEVALUE_VAL(e,min_pump)*(time + IRTC/60 - ...
                   RTSCUCBINDINGPUMPSCHEDULE(pumpup_period_check_time,1))/STORAGEVALUE_VAL(e,pump_su_time);
           end;
       end;
    end;
end;

if rpu_running
    PUMPUP_PERIOD_VAL(e,1) = max(0,ceil(STORAGEVALUE_VAL(e,pump_su_time)*60/IRPU));
    PUMPDOWN_PERIOD_VAL(e,1) = max(0,ceil(STORAGEVALUE_VAL(e,pump_sd_time)*60/IRPU));
end
