%Units starting and stopping will have different ramp rates.
ramp_agc=zeros(ngen,1);
for i=1:ngen
    if unit_startup_agc(i,1) == 1
%         ramp_agc(i,1) = GENVALUE_VAL(i,min_gen)/(GENVALUE_VAL(i,su_time)*60);
        if GENVALUE_VAL(i,min_gen) == 0
            ramp_agc(i,1) = GENVALUE_VAL(i,ramp_rate);
        else
            ramp_agc(i,1) = GENVALUE_VAL(i,min_gen)/(GENVALUE_VAL(i,su_time)*60);
        end
    elseif unit_shutdown_agc(i,1) == 1
        if GENVALUE_VAL(i,min_gen) == 0
            ramp_agc(i,1) = ACTUAL_GENERATION(find(mod(ACTUAL_GENERATION(1:AGC_interval_index,1),tRTD/60)==0,1,'last'),i+1)/tRTD;
        else
            ramp_agc(i,1) = GENVALUE_VAL(i,min_gen)/(GENVALUE_VAL(i,sd_time)*60);
        end
    else
        ramp_agc(i,1) = GENVALUE_VAL(i,ramp_rate);
    end;
    if unit_pumpup_agc(i,1) == 1
%         ramp_agc(i,1) = STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),min_pump)/(STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),pump_su_time)*60);
        if STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),min_pump) == 0
            ramp_agc(i,1) = STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),pump_ramp_rate);
        else
            ramp_agc(i,1) = STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),min_pump)/(STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),pump_su_time)*60);
        end
    elseif unit_pumpdown_agc(i,1) == 1
%         ramp_agc(i,1) = STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),min_pump)/(STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),pump_sd_time)*60);
        if STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),min_pump) == 0
            ramp_agc(i,1) = ACTUAL_PUMP(find(mod(ACTUAL_PUMP(1:AGC_interval_index,1),tRTD/60)==0,1,'last'),find(storage_to_gen_index(:,1)==i)+1)/tRTD;
        else
            ramp_agc(i,1) = STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),min_pump)/(STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),pump_sd_time)*60);
        end
    elseif unit_pumping_agc(i,1) == 1
        ramp_agc(i,1) = STORAGEVALUE_VAL(find(storage_to_gen_index(:,1)==i),pump_ramp_rate);
    end
end 

