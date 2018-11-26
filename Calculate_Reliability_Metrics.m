
% Calculate ALFEE
if monitor_ALFEE == 1
bus_injection = zeros(nbus,1);

for t=1:AGC_interval_index-1
    for n=1:nbus
        bus_injection(n,1) = -1*LOAD_DIST_VAL(n,1)*ACTUAL_LOAD_FULL(t,2);
    end;
    for i=1:ngen
        bus_injection(GENBUS_CALCS_VAL(i,2),1)= bus_injection(GENBUS_CALCS_VAL(i,2),1) + ACTUAL_GENERATION(t,1+i);
    end;
    LF_violation(t,1) = ACE(t,ACE_time_index);
    LF_violation_exceedance(t,1) = ACE(t,ACE_time_index);
    %ALFEE_Monitor_sort = sortrows(ALFEE_Monitor);
    for l=1:nbranch
        ACTUAL_LF(l,1) = PTDF_VAL(l,:)*bus_injection;
        if ACTUAL_LF(l,1) > BRANCHDATA_VAL(l,line_rating) || ACTUAL_LF(l,1) < -1*BRANCHDATA_VAL(l,line_rating)
            LF_violation(t,l+1) = 1;
            LF_violation_exceedance(t,l+1) = max(ACTUAL_LF(l,1) - BRANCHDATA_VAL(l,line_rating),(-1)*BRANCHDATA_VAL(l,line_rating) - ACTUAL_LF(l,1) );
        else
            LF_violation(t,l+1) = 0;
            LF_violation_exceedance(t,l+1) = 0;
        end;
    end;
end;
ALFEE = sum(LF_violation_exceedance(:,2:nbranch+1)).*(t_AGC/60/60);
end;

% Calculate Generator Cycles
generator_cycles = 0;
last_gen_change = 0;
for i=1:ngen
    if GENVALUE_VAL(i,gen_type) == wind_gen_type_index || GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == interface_gen_type_index || GENVALUE_VAL(i,gen_type) == variable_dispatch_gen_type_index
    else
    for t=2:AGC_interval_index-1
        gen_change = ACTUAL_GENERATION(t,1+i)-ACTUAL_GENERATION(t-1,1+i);
        if gen_change*last_gen_change < -1*eps
            generator_cycles = generator_cycles + 1;
        end;
        last_gen_change = gen_change;
    end;
    end;
end;

% Calculate Reliability Metrics
CPS2_violations = 0;
eps = 0.00001;
for t1=2:AGC_interval_index-1
    if mod(ACE(t1,1)*60,CPS2_interval)- 0 < eps || CPS2_interval - mod(ACE(t1,1)*60,CPS2_interval) < eps
        if abs(ACE(t1-1,CPS2_ACE_index)) > L10
            CPS2_violations = CPS2_violations + 1;
        end;
    end;
end;
nCPS2_interval = ceil((time - start_time)*60/CPS2_interval);
CPS2 = 1-CPS2_violations/nCPS2_interval;
Total_MWH_Absolute_ACE = ACE(AGC_interval_index-1,AACEE_index);
sigma_ACE = std(ACE(:,raw_ACE_index));
inadvertent_interchange=ACE(AGC_interval_index-1,integrated_ACE_index);



