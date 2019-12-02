PREVIOUS_UNIT_STARTUP_VAL=zeros(ngen,1);
INTERVALS_STARTED_AGO_VAL=zeros(ngen,1);
temp_idx=GENVALUE_VAL(:,initial_status) > 1-eps & GENVALUE_VAL(:,initial_hour) <= GENVALUE_VAL(:,su_time);
PREVIOUS_UNIT_STARTUP_VAL(temp_idx)=1;
INTERVALS_STARTED_AGO_VAL(temp_idx)=GENVALUE_VAL(temp_idx,initial_hour);
PREVIOUS_UNIT_PUMPUP_VAL=zeros(nESR,1);
INTERVALS_PUMPUP_AGO_VAL=zeros(nESR,1);
if nESR >0
    temp_idx=STORAGEVALUE_VAL(:,initial_pump_status) > 1-eps & STORAGEVALUE_VAL(:,initial_pump_hour) <= STORAGEVALUE_VAL(:,pump_su_time);
    PREVIOUS_UNIT_PUMPUP_VAL(temp_idx)=1;
    INTERVALS_PUMPUP_AGO_VAL(temp_idx)=STORAGEVALUE_VAL(temp_idx,initial_pump_hour);
end;

STARTUP_PERIOD_VAL=max(1,ceil(GENVALUE_VAL(:,su_time)/IDAC));
SHUTDOWN_PERIOD_VAL=max(1,ceil(GENVALUE_VAL(:,sd_time)/IDAC));
PUMPUP_PERIOD_VAL=zeros(nESR,1);
PUMPDOWN_PERIOD_VAL=zeros(nESR,1);
if nESR >0
    PUMPUP_PERIOD_VAL=max(1,ceil(STORAGEVALUE_VAL(:,pump_su_time)/IDAC));
    PUMPDOWN_PERIOD_VAL=max(1,ceil(STORAGEVALUE_VAL(:,pump_sd_time)/IDAC));
end;

INITIAL_SHUTDOWN_PERIODS_VAL=zeros(ngen,1);
temp_idx=GENVALUE_VAL(:,initial_status) > 1-eps & GENVALUE_VAL(:,initial_hour) >= GENVALUE_VAL(:,su_time) & GENVALUE_VAL(:,initial_MW) < GENVALUE_VAL(:,min_gen);
INITIAL_SHUTDOWN_PERIODS_VAL(temp_idx)=1;
INTERVALS_SHUTDOWN_AGO_VAL=zeros(ngen,1);
INTERVALS_SHUTDOWN_AGO_VAL(temp_idx)=(1-(GENVALUE_VAL(temp_idx,initial_MW)./GENVALUE_VAL(temp_idx,min_gen))).*SHUTDOWN_PERIOD_VAL(temp_idx);

INITIAL_PUMPDOWN_PERIODS_VAL=zeros(nESR,1);
INTERVALS_PUMPDOWN_AGO_VAL=zeros(nESR,1);
if nESR >0
    temp_idx=STORAGEVALUE_VAL(:,initial_pump_status) > 1-eps & STORAGEVALUE_VAL(:,initial_pump_hour) >= STORAGEVALUE_VAL(:,pump_su_time) & STORAGEVALUE_VAL(:,initial_pump_mw) < STORAGEVALUE_VAL(:,min_pump);
    INITIAL_PUMPDOWN_PERIODS_VAL(temp_idx)=1;
    INTERVALS_PUMPDOWN_AGO_VAL(temp_idx)=(1-(STORAGEVALUE_VAL(temp_idx,initial_pump_mw)./STORAGEVALUE_VAL(temp_idx,min_pump))).*PUMPDOWN_PERIOD_VAL(temp_idx);
end;

initally_off_gens=GENVALUE_VAL(:,initial_status) < eps;
INITIAL_STARTUP_COST_HELPER_VAL=zeros(ngen,1);
temp5=find(initally_off_gens);
for io=1:size(temp5,1)
    if find(strcmp(STARTUP_VALUE_STRING1,GEN_VAL{temp5(io)})) % if gen was initially off with variable startup cost
        temp_idx=find(strcmp(STARTUP_VALUE_STRING1,GEN_VAL{temp5(io)}));
        if GENVALUE_VAL(temp5(io),initial_hour) >= OFFLINE_BLOCK_VAL(temp_idx,1)
            INITIAL_STARTUP_COST_HELPER_VAL(temp5(io))=STARTUP_COST_BLOCK_VAL(temp_idx,1);
        elseif GENVALUE_VAL(temp5(io),initial_hour) >= OFFLINE_BLOCK_VAL(temp_idx,2)
            INITIAL_STARTUP_COST_HELPER_VAL(temp5(io))=STARTUP_COST_BLOCK_VAL(temp_idx,2);
        else
            INITIAL_STARTUP_COST_HELPER_VAL(temp5(io))=STARTUP_COST_BLOCK_VAL(temp_idx,3);
        end
    end
end

MAX_OFFLINE_TIME_VAL=HDAC+GENVALUE_VAL(:,initial_hour).*(1-GENVALUE_VAL(:,initial_status));
