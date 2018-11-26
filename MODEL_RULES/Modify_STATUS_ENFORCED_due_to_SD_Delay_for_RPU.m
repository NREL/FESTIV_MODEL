if time > 0 && time < daystosimulate*24-IRTC*HRPU/60
    indexofunitsSD=zeros(ngen,1);
    indexofunitsSD2=zeros(ngen,1);
    rputotaltime=zeros(ngen,1);
    for i=1:ngen
        for j=1:HRPU-1
            if (STATUS(RTSCUC_binding_interval_index+j,1+i)-STATUS(RTSCUC_binding_interval_index+j-1,1+i)==-1) && ( GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index )
                indexofunitsSD(i,1)=RTSCUC_binding_interval_index+j;
                temp=STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRPU-1,2:end);
                indexofunitsSD2(i,1)=find(temp(:,i),1,'last')+1;
                rputotaltime(i,1)=IRTC*(indexofunitsSD2(i,1)-1);
            end
        end
    end
    rpugennow=ACTUAL_GEN_OUTPUT_VAL;
    rpustatusnow=LAST_STATUS_ACTUAL_VAL;
    rputotalramp=GENVALUE_VAL(:,ramp_rate).*rputotaltime;
    rpuminimumpossible=max(0,rpugennow-(rputotalramp.*rpustatusnow));
    X=max(0,ceil((rpuminimumpossible-GENVALUE_VAL(:,min_gen))./(GENVALUE_VAL(:,ramp_rate)*IRTC)));
    for i=1:ngen
            rpudelaycondition= (indexofunitsSD(i,1) > 0 && ((rpuminimumpossible(i,1) > GENVALUE_VAL(i,min_gen)+eps) && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > GENVALUE_VAL(i,min_gen)))) && ( GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index );
        if rpudelaycondition
            STATUS(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),1+i)=1;
            STATUS(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),1+i)=0;
            RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=1;
            RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),i)=0;
            RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=GENVALUE_VAL(i,min_gen);
            RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),i)=0;
            UNIT_STATUS_ENFORCED_ON_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRPU))=1;
            UNIT_STATUS_ENFORCED_OFF_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRPU))=1;
            delayedshutdown(i,1)=1;
        end
    end
end

for i=1:ngen
    if (RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) - RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > 0 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + eps < GENVALUE_VAL(i,min_gen) && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) ~= 0) && ( GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index )
        numberOfIntervalsLeftInSD=round(RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/GENVALUE_VAL(i,min_gen)*max(0,ceil(GENVALUE_VAL(i,sd_time)*60/IRTC)));
        if numberOfIntervalsLeftInSD < HRPU && numberOfIntervalsLeftInSD ~= 0
            UNIT_STATUS_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRPU,numberOfIntervalsLeftInSD-1+GENVALUE_VAL(i,md_time)*60/IRTC))=0;
        end
    end
end
for e=1:nESR
    if RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-2,e+1) - RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1) > 0 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1) + eps < STORAGEVALUE_VAL(e,min_pump) && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1) ~= 0
        numberOfIntervalsLeftInSD=round(RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1)/STORAGEVALUE_VAL(e,min_pump)*max(0,ceil(STORAGEVALUE_VAL(e,pump_sd_time)*60/IRTC)));
        if numberOfIntervalsLeftInSD < HRPU && numberOfIntervalsLeftInSD ~= 0
            PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(e,1),numberOfIntervalsLeftInSD:min(HRPU,numberOfIntervalsLeftInSD-1+STORAGEVALUE_VAL(e,min_pump_time)*60/IRTC))=0;
        end
    end
end

if RTSCUC_binding_interval_index <= 2
    DELAYSD.val = zeros(ngen,1);
else
    DELAYSD.val = delayedshutdown;
end
DELAYSD.name = 'DELAYSD';
DELAYSD.form = 'full';
DELAYSD.uels = GEN_VAL';
DELAYSD.type = 'parameter';
wgdx(['TEMP', filesep, 'SHUT_DOWN_DELAY_FILE'],DELAYSD);