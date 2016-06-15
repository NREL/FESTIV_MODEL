% Convert to per unit
GENVALUE.val(:,capacity)=GENVALUE.val(:,capacity)./SYSTEMVALUE.val(mva_pu);
GENVALUE.val(:,min_gen)=GENVALUE.val(:,min_gen)./SYSTEMVALUE.val(mva_pu);
GENVALUE.val(:,ramp_rate)=GENVALUE.val(:,ramp_rate)./SYSTEMVALUE.val(mva_pu);
GENVALUE.val(:,initial_MW)=GENVALUE.val(:,initial_MW)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,storage_max)=STORAGEVALUE.val(:,storage_max)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,initial_storage)=STORAGEVALUE.val(:,initial_storage)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,final_storage)=STORAGEVALUE.val(:,final_storage)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,max_pump)=STORAGEVALUE.val(:,max_pump)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,min_pump)=STORAGEVALUE.val(:,min_pump)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,pump_ramp_rate)=STORAGEVALUE.val(:,pump_ramp_rate)./SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,initial_pump_mw)=STORAGEVALUE.val(:,initial_pump_mw)./SYSTEMVALUE.val(mva_pu);
LOAD.val=LOAD.val./SYSTEMVALUE.val(mva_pu);
RESERVELEVEL.val=RESERVELEVEL.val./SYSTEMVALUE.val(mva_pu);
BRANCHDATA.val(:,line_rating)=BRANCHDATA.val(:,line_rating)./SYSTEMVALUE.val(mva_pu);
BRANCHDATA.val(:,ste_rating)=BRANCHDATA.val(:,ste_rating)./SYSTEMVALUE.val(mva_pu);
VG_FORECAST.val=VG_FORECAST.val./SYSTEMVALUE.val(mva_pu);
INTERCHANGE.val=INTERCHANGE.val./SYSTEMVALUE.val(mva_pu);
LOSS_BIAS.val=LOSS_BIAS.val./SYSTEMVALUE.val(mva_pu);
COST_CURVE.val(:,[2 4 6 8])=COST_CURVE.val(:,[2 4 6 8])./SYSTEMVALUE.val(mva_pu);
if ~isempty(PUMPEFFICIENCYVALUE.val)
    PUMPEFFICIENCYVALUE.val(:,[2 4 6])=PUMPEFFICIENCYVALUE.val(:,[2 4 6])./SYSTEMVALUE.val(mva_pu);
    GENEFFICIENCYVALUE.val(:,[2 4 6])=GENEFFICIENCYVALUE.val(:,[2 4 6])./SYSTEMVALUE.val(mva_pu);
end
QSC.val=QSC.val./SYSTEMVALUE.val(mva_pu);
GEN_EFFICIENCY_MW.val=geneffmwvalues./SYSTEMVALUE.val(mva_pu);
PUMP_EFFICIENCY_MW.val=stoeffmwvalues./SYSTEMVALUE.val(mva_pu);

% RTSCUC
if rtscuc_running || rtsced_running || rpu_running
ACTUAL_GEN_OUTPUT.val=ACTUAL_GEN_OUTPUT.val./SYSTEMVALUE.val(mva_pu);
LAST_GEN_SCHEDULE.val=LAST_GEN_SCHEDULE.val./SYSTEMVALUE.val(mva_pu);
ACTUAL_PUMP_OUTPUT.val=ACTUAL_PUMP_OUTPUT.val./SYSTEMVALUE.val(mva_pu);
LAST_PUMP_SCHEDULE.val=LAST_PUMP_SCHEDULE.val./SYSTEMVALUE.val(mva_pu);
RAMP_SLACK_UP.val=RAMP_SLACK_UP.val./SYSTEMVALUE.val(mva_pu);
RAMP_SLACK_DOWN.val=RAMP_SLACK_DOWN.val./SYSTEMVALUE.val(mva_pu);
end;
if rtsced_running
UNIT_STARTUPMINGENHELP.val=UNIT_STARTUPMINGENHELP.val./SYSTEMVALUE.val(mva_pu);
UNIT_PUMPUPMINGENHELP.val=UNIT_PUMPUPMINGENHELP.val./SYSTEMVALUE.val(mva_pu);
end;
