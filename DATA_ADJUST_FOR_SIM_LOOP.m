%Adjust data for the main simulation loop.

AGC_interval_index = 1;
ACTUAL_GENERATION(1,:) = RTSCEDBINDINGSCHEDULE(1,:);
ACTUAL_PUMP(1,:) = RTSCEDBINDINGPUMPSCHEDULE(1,:);
ACTUAL_STORAGE_LEVEL(1,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) STORAGEVALUE_VAL(:,initial_storage)'];
if AGC_MODE ~= 5
    GENVALUE_VAL(:,gen_agc_mode) = AGC_MODE;
    DEFAULT_DATA.GENVALUE.val(:,gen_agc_mode) = AGC_MODE;
end;

finalvariablescounter=1;

% Updates
dascuc_update = start_time + (24-GDAC); 
rtscuc_update = tRTC + 1;
rtsced_update = tRTD + 1;
