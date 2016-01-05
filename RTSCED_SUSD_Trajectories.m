function [STARTINGUP_VAL,STARTUPMINGENHELP_VAL,SHUTTINGDOWN_VAL]=RTSCED_SUSD_Trajectories(UNITSTATUS,STATUS_VAL,gentypes,UNITVALUE,ACTUAL_START_TIME,LASTRTSCEDBINDINGSCHEDULE,RTD_LOOKAHEAD_INTERVAL_VAL,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,su_time_index,sd_time_index,min_gen_index,initial_status_index,i,t,time,initialcall)

try

STARTUPMINGENHELP_VAL = 0;

%SU and SD trajectories
STARTINGUP_VAL = 0;
if (gentypes(i,1) ~= 7 && gentypes(i,1) ~= 10 && gentypes(i,1) ~= 14 && gentypes(i,1) ~= 16) && ((LASTRTSCEDBINDINGSCHEDULE(1,i+1)+eps < UNITVALUE.val(i,min_gen_index)) ) % the LASTRTSCEDBIN... may need to be removed
    earliest_index  = (max(1,ceil((RTD_LOOKAHEAD_INTERVAL_VAL(t,1)-UNITVALUE.val(i,su_time_index))*rtscuc_I_perhour+eps)+1));
    startup_time_check_index = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1;
    while(startup_time_check_index >= earliest_index)
        if startup_time_check_index <= 1
            Initial_RTD_last_startup_check = UNITVALUE.val(i,initial_status_index);
        else
            Initial_RTD_last_startup_check = UNITSTATUS(startup_time_check_index-1,i);
        end;
        if UNITSTATUS(startup_time_check_index,i)-Initial_RTD_last_startup_check == 1 && STATUS_VAL(i,t) == 1
%         if STATUS_VAL(i,t) == 1 && (UNITSTATUS(startup_time_check_index,i)-Initial_RTD_last_startup_check == 1 || LASTRTSCEDBINDINGSCHEDULE(1,i+1)+eps < UNITVALUE.val(i,min_gen_index))
            STARTINGUP_VAL = 1;
%             if initialcall == 0
                if ACTUAL_START_TIME(i,1) < time 
                    STARTUPMINGENHELP_VAL = UNITVALUE.val(i,min_gen_index)*(time-ACTUAL_START_TIME(i,1))/UNITVALUE.val(i,su_time_index);
                    if t == 1
                        if STARTUPMINGENHELP_VAL >= UNITVALUE.val(i,min_gen_index)
                            STARTUPMINGENHELP_VAL = 0;
                            STARTINGUP_VAL = 0;
                        end;
                    else
                        if STARTUPMINGENHELP_VAL+sum(INTERVAL_MINUTES_VAL(1:t-1,1))*UNITVALUE.val(i,min_gen_index)/(UNITVALUE.val(i,su_time_index)*60)+eps >= UNITVALUE.val(i,min_gen_index)
                            STARTINGUP_VAL = 0;
                        end;
                    end;
                end;
%             end
        end;
        startup_time_check_index = startup_time_check_index - 1;
    end;
end;
SHUTTINGDOWN_VAL = 0;
if gentypes(i,1) ~= 7 && gentypes(i,1) ~= 10 && gentypes(i,1) ~= 14 && gentypes(i,1) ~= 16
    latest_shut_index = min(size(UNITSTATUS,1),ceil((RTD_LOOKAHEAD_INTERVAL_VAL(t,1) + UNITVALUE.val(i,sd_time_index))*rtscuc_I_perhour-eps)+1);
    shutdown_time_check_index = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1;
    while(shutdown_time_check_index < latest_shut_index)
        if shutdown_time_check_index <= 1
            Initial_RTD_last_shutdown_check = UNITVALUE.val(i,initial_status_index);
        else
            Initial_RTD_last_shutdown_check = UNITSTATUS(shutdown_time_check_index-1,i);
        end;
        if Initial_RTD_last_shutdown_check - UNITSTATUS(shutdown_time_check_index,i) == 1
            SHUTTINGDOWN_VAL = 1;
        end;
        shutdown_time_check_index = shutdown_time_check_index + 1;
    end;
end;



catch
   s = lasterror; 
   Stack  = dbstack;
   stoppingpoint=Stack(1,1).line+4;
   stopcommand=sprintf('dbstop in RTSCED_SUSD_Trajectories.m at %d',stoppingpoint);
   eval(stopcommand);
   i;
end






end % end function