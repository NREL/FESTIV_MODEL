% Add to ACE Pre
% storage trajectory since they are zero mingen

for i=1:nESR
    if abs(RTDPUMPSCHEDULE.val(i,1)) > eps
        unit_pumping_agc(storage_to_gen_index(i))=1;
    end
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