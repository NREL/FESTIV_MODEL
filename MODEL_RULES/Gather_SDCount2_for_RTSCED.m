%Initial RTSCED sdcount
sdcount=sdcount+UNIT_SHUTTINGDOWN_VAL(:,1);
sdcount2=zeros(ngen,HRTD);
for i=1:ngen
    if sum(UNIT_SHUTTINGDOWN_VAL(i,:)) > 0 && GENVALUE_VAL(i,gen_type) ~= outage_gen_type_index && GENVALUE_VAL(i,gen_type) ~= PV_gen_type_index && GENVALUE_VAL(i,gen_type) ~= wind_gen_type_index && GENVALUE_VAL(i,gen_type) ~= interface_gen_type_index && GENVALUE_VAL(i,gen_type) ~= variable_dispatch_gen_type_index
        for tc=1:HRTD
            sdcount2(i,tc)= round((GENVALUE_VAL(i,sd_time)*60/IRTD))-round((min(GENVALUE_VAL(i,min_gen),LAST_GEN_SCHEDULE_VAL(i))/GENVALUE_VAL(i,min_gen))*(GENVALUE_VAL(i,sd_time)*60/IRTD))+(sum(INTERVAL_MINUTES_VAL(1:tc)'.*UNIT_SHUTTINGDOWN_VAL(i,1:tc))/IRTD);
        end
    end
end
pumpsdcount=pumpsdcount+UNIT_PUMPINGDOWN_VAL(:,1);
pumpsdcount2=[pumpsdcount zeros(nESR,HRTD-1)];
