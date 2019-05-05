% Convert to per unit
GENVALUE.val(:,capacity)=GENVALUE_VAL(:,capacity)./SYSTEMVALUE_VAL(mva_pu);
GENVALUE.val(:,min_gen)=GENVALUE_VAL(:,min_gen)./SYSTEMVALUE_VAL(mva_pu);
GENVALUE.val(:,ramp_rate)=GENVALUE_VAL(:,ramp_rate)./SYSTEMVALUE_VAL(mva_pu);
GENVALUE.val(:,initial_MW)=GENVALUE_VAL(:,initial_MW)./SYSTEMVALUE_VAL(mva_pu);
if nESR>0
    STORAGEVALUE.val(:,storage_max)=STORAGEVALUE_VAL(:,storage_max)./SYSTEMVALUE_VAL(mva_pu);
    STORAGEVALUE.val(:,initial_storage)=STORAGEVALUE_VAL(:,initial_storage)./SYSTEMVALUE_VAL(mva_pu);
    STORAGEVALUE.val(:,final_storage)=STORAGEVALUE_VAL(:,final_storage)./SYSTEMVALUE_VAL(mva_pu);
    STORAGEVALUE.val(:,max_pump)=STORAGEVALUE_VAL(:,max_pump)./SYSTEMVALUE_VAL(mva_pu);
    STORAGEVALUE.val(:,min_pump)=STORAGEVALUE_VAL(:,min_pump)./SYSTEMVALUE_VAL(mva_pu);
    STORAGEVALUE.val(:,pump_ramp_rate)=STORAGEVALUE_VAL(:,pump_ramp_rate)./SYSTEMVALUE_VAL(mva_pu);
    STORAGEVALUE.val(:,initial_pump_mw)=STORAGEVALUE_VAL(:,initial_pump_mw)./SYSTEMVALUE_VAL(mva_pu);
end;
LOAD.val=LOAD.val./SYSTEMVALUE_VAL(mva_pu);
RESERVELEVEL.val=RESERVELEVEL.val./SYSTEMVALUE_VAL(mva_pu);
BRANCHDATA.val(:,line_rating)=BRANCHDATA_VAL(:,line_rating)./SYSTEMVALUE_VAL(mva_pu);
BRANCHDATA.val(:,ste_rating)=BRANCHDATA_VAL(:,ste_rating)./SYSTEMVALUE_VAL(mva_pu);
VG_FORECAST.val=VG_FORECAST.val./SYSTEMVALUE_VAL(mva_pu);
LOSS_BIAS.val=LOSS_BIAS.val./SYSTEMVALUE_VAL(mva_pu);
COST_CURVE.val(:,[2 4 6 8])=COST_CURVE.val(:,[2 4 6 8])./SYSTEMVALUE_VAL(mva_pu);
QSC.val=QSC.val./SYSTEMVALUE_VAL(mva_pu);
BLOCK_CAP.val=BLOCK_CAP_VAL./SYSTEMVALUE_VAL(mva_pu);
% RTSCUC
if rtscuc_running || rtsced_running || rpu_running
ACTUAL_GEN_OUTPUT.val=ACTUAL_GEN_OUTPUT.val./SYSTEMVALUE_VAL(mva_pu);
LAST_GEN_SCHEDULE.val=LAST_GEN_SCHEDULE.val./SYSTEMVALUE_VAL(mva_pu);
ACTUAL_PUMP_OUTPUT.val=ACTUAL_PUMP_OUTPUT.val./SYSTEMVALUE_VAL(mva_pu);
LAST_PUMP_SCHEDULE.val=LAST_PUMP_SCHEDULE.val./SYSTEMVALUE_VAL(mva_pu);
RAMP_SLACK_UP.val=RAMP_SLACK_UP.val./SYSTEMVALUE_VAL(mva_pu);
RAMP_SLACK_DOWN.val=RAMP_SLACK_DOWN.val./SYSTEMVALUE_VAL(mva_pu);
end;
if rtsced_running
UNIT_STARTUPMINGENHELP.val=UNIT_STARTUPMINGENHELP.val./SYSTEMVALUE_VAL(mva_pu);
UNIT_PUMPUPMINGENHELP.val=UNIT_PUMPUPMINGENHELP.val./SYSTEMVALUE_VAL(mva_pu);
end;
