%commitment parameters for rtd, they cannot be adjusted in model
UNIT_STATUS_VAL = zeros(ngen,HRTD);
UNIT_STARTINGUP_VAL = zeros(ngen,HRTD);
UNIT_SHUTTINGDOWN_VAL = zeros(ngen,HRTD);
UNIT_STARTUPMINGENHELP_VAL = zeros(ngen,HRTD);
PUMPING_VAL = zeros(ngen,HRTD);
UNIT_PUMPINGUP_VAL = zeros(nESR,HRTD);
UNIT_PUMPINGDOWN_VAL = zeros(nESR,HRTD);
UNIT_PUMPUPMINGENHELP_VAL = zeros(nESR,HRTD);
RTD_SU_TWICE_IND_VAL = zeros(ngen,HRTD);
LAST_STATUS_VAL = zeros(ngen,1);
LAST_STATUS_ACTUAL_VAL = zeros(ngen,1);
LAST_STATUS_VAL(abs(LAST_GEN_SCHEDULE_VAL)>0)=1;  
LAST_STATUS_ACTUAL_VAL(abs(ACTUAL_GEN_OUTPUT_VAL)>0)=1; 
LAST_PUMPSTATUS_VAL = zeros(nESR,1);
LAST_PUMPSTATUS_ACTUAL_VAL = zeros(nESR,1);
LAST_PUMPSTATUS_VAL(LAST_PUMP_SCHEDULE_VAL>0)=1;  
LAST_PUMPSTATUS_ACTUAL_VAL(ACTUAL_PUMP_OUTPUT_VAL>0)=1; 
STARTUP_PERIOD_VAL = max(0,ceil(GENVALUE_VAL(:,su_time)*60/IRTDADV));

UNIT_PUMPINGUP_ACTUAL_VAL=zeros(nESR,1);
UNIT_STARTINGUP_ACTUAL_VAL=zeros(ngen,1); %in startup transition from actual to first interval of RTSCED.
%UNIT_STARTINGUP_ACTUAL_VAL(sttemp)=1;
%sdtemp=ACTUAL_GEN_OUTPUT_VAL>zeros(ngen,1)&LAST_GEN_SCHEDULE_VAL<=eps.*ones(ngen,1);
UNIT_SHUTTINGDOWN_ACTUAL_VAL=zeros(ngen,1);
%UNIT_SHUTTINGDOWN_ACTUAL_VAL(sdtemp)=1;
%sdtemp=ACTUAL_PUMP_OUTPUT_VAL>zeros(nESR,1)&LAST_PUMP_SCHEDULE_VAL<=eps.*ones(nESR,1);
UNIT_PUMPINGDOWN_ACTUAL_VAL=zeros(nESR,1);
%UNIT_PUMPINGDOWN_ACTUAL_VAL(sdtemp)=1;

%{
for e=1:nESR
    if ACTUAL_PUMP_OUTPUT_VAL(e,1)<STORAGEVALUE_VAL(e,min_pump) && LAST_PUMP_SCHEDULE_VAL(e,1)>=STORAGEVALUE_VAL(e,min_pump)
        UNIT_PUMPINGUP_ACTUAL_VAL(e,1)=1;
    end
end
for i=1:ngen
    if ACTUAL_GEN_OUTPUT_VAL(i,1)<GENVALUE_VAL(i,min_gen) && LAST_GEN_SCHEDULE_VAL(i,1)>=GENVALUE_VAL(i,min_gen)
        UNIT_STARTINGUP_ACTUAL_VAL(i,1)=1;
    end
end
%}

if Solving_Initial_Models
    % Align with initial RTSCUC
    GENVALUE_VAL(:,initial_MW)=LAST_GEN_SCHEDULE_VAL;
    GENVALUE_VAL(:,initial_status)=double(GENVALUE_VAL(:,initial_MW)>0);
    DEFAULT_DATA.GENVALUE.val=GENVALUE_VAL;
    ACTUAL_GEN_OUTPUT_VAL=LAST_GEN_SCHEDULE_VAL;
    LAST_STATUS_ACTUAL_VAL=double(ACTUAL_GEN_OUTPUT_VAL>0);
    UNIT_SHUTTINGDOWN_ACTUAL_VAL=UNIT_SHUTTINGDOWN_VAL(:,1);
    UNIT_STARTINGUP_ACTUAL_VAL=UNIT_STARTINGUP_VAL(:,1);
end

for i=1:ngen
    if Solving_Initial_Models==0
    if  gen_outage_time(i,1) <= time - PRTD/60 && gen_repair_time(i,1) >= time - PRTD/60
        rtd_gen_forced_out(i,1) = 1;
    else
        rtd_gen_forced_out(i,1) = 0;
    end;
    end;
    if Solving_Initial_Models==0 && rtd_gen_forced_out(i,1) == 1
       GEN_FORCED_OUT_VAL(i,1) = 1;
       UNIT_STATUS_VAL(i,1:HRTD) = 0;
       UNIT_STARTINGUP_VAL(i,1:HRTD) = 0;
       UNIT_SHUTTINGDOWN_VAL(i,1) = LAST_STATUS_VAL(i,1);
       UNIT_SHUTTINGDOWN_VAL(i,2:HRTD) = 0;
       PUMPING_VAL(i,1:HRTD) = 0;
       UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
       try
       UNIT_PUMPINGUP_VAL(find(storage_to_gen_index==i),1:HRTD) = 0;
       UNIT_PUMPINGDOWN_VAL(find(storage_to_gen_index==i),1) = LAST_PUMPSTATUS_VAL(find(storage_to_gen_index==i),1);
       UNIT_PUMPINGDOWN_VAL(find(storage_to_gen_index==i),2:HRTD) = 0;
       UNIT_PUMPUPMINGENHELP_VAL(find(storage_to_gen_index==i),1) = 0;
       catch; end;
   else
        GEN_FORCED_OUT_VAL(i,1) = 0;
        t = 0;
        UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
        if Solving_Initial_Models && RTSCUCBINDINGSCHEDULE(1,1+i) > 0 && GENVALUE_VAL(i,initial_MW) < eps
           ACTUAL_START_TIME(i,1) = -1*IDAC; 
        end;
        if time - PRTD/60 < ACTUAL_GENERATION(1,1)
            UNIT_STARTINGUP_ACTUAL_VAL(i,1) = max(0,STATUS(1,i+1)-GENVALUE_VAL(i,initial_status));
            UNIT_SHUTTINGDOWN_ACTUAL_VAL(i,1) = max(0,GENVALUE_VAL(i,initial_status)-STATUS(1,i+1));
        else
        Actuals_time = ACTUAL_GENERATION(AGC_interval_index-round(PRTD*60/t_AGC),1);
        lookahead_interval_index_ceil = min(size(STATUS,1),ceil(Actuals_time*rtscuc_I_perhour-eps) + 1);
        lookahead_interval_index_floor = min(size(STATUS,1),floor(Actuals_time*rtscuc_I_perhour+eps) + 1); 
        [UNIT_STARTINGUP_ACTUAL_VAL(i,1),~,UNIT_SHUTTINGDOWN_ACTUAL_VAL(i,1)]=RTSCED_SUSD_Trajectories(STATUS(:,1+i),LAST_STATUS_VAL(i,1),LAST_STATUS_ACTUAL_VAL(i,1),GENVALUE_VAL(i,gen_type),GENVALUE_VAL(i,:),ACTUAL_START_TIME(i,1),Actuals_time,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,su_time,sd_time,min_gen,initial_status,t,time,IDAC,0);
        end
        
        for t=1:HRTD
            lookahead_interval_index_ceil = min(size(STATUS,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);
            lookahead_interval_index_floor = min(size(STATUS,1),floor(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour+eps) + 1); 
            %determining what the unit status will be will depend on the RTSCUC status at both sides of its time interval.
            if GENVALUE_VAL(i,min_gen) == 0 && (GENVALUE_VAL(i,gen_type) == wind_gen_type_index || GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == interface_gen_type_index  || GENVALUE_VAL(i,gen_type) == variable_dispatch_gen_type_index)
                UNIT_STATUS_VAL(i,t) = 1; %keeping all vg on
            elseif STATUS(lookahead_interval_index_ceil,1+i) == STATUS(lookahead_interval_index_floor,1+i)
                UNIT_STATUS_VAL(i,t) = STATUS(lookahead_interval_index_ceil,1+i); %no change across the RTSCUC interval
            elseif STATUS(lookahead_interval_index_ceil,1+i) == 1 %unit in process of turning on
                if GENVALUE_VAL(i,su_time) > RTSCUCBINDINGCOMMITMENT(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                    UNIT_STATUS_VAL(i,t) = 1;
                else
                    UNIT_STATUS_VAL(i,t) = 0;
                end;
            elseif STATUS(lookahead_interval_index_ceil,1+i) == 0 %unit in process of turning off should still be on until absolute last interval
                UNIT_STATUS_VAL(i,t) = 1;
            end;
            %SU and SD trajectories
            if t==1
                last_startup = ACTUAL_START_TIME(i,1)<RTD_LOOKAHEAD_INTERVAL_VAL(t,1)-(tRTD/60);
                last_status = LAST_STATUS_VAL(i,1);
            else
                last_startup = UNIT_STARTINGUP_VAL(i,t-1); % for knowing whether start-up is continuous or new.
                last_status = UNIT_STATUS_VAL(i,t-1);
            end
            [UNIT_STARTINGUP_VAL(i,t),UNIT_STARTUPMINGENHELP_VAL(i,t),UNIT_SHUTTINGDOWN_VAL(i,t)]=RTSCED_SUSD_Trajectories(STATUS(:,1+i),UNIT_STATUS_VAL(i,t),last_status,GENVALUE_VAL(i,gen_type),GENVALUE_VAL(i,:),ACTUAL_START_TIME(i,1),RTD_LOOKAHEAD_INTERVAL_VAL(t,1),INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,su_time,sd_time,min_gen,initial_status,t,time,IDAC,last_startup);
            
            if isempty(find(storage_to_gen_index==i))==0
            if PUMPSTATUS(lookahead_interval_index_ceil,1+i) == PUMPSTATUS(lookahead_interval_index_floor,1+i)
                PUMPING_VAL(i,t) = PUMPSTATUS(lookahead_interval_index_ceil,1+i); %no change across the RTSCUC interval
            elseif PUMPSTATUS(lookahead_interval_index_ceil,1+i) == 1 %unit in process of turning on
                if STORAGEVALUE_VAL(find(storage_to_gen_index==i),pump_su_time) > RTSCUCBINDINGCOMMITMENT(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                    PUMPING_VAL(i,t) = 1;
                else
                    PUMPING_VAL(i,t) = 0;
                end;
            elseif PUMPSTATUS(lookahead_interval_index_ceil,1+i) == 0 %unit in process of turning off should still be on until absolute last interval
                PUMPING_VAL(i,t) = 1;
            end;
            end
        end;
    end;
end;

for e=1:nESR
    for t=1:HRTD
        if time - PRTD/60 < ACTUAL_GENERATION(1,1)
            UNIT_PUMPINGUP_ACTUAL_VAL(e,1) = max(0,PUMPSTATUS(1,1+storage_to_gen_index(e,1))-STORAGEVALUE_VAL(e,initial_pump_status));
            UNIT_PUMPINGDOWN_ACTUAL_VAL(e,1) = max(0,STORAGEVALUE_VAL(e,initial_pump_status)-PUMPSTATUS(1,1+storage_to_gen_index(e,1)));
            Actuals_time = ACTUAL_GENERATION(1,1);
        else
            [UNIT_PUMPINGUP_ACTUAL_VAL(e,1),~,UNIT_PUMPINGDOWN_ACTUAL_VAL(e,1)]=RTSCED_SUSD_Trajectories(PUMPSTATUS(:,1+storage_to_gen_index(e,1)),LAST_PUMPSTATUS_VAL(e,1),LAST_PUMPSTATUS_ACTUAL_VAL(e,1),GENVALUE_VAL(storage_to_gen_index(e,1),gen_type),STORAGEVALUE_VAL(e,:),ACTUAL_PUMPUP_TIME(e,1),Actuals_time,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,pump_su_time,pump_sd_time,min_pump,initial_pump_status,t,time,IDAC,0);
            Actuals_time = ACTUAL_GENERATION(AGC_interval_index-round(PRTD*60/t_AGC),1);
        end
        
        lookahead_interval_index_ceil = min(size(PUMPSTATUS,1),ceil(Actuals_time*rtscuc_I_perhour-eps) + 1);
        lookahead_interval_index_floor = min(size(PUMPSTATUS,1),floor(Actuals_time*rtscuc_I_perhour+eps) + 1); 
        if PUMPSTATUS(lookahead_interval_index_ceil,1+storage_to_gen_index(e,1)) == PUMPSTATUS(lookahead_interval_index_floor,1+storage_to_gen_index(e,1))
            last_pump_status = PUMPSTATUS(lookahead_interval_index_ceil,1+storage_to_gen_index(e,1)); %no change across the RTSCUC interval
        elseif PUMPSTATUS(lookahead_interval_index_ceil,1+storage_to_gen_index(e,1)) == 1 %unit in process of turning on
            if STORAGEVALUE_VAL(e,pump_su_time) > RTSCUCBINDINGPUMPING(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                last_pump_status = 1;
            else
                last_pump_status = 0;
            end;
        elseif PUMPSTATUS(lookahead_interval_index_ceil,1+storage_to_gen_index(e,1)) == 0 %unit in process of turning off should still be on until absolute last interval
            last_pump_status = 1;
        end;
    
        if t==1
            last_startup = 0;
        else
            last_startup = UNIT_PUMPINGUP_VAL(e,t-1); % for knowing whether start-up is continuous or new.
        end
        [UNIT_PUMPINGUP_VAL(e,t),UNIT_PUMPUPMINGENHELP_VAL(e,t),UNIT_PUMPINGDOWN_VAL(e,t)]=RTSCED_SUSD_Trajectories(PUMPSTATUS(:,1+storage_to_gen_index(e,1)),PUMPING_VAL(e,t),last_pump_status,GENVALUE_VAL(storage_to_gen_index(e,1),gen_type),STORAGEVALUE_VAL(e,:),ACTUAL_PUMPUP_TIME(e,1),RTD_LOOKAHEAD_INTERVAL_VAL(t,1),INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,pump_su_time,pump_sd_time,min_pump,initial_pump_status,t,time,IDAC,last_startup);
    end
end

if Solving_Initial_Models
    % Align with initial RTSCUC
    UNIT_SHUTTINGDOWN_ACTUAL_VAL=UNIT_SHUTTINGDOWN_VAL(:,1);
    UNIT_STARTINGUP_ACTUAL_VAL=UNIT_STARTINGUP_VAL(:,1);
end