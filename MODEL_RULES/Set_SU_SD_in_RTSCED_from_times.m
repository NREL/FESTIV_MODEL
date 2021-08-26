%
%different way to calculate unit_startingup and unit_shuttingdown in RTSCED
%Before RTSCED
%Must be used together with Save_SU_SD_start_end_times_from_RTSCUC
%

%There is a lot of clunkiness to calculating these when intervals do not
%line up well between RTSCUC and RTSCED. This seems more straightforward
%and just going by the time.

UNIT_STARTINGUP_VAL=zeros(ngen,HRTD);
UNIT_SHUTTINGDOWN_VAL = zeros(ngen,HRTD);
UNIT_STARTINGUP_ACTUAL_VAL=zeros(ngen,1);
UNIT_SHUTTINGDOWN_ACTUAL_VAL = zeros(ngen,1);
for i=1:ngen
    if GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= outage_gen_index
    if time>RTSCUC_INITIAL_START_TIME(i,1)+eps && time<=RTSCUC_END_START_TIME(i,1)+eps
        UNIT_STARTINGUP_ACTUAL_VAL(i,1) = 1;
    end
    if time>RTSCUC_INITIAL_SHUT_TIME(i,1)+eps && time<=RTSCUC_END_SHUT_TIME(i,1)+eps
        UNIT_SHUTTINGDOWN_ACTUAL_VAL(i,1) = 1;
    end
    for t=1:HRTD
        if RTD_LOOKAHEAD_INTERVAL_VAL(t,1)>RTSCUC_INITIAL_START_TIME(i,1)+eps && RTD_LOOKAHEAD_INTERVAL_VAL(t,1)<=RTSCUC_END_START_TIME(i,1)+eps
            if LAST_GEN_SCHEDULE_VAL(i,1)>=GENVALUE_VAL(i,min_gen) && time > RTSCUC_INITIAL_START_TIME(i,1)
                RTSCUC_INITIAL_START_TIME(i,1) = -1;
                RTSCUC_END_START_TIME(i,1) = -1;
            else
                UNIT_STARTINGUP_VAL(i,t) = 1;
                UNIT_STARTUPMINGENHELP_VAL(i,t) = GENVALUE_VAL(i,min_gen)*max(0,(time-ACTUAL_START_TIME(i,1))/GENVALUE_VAL(i,su_time));
                if UNIT_STARTUPMINGENHELP_VAL(i,t) + (UNIT_STARTINGUP_VAL(i,1:t)*INTERVAL_MINUTES_VAL(1:t,1))*(GENVALUE_VAL(i,min_gen)/(60*GENVALUE_VAL(i,su_time)))> GENVALUE_VAL(i,min_gen)
                    UNIT_STARTUPMINGENHELP_VAL(i,t) = max(0,GENVALUE_VAL(i,min_gen) - INTERVAL_MINUTES_VAL(1,1)*(GENVALUE_VAL(i,min_gen)/(60*GENVALUE_VAL(i,su_time))));
                end
            end
        end
        if RTD_LOOKAHEAD_INTERVAL_VAL(t,1)>RTSCUC_INITIAL_SHUT_TIME(i,1)+eps && RTD_LOOKAHEAD_INTERVAL_VAL(t,1)<=RTSCUC_END_SHUT_TIME(i,1)+eps
            if LAST_GEN_SCHEDULE_VAL(i,1)<=0 && time > RTSCUC_INITIAL_SHUT_TIME
                RTSCUC_INITIAL_SHUT_TIME(i,1) = -1;
                RTSCUC_END_SHUT_TIME(i,1) = -1;
            else
                UNIT_SHUTTINGDOWN_VAL(i,t) = 1;
            end
        end
    end
    end
end
%For now, we assume that the STARTUPMINGENHELP_VAL is correctly applied, since that is based on ACTUAL_START_TIME.