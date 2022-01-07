%
%different way to calculate unit_startingup and unit_shuttingdown in RTSCED
%After RTSCUC
%Must be used together with Set_SU_SD_in_RTSCED_from_times
%

%There is a lot of clunkiness to calculating these when intervals do not
%line up well between RTSCUC and RTSCED
if RTSCUC_binding_interval_index==1 
    RTSCUC_INITIAL_START_TIME = -1.*ones(ngen,1);
    RTSCUC_END_START_TIME = -1.*ones(ngen,1);
    RTSCUC_INITIAL_SHUT_TIME = -1.*ones(ngen,1);
    RTSCUC_END_SHUT_TIME = -1.*ones(ngen,1);
end

%delete advisory start up and shut downs.
RTSCUC_END_START_TIME(RTSCUC_INITIAL_START_TIME+eps>=time)=-1;
RTSCUC_INITIAL_START_TIME(RTSCUC_INITIAL_START_TIME+eps>=time)=-1;
RTSCUC_END_SHUT_TIME(RTSCUC_INITIAL_SHUT_TIME+eps>=time)=-1;
RTSCUC_INITIAL_SHUT_TIME(RTSCUC_INITIAL_SHUT_TIME+eps>=time)=-1;
for i=1:ngen
    t=1;
    while t<=HRTC 
        if abs(RTCUNITSTARTUP.val(i,t) - 1) <= eps
            SU_min_gen_time_index = t+find(RTCGENSCHEDULE.val(i,t:end)+eps>=GENVALUE_VAL(i,min_gen),1)-1;
            if isempty(SU_min_gen_time_index)==0
                RTSCUC_END_START_TIME(i,1) = RTC_LOOKAHEAD_INTERVAL_VAL(SU_min_gen_time_index,1); 
                RTSCUC_INITIAL_START_TIME(i,1) = RTSCUC_END_START_TIME(i,1)-GENVALUE_VAL(i,su_time);
                t=HRTC;%if there are two startups in one RTSCUC, we just have to ignore the other.
            elseif t>1
                RTSCUC_INITIAL_START_TIME(i,1) = RTC_LOOKAHEAD_INTERVAL_VAL(t-1,1);
                RTSCUC_END_START_TIME(i,1) = RTSCUC_INITIAL_START_TIME(i,1) + GENVALUE_VAL(i,su_time); 
                t=HRTC;%if there are two startups in one RTSCUC, we just have to ignore the other.
            else
                RTSCUC_INITIAL_START_TIME(i,1) = time;
                RTSCUC_END_START_TIME(i,1) = RTSCUC_INITIAL_START_TIME(i,1) + GENVALUE_VAL(i,su_time); 
                t=HRTC;%if there are two startups in one RTSCUC, we just have to ignore the other.
            end
        end
        t=t+1;
    end
end

for i=1:ngen
    t=1;
    while t<=HRTC 
        if RTCUNITSHUTDOWN.val(i,t) == 1
            SD_complete_shut_time_index = t+find(RTCGENSCHEDULE.val(i,t:end)<=eps,1)-1; 
            if isempty(SD_complete_shut_time_index)==0
                RTSCUC_END_SHUT_TIME(i,1)  = RTC_LOOKAHEAD_INTERVAL_VAL(SD_complete_shut_time_index,1);
                RTSCUC_INITIAL_SHUT_TIME(i,1)  = RTSCUC_END_SHUT_TIME(i,1) - GENVALUE_VAL(i,sd_time);
                t=HRTC;%if there are two shutdowns in one RTSCUC, we just have to ignore the other.
            elseif t>1
                RTSCUC_INITIAL_SHUT_TIME(i,1)  = RTC_LOOKAHEAD_INTERVAL_VAL(t-1,1);
                RTSCUC_END_SHUT_TIME(i,1)  = RTSCUC_INITIAL_SHUT_TIME(i,1) + GENVALUE_VAL(i,sd_time);
                t=HRTC;%if there are two shutdowns in one RTSCUC, we just have to ignore the other.
            else
                RTSCUC_INITIAL_SHUT_TIME(i,1) = time;
                RTSCUC_END_SHUT_TIME(i,1) = RTSCUC_INITIAL_START_TIME(i,1) + GENVALUE_VAL(i,sd_time); 
                t=HRTC;%if there are two shutdowns in one RTSCUC, we just have to ignore the other.
            end
        end
        t=t+1;
    end
end        

