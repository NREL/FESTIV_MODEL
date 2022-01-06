if rtscuc_running
    H=HRTC;
elseif rpu_running
    H=HRPU;
end;

if Solving_Initial_Models == 0
    for i=1:ngen
        if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index
            RTSCUCPUMPSTART_YES_TMP=RTSCUCPUMPSTART_YES(find(storage_to_gen_index==i),1);
        else
            RTSCUCPUMPSTART_YES_TMP = 0;
        end;
        if RTSCUCSTART_YES(i,1) || RTSCUCPUMPSTART_YES_TMP
            min_down_check_start_time = max(1,RTSCUC_binding_interval_index -GENVALUE_VAL(i,md_time)*rtscuc_I_perhour+1);
            min_down_check_end_time = RTSCUC_binding_interval_index - 1;
            min_down_interval_enforced=0;
            min_down_check_time = min_down_check_start_time;
            while min_down_check_time <= min_down_check_end_time
                if min_down_check_time == 1
                    mindown_last_status = GENVALUE_VAL(i,initial_status);
                    try mindown_last_status=mindown_last_status + STORAGEVALUE_VAL(find(storage_to_gen_index==i),initial_pump_status);
                    catch; end;
                else
                    mindown_last_status = STATUS(min_down_check_time-1,1+i)+PUMPSTATUS(min_down_check_time-1,1+i);
                end;
                if mindown_last_status - (STATUS(max(1,min_down_check_time),1+i)+ PUMPSTATUS(max(1,min_down_check_time),1+i))== 1  
                    min_down_interval_enforced = GENVALUE_VAL(i,md_time)*rtscuc_I_perhour - (min_down_check_end_time - min_down_check_time)-1;
                    min_down_check_time = min_down_check_end_time + 1;
                else
                    min_down_interval_enforced = 0;
                    min_down_check_time = min_down_check_time + 1;
                end;
            end;
            if min_down_interval_enforced > 0
                UNIT_STATUS_ENFORCED_OFF_VAL(i,1:min(H,min_down_interval_enforced)) = 0;
                PUMPING_ENFORCED_OFF_VAL(i,1:min(H,min_down_interval_enforced)) = 0;
            end;
        end;
        if RTSCUCSHUT_YES(i,1)
            min_run_check_start_time = max(1,RTSCUC_binding_interval_index -GENVALUE_VAL(i,mr_time)*rtscuc_I_perhour+1);
            min_run_check_end_time = RTSCUC_binding_interval_index - 1;
            min_run_interval_enforced=0;
            min_run_check_time = min_run_check_start_time;
            while min_run_check_time <= min_run_check_end_time
                if min_run_check_time == 1
                    minrun_last_status = GENVALUE_VAL(i,initial_status);
                else
                    minrun_last_status = STATUS(min_run_check_time-1,1+i);
                end;
                if STATUS(min_run_check_time,1+i)-minrun_last_status == 1
                    min_run_interval_enforced = GENVALUE_VAL(i,mr_time)*rtscuc_I_perhour - (min_run_check_end_time - min_run_check_time)-1;
                    min_run_check_time = min_run_check_end_time + 1;
                else
                    min_run_interval_enforced = 0;
                    min_run_check_time = min_run_check_time + 1;
                end;
            end;
            if min_run_interval_enforced > 0 && rtc_gen_forced_out(i,1) ~= 1
                UNIT_STATUS_ENFORCED_ON_VAL(i,1:min(H,min_run_interval_enforced)) = 1;
            end;
        end;
    end;
    for e=1:nESR
        if RTSCUCPUMPSHUT_YES(e,1)
            min_pump_check_start_time = max(1,RTSCUC_binding_interval_index -STORAGEVALUE_VAL(e,min_pump_time)*rtscuc_I_perhour+1);
            min_pump_check_end_time = RTSCUC_binding_interval_index - 1;
            min_pump_interval_enforced=0;
            min_pump_check_time = min_pump_check_start_time;
            while min_pump_check_time <= min_pump_check_end_time
                if min_pump_check_time == 1
                    minpump_last_status = STORAGE_VALUE_VAL(e,initial_pump_status);
                else
                    minpump_last_status = PUMPSTATUS(min_pump_check_time-1,1+storage_to_gen_index(e,1));
                end;
                if PUMPSTATUS(min_pump_check_time,1+storage_to_gen_index(e,1))-minpump_last_status == 1
                    min_pump_interval_enforced = STORAGEVALUE_VAL(e,min_pump_time)*rtscuc_I_perhour - (min_pump_check_end_time - min_pump_check_time)-1;
                    min_pump_check_time = min_pump_check_end_time + 1;
                else
                    min_pump_interval_enforced = 0;
                    min_pump_check_time = min_pump_check_time + 1;
                end;
            end;
            if min_pump_interval_enforced > 0
                PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(e,1),1:min_pump_interval_enforced) = 1;
            end;
        end;
    end;
end;
