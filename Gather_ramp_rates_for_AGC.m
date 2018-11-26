%Units starting and stopping will have different ramp rates.
ramp_agc=zeros(ngen,1);
for i=1:ngen
    if unit_startup_agc(i,1) == 1
        ramp_agc(i,1) = GENVALUE_VAL(i,min_gen)/(GENVALUE_VAL(i,su_time)*60);
    elseif unit_shutdown_agc(i,1) == 1
        ramp_agc(i,1) = GENVALUE_VAL(i,min_gen)/(GENVALUE_VAL(i,sd_time)*60);
    else
        ramp_agc(i,1) = GENVALUE_VAL(i,ramp_rate);
    end;
end;
for e=1:nESR
   if unit_pumpup_agc(e,1) == 1
        ramp_agc(storage_to_gen_index(e,1),1) = STORAGEVALUE_VAL(e,min_pump)/(STORAGEVALUE_VAL(e,pump_su_time)*60);
   elseif unit_pumpdown_agc(e,1) == 1
        ramp_agc(storage_to_gen_index(e,1),1) = STORAGEVALUE_VAL(e,min_pump)/(STORAGEVALUE_VAL(e,pump_sd_time)*60);
   elseif unit_pumping_agc(e,1) == 1
        ramp_agc(storage_to_gen_index(e,1),1) = STORAGEVALUE_VAL(e,pump_ramp_rate);
   end;
end;
