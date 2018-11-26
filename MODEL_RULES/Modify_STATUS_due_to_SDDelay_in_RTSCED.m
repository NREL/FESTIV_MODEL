% Check if a unit shutting down needs to be delayed
if sum(sum(UNIT_SHUTTINGDOWN_VAL)) > 0
    [delayedshutdown,LAST_STATUS_VAL,RTSCUCBINDINGSCHEDULE,RTSCUCBINDINGCOMMITMENT,STATUS,UNIT_SHUTTINGDOWN_VAL,UNIT_STATUS_VAL,UNIT_PUMPINGUP_VAL,PUMPING_VAL,PUMPSTATUS,RTSCUCBINDINGPUMPING,RTSCUCBINDINGPUMPSCHEDULE]=rtdDelayShutdowns(delayedshutdown,ACTUAL_GEN_OUTPUT_VAL,LAST_STATUS_ACTUAL_VAL,LAST_GEN_SCHEDULE_VAL,LAST_STATUS_VAL,UNIT_SHUTTINGDOWN_VAL,INTERVAL_MINUTES_VAL,GENVALUE_VAL,ramp_rate,PRTD,min_gen,IRTD,HRTD,IRTC,RTSCEDBINDINGSCHEDULE,UNIT_STATUS_VAL,STATUS,RTSCUC_binding_interval_index,HRTC,RTSCUCBINDINGCOMMITMENT,RTSCUCBINDINGSCHEDULE,LAST_STATUS_VAL,PUMPSTATUS,RTSCUCBINDINGPUMPING,RTSCUCBINDINGPUMPSCHEDULE,UNIT_PUMPINGUP_VAL,PUMPING_VAL,md_time,STORAGEVALUE_VAL,min_pump_time,eps,RTSCED_binding_interval_index);
end
if sum(sum(UNIT_PUMPINGDOWN_VAL)) > 0
    [delayedpumpdown,LAST_PUMPSTATUS_VAL,RTSCUCBINDINGPUMPSCHEDULE,RTSCUCBINDINGPUMPING,PUMPSTATUS,UNIT_PUMPINGDOWN_VAL,PUMPING_VAL,UNIT_STARTINGUP_VAL,UNIT_STATUS_VAL,STATUS,RTSCUCBINDINGCOMMITMENT,RTSCUCBINDINGSCHEDULE]=rtdDelayShutdowns(delayedpumpdown,ACTUAL_PUMP_OUTPUT_VAL,LAST_PUMPSTATUS_ACTUAL_VAL,LAST_PUMP_SCHEDULE_VAL,LAST_PUMPSTATUS_VAL,UNIT_PUMPINGDOWN_VAL,INTERVAL_MINUTES_VAL,STORAGEVALUE,pump_ramp_rate,PRTD,min_pump,IRTD,HRTD,IRTC,RTSCEDBINDINGPUMPSCHEDULE,PUMPING_VAL,PUMPSTATUS,RTSCUC_binding_interval_index,HRTC,RTSCUCBINDINGPUMPING,RTSCUCBINDINGPUMPSCHEDULE,LAST_PUMPSTATUS_VAL,STATUS,RTSCUCBINDINGCOMMITMENT,RTSCUCBINDINGSCHEDULE,UNIT_STARTINGUP_VAL,UNIT_STATUS_VAL,0,GENVALUE_VAL,mr_time,eps,GENVALUE_VAL(:,gen_type),RTSCED_binding_interval_index);
end
RTD_SU_TWICE_IND_VAL=ones(ngen,1);
SU_TWICE_CHECK=zeros(ngen,1);
for i=1:ngen
    for t1=1:HRTD-1
        if UNIT_STATUS_VAL(i,t1+1)-UNIT_STATUS_VAL(i,t1)==-1
            for t2=t1:HRTD-1
                if UNIT_STATUS_VAL(i,t2+1)-UNIT_STATUS_VAL(i,t2)==1
                    SU_TWICE_CHECK(i,1)=1;
                end
            end
        end
    end
end
i=1;
while i <=ngen
    if GENVALUE_VAL(i,md_time) <= sum(INTERVAL_MINUTES_VAL)/60 && SU_TWICE_CHECK(i,1)==1
        t=1;
        while t<=HRTD
            % update unit status for units with Toff < HRTD
            lookahead_interval_index_ceil = min(size(STATUS,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);
            lookahead_interval_index_floor = min(size(STATUS,1),floor(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour+eps) + 1); %fixed was turning units off at the wrong time.
            if GENVALUE_VAL(i,gen_type) == wind_gen_type_index || GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == interface_gen_type_index || GENVALUE_VAL(i,gen_type) == variable_dispatch_gen_type_index
                UNIT_STATUS_VAL(i,t) = 1; %keeping all vg on
            elseif STATUS(lookahead_interval_index_ceil,1+i) == STATUS(lookahead_interval_index_floor,1+i)
                UNIT_STATUS_VAL(i,t) = STATUS(lookahead_interval_index_ceil,1+i);
            elseif STATUS(lookahead_interval_index_ceil,1+i) == 1
                if GENVALUE_VAL(i,su_time) > RTSCUCBINDINGCOMMITMENT(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                    UNIT_STATUS_VAL(i,t) = 1;
                else
                    UNIT_STATUS_VAL(i,t) = 0;
                end;
            elseif STATUS(lookahead_interval_index_ceil,1+i) == 0
                UNIT_STATUS_VAL(i,t) = 1;
            end;
            % update unit startingup for units with Toff < HRTD 
            temp=find(not(UNIT_STATUS_VAL(i,:)),1,'first');
            if isempty(temp)
               RTD_SU_TWICE_IND_VAL(i,1)=HRTD+1;
            else
               RTD_SU_TWICE_IND_VAL(i,1)=temp;
            end
            UNIT_STARTINGUP_VAL(i,t) = 0;
            if (GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index) && ((RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,i+1)+eps < GENVALUE_VAL(i,min_gen)) || t >= RTD_SU_TWICE_IND_VAL(i,1))
                earliest_start_index = max(1,ceil((RTD_LOOKAHEAD_INTERVAL_VAL(t,1)-GENVALUE_VAL(i,su_time))*rtscuc_I_perhour-eps)+1);
                startup_time_check_index = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1;
                while(startup_time_check_index >= earliest_start_index)
                    if startup_time_check_index <= 1
                        Initial_RTD_last_startup_check = GENVALUE_VAL(i,initial_status);
                    else
                        Initial_RTD_last_startup_check = STATUS(startup_time_check_index-1,1+i);
                    end;
                    if STATUS(startup_time_check_index,1+i)-Initial_RTD_last_startup_check == 1 && UNIT_STATUS_VAL(i,t) == 1 && (time - ACTUAL_START_TIME(i,1) - GENVALUE_VAL(i,su_time) < eps)
                        UNIT_STARTINGUP_VAL(i,t) = 1;
                        if ACTUAL_START_TIME(i,1) < time && t==1
                            UNIT_STARTUPMINGENHELP_VAL(i,1) = GENVALUE_VAL(i,min_gen)*(time-ACTUAL_START_TIME(i,1))/GENVALUE_VAL(i,su_time);
                            if UNIT_STARTUPMINGENHELP_VAL(i,1) >= GENVALUE_VAL(i,min_gen)
                                UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
                                UNIT_STARTINGUP_VAL(i,1:HRTD) = 0;
                            end;
                        end;
                    end;
                    startup_time_check_index = startup_time_check_index - 1;
                end;
            end;
            t=t+1;
        end
    end
    i=i+1;
end
temp=ones(ngen,HRTD);
for i=1:ngen
    if RTD_SU_TWICE_IND_VAL(i,1)==HRTD+1
        RTD_SU_TWICE_IND_VAL(i,1)=1;
    end
    temp(i,RTD_SU_TWICE_IND_VAL(i,1):end)=RTD_SU_TWICE_IND_VAL(i,1);
end
RTD_SU_TWICE_IND_VAL=temp;
if HRTD > 1
     UNIT_STARTUPMINGENHELP_VAL(1:ngen,2:HRTD)=zeros(ngen,HRTD-1);
     UNIT_PUMPUPMINGENHELP_VAL(1:nESR,2:HRTD)=zeros(nESR,HRTD-1);
end

for i=1:ngen
    if  (RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,i+1) <= GENVALUE_VAL(i,min_gen))
        delayedshutdown(i,1)=0;
    end
end;
for e=1:nESR
    if  (RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1,e+1) <= STORAGEVALUE_VAL(e,min_pump))
        delayedpumpdown(storage_to_gen_index(e,1),1)=0;
    end
end

UNITSDCOUNT.val = sdcount2;
UNITSDCOUNT.name = 'UNITSDCOUNT';
UNITSDCOUNT.form = 'full';
UNITSDCOUNT.uels = {GEN_VAL' INTERVAL_VAL'};
UNITSDCOUNT.type = 'parameter';

PUMPUNITSDCOUNT.val = pumpsdcount2;
PUMPUNITSDCOUNT.name = 'PUMPUNITSDCOUNT';
PUMPUNITSDCOUNT.form = 'full';
PUMPUNITSDCOUNT.uels = {STORAGE_UNITS' INTERVAL_VAL'};
PUMPUNITSDCOUNT.type = 'parameter';

if Solving_Initial_Models == 1
    DELAYSD.val = zeros(ngen,1);
else
    DELAYSD.val = delayedshutdown;
end
DELAYSD.name = 'DELAYSD';
DELAYSD.form = 'full';
DELAYSD.uels = GEN_VAL';
DELAYSD.type = 'parameter';

if Solving_Initial_Models == 1
    DELAYPUMPSD.val = zeros(ngen,1);
else
    DELAYPUMPSD.val = delayedpumpdown;
end
DELAYPUMPSD.name = 'DELAYPUMPSD';
DELAYPUMPSD.form = 'full';
DELAYPUMPSD.uels = GEN_VAL';
DELAYPUMPSD.type = 'parameter';

wgdx(['TEMP', filesep, 'SHUT_DOWN_DELAY_FILE'],DELAYSD,DELAYPUMPSD,UNITSDCOUNT,PUMPUNITSDCOUNT);
