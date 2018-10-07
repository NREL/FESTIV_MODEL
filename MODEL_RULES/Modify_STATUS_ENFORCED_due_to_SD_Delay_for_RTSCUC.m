rtcdelaytrack=[];
if time > 0 && time < daystosimulate*24-IRTC*HRTC/60
    indexofunitsSD=zeros(ngen,1);
    indexofunitsSD2=zeros(ngen,1);
    for i=1:ngen
        for j=1:HRTC-1
            if (STATUS(RTSCUC_binding_interval_index+j,1+i)-STATUS(RTSCUC_binding_interval_index+j-1,1+i)==-1) && ( GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index )
                indexofunitsSD(i,1)=RTSCUC_binding_interval_index+j;
                temp=STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,2:end);
                indexofunitsSD2(i,1)=find(temp(:,i),1,'last')+1;
                rtctotaltime(i,1)=IRTC*(indexofunitsSD2(i,1)-1);
            end
        end
    end

    rtcgennow=ACTUAL_GEN_OUTPUT_VAL;
    rtcstatusnow=LAST_STATUS_ACTUAL_VAL;
    rtctotalramp=GENVALUE_VAL(:,ramp_rate).*rtctotaltime;
    rtcminimumpossible=max(0,rtcgennow-(rtctotalramp.*rtcstatusnow));
    X=max(0,ceil((rtcminimumpossible-GENVALUE_VAL(:,min_gen))./(GENVALUE_VAL(:,ramp_rate)*IRTC)));

    for i=1:ngen
        rtcdelaycondition= (indexofunitsSD(i,1) > eps && ((rtcminimumpossible(i,1) > GENVALUE_VAL(i,min_gen)+eps) && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > GENVALUE_VAL(i,min_gen)))) && ( GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= 16);
        rtcdelaycondition2= indexofunitsSD(i,1) > eps && ceil(((RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC))-eps*10) > eps && sum(STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,i)) < HRTC && (GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index) && GENVALUE_VAL(i,su_time) > tRTCstart; %EE 08162016 Interim bandaid to add the indexofunitsSD(i,1) > eps. I am not sure what this line does.
        if rtcdelaycondition
            STATUS(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),1+i)=1;
            STATUS(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),1+i)=0;
            RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=1;
            RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),i)=0;
            RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=GENVALUE_VAL(i,min_gen);
            RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),i)=0;
            UNIT_STATUS_ENFORCED_ON_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRTC))=1;
            UNIT_STATUS_ENFORCED_OFF_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRTC))=1;
            delayedshutdown(i,1)=1;
        end
        if rtcdelaycondition2
            STATUS(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1),1+i)=1;
            STATUS(indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC))):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),1+i)=0;
            RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1),i+1)=1;
            RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC))):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),i)=0;
            RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1),i+1)=GENVALUE_VAL(i,min_gen);
            RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC))):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1+(GENVALUE_VAL(i,md_time)*60/IRTC)),i)=0;
            UNIT_STATUS_ENFORCED_ON_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1,HRTC))=1;
            UNIT_STATUS_ENFORCED_OFF_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE_VAL(i,min_gen))/(GENVALUE_VAL(i,ramp_rate)*IRTC)))-1,HRTC))=1;
            delayedshutdown(i,1)=1;
            rtcdelaytrack=[rtcdelaytrack;i];
        end
    end
end

for i=1:ngen
    if (RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) - RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > 0 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + 2*eps < GENVALUE_VAL(i,min_gen) && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) ~= 0) && ( GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index)
        numberOfIntervalsLeftInSD=round(RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/GENVALUE_VAL(i,min_gen)*max(0,ceil(GENVALUE_VAL(i,sd_time)*60/IRTC)));
%                 if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD ~= 0
        if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD > 1
            UNIT_STATUS_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+GENVALUE_VAL(i,md_time)*60/IRTC))=0;
        end
    end
end
for e=1:nESR
    if RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-2,e+1) - RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1) > 0 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1) + 2*eps < STORAGEVALUE_VAL(e,min_pump) && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1) ~= 0
        numberOfIntervalsLeftInSD=round(RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,e+1)/STORAGEVALUE_VAL(e,min_pump)*max(0,ceil(STORAGEVALUE_VAL(e,pump_sd_time)*60/IRTC)));
        if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD > 1
            PUMPING_ENFORCED_OFF_VAL(storage_to_gen_index(e,1),numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+STORAGEVALUE_VAL(e,min_pump_time)*60/IRTC))=0;
            %PUMPING_ENFORCED_OFF_VAL(e,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+0*60/IRTC))=0;
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