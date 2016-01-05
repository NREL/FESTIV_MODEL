% Create GAMS variables for DASCUC model solve

if Solving_Initial_Models == 1
    NDACINTERVAL.val = HDAC;
end
NDACINTERVAL.name = 'NDACINTERVAL';
NDACINTERVAL.form = 'full';
NDACINTERVAL.uels = cell(1,0);
NDACINTERVAL.type = 'parameter';

DACINTERVAL_LENGTH.val = IDAC;
DACINTERVAL_LENGTH.name = 'DACINTERVAL_LENGTH';
DACINTERVAL_LENGTH.form = 'full';
DACINTERVAL_LENGTH.uels = cell(1,0);
DACINTERVAL_LENGTH.type = 'parameter';

INTERVAL.uels = num2cell(1:NDACINTERVAL.val);
INTERVAL.val = ones(NDACINTERVAL.val,1);
INTERVAL.name = 'INTERVAL';
INTERVAL.form = 'full';
INTERVAL.type = 'set';

VG_FORECAST.name = 'VG_FORECAST';
VG_FORECAST.val = VG_FORECAST_VAL;
VG_FORECAST.uels = {INTERVAL.uels GEN.uels};
VG_FORECAST.form = 'full';
VG_FORECAST.type = 'parameter';

if Solving_Initial_Models == 1
    GEN_FORCED_OUT.val = zeros(ngen,1);
else
    GEN_FORCED_OUT.val = actual_gen_forced_out;
end
GEN_FORCED_OUT.name = 'GEN_FORCED_OUT';
GEN_FORCED_OUT.form = 'full';
GEN_FORCED_OUT.type = 'parameter';
GEN_FORCED_OUT.uels = GEN.uels;

if Solving_Initial_Models == 1
    DA_RESERVELEVEL_VAL = DAC_RESERVE_FULL((DASCUC_binding_interval_index-1)*HDAC+1:DASCUC_binding_interval_index*HDAC,3:end);
    RESERVELEVEL.val = DA_RESERVELEVEL_VAL(1:HDAC,:);
else
    RESERVELEVEL.val = RESERVELEVEL_VAL(1:NDACINTERVAL.val,:);
end
RESERVELEVEL.uels = {INTERVAL.uels DAC_RESERVE_FIELD(1,3:end)};
RESERVELEVEL.name = 'RESERVELEVEL';
RESERVELEVEL.form = 'full';
RESERVELEVEL.type = 'parameter';

if Solving_Initial_Models == 1
    DA_LOAD_VAL = DAC_LOAD_FULL((DASCUC_binding_interval_index-1)*HDAC+1:DASCUC_binding_interval_index*HDAC,3);
    LOAD.val = DA_LOAD_VAL(1:HDAC,:);    
else
    clear LOAD;
    dac_int=1;
    t=1;
    while(t <= size_DAC_LOAD_FULL && DAC_LOAD_FULL(t,1)<= DASCUC_binding_interval_index+1)
        if(abs(DAC_LOAD_FULL(t,1) - DASCUC_binding_interval_index) < eps)
            LOAD.val(dac_int,:) = DAC_LOAD_FULL(t,3);
            dac_int = dac_int+1;
        end;
        t = t+1;
    end;
end
LOAD.uels = INTERVAL.uels;
LOAD.name = 'LOAD';
LOAD.form = 'full';
LOAD.type = 'parameter';

clear BUS_DELIVERY_FACTORS GEN_DELIVERY_FACTORS;

GEN_DELIVERY_FACTORS.val=DAC_GEN_DELIVERY_FACTORS_VAL;
GEN_DELIVERY_FACTORS.name='GEN_DELIVERY_FACTORS';
GEN_DELIVERY_FACTORS.form='full';
GEN_DELIVERY_FACTORS.type='parameter';
GEN_DELIVERY_FACTORS.uels={GEN.uels INTERVAL.uels};

BUS_DELIVERY_FACTORS.val=DAC_BUS_DELIVERY_FACTORS_VAL;
BUS_DELIVERY_FACTORS.name='BUS_DELIVERY_FACTORS';
BUS_DELIVERY_FACTORS.form='full';
BUS_DELIVERY_FACTORS.type='parameter';
BUS_DELIVERY_FACTORS.uels={BUS.uels INTERVAL.uels};

if ninterchange > 0
    UNIT_STATUS_ENFORCED_ON_VAL(interchanges,:)=1;
    UNIT_STATUS_ENFORCED_OFF_VAL(interchanges,:)=1;
end
UNIT_STATUS_ENFORCED_ON.name = 'UNIT_STATUS_ENFORCED_ON';
UNIT_STATUS_ENFORCED_ON.val = UNIT_STATUS_ENFORCED_ON_VAL(:,1:HDAC);
UNIT_STATUS_ENFORCED_ON.uels = {GEN.uels INTERVAL.uels};
UNIT_STATUS_ENFORCED_ON.form = 'full';
UNIT_STATUS_ENFORCED_ON.type = 'parameter';

UNIT_STATUS_ENFORCED_OFF.name = 'UNIT_STATUS_ENFORCED_OFF';
UNIT_STATUS_ENFORCED_OFF.val = UNIT_STATUS_ENFORCED_OFF_VAL(:,1:HDAC);
UNIT_STATUS_ENFORCED_OFF.uels = {GEN.uels INTERVAL.uels};
UNIT_STATUS_ENFORCED_OFF.form = 'full';
UNIT_STATUS_ENFORCED_OFF.type = 'parameter';

PUMPING_ENFORCED_ON.name = 'PUMPING_ENFORCED_ON';
PUMPING_ENFORCED_ON.val = PUMPING_ENFORCED_ON_VAL(:,1:HDAC);
PUMPING_ENFORCED_ON.uels = {GEN.uels INTERVAL.uels};
PUMPING_ENFORCED_ON.form = 'full';
PUMPING_ENFORCED_ON.type = 'parameter';

PUMPING_ENFORCED_OFF.name = 'PUMPING_ENFORCED_OFF';
PUMPING_ENFORCED_OFF.val = PUMPING_ENFORCED_OFF_VAL(:,1:HDAC);
PUMPING_ENFORCED_OFF.uels = {GEN.uels INTERVAL.uels};
PUMPING_ENFORCED_OFF.form = 'full';
PUMPING_ENFORCED_OFF.type = 'parameter';

GAMS_SOLVER.name = 'GAMS_SOLVER';
GAMS_SOLVER.form = 'full';
GAMS_SOLVER.type = 'parameter';
GAMS_SOLVER.uels = cell(1,0);
if strcmp(computer,'GLNX64')
  GAMS_SOLVER.val = 1;  % 1 = gurobi
else
  GAMS_SOLVER.val = 2;  % 2 = cplex
end

if Solving_Initial_Models == 1
    DAC_INTERCHANGE_VAL = DAC_INTERCHANGE_FULL((DASCUC_binding_interval_index-1)*HDAC+1:DASCUC_binding_interval_index*HDAC,3:end);
    INTERCHANGE.val = DAC_INTERCHANGE_VAL(1:HDAC,:);
else
    INTERCHANGE.val = DAC_INTERCHANGE_VAL(1:NDACINTERVAL.val,:);
end
INTERCHANGE.uels = {INTERVAL.uels DAC_INTERCHANGE_FIELD(1,3:end)};
INTERCHANGE.name = 'INTERCHANGE';
INTERCHANGE.form = 'full';
INTERCHANGE.type = 'parameter';

if Solving_Initial_Models == 1
    LOSS_BIAS.val = 0;
else
    LOSS_BIAS.val = storelosses(max(1,AGC_interval_index-1),1)-mean(abs(DASCUCMARGINALLOSS((DASCUC_binding_interval_index-2)*HDAC+1:HDAC+(DASCUC_binding_interval_index-2)*HDAC,2)));
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

PUMPBLOCKS={'BLOCK1','BLOCK2','BLOCK3'};
if ~isempty(GENEFFICIENCYVALUE_VAL)
    geneffmwvalues=GENEFFICIENCYVALUE_VAL(:,[2,4,6]);
    stoeffmwvalues=PUMPEFFICIENCYVALUE_VAL(:,[2,4,6]);
    geneffvalues=GENEFFICIENCYVALUE_VAL(:,[1,3,5]);
    stoeffvalues=PUMPEFFICIENCYVALUE_VAL(:,[1,3,5]);
else
    geneffmwvalues=[];
    stoeffmwvalues=[];
    geneffvalues=[];
    stoeffvalues=[];
end
STORAGEGENEFFICIENCYBLOCK.uels={GENEFFICIENCYVALUE_STRING' PUMPBLOCKS};
STORAGEPUMPEFFICIENCYBLOCK.uels={PUMPEFFICIENCYVALUE_STRING' PUMPBLOCKS};
STORAGEGENEFFICIENCYBLOCK.name='STORAGEGENEFFICIENCYBLOCK';
STORAGEPUMPEFFICIENCYBLOCK.name='STORAGEPUMPEFFICIENCYBLOCK';
STORAGEGENEFFICIENCYBLOCK.type='SET';
STORAGEPUMPEFFICIENCYBLOCK.type='SET';
STORAGEGENEFFICIENCYBLOCK.form='FULL';
STORAGEPUMPEFFICIENCYBLOCK.form='FULL';
STORAGEGENEFFICIENCYBLOCK.val=double(geneffmwvalues>eps);
STORAGEPUMPEFFICIENCYBLOCK.val=double(stoeffmwvalues>eps);

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

OFFLINE_BLOCK.name='OFFLINE_BLOCK';
OFFLINE_BLOCK.uels={STARTUP_VALUE_STRING1' STARTUP_VALUE_STRING2};
OFFLINE_BLOCK.form='FULL';
OFFLINE_BLOCK.type='parameter';
if ~isempty(STARTUP_VALUE.val)
    OFFLINE_BLOCK.val=STARTUP_VALUE.val(:,[1 3 5]);
    STARTUP_COST_BLOCK.val=STARTUP_VALUE.val(:,[2 4 6]);
else
    OFFLINE_BLOCK.val=[];
    STARTUP_COST_BLOCK.val=[];
end

STARTUP_COST_BLOCK.name='STARTUP_COST_BLOCK';
STARTUP_COST_BLOCK.uels={STARTUP_VALUE_STRING1' STARTUP_VALUE_STRING2};
STARTUP_COST_BLOCK.form='FULL';
STARTUP_COST_BLOCK.type='parameter';

MAX_OFFLINE_TIME.name='MAX_OFFLINE_TIME';
MAX_OFFLINE_TIME.uels={GEN_VAL'};
MAX_OFFLINE_TIME.form='FULL';
MAX_OFFLINE_TIME.type='parameter';
MAX_OFFLINE_TIME.val=HDAC+GENVALUE.val(:,initial_hour).*(1-GENVALUE.val(:,initial_status));

initally_off_gens=GENVALUE.val(:,initial_status) < eps;
INITIAL_STARTUP_COST_HELPER.val=zeros(ngen,1);
temp5=find(initally_off_gens);
for io=1:size(temp5,1)
    if find(strcmp(OFFLINE_BLOCK.uels{1,1},GEN_VAL{temp5(io)})) % if gen was initially off with variable startup cost
        temp_idx=find(strcmp(OFFLINE_BLOCK.uels{1,1},GEN_VAL{temp5(io)}));
        if GENVALUE.val(temp5(io),initial_hour) >= OFFLINE_BLOCK.val(temp_idx,1)
            INITIAL_STARTUP_COST_HELPER.val(temp5(io))=STARTUP_COST_BLOCK.val(temp_idx,1);
        elseif GENVALUE.val(temp5(io),initial_hour) >= OFFLINE_BLOCK.val(temp_idx,2)
            INITIAL_STARTUP_COST_HELPER.val(temp5(io))=STARTUP_COST_BLOCK.val(temp_idx,2);
        else
            INITIAL_STARTUP_COST_HELPER.val(temp5(io))=STARTUP_COST_BLOCK.val(temp_idx,3);
        end
    end
end
INITIAL_STARTUP_COST_HELPER.name='INITIAL_STARTUP_COST_HELPER';
INITIAL_STARTUP_COST_HELPER.uels={GEN_VAL'};
INITIAL_STARTUP_COST_HELPER.form='FULL';
INITIAL_STARTUP_COST_HELPER.type='PARAMETER';

INITIAL_STARTUP_PERIODS.name='INITIAL_STARTUP_PERIODS';
INITIAL_STARTUP_PERIODS.uels={GEN_VAL'};
INITIAL_STARTUP_PERIODS.form='full';
INITIAL_STARTUP_PERIODS.type='parameter';
INTERVALS_STARTED_AGO.name='INTERVALS_STARTED_AGO';
INTERVALS_STARTED_AGO.uels={GEN_VAL'};
INTERVALS_STARTED_AGO.form='full';
INTERVALS_STARTED_AGO.type='parameter';
INITIAL_STARTUP_PERIODS.val=zeros(ngen,1);
INTERVALS_STARTED_AGO.val=zeros(ngen,1);
temp_idx=GENVALUE.val(:,initial_status) > 1-eps & GENVALUE.val(:,initial_hour) <= GENVALUE.val(:,su_time);
INITIAL_STARTUP_PERIODS.val(temp_idx)=1;
INTERVALS_STARTED_AGO.val(temp_idx)=GENVALUE.val(temp_idx,initial_hour);
INITIAL_PUMPUP_PERIODS.name='INITIAL_PUMPUP_PERIODS';
INITIAL_PUMPUP_PERIODS.uels={GEN_VAL'};
INITIAL_PUMPUP_PERIODS.form='full';
INITIAL_PUMPUP_PERIODS.type='parameter';
INTERVALS_PUMPUP_AGO.name='INTERVALS_PUMPUP_AGO';
INTERVALS_PUMPUP_AGO.uels={GEN_VAL'};
INTERVALS_PUMPUP_AGO.form='full';
INTERVALS_PUMPUP_AGO.type='parameter';
INITIAL_PUMPUP_PERIODS.val=zeros(ngen,1);
INTERVALS_PUMPUP_AGO.val=zeros(ngen,1);
temp_idx=STORAGEVALUE.val(:,initial_pump_status) > 1-eps & STORAGEVALUE.val(:,initial_pump_hour) <= STORAGEVALUE.val(:,pump_su_time);
INITIAL_PUMPUP_PERIODS.val(temp_idx)=1;
INTERVALS_PUMPUP_AGO.val(temp_idx)=GENVALUE.val(temp_idx,initial_hour);

STARTUP_PERIOD.val=max(1,ceil(GENVALUE.val(:,su_time)/IDAC));
SHUTDOWN_PERIOD.val=max(1,ceil(GENVALUE.val(:,sd_time)/IDAC));
PUMPUP_PERIOD.val=max(1,ceil(STORAGEVALUE.val(:,pump_su_time)/IDAC));
PUMPDOWN_PERIOD.val=max(1,ceil(STORAGEVALUE.val(:,pump_sd_time)/IDAC));
STARTUP_PERIOD.name='STARTUP_PERIOD';
SHUTDOWN_PERIOD.name='SHUTDOWN_PERIOD';
PUMPUP_PERIOD.name='PUMPUP_PERIOD';
PUMPDOWN_PERIOD.name='PUMPDOWN_PERIOD';
STARTUP_PERIOD.uels={GEN_VAL'};
SHUTDOWN_PERIOD.uels={GEN_VAL'};
PUMPUP_PERIOD.uels={GEN_VAL'};
PUMPDOWN_PERIOD.uels={GEN_VAL'};
STARTUP_PERIOD.type='parameter';
SHUTDOWN_PERIOD.type='parameter';
PUMPUP_PERIOD.type='parameter';
PUMPDOWN_PERIOD.type='parameter';
STARTUP_PERIOD.form='full';
SHUTDOWN_PERIOD.form='full';
PUMPUP_PERIOD.form='full';
PUMPDOWN_PERIOD.form='full';

INITIAL_SHUTDOWN_PERIODS.name='INITIAL_SHUTDOWN_PERIODS';
INITIAL_SHUTDOWN_PERIODS.uels={GEN_VAL'};
INITIAL_SHUTDOWN_PERIODS.form='full';
INITIAL_SHUTDOWN_PERIODS.type='parameter';
INTERVALS_SHUTDOWN_AGO.name='INTERVALS_SHUTDOWN_AGO';
INTERVALS_SHUTDOWN_AGO.uels={GEN_VAL'};
INTERVALS_SHUTDOWN_AGO.form='full';
INTERVALS_SHUTDOWN_AGO.type='parameter';
INITIAL_SHUTDOWN_PERIODS.val=zeros(ngen,1);
INTERVALS_SHUTDOWN_AGO.val=zeros(ngen,1);
temp_idx=GENVALUE.val(:,initial_status) > 1-eps & GENVALUE.val(:,initial_hour) >= GENVALUE.val(:,su_time) & GENVALUE.val(:,initial_MW) < GENVALUE.val(:,min_gen);
INITIAL_SHUTDOWN_PERIODS.val(temp_idx)=1;
INTERVALS_SHUTDOWN_AGO.val(temp_idx)=(1-(GENVALUE.val(temp_idx,initial_MW)./GENVALUE.val(temp_idx,min_gen))).*SHUTDOWN_PERIOD.val(temp_idx);
INITIAL_PUMPDOWN_PERIODS.name='INITIAL_PUMPDOWN_PERIODS';
INITIAL_PUMPDOWN_PERIODS.uels={GEN_VAL'};
INITIAL_PUMPDOWN_PERIODS.form='full';
INITIAL_PUMPDOWN_PERIODS.type='parameter';
INTERVALS_PUMPDOWN_AGO.name='INTERVALS_PUMPDOWN_AGO';
INTERVALS_PUMPDOWN_AGO.uels={GEN_VAL'};
INTERVALS_PUMPDOWN_AGO.form='full';
INTERVALS_PUMPDOWN_AGO.type='parameter';
INITIAL_PUMPDOWN_PERIODS.val=zeros(ngen,1);
INTERVALS_PUMPDOWN_AGO.val=zeros(ngen,1);
temp_idx=STORAGEVALUE.val(:,initial_pump_status) > 1-eps & STORAGEVALUE.val(:,initial_pump_hour) >= STORAGEVALUE.val(:,pump_su_time) & STORAGEVALUE.val(:,initial_pump_mw) < STORAGEVALUE.val(:,min_pump);
INITIAL_PUMPDOWN_PERIODS.val(temp_idx)=1;
INTERVALS_PUMPDOWN_AGO.val(temp_idx)=(1-(STORAGEVALUE.val(temp_idx,initial_pump_mw)./STORAGEVALUE.val(temp_idx,min_pump))).*PUMPDOWN_PERIOD.val(temp_idx);

GEN_EFFICIENCY_BLOCK.name='GEN_EFFICIENCY_BLOCK';
GEN_EFFICIENCY_BLOCK.uels={STORAGEGENEFFICIENCYBLOCK.uels{1,1} STORAGEGENEFFICIENCYBLOCK.uels{1,2}};
GEN_EFFICIENCY_BLOCK.form='full';
GEN_EFFICIENCY_BLOCK.type='parameter';
GEN_EFFICIENCY_BLOCK.val=geneffvalues;
GEN_EFFICIENCY_MW.name='GEN_EFFICIENCY_MW';
GEN_EFFICIENCY_MW.uels={STORAGEGENEFFICIENCYBLOCK.uels{1,1} STORAGEGENEFFICIENCYBLOCK.uels{1,2}};
GEN_EFFICIENCY_MW.form='full';
GEN_EFFICIENCY_MW.type='parameter';
GEN_EFFICIENCY_MW.val=geneffmwvalues./SYSTEMVALUE.val(mva_pu);
PUMP_EFFICIENCY_BLOCK.name='PUMP_EFFICIENCY_BLOCK';
PUMP_EFFICIENCY_BLOCK.uels={STORAGEGENEFFICIENCYBLOCK.uels{1,1} STORAGEGENEFFICIENCYBLOCK.uels{1,2}};
PUMP_EFFICIENCY_BLOCK.form='full';
PUMP_EFFICIENCY_BLOCK.type='parameter';
PUMP_EFFICIENCY_BLOCK.val=stoeffvalues;
PUMP_EFFICIENCY_MW.name='PUMP_EFFICIENCY_MW';
PUMP_EFFICIENCY_MW.uels={STORAGEGENEFFICIENCYBLOCK.uels{1,1} STORAGEGENEFFICIENCYBLOCK.uels{1,2}};
PUMP_EFFICIENCY_MW.form='full';
PUMP_EFFICIENCY_MW.type='parameter';
PUMP_EFFICIENCY_MW.val=stoeffmwvalues./SYSTEMVALUE.val(mva_pu);

DROOP_EQ.name='DROOP_EQ';
DROOP_EQ.form='full';
DROOP_EQ.type='parameter';
DROOP_EQ.uels={GEN_VAL'};
DROOP_EQ.val=zeros(ngen,1);
temp_idx=GENVALUE.val(:,droop) > 0 & GENVALUE.val(:,capacity) > 0;
DROOP_EQ.val(temp_idx,1)=GENVALUE.val(temp_idx,droop).*SYSTEMVALUE.val(frequency,1)./GENVALUE.val(temp_idx,capacity);

END_STORAGE_PENALTY_PLUS_PRICE.name='END_STORAGE_PENALTY_PLUS_PRICE';
END_STORAGE_PENALTY_PLUS_PRICE.form='full';
END_STORAGE_PENALTY_PLUS_PRICE.type='parameter';
END_STORAGE_PENALTY_PLUS_PRICE.uels={GEN_VAL'};
END_STORAGE_PENALTY_PLUS_PRICE.val=zeros(ngen,1);
temp_idx=STORAGEVALUE.val(:,enforce_final_storage) > 1-eps;
END_STORAGE_PENALTY_PLUS_PRICE.val(temp_idx,1)=SYSTEMVALUE.val(voll,1);
END_STORAGE_PENALTY_MINUS_PRICE.name='END_STORAGE_PENALTY_MINUS_PRICE';
END_STORAGE_PENALTY_MINUS_PRICE.form='full';
END_STORAGE_PENALTY_MINUS_PRICE.type='parameter';
END_STORAGE_PENALTY_MINUS_PRICE.uels={GEN_VAL'};
END_STORAGE_PENALTY_MINUS_PRICE.val=zeros(ngen,1);
END_STORAGE_PENALTY_MINUS_PRICE.val(temp_idx,1)=SYSTEMVALUE.val(voll,1);

gens_with_govs=GEN_VAL(GENVALUE.val(:,droop)>0);
PFR_MULTIPLIER.name='PFR_MULTIPLIER';
PFR_MULTIPLIER.form='full';
PFR_MULTIPLIER.type='parameter';
PFR_MULTIPLIER.uels={gens_with_govs' INTERVAL.uels RESERVETYPE_VAL'};
PFR_MULTIPLIER.val=zeros(size(gens_with_govs,1),HDAC,nreserve);
for rr=1:nreserve
    if RESERVEVALUE.val(rr,res_gov) > 1 - eps
        PFR_MULTIPLIER.val(gens_with_govs,:,rr)=1;
    end
end

DAMPING_MULTIPLIER.name='DAMPING_MULTIPLIER';
DAMPING_MULTIPLIER.form='full';
DAMPING_MULTIPLIER.type='parameter';
DAMPING_MULTIPLIER.uels={INTERVAL.uels RESERVETYPE_VAL'};
DAMPING_MULTIPLIER.val=zeros(HDAC,nreserve);
res_with_govs=RESERVEVALUE.val(:,res_gov)>1-eps;
DAMPING_MULTIPLIER.val(:,res_with_govs)=1;

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