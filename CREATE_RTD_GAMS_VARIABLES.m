% Create GAMS variables for RTSCED model solved

INTERVAL.name = 'INTERVAL';
INTERVAL.uels = {'1'};
for t=2:HRTD
    INTERVAL.uels = [INTERVAL.uels; num2str(t)];
end
INTERVAL.uels = INTERVAL.uels';
INTERVAL.val = ones(HRTD,1);
INTERVAL.form = 'full';

if Solving_Initial_Models == 1
    clear LOAD;
    LOAD.val(1:HRTD,1) = RTD_LOAD_FULL(1:HRTD,3);
end
LOAD.name = 'LOAD';
LOAD.uels = INTERVAL.uels;
LOAD.form = 'full';
LOAD.type = 'parameter';
RTD_LOAD = LOAD;

VG_FORECAST.name = 'VG_FORECAST';
VG_FORECAST.val = VG_FORECAST_VAL;
VG_FORECAST.uels = {INTERVAL.uels GEN.uels};
VG_FORECAST.form = 'full';
VG_FORECAST.type = 'parameter';

if Solving_Initial_Models == 1
    clear RESERVELEVEL_VAL;
    RESERVELEVEL_VAL(1:HRTD,:) = RTD_RESERVE_FULL(1:HRTD,3:end);
    RESERVELEVEL.val = RESERVELEVEL_VAL;
else
    RESERVELEVEL.val = RESERVELEVEL_VAL(1:HRTD,:);
end
RESERVELEVEL.name = 'RESERVELEVEL';
RESERVELEVEL.uels = {INTERVAL.uels RTD_RESERVE_FIELD(3:end)};
RESERVELEVEL.form = 'full';
RESERVELEVEL.type = 'parameter';

if Solving_Initial_Models == 1
    RTD_INTERCHANGE_VAL(1:HRTD,:) = RTD_INTERCHANGE_FULL(1:HRTD,3:end); 
    INTERCHANGE.val = RTD_INTERCHANGE_VAL;
else
    INTERCHANGE.val = RTD_INTERCHANGE_VAL(1:HRTD,:);
end
INTERCHANGE.name = 'INTERCHANGE';
INTERCHANGE.uels = {INTERVAL.uels RTD_INTERCHANGE_FIELD(3:end)};
INTERCHANGE.form = 'full';
INTERCHANGE.type = 'parameter';

NRTDINTERVAL.val = HRTD;
NRTDINTERVAL.name = 'NRTDINTERVAL';
NRTDINTERVAL.form = 'full';
NRTDINTERVAL.uels = cell(1,0);
NRTDINTERVAL.type = 'parameter';

RTDINTERVAL_LENGTH.val = IRTD;
RTDINTERVAL_LENGTH.name = 'RTDINTERVAL_LENGTH';
RTDINTERVAL_LENGTH.form = 'full';
RTDINTERVAL_LENGTH.uels = cell(1,0);
RTDINTERVAL_LENGTH.type = 'parameter';

RTDINTERVAL_ADVISORY_LENGTH.val = IRTDADV;
RTDINTERVAL_ADVISORY_LENGTH.name = 'RTDINTERVAL_ADVISORY_LENGTH';
RTDINTERVAL_ADVISORY_LENGTH.form = 'full';
RTDINTERVAL_ADVISORY_LENGTH.uels = cell(1,0);
RTDINTERVAL_ADVISORY_LENGTH.type = 'parameter';

RTDINTERVAL_UPDATE.val = tRTD;
RTDINTERVAL_UPDATE.name = 'RTDINTERVAL_UPDATE';
RTDINTERVAL_UPDATE.form = 'full';
RTDINTERVAL_UPDATE.uels = cell(1,0);
RTDINTERVAL_UPDATE.type = 'parameter';

if Solving_Initial_Models == 1
    RTD_PROCESS_TIME.val = IDAC*60-IRTD;
else
    RTD_PROCESS_TIME.val = PRTD;
end
RTD_PROCESS_TIME.name = 'RTD_PROCESS_TIME';
RTD_PROCESS_TIME.form = 'full';
RTD_PROCESS_TIME.uels = cell(1,0);
RTD_PROCESS_TIME.type = 'parameter';

INTERVAL_MINUTES.name = 'INTERVAL_MINUTES';
INTERVAL_MINUTES.val = INTERVAL_MINUTES_VAL;
INTERVAL_MINUTES.uels = {INTERVAL.uels};
INTERVAL_MINUTES.form = 'full';
INTERVAL_MINUTES.type = 'parameter';

UNIT_STATUS.name = 'UNIT_STATUS';
UNIT_STATUS.val = UNIT_STATUS_VAL;
UNIT_STATUS.uels = {GEN.uels INTERVAL.uels};
UNIT_STATUS.form = 'full';
UNIT_STATUS.type = 'parameter';

if Solving_Initial_Models == 1
    GEN_FORCED_OUT.val = zeros(ngen,1);
else
    GEN_FORCED_OUT.val = GEN_FORCED_OUT_VAL;
end
GEN_FORCED_OUT.name = 'GEN_FORCED_OUT';
GEN_FORCED_OUT.uels = {GEN.uels};        
GEN_FORCED_OUT.form = 'full';
GEN_FORCED_OUT.type = 'parameter';

UNIT_STARTINGUP.name = 'UNIT_STARTINGUP';
UNIT_STARTINGUP.val = UNIT_STARTINGUP_VAL;
UNIT_STARTINGUP.uels = {GEN.uels INTERVAL.uels };
UNIT_STARTINGUP.form = 'full';
UNIT_STARTINGUP.type = 'parameter';

if Solving_Initial_Models == 1
%     UNIT_STARTUPMINGENHELP.val = zeros(ngen,HRTD);
    UNIT_STARTUPMINGENHELP.val = max(0,UNIT_STARTUPMINGENHELP_VAL-repmat((ones(ngen,1).*IRTD./60./GENVALUE.val(:,su_time)).*GENVALUE.val(:,min_gen),1,HRTD));
else
    UNIT_STARTUPMINGENHELP.val = UNIT_STARTUPMINGENHELP_VAL;
end
UNIT_STARTUPMINGENHELP.name = 'UNIT_STARTUPMINGENHELP';
UNIT_STARTUPMINGENHELP.uels = {GEN.uels INTERVAL.uels};
UNIT_STARTUPMINGENHELP.form = 'full';
UNIT_STARTUPMINGENHELP.type = 'parameter';

UNIT_SHUTTINGDOWN.name = 'UNIT_SHUTTINGDOWN';
UNIT_SHUTTINGDOWN.val = UNIT_SHUTTINGDOWN_VAL;
UNIT_SHUTTINGDOWN.uels = {GEN.uels INTERVAL.uels};
UNIT_SHUTTINGDOWN.form = 'full';
UNIT_SHUTTINGDOWN.type = 'parameter';

PUMPING.name = 'PUMPING';
PUMPING.val = PUMPING_VAL;
PUMPING.uels = {GEN.uels INTERVAL.uels};
PUMPING.form = 'full';
PUMPING.type = 'parameter';

UNIT_PUMPINGUP.name = 'UNIT_PUMPINGUP';
UNIT_PUMPINGUP.val = UNIT_PUMPINGUP_VAL;
UNIT_PUMPINGUP.uels = {GEN.uels INTERVAL.uels};
UNIT_PUMPINGUP.form = 'full';
UNIT_PUMPINGUP.type = 'parameter';

if Solving_Initial_Models == 1
    UNIT_PUMPUPMINGENHELP.val = zeros(ngen,HRTD);
else
    UNIT_PUMPUPMINGENHELP.val = UNIT_PUMPUPMINGENHELP_VAL;
end
UNIT_PUMPUPMINGENHELP.name = 'UNIT_PUMPUPMINGENHELP';
UNIT_PUMPUPMINGENHELP.uels = {GEN.uels INTERVAL.uels};
UNIT_PUMPUPMINGENHELP.form = 'full';
UNIT_PUMPUPMINGENHELP.type = 'parameter';

UNIT_PUMPINGDOWN.name = 'UNIT_PUMPINGDOWN';
UNIT_PUMPINGDOWN.val = UNIT_PUMPINGDOWN_VAL;
UNIT_PUMPINGDOWN.uels = {GEN.uels INTERVAL.uels};
UNIT_PUMPINGDOWN.form = 'full';
UNIT_PUMPINGDOWN.type = 'parameter';

ACTUAL_GEN_OUTPUT.name = 'ACTUAL_GEN_OUTPUT';
ACTUAL_GEN_OUTPUT_VAL(ACTUAL_GEN_OUTPUT_VAL~=0)=ACTUAL_GEN_OUTPUT_VAL(ACTUAL_GEN_OUTPUT_VAL~=0)+eps;
ACTUAL_GEN_OUTPUT.val = ACTUAL_GEN_OUTPUT_VAL;
ACTUAL_GEN_OUTPUT.uels ={GEN.uels};
ACTUAL_GEN_OUTPUT.form = 'full';
ACTUAL_GEN_OUTPUT.type = 'parameter';

LAST_GEN_SCHEDULE.name = 'LAST_GEN_SCHEDULE';
LAST_GEN_SCHEDULE_VAL(LAST_GEN_SCHEDULE_VAL~=0)=LAST_GEN_SCHEDULE_VAL(LAST_GEN_SCHEDULE_VAL~=0)+eps;
LAST_GEN_SCHEDULE.val = LAST_GEN_SCHEDULE_VAL;
LAST_GEN_SCHEDULE.uels ={GEN.uels};
LAST_GEN_SCHEDULE.form = 'full';
LAST_GEN_SCHEDULE.type = 'parameter';

RAMP_SLACK_UP.name = 'RAMP_SLACK_UP';
RAMP_SLACK_UP.val = RAMP_SLACK_UP_VAL;
RAMP_SLACK_UP.uels ={GEN.uels};
RAMP_SLACK_UP.form = 'full';
RAMP_SLACK_UP.type = 'parameter';

RAMP_SLACK_DOWN.name = 'RAMP_SLACK_DOWN';
RAMP_SLACK_DOWN.val = RAMP_SLACK_DOWN_VAL;
RAMP_SLACK_DOWN.uels ={GEN.uels};
RAMP_SLACK_DOWN.form = 'full';
RAMP_SLACK_DOWN.type = 'parameter';

LAST_STATUS.name = 'LAST_STATUS';
LAST_STATUS.val = LAST_STATUS_VAL;
LAST_STATUS.uels ={GEN.uels};
LAST_STATUS.form = 'full';
LAST_STATUS.type = 'parameter';

LAST_STATUS_ACTUAL.name = 'LAST_STATUS_ACTUAL';
LAST_STATUS_ACTUAL.val = LAST_STATUS_ACTUAL_VAL;
LAST_STATUS_ACTUAL.uels ={GEN.uels};
LAST_STATUS_ACTUAL.form = 'full';
LAST_STATUS_ACTUAL.type = 'parameter';

ACTUAL_PUMP_OUTPUT.name = 'ACTUAL_PUMP_OUTPUT';
ACTUAL_PUMP_OUTPUT.val = ACTUAL_PUMP_OUTPUT_VAL;
ACTUAL_PUMP_OUTPUT.uels ={GEN.uels};
ACTUAL_PUMP_OUTPUT.form = 'full';
ACTUAL_PUMP_OUTPUT.type = 'parameter';

LAST_PUMP_SCHEDULE.name = 'LAST_PUMP_SCHEDULE';
LAST_PUMP_SCHEDULE.val = LAST_PUMP_SCHEDULE_VAL;
LAST_PUMP_SCHEDULE.uels ={GEN.uels};
LAST_PUMP_SCHEDULE.form = 'full';
LAST_PUMP_SCHEDULE.type = 'parameter';

LAST_PUMPSTATUS.name = 'LAST_PUMPSTATUS';
LAST_PUMPSTATUS.val = LAST_PUMPSTATUS_VAL;
LAST_PUMPSTATUS.uels ={GEN.uels};
LAST_PUMPSTATUS.form = 'full';
LAST_PUMPSTATUS.type = 'parameter';

LAST_PUMPSTATUS_ACTUAL.name = 'LAST_PUMPSTATUS_ACTUAL';
LAST_PUMPSTATUS_ACTUAL.val = LAST_PUMPSTATUS_ACTUAL_VAL;
LAST_PUMPSTATUS_ACTUAL.uels ={GEN.uels};
LAST_PUMPSTATUS_ACTUAL.form = 'full';
LAST_PUMPSTATUS_ACTUAL.type = 'parameter';

UNITSDCOUNT.val = sdcount2;
UNITSDCOUNT.name = 'UNITSDCOUNT';
UNITSDCOUNT.form = 'full';
UNITSDCOUNT.uels = {GEN.uels INTERVAL.uels};
UNITSDCOUNT.type = 'parameter';

PUMPUNITSDCOUNT.val = pumpsdcount2;
PUMPUNITSDCOUNT.name = 'PUMPUNITSDCOUNT';
PUMPUNITSDCOUNT.form = 'full';
PUMPUNITSDCOUNT.uels = {GEN.uels INTERVAL.uels};
PUMPUNITSDCOUNT.type = 'parameter';

if Solving_Initial_Models == 1
    DELAYSD.val = zeros(ngen,1);
else
    DELAYSD.val = delayedshutdown;
end
DELAYSD.name = 'DELAYSD';
DELAYSD.form = 'full';
DELAYSD.uels = GEN.uels;
DELAYSD.type = 'parameter';

if Solving_Initial_Models == 1
    DELAYPUMPSD.val = zeros(ngen,1);
else
    DELAYPUMPSD.val = delayedpumpdown;
end
DELAYPUMPSD.name = 'DELAYPUMPSD';
DELAYPUMPSD.form = 'full';
DELAYPUMPSD.uels = GEN.uels;
DELAYPUMPSD.type = 'parameter';

if HRTD > 1
    BIND_INTERVAL_1.val=[1 zeros(1,HRTD-1)];
else
    BIND_INTERVAL_1.val=1;
end
BIND_INTERVAL_1.name='BIND_INTERVAL_1';
BIND_INTERVAL_1.type='parameter';
BIND_INTERVAL_1.form='full';
BIND_INTERVAL_1.uels={INTERVAL.uels};

if Solving_Initial_Models == 1
    RTD_SU_TWICE_IND.val = ones(ngen,HRTD);
else
    RTD_SU_TWICE_IND.val = RTD_SU_TWICE_IND_VAL;
end
RTD_SU_TWICE_IND.name = 'RTD_SU_TWICE_IND';
RTD_SU_TWICE_IND.uels = {GEN.uels INTERVAL.uels};
RTD_SU_TWICE_IND.form = 'full';
RTD_SU_TWICE_IND.type = 'parameter';

%This is a gams parameter to avoid using the time 0 ramp constraints.
if Solving_Initial_Models == 1
    INITIAL_DISPATCH_SLACK.val = [0;1]; 
    INITIAL_DISPATCH_SLACK.name = 'INITIAL_DISPATCH_SLACK';
    INITIAL_DISPATCH_SLACK.form = 'full';
    INITIAL_DISPATCH_SLACK.uels = INITIAL_DISPATCH_SLACK_SET.uels;
    INITIAL_DISPATCH_SLACK.type = 'parameter';
end

clear BUS_DELIVERY_FACTORS GEN_DELIVERY_FACTORS;

GEN_DELIVERY_FACTORS.val=RTD_GEN_DELIVERY_FACTORS_VAL;
GEN_DELIVERY_FACTORS.name='GEN_DELIVERY_FACTORS';
GEN_DELIVERY_FACTORS.form='full';
GEN_DELIVERY_FACTORS.type='parameter';
GEN_DELIVERY_FACTORS.uels={GEN.uels INTERVAL.uels};

BUS_DELIVERY_FACTORS.val=RTD_BUS_DELIVERY_FACTORS_VAL;
BUS_DELIVERY_FACTORS.name='BUS_DELIVERY_FACTORS';
BUS_DELIVERY_FACTORS.form='full';
BUS_DELIVERY_FACTORS.type='parameter';
BUS_DELIVERY_FACTORS.uels={BUS.uels INTERVAL.uels};

if Solving_Initial_Models == 1
    LOSS_BIAS.val = 0;
else
    LOSS_BIAS.val = storelosses(max(1,AGC_interval_index-1),1)-abs(RTSCEDMARGINALLOSS(RTSCED_binding_interval_index-1,2));
end
LOSS_BIAS.name = 'LOSS_BIAS';
LOSS_BIAS.form = 'full';
LOSS_BIAS.uels = cell(1,0);
LOSS_BIAS.type = 'parameter';

BLOCK2.uels={'BLOCK1','BLOCK2','BLOCK3','BLOCK4'};
BLOCK2.name='BLOCK';
BLOCK2.type='SET';
BLOCK2.form='FULL';
BLOCK2.val=ones(1,4);

GENBLOCK.uels = {COST_CURVE_STRING' BLOCK2.uels};
BLOCKMW=COST_CURVE_VAL(:,[2,4,6,8]);
GENBLOCK.val = double(BLOCKMW>eps);
GENBLOCK.name = 'GENBLOCK';
GENBLOCK.form = 'full';
GENBLOCK.type = 'set';

BLOCK_COST.name='BLOCK_COST';
BLOCK_COST.uels={COST_CURVE_STRING' BLOCK2.uels};
BLOCK_COST.form='FULL';
BLOCK_COST.type='parameter';
BLOCK_COST.val=COST_CURVE_VAL(:,[1 3 5 7]);

BLOCK_CAP.name='BLOCK_CAP';
BLOCK_CAP.uels={COST_CURVE_STRING' BLOCK2.uels};
BLOCK_CAP.form='FULL';
BLOCK_CAP.type='parameter';
BLOCK_CAP.val=COST_CURVE_VAL(:,[2 4 6 8])./SYSTEMVALUE.val(mva_pu);

QSC.name='QSC';
QSC.uels={GEN_VAL' RESERVETYPE_VAL'};
QSC.form='FULL';
QSC.type='parameter';
QSC.val=zeros(ngen,nreserve);
for rr=1:nreserve
    if RESERVEVALUE.val(rr,res_on)==0
        qsc_idx=60*GENVALUE.val(:,su_time)<=RESERVEVALUE.val(rr,res_time);
        QSC.val(qsc_idx,rr)=min(GENVALUE.val(qsc_idx,capacity),GENVALUE.val(qsc_idx,min_gen)+GENVALUE.val(qsc_idx,ramp_rate).*(repmat(RESERVEVALUE.val(rr,res_time),size(find(qsc_idx)))-60*GENVALUE.val(qsc_idx,su_time)));
    end
end
QSC.val=QSC.val./SYSTEMVALUE.val(mva_pu);


sdtemp=ACTUAL_GEN_OUTPUT.val>zeros(ngen,1)&LAST_GEN_SCHEDULE.val<=eps.*ones(ngen,1);
UNIT_SHUTTINGDOWN_ACTUAL.val=zeros(ngen,1);
UNIT_SHUTTINGDOWN_ACTUAL.name='UNIT_SHUTTINGDOWN_ACTUAL';
UNIT_SHUTTINGDOWN_ACTUAL.form='full';
UNIT_SHUTTINGDOWN_ACTUAL.type='parameter';
UNIT_SHUTTINGDOWN_ACTUAL.uels={GEN.uels};
UNIT_SHUTTINGDOWN_ACTUAL.val(sdtemp)=1;
sdtemp=ACTUAL_PUMP_OUTPUT.val>zeros(ngen,1)&LAST_PUMP_SCHEDULE.val<=eps.*ones(ngen,1);
UNIT_PUMPINGDOWN_ACTUAL.val=zeros(ngen,1);
UNIT_PUMPINGDOWN_ACTUAL.name='UNIT_PUMPINGDOWN_ACTUAL';
UNIT_PUMPINGDOWN_ACTUAL.form='full';
UNIT_PUMPINGDOWN_ACTUAL.type='parameter';
UNIT_PUMPINGDOWN_ACTUAL.uels={GEN.uels};
UNIT_PUMPINGDOWN_ACTUAL.val(sdtemp)=1;

sttemp=ACTUAL_GEN_OUTPUT.val<GENVALUE.val(:,min_gen)&LAST_GEN_SCHEDULE.val>=GENVALUE.val(:,min_gen);
UNIT_STARTINGUP_ACTUAL.val=zeros(ngen,1);
UNIT_STARTINGUP_ACTUAL.name='UNIT_STARTINGUP_ACTUAL';
UNIT_STARTINGUP_ACTUAL.form='full';
UNIT_STARTINGUP_ACTUAL.type='parameter';
UNIT_STARTINGUP_ACTUAL.uels={GEN.uels};
UNIT_STARTINGUP_ACTUAL.val(sttemp)=1;
sttemp=ACTUAL_PUMP_OUTPUT.val<STORAGEVALUE.val(:,min_pump)&LAST_PUMP_SCHEDULE.val>=STORAGEVALUE.val(:,min_pump);
UNIT_PUMPINGUP_ACTUAL.val=zeros(ngen,1);
UNIT_PUMPINGUP_ACTUAL.name='UNIT_PUMPINGUP_ACTUAL';
UNIT_PUMPINGUP_ACTUAL.form='full';
UNIT_PUMPINGUP_ACTUAL.type='parameter';
UNIT_PUMPINGUP_ACTUAL.uels={GEN.uels};
UNIT_PUMPINGUP_ACTUAL.val(sttemp)=1;

gt1=GENVALUE.val(:,pucost);
gt2=GENVALUE.val(:,gen_type);
cond1=gt1==1;
cond2=gt2==7|gt2==10|gt2==16;
cond3=cond1&cond2;
cond4=VG_FORECAST.val(1,:)<1;
cond5=cond4'&cond3;
offset_temp1=max(zeros(ngen,1),LAST_GEN_SCHEDULE.val-GENVALUE.val(:,ramp_rate).*IRTD);
offset_temp2=max(offset_temp1,ACTUAL_GEN_OUTPUT.val-GENVALUE.val(:,ramp_rate).*(IRTD+PRTD));
offset_temp2(~cond3)=0;
offset_temp2(~cond5)=0;
PUCOST_BLOCK_OFFSET.name='PUCOST_BLOCK_OFFSET';
PUCOST_BLOCK_OFFSET.form='full';
PUCOST_BLOCK_OFFSET.type='parameter';
PUCOST_BLOCK_OFFSET.uels={GEN.uels};
PUCOST_BLOCK_OFFSET.val=offset_temp2;

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
ACTUAL_GEN_OUTPUT.val=ACTUAL_GEN_OUTPUT.val./SYSTEMVALUE.val(mva_pu);
LAST_GEN_SCHEDULE.val=LAST_GEN_SCHEDULE.val./SYSTEMVALUE.val(mva_pu);
ACTUAL_PUMP_OUTPUT.val=ACTUAL_PUMP_OUTPUT.val./SYSTEMVALUE.val(mva_pu);
LAST_PUMP_SCHEDULE.val=LAST_PUMP_SCHEDULE.val./SYSTEMVALUE.val(mva_pu);
RAMP_SLACK_UP.val=RAMP_SLACK_UP.val./SYSTEMVALUE.val(mva_pu);
RAMP_SLACK_DOWN.val=RAMP_SLACK_DOWN.val./SYSTEMVALUE.val(mva_pu);
UNIT_STARTUPMINGENHELP.val=UNIT_STARTUPMINGENHELP.val./SYSTEMVALUE.val(mva_pu);
UNIT_PUMPUPMINGENHELP.val=UNIT_PUMPUPMINGENHELP.val./SYSTEMVALUE.val(mva_pu);
DEFAULT_DATA.GENVALUE=GENVALUE;
DEFAULT_DATA.STORAGEVALUE=STORAGEVALUE;
DEFAULT_DATA.BRANCHDATA=BRANCHDATA;
DEFAULT_DATA.COST_CURVE=COST_CURVE;
DEFAULT_DATA.PUMPEFFICIENCYVALUE=PUMPEFFICIENCYVALUE;
DEFAULT_DATA.GENEFFICIENCYVALUE=GENEFFICIENCYVALUE;

% Update initial statuses of DEFAULT_DATA set
DEFAULT_DATA.GENVALUE.val(:,initial_status:initial_MW) = GENVALUE.val(:,initial_status:initial_MW);
DEFAULT_DATA.STORAGEVALUE.val(:,[initial_storage,final_storage,initial_pump_status,initial_pump_mw,initial_pump_hour]) = STORAGEVALUE.val(:,[initial_storage,final_storage,initial_pump_status,initial_pump_mw,initial_pump_hour]);

% Load default system values
BRANCHBUS2            = DEFAULT_DATA.BRANCHBUS2;
GENBUS2               = DEFAULT_DATA.GENBUS2;
PARTICIPATION_FACTORS = DEFAULT_DATA.PARTICIPATION_FACTORS;
BRANCHDATA            = DEFAULT_DATA.BRANCHDATA;
COST_CURVE            = DEFAULT_DATA.COST_CURVE;
SYSTEMVALUE           = DEFAULT_DATA.SYSTEMVALUE;
STARTUP_VALUE         = DEFAULT_DATA.STARTUP_VALUE;
RESERVE_COST          = DEFAULT_DATA.RESERVE_COST;
RESERVEVALUE          = DEFAULT_DATA.RESERVEVALUE;
PUMPEFFICIENCYVALUE   = DEFAULT_DATA.PUMPEFFICIENCYVALUE;
GENEFFICIENCYVALUE    = DEFAULT_DATA.GENEFFICIENCYVALUE;
GENVALUE              = DEFAULT_DATA.GENVALUE;
LOAD_DIST             = DEFAULT_DATA.LOAD_DIST;
STORAGEVALUE          = DEFAULT_DATA.STORAGEVALUE;
PTDF                  = DEFAULT_DATA.PTDF;
PTDF_PAR              = DEFAULT_DATA.PTDF_PAR;
LODF                  = DEFAULT_DATA.LODF;