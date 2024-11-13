    GEN_AGC_MODES=GENVALUE_VAL(:,gen_agc_mode);
    ACTUAL_GENERATION(AGC_interval_index,1) = time;
    ACTUAL_PUMP(AGC_interval_index,1) = time;
    ACTUAL_STORAGE_LEVEL(AGC_interval_index,1) = time;
    
    if AGC_interval_index >2
        for i=1:ngen
            if actual_gen_forced_out(i,1) == 1
                ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
            else
                if((GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == wind_gen_type_index)  )
                    w = 1;
                    while(w<=size(ACTUAL_VG_FIELD,2)-1)
                        if(strcmp(GEN_VAL(i,1),ACTUAL_VG_FIELD(1+w)))
                        if rtd_binding_vg_curtailment(i,1) == 1 || agc_vg_curtailment(i,1)==1
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = min(ACTUAL_VG_FULL(AGC_interval_index,1+w),min(GENVALUE_VAL(i,capacity),...
                                max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE_VAL(i,min_gen),...
                                AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE_VAL(i,behavior_rate))*randn(1)) ...
                                + ((1-GENVALUE_VAL(i,behavior_rate))*randn(1))*(ACTUAL_GENERATION(AGC_interval_index-1,1+i)...
                                - AGC_SCHEDULE(AGC_interval_index-2,1+i)))));
                            w=size(ACTUAL_VG_FIELD,2);
                        else
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_VG_FULL(AGC_interval_index,1+w);
%                                 ACTUAL_GENERATION(AGC_interval_index,1+i) = min(ACTUAL_GENERATION(AGC_interval_index-1,1+i)+5,ACTUAL_VG_FULL(AGC_interval_index,1+w));
                        end
                            w=size(ACTUAL_VG_FIELD,2);
                        elseif(w==size(ACTUAL_VG_FIELD,2)-1)        %gone through entire list of VG and gen is not included
                             ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
                        end
                        w = w+1;
                    end
                elseif GENVALUE_VAL(i,gen_type) == interface_gen_type_index && GENVALUE_VAL(i,agc_qualified)==0
                    interchangeindices=find(find(interchanges)==i);
                    ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_INTERCHANGE_FULL(AGC_interval_index,interchangeindices+1);
                else
                   ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE_VAL(i,capacity),...
                        max(max(0,(UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1)))*GENVALUE_VAL(i,min_gen),...
                        AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE_VAL(i,behavior_rate))*randn(1)) ...
                        + ((1-GENVALUE_VAL(i,behavior_rate))*randn(1))*(ACTUAL_GENERATION(AGC_interval_index-1,1+i)...
                        - AGC_SCHEDULE(AGC_interval_index-2,1+i))));
                end
            end
        end
        for e=1:nESR
            if actual_gen_forced_out(storage_to_gen_index(e,1),1) == 1
                ACTUAL_PUMP(AGC_interval_index,1+e) = 0;
            elseif AGC_SCHEDULE(AGC_interval_index-1,1+storage_to_gen_index(e,1)) < 0
                ACTUAL_PUMP(AGC_interval_index,1+e) = min(STORAGEVALUE_VAL(e,max_pump),...
                    max((PUMPING_VAL(storage_to_gen_index(e,1),1)-UNIT_PUMPINGUP_VAL(e,1)-UNIT_PUMPINGDOWN_VAL(e,1))*STORAGEVALUE_VAL(e,min_pump),...
                    abs(AGC_SCHEDULE(AGC_interval_index-1,1+storage_to_gen_index(e,1)))*(1+(1-GENVALUE_VAL(storage_to_gen_index(e,1),behavior_rate))*randn(1)) ...
                    + ((1-GENVALUE_VAL(storage_to_gen_index(e,1),behavior_rate))*randn(1))*(abs(ACTUAL_PUMP(AGC_interval_index-1,1+e))...
                    - AGC_SCHEDULE(AGC_interval_index-2,1+storage_to_gen_index(e,1)))));
            else
                ACTUAL_PUMP(AGC_interval_index,1+e) = 0;
            end
           ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-1,1+e) ...
                - (t_AGC/60/60)*ACTUAL_GENERATION(AGC_interval_index,1+storage_to_gen_index(e,1)) + (t_AGC/60/60)*ACTUAL_PUMP(AGC_interval_index,1+e)*STORAGEVALUE_VAL(e,efficiency);
           if ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) > STORAGEVALUE_VAL(e,storage_max)
               ACTUAL_PUMP(AGC_interval_index,1+e) = ACTUAL_PUMP(AGC_interval_index,1+e) - (ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) - STORAGEVALUE_VAL(e,storage_max))/(t_AGC/60/60)/STORAGEVALUE_VAL(e,efficiency);
               ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) = STORAGEVALUE_VAL(e,storage_max);
           elseif ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) < 0
               ACTUAL_GENERATION(AGC_interval_index,1+storage_to_gen_index(e,1)) = ACTUAL_GENERATION(AGC_interval_index,1+storage_to_gen_index(e,1)) + ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e)/(t_AGC/60/60);
               ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) = 0;
           end
        end
        AGC_LAST = AGC_SCHEDULE(AGC_interval_index-1,:);
    elseif AGC_interval_index ==2
        for i=1:ngen
            if actual_gen_forced_out(i,1) == 1
                ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
            else
                if((GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == wind_gen_type_index)  )
                    w = 1;
                    while(w<=size(ACTUAL_VG_FIELD,2)-1)
                        if(strcmp(GEN_VAL(i,1),ACTUAL_VG_FIELD(1+w)))
                        if rtd_binding_vg_curtailment(i,1) == 1 || agc_vg_curtailment(i,1)==1
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = min(ACTUAL_VG_FULL(AGC_interval_index,1+w),min(GENVALUE_VAL(i,capacity),...
                                max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE_VAL(i,min_gen),...
                                AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE_VAL(i,behavior_rate))*randn(1)))));
                        else
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_VG_FULL(AGC_interval_index,1+w);
                        end
                        w=size(ACTUAL_VG_FIELD,2);
                        elseif(w==nvg)        %gone through entire list of VG and gen is not included
                             ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
                        end
                        w = w+1;
                    end
                elseif GENVALUE_VAL(i,gen_type) == interface_gen_type_index && GENVALUE_VAL(i,agc_qualified)==0
                    interchangeindices=find(find(interchanges)==i);
                    ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_INTERCHANGE_FULL(AGC_interval_index,interchangeindices+1);
                else
                    ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE_VAL(i,capacity),...
                        max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE_VAL(i,min_gen),...
                        AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE_VAL(i,behavior_rate))*randn(1)))); 
                end
            end
            if abs(ACTUAL_GENERATION(AGC_interval_index,1+i)) < eps && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index
                ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
            end
        end
        for e=1:nESR
            if actual_gen_forced_out(storage_to_gen_index(e,1),1) == 1
                ACTUAL_PUMP(AGC_interval_index,1+e) = 0;
            elseif AGC_SCHEDULE(AGC_interval_index-1,1+storage_to_gen_index(e,1)) < 0
                ACTUAL_PUMP(AGC_interval_index,1+e) = min(STORAGEVALUE_VAL(e,max_pump),...
                    max((PUMPING_VAL(storage_to_gen_index(e,1),1)-UNIT_PUMPINGUP_VAL(e,1)-UNIT_PUMPINGDOWN_VAL(e,1))*STORAGEVALUE_VAL(e,min_pump),...
                    abs(AGC_SCHEDULE(AGC_interval_index-1,1+storage_to_gen_index(e,1)))*(1+(1-GENVALUE_VAL(storage_to_gen_index(e,1),behavior_rate))*randn(1))));
            else
                ACTUAL_PUMP(AGC_interval_index,1+e) = 0;
            end
            %Only works for constant efficiency.
            ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) = min(STORAGEVALUE_VAL(e,storage_max),ACTUAL_STORAGE_LEVEL(AGC_interval_index-1,1+e) ...
                - (t_AGC/60/60)*ACTUAL_GENERATION(AGC_interval_index,1+storage_to_gen_index(e,1)) + (t_AGC/60/60)*ACTUAL_PUMP(AGC_interval_index,1+e)*STORAGEVALUE_VAL(e,efficiency));
            if ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) > STORAGEVALUE_VAL(e,storage_max)
               ACTUAL_PUMP(AGC_interval_index,1+e) = ACTUAL_PUMP(AGC_interval_index,1+e) - (ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) - STORAGEVALUE_VAL(e,storage_max))/(t_AGC/60/60)/STORAGEVALUE_VAL(e,efficiency);
               ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) = STORAGEVALUE_VAL(e,storage_max);
            elseif ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) < 0
               ACTUAL_GENERATION(AGC_interval_index,1+storage_to_gen_index(e,1)) = ACTUAL_GENERATION(AGC_interval_index,1+storage_to_gen_index(e,1)) + ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e)/(t_AGC/60/60);
               ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+e) = 0;
            end
        end
        AGC_LAST = AGC_SCHEDULE(AGC_interval_index-1,:);
    else
        AGC_LAST = 0;
        ACE(1,:) = [time 0 0 0 0 0];
        Max_Reg_Limit_Hit=[0 0];
        Min_Reg_Limit_Hit=[0 0];
        ACTUAL_GENERATION(AGC_interval_index,2:ngen+1) = RTSCEDBINDINGSCHEDULE(1,2:ngen+1);
        ACTUAL_PUMP(AGC_interval_index,2:nESR+1) = RTSCEDBINDINGPUMPSCHEDULE(1,2:nESR+1);
    end;
    

    if AGC_interval_index > 1
        for i=1:ngen
            if ACTUAL_GENERATION(AGC_interval_index,1+i) > eps && ACTUAL_GENERATION(AGC_interval_index-1,1+i) < eps
                ACTUAL_START_TIME(i,1) = ACTUAL_GENERATION(AGC_interval_index-1,1);
            end
            if ACTUAL_GENERATION(AGC_interval_index,1+i) < eps || ACTUAL_GENERATION(AGC_interval_index,1+i) >= GENVALUE_VAL(i,min_gen)
                ACTUAL_START_TIME(i,1) = inf;
            end
        end
        for e=1:nESR
            if ACTUAL_PUMP(AGC_interval_index,1+e) > 0 && ACTUAL_PUMP(AGC_interval_index-1,1+e) < eps
                ACTUAL_PUMPUP_TIME(e,1) = ACTUAL_PUMP(AGC_interval_index-1,1);
            end         
            if ACTUAL_PUMP(AGC_interval_index,1+e) < eps
                ACTUAL_PUMPUP_TIME(e,1) = inf;
            end
        end
    else
        for i=1:ngen
            if ACTUAL_GENERATION(AGC_interval_index,1+i) > 0 && GENVALUE_VAL(i,initial_MW) < eps
               ACTUAL_START_TIME(i,1) = -1*IDAC; 
            end
        end
        for e=1:nESR
            if ACTUAL_PUMP(AGC_interval_index,1+e) > 0 && STORAGEVALUE_VAL(e,initial_pump_mw) < eps
               ACTUAL_PUMPUP_TIME(e,1) = -1*IDAC; 
            end
        end
    end
