PUMPING_ENFORCED_ON_VAL = zeros(ngen,HRTC);
PUMPING_ENFORCED_OFF_VAL = ones(ngen,HRTC);
UNIT_STATUS_ENFORCED_ON_VAL = zeros(ngen,HRTC);
UNIT_STATUS_ENFORCED_OFF_VAL = ones(ngen,HRTC);
for i=1:ngen
    if Solving_Initial_Models==0
        if gen_outage_time(i,1) <= time - PRTC/60 && gen_repair_time(i,1) >= time -PRTC/60 && Solving_Initial_Models == 0
            rtc_gen_forced_out(i,1) = 1;
        else
            rtc_gen_forced_out(i,1) = 0;
        end;
    end;
    t = 1;
    if Solving_Initial_Models==0 && rtc_gen_forced_out(i,1) == 1
        GEN_FORCED_OUT_VAL(i,1) = 1;
        UNIT_STATUS_ENFORCED_ON_VAL(i,1:HRTC) = 0;
        PUMPING_ENFORCED_ON_VAL(i,1:HRTC) = 0;
        UNIT_STATUS_ENFORCED_OFF_VAL(i,1:HRTC) = 0;
        PUMPING_ENFORCED_OFF_VAL(i,1:HRTC) = 0;
    else
        GEN_FORCED_OUT_VAL(i,1) = 0;
        for t=1:HRTC
            lookahead_index = min(size(STATUS,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);    %This is based on SCUC starting at hour 0!!!
            if  RTSCUCSTART_YES(i,t) == 1
                UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
            else
                UNIT_STATUS_ENFORCED_ON_VAL(i,t) = STATUS(lookahead_index,1+i);
            end;
            if RTSCUCSHUT_YES(i,t) == 1
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            else
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = STATUS(lookahead_index,1+i);
            end;
            if GENVALUE_VAL(i,gen_type)== outage_gen_type_index
                UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 0;
            elseif GENVALUE_VAL(i,gen_type) == wind_gen_type_index || GENVALUE_VAL(i,gen_type) == PV_gen_type_index 
                UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            end
        end;
    end;
end;

for e=1:nESR
    for t=1:HRTC
        lookahead_index = min(size(PUMPSTATUS,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);    %This is based on SCUC starting at hour 0!!!
        if  RTSCUCPUMPSTART_YES(e,t) == 1
            PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(e,1),t) = 0;
        else
            PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(e,1),t) = PUMPSTATUS(lookahead_index,1+storage_to_gen_index(e,1));
        end;
        if RTSCUCPUMPSHUT_YES(e,t) == 1
            PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(e,1),t) = 1;
        else
            PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(e,1),t) = PUMPSTATUS(lookahead_index,1+storage_to_gen_index(e,1));
        end;
    end;
end;
