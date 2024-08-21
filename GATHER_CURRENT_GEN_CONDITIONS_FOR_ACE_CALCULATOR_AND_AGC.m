current_gen_agc=ACTUAL_GENERATION(AGC_interval_index,:);
current_load_agc = ACTUAL_LOAD_FULL(AGC_interval_index,1:2);
current_pump_agc(1,1)=ACTUAL_PUMP(AGC_interval_index,1); 
current_pump_agc(1,2:ngen+1)=zeros(1,ngen);
current_pump_agc(1,storage_to_gen_index+1)=-1.*ACTUAL_PUMP(AGC_interval_index,2:nESR+1);
unit_startup_agc=UNIT_STARTINGUP_VAL(:,1);
unit_shutdown_agc=UNIT_SHUTTINGDOWN_VAL(:,1);
%storage parameters must be for all generators to work in AGC effectively
unit_pumpup_agc = zeros(ngen,1);
unit_pumpdown_agc = zeros(ngen,1);
unit_pumping_agc = zeros(ngen,1);
unit_pumpup_agc(storage_to_gen_index,1)=UNIT_PUMPINGUP_VAL(:,1);
unit_pumpdown_agc(storage_to_gen_index,1)=UNIT_PUMPINGDOWN_VAL(:,1);
% unit_pumping_agc=PUMPING_VAL(:,1);
for i=1:nESR
    if abs(RTDPUMPSCHEDULE.val(i,1)) > eps
        unit_pumping_agc(storage_to_gen_index(e))=1;
    end
end
if time >= 5.23
    time;
end
for e=1:nESR
    if RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,storage_to_gen_index(e)+1) < eps && RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-2,storage_to_gen_index(e)+1) > eps
        unit_shutdown_agc(storage_to_gen_index(e))=1;
        unit_pumpup_agc(storage_to_gen_index,1)=0;
        unit_pumping_agc(storage_to_gen_index,1)=0;
        unit_pumpdown_agc(storage_to_gen_index,1)=0;
    else
        unit_shutdown_agc(storage_to_gen_index(e))=0;
    end
    
    if RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,storage_to_gen_index(e)+1) > eps && RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-2,storage_to_gen_index(e)+1) < eps
        unit_startup_agc(storage_to_gen_index(e))=1;
        unit_pumpup_agc(storage_to_gen_index,1)=0;
        unit_pumping_agc(storage_to_gen_index,1)=0;
        unit_pumpdown_agc(storage_to_gen_index,1)=0;
    else
        unit_startup_agc(storage_to_gen_index(e))=0;
    end
    
    if RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1,e+1) < eps && RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-2,e+1) > eps
        unit_pumpdown_agc(storage_to_gen_index(e))=1;
        unit_startup_agc(storage_to_gen_index,1)=0;
%         unit_pumping_agc(storage_to_gen_index,1)=0;
        unit_shutdown_agc(storage_to_gen_index,1)=0;
    else
        unit_pumpdown_agc(storage_to_gen_index(e))=0;
    end
    
    if RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1,e+1) > eps && RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-2,e+1) < eps
        unit_pumpup_agc(storage_to_gen_index(e))=1;
        unit_startup_agc(storage_to_gen_index,1)=0;
%         unit_pumping_agc(storage_to_gen_index,1)=0;
        unit_shutdown_agc(storage_to_gen_index,1)=0;
    else
        unit_pumpup_agc(storage_to_gen_index(e))=0;
    end
    
end
if time >= 6.9167
    time;
end