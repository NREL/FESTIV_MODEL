
RPU_YES = 0;
%Default Mode
if RPU_TRIGGER_MODE == 1
    if (ctgc_start == 1 && time - PRPU/60 >= ctgc_start_time) && 60*(time - max(rpu_time)) > restrict_multiple_rpu_time  
        RPU_YES = 1;
        rpu_time = [rpu_time; time - PRPU/60];
        ctgc_start = 0;
        ctgc_start_time = inf;
    end;
    if (min(abs(ACE(max(1,AGC_interval_index-ACE_RPU_THRESHOLD_T+1):AGC_interval_index,raw_ACE_index))) > ACE_RPU_THRESHOLD_MW) && ...
            60*(time - max(rpu_time)) > restrict_multiple_rpu_time
        rpu_time = [rpu_time; time - PRPU/60];
        RPU_YES = 1;
    end;
else
    RPU_TRIGGER_USER_DEFINED
end
