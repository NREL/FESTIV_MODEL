%
%Post RTSCED
%

if sum(double(GENVALUE.val(:,gen_type)==9)) > 0
    NC_STORAGE_GEN_SCHEDULE_rgdx.name='NC_STORAGE_GEN_SCHEDULE';
    NC_STORAGE_GEN_SCHEDULE_rgdx.form='full';
    NC_STORAGE_GEN_SCHEDULE_rgdx.uels={GEN.uels INTERVAL.uels};
    NC_STORAGE_GEN_SCHEDULE=rgdx(input1,NC_STORAGE_GEN_SCHEDULE_rgdx);    
    NC_STORAGE_PUMP_SCHEDULE_rgdx.name='NC_STORAGE_PUMP_SCHEDULE';
    NC_STORAGE_PUMP_SCHEDULE_rgdx.form='full';
    NC_STORAGE_PUMP_SCHEDULE_rgdx.uels={GEN.uels INTERVAL.uels};
    NC_STORAGE_PUMP_SCHEDULE=rgdx(input1,NC_STORAGE_PUMP_SCHEDULE_rgdx);  
    RTDPRODCOST.val(6,1) = total_cost + sum(sum(NC_STORAGE_GEN_SCHEDULE.val+NC_STORAGE_PUMP_SCHEDULE.val))*0.005;
    RTDPRODCOST.val(7,1) = RTDPRODCOST.val(7,1) - (sum(DEVIATION_HELP.val)*0.05*SYSTEMVALUE.val(mva_pu)*ILMP/60);
end

