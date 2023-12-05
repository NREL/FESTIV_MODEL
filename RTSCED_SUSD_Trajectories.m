function [STARTINGUP_VAL,STARTUPMINGENHELP_VAL,SHUTTINGDOWN_VAL]=RTSCED_SUSD_Trajectories(UNITSTATUS,current_status,last_status,gentype,UNITVALUE,ACTUAL_START_TIME,Interval_Time,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,su_time_index,sd_time_index,min_gen_index,initial_status_index,t,time,IDAC,last_startup)

STARTUPMINGENHELP_VAL = 0;

%SU and SD trajectories
STARTINGUP_VAL = 0;
if gentype ~= 7 && gentype ~= 10 && gentype ~= 14 && gentype ~= 16  
    startup_period_check_end  = (max(1,ceil((Interval_Time-UNITVALUE(1,su_time_index))*rtscuc_I_perhour+eps)+1));
    startup_period_check_time = ceil(Interval_Time*rtscuc_I_perhour-eps) + 1;
    while(startup_period_check_time >= startup_period_check_end)
        if startup_period_check_time <= 1
            Initial_RTD_last_startup_check = UNITVALUE(1,initial_status_index);
            initialflag=1;
        else
            Initial_RTD_last_startup_check = UNITSTATUS(startup_period_check_time-1,1);
            initialflag=0;
        end;
        if UNITSTATUS(startup_period_check_time,1)-Initial_RTD_last_startup_check == 1 && current_status == 1 
%         if STATUS_VAL(i,t) == 1 && (UNITSTATUS(startup_time_check_index,i)-Initial_RTD_last_startup_check == 1 || LASTRTSCEDBINDINGSCHEDULE(1,i+1)+eps < UNITVALUE(i,min_gen_index))
            STARTINGUP_VAL = 1;
            if initialflag == 1
                ACTUAL_START_TIME =-IDAC;
            end
                if ACTUAL_START_TIME < time && last_startup==1
                    STARTUPMINGENHELP_VAL = UNITVALUE(1,min_gen_index)*(time-ACTUAL_START_TIME)/UNITVALUE(1,su_time_index);
                    if t <= 1
                        if STARTUPMINGENHELP_VAL >= UNITVALUE(1,min_gen_index)
                            STARTUPMINGENHELP_VAL = 0;
                            STARTINGUP_VAL = 0;
                        end;
                    else
                        if STARTUPMINGENHELP_VAL+sum(INTERVAL_MINUTES_VAL(1:t-1,1))*UNITVALUE(1,min_gen_index)/(UNITVALUE(1,su_time_index)*60)+eps >= UNITVALUE(1,min_gen_index)
                            STARTINGUP_VAL = 0;
                        end;
                    end;
                end;
        end;
        startup_period_check_time = startup_period_check_time - 1;
    end;
end;
SHUTTINGDOWN_VAL = 0;
if t==0 %test for now, can be consolodated or simplified.
if gentype ~= 7 && gentype ~= 10 && gentype ~= 14 && gentype ~= 16
    latest_shut_index = min(size(UNITSTATUS,1),ceil((Interval_Time + UNITVALUE(1,sd_time_index))*rtscuc_I_perhour-eps)+1);
    shutdown_time_check_index = ceil(Interval_Time*rtscuc_I_perhour-eps) + 1;
    while(shutdown_time_check_index <= latest_shut_index)
        if shutdown_time_check_index <= 1
            Initial_RTD_last_shutdown_check = UNITVALUE(1,initial_status_index);
            initialflag=1;
        else
            Initial_RTD_last_shutdown_check = UNITSTATUS(shutdown_time_check_index-1,1);
            initialflag=0;
        end
        if Initial_RTD_last_shutdown_check - UNITSTATUS(shutdown_time_check_index,1) == 1 && last_status==1
            if initialflag && UNITVALUE(1,sd_time_index)<IDAC
                SHUTTINGDOWN_VAL = 0;
            else    
                SHUTTINGDOWN_VAL = 1;
            end;
        end;
        shutdown_time_check_index = shutdown_time_check_index + 1;
    end;
end;
else
if gentype ~= 7 && gentype ~= 10 && gentype ~= 14 && gentype ~= 16
    latest_shut_index = min(size(UNITSTATUS,1),ceil((Interval_Time + UNITVALUE(1,sd_time_index))*rtscuc_I_perhour-eps)+1);
    shutdown_time_check_index = ceil(Interval_Time*rtscuc_I_perhour-eps) + 1;
    while(shutdown_time_check_index < latest_shut_index)
        if shutdown_time_check_index <= 1
            Initial_RTD_last_shutdown_check = UNITVALUE(1,initial_status_index);
            initialflag=1;
        else
            Initial_RTD_last_shutdown_check = UNITSTATUS(shutdown_time_check_index-1,1);
            initialflag=0;
        end
        if Initial_RTD_last_shutdown_check - UNITSTATUS(shutdown_time_check_index,1) == 1 && last_status==1
            if initialflag && UNITVALUE(1,sd_time_index)<IDAC
                SHUTTINGDOWN_VAL = 0;
            else    
                SHUTTINGDOWN_VAL = 1;
            end;
        end;
        shutdown_time_check_index = shutdown_time_check_index + 1;
    end;
end;
end






end % end function