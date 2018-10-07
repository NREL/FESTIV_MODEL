%RTSCUCSTART_YES means the RTSCUC can have the option to turn/leave it on.
%RTSCUCSTART_YES of 0 means if STATUS is on, must stay on.
%RTSCUCSHUT_YES means the RTSCUC can have the option to turn/leave it off.
%RTSCUCSHUT_YES of 0 means if STATUS if off, must stay off.
%Default mode
if RTSCUCSTART_MODE == 1 %RTSCUC
    RTSCUCSTART_YES = zeros(ngen,HRTC);
    RTSCUCSHUT_YES = zeros(ngen,HRTC);
    RTSCUCPUMPSTART_YES = zeros(nESR,HRTC);
    RTSCUCPUMPSHUT_YES = zeros(nESR,HRTC);
    if RTSCUC_binding_interval_index<=2
    for i=1:ngen
        if GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index )) ...
            RTSCUCSTART_YES(i,1:HRTC) = 1;
            RTSCUCSHUT_YES(i,1:HRTC) = 1;
        else
            RTSCUCSTART_YES(i,1:HRTC) = 0;
            RTSCUCSHUT_YES(i,HRTC) = 0;
        end
    end
    else
    for i=1:ngen
        if GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index )) ...
                && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) < eps || RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)+eps >=GENVALUE_VAL(i,min_gen))
            RTSCUCSTART_YES(i,1:HRTC) = 1;
            RTSCUCSHUT_YES(i,1:HRTC) = 1;
        elseif GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index ))
            if RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) - RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) > 0
                t=RTSCUC_binding_interval_index;
                while t>=1
                    if STATUS(t,1+i)==0
                        RTSCUC_start_index=t;
                        t=0;
                    end
                    t=t-1;
                end
                RTSCUC_allow = RTSCUC_binding_interval_index - RTSCUC_start_index + ceil(GENVALUE_VAL(i,su_time)*60/IRTC) + ceil(GENVALUE_VAL(i,mr_time));
                RTSCUCSTART_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSTART_YES(i,RTSCUC_allow:HRTC) = 1;
                RTSCUCSHUT_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSHUT_YES(i,RTSCUC_allow:HRTC) = 1;
            elseif RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) - RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) < 0
                RTSCUCSHUT_YES(i,1:HRTC) = 0;
                t=RTSCUC_binding_interval_index;
                RTSCUC_shut_index=RTSCUC_binding_interval_index+HRTC+1;
                while t<=RTSCUC_binding_interval_index+HRTC
                    if STATUS(t,1+i)==0
                        RTSCUC_shut_index=t;
                        t=RTSCUC_binding_interval_index+HRTC;
                    end
                    t=t+1;
                end
                RTSCUC_allow = RTSCUC_shut_index - RTSCUC_binding_interval_index + ceil(GENVALUE_VAL(i,md_time));
                RTSCUCSTART_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSTART_YES(i,RTSCUC_allow:HRTC) = 1;
                RTSCUCSHUT_YES(i,1:RTSCUC_allow-1) = 0;
                RTSCUCSHUT_YES(i,RTSCUC_allow:HRTC) = 1;
            else
                RTSCUCSTART_YES(i,1:HRTC) = 0;
                RTSCUCSHUT_YES(i,HRTC) = 0;
            end
        else
            RTSCUCSTART_YES(i,1:HRTC) = 0;
            RTSCUCSHUT_YES(i,HRTC) = 0;
        end
    end
    end
    for i=1:nESR
        if STORAGEVALUE_VAL(i,pump_su_time) <= tRTCstart && Fix_RT_Pump == 0
            RTSCUCPUMPSTART_YES(i,1:HRTC) = 1;
            RTSCUCPUMPSHUT_YES(i,1:HRTC) = 1;
        else
            RTSCUCPUMPSTART_YES(i,1:HRTC) = 0;
            RTSCUCPUMPSHUT_YES(i,HRTC) = 0;
        end
    end
    RTSCUCSTART_YES = RTSCUCSTART_YES(:,1:HRTC);
    RTSCUCSHUT_YES = RTSCUCSHUT_YES(:,1:HRTC);
    RTSCUCPUMPSTART_YES = RTSCUCPUMPSTART_YES(:,1:HRTC);
    RTSCUCPUMPSHUT_YES = RTSCUCPUMPSHUT_YES(:,1:HRTC);
elseif RTSCUCSTART_MODE == 2 %RPU
    RTSCUCSTART_YES = zeros(ngen,HRPU);
    RTSCUCSHUT_YES = zeros(ngen,HRPU);
    RTSCUCPUMPSTART_YES = zeros(nESR,HRPU);
    RTSCUCPUMPSHUT_YES = zeros(nESR,HRPU);
    for i=1:ngen
        if GENVALUE_VAL(i,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE_VAL(i,gen_type) ~= pumped_storage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= ESR_gen_type_index )) ...
            && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) < eps || RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)+eps >=GENVALUE_VAL(i,min_gen))
            RTSCUCSTART_YES(i,1:HRPU) = 1;
            RTSCUCSHUT_YES(i,1:HRPU) = 1;
        else
            if STATUS(lookahead_index-1,1+i) == 1
                RTSCUCSTART_YES(i,1:HRPU) = 1;
            else
                RTSCUCSTART_YES(i,1:HRPU) = 0;
            end
            RTSCUCSHUT_YES(i,1:HRPU) = 0;
        end;
    end
    for i=1:nESR
        if STORAGEVALUE_VAL(i,pump_su_time) <= tRTCstart && Fix_RT_Pump == 0
            RTSCUCPUMPSTART_YES(i,1:HRPU) = 1;
            RTSCUCPUMPSHUT_YES(i,1:HRPU) = 1;
        else
            RTSCUCPUMPSTART_YES(i,1:HRPU) = 0;
            RTSCUCPUMPSHUT_YES(i,HRPU) = 0;
        end
    end
else
    %User entered code can go here.
end
