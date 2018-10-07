UNIT_STATUS_ENFORCED_ON_VAL=zeros(ngen,HDAC);
UNIT_STATUS_ENFORCED_OFF_VAL=ones(ngen,HDAC);
for i=1:ngen
    if GENVALUE_VAL(i,initial_status) == 0
        for t=1:HDAC
            if t <= GENVALUE_VAL(i,md_time) - GENVALUE_VAL(i,initial_hour)
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 0;
            else
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            end
        end
    else
        for t=1:HDAC
            if t <= GENVALUE_VAL(i,mr_time) - GENVALUE_VAL(i,initial_hour)
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 1;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            else
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            end
        end
    end
    if GENVALUE_VAL(i,gen_type)== outage_gen_type_index
        UNIT_STATUS_ENFORCED_OFF_VAL(i,1:HDAC) = 0;
    end
end
PUMPING_ENFORCED_ON_VAL=zeros(ngen,HDAC);
PUMPING_ENFORCED_OFF_VAL=ones(ngen,HDAC);
if size(STORAGEVALUE.uels{1, 1},1) > 0 && ~isempty(storage_to_gen_index)
    for i=1:size(storage_to_gen_index,1)
        if STORAGEVALUE_VAL(i,initial_pump_status) == 0
            for t=1:HDAC
                if t <= GENVALUE_VAL(storage_to_gen_index(i),md_time) - STORAGEVALUE_VAL(i,initial_pump_hour)
                    PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(i),t)  = 0;
                    PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(i),t) = 0;
                else
                    PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(i),t)  = 0;
                    PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(i),t) = 1;
                end
            end
        else
            for t=1:HDAC
                if t <= STORAGEVALUE_VAL(i,min_pump_time) - STORAGEVALUE_VAL(i,initial_pump_hour)
                    PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(i),t)  = 1;
                    PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(i),t) = 1;
                else
                    PUMPING_ENFORCED_ON_VAL(storage_to_gen_index(i),t)  = 0;
                    PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(i),t) = 1;
                end
            end
        end
        if GENVALUE_VAL(storage_to_gen_index(i),gen_type)== outage_gen_type_index
            PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(i),1:HDAC) = 0;
        end
    end
end
