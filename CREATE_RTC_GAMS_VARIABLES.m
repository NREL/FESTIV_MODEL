% Create GAMS variables for RTSCUC model solve

if rtscuc_running
    H=HRTC;
else
    H=HRPU;
end

clear INTERVAL
INTERVAL.name = 'INTERVAL';
INTERVAL_VAL = {'1'};
for t=2:H
    INTERVAL_VAL = [INTERVAL_VAL; num2str(t)];
end
INTERVAL.uels = INTERVAL_VAL';
INTERVAL.val = ones(H,1);
INTERVAL.form = 'full';

LOAD.val = LOAD_VAL;
LOAD.uels = {INTERVAL_VAL'}; 
LOAD.name = 'LOAD';
LOAD.form = 'full';
LOAD.type = 'parameter';
RTC_LOAD = LOAD;

VG_FORECAST.name = 'VG_FORECAST';
VG_FORECAST.val = VG_FORECAST_VAL;
VG_FORECAST.uels = {INTERVAL_VAL' GEN_VAL'};
VG_FORECAST.form = 'full';
VG_FORECAST.type = 'parameter';

RESERVELEVEL.val = RESERVELEVEL_VAL;
RESERVELEVEL.name = 'RESERVELEVEL';
RESERVELEVEL.uels = {INTERVAL_VAL' RTC_RESERVE_FIELD(3:end)};
RESERVELEVEL.form = 'full';
RESERVELEVEL.type = 'parameter';

INTERCHANGE.val = INTERCHANGE_VAL;
INTERCHANGE.name = 'INTERCHANGE';
INTERCHANGE.uels = {INTERVAL_VAL' RTC_INTERCHANGE_FIELD(3:end)};
INTERCHANGE.form = 'full';
INTERCHANGE.type = 'parameter';

if rtscuc_running
    NRTCINTERVAL.val = HRTC;
elseif rpu_running
    NRTCINTERVAL.val = HRPU;
end    
NRTCINTERVAL.name = 'NUMINTERVAL';
NRTCINTERVAL.form = 'full';
NRTCINTERVAL.uels = cell(1,0);
NRTCINTERVAL.type = 'parameter';

if rtscuc_running
    RTCINTERVAL_LENGTH.val = IRTC/60;
elseif rpu_running
    RTCINTERVAL_LENGTH.val = IRPU/60;
end    
RTCINTERVAL_LENGTH.name = 'INTERVAL_LENGTH';
RTCINTERVAL_LENGTH.form = 'full';
RTCINTERVAL_LENGTH.uels = cell(1,0);
RTCINTERVAL_LENGTH.type = 'parameter';

if rtscuc_running
    RTCINTERVAL_UPDATE.val = tRTC/60;
elseif rpu_running
    RTCINTERVAL_UPDATE.val = 24;
end    
RTCINTERVAL_UPDATE.name = 'INTERVAL_UPDATE';
RTCINTERVAL_UPDATE.form = 'full';
RTCINTERVAL_UPDATE.uels = cell(1,0);
RTCINTERVAL_UPDATE.type = 'parameter';

if Solving_Initial_Models == 1
    RTC_PROCESS_TIME.val = IDAC-IRTC/60;
elseif rtscuc_running
    RTC_PROCESS_TIME.val = PRTC/60;
elseif rpu_running
    RTC_PROCESS_TIME.val = PRPU/60;
end
RTC_PROCESS_TIME.name = 'PROCESS_TIME';
RTC_PROCESS_TIME.form = 'full';
RTC_PROCESS_TIME.uels = cell(1,0);
RTC_PROCESS_TIME.type = 'parameter';

RTCSTART.val = RTSCUCSTART_YES;
RTCSTART.name = 'RTCSTART';
RTCSTART.form = 'full';
RTCSTART.uels = {GEN_VAL' INTERVAL_VAL'};
RTCSTART.type = 'parameter';

RTCSHUT.val = RTSCUCSHUT_YES;
RTCSHUT.name = 'RTCSHUT';
RTCSHUT.form = 'full';
RTCSHUT.uels = {GEN_VAL' INTERVAL_VAL'};
RTCSHUT.type = 'parameter';

RTCPUMPSTART.val = RTSCUCPUMPSTART_YES;
RTCPUMPSTART.name = 'RTCPUMPSTART';
RTCPUMPSTART.form = 'full';
RTCPUMPSTART.uels = {STORAGE_UNITS' INTERVAL_VAL'};
RTCPUMPSTART.type = 'parameter';

RTCPUMPSHUT.val = RTSCUCPUMPSHUT_YES;
RTCPUMPSHUT.name = 'RTCPUMPSHUT';
RTCPUMPSHUT.form = 'full';
RTCPUMPSHUT.uels = {STORAGE_UNITS' INTERVAL_VAL'};
RTCPUMPSHUT.type = 'parameter';

if ninterchange > 0
    UNIT_STATUS_ENFORCED_ON_VAL(interchanges,:)=1;
    UNIT_STATUS_ENFORCED_OFF_VAL(interchanges,:)=1;
end

UNIT_STATUS_ENFORCED_ON.name = 'UNIT_STATUS_ENFORCED_ON';
UNIT_STATUS_ENFORCED_ON.val = UNIT_STATUS_ENFORCED_ON_VAL;
UNIT_STATUS_ENFORCED_ON.uels = {GEN_VAL' INTERVAL_VAL'};
UNIT_STATUS_ENFORCED_ON.form = 'full';
UNIT_STATUS_ENFORCED_ON.type = 'parameter';

UNIT_STATUS_ENFORCED_OFF.name = 'UNIT_STATUS_ENFORCED_OFF';
UNIT_STATUS_ENFORCED_OFF.val = UNIT_STATUS_ENFORCED_OFF_VAL;
UNIT_STATUS_ENFORCED_OFF.uels = {GEN_VAL' INTERVAL_VAL'};
UNIT_STATUS_ENFORCED_OFF.form = 'full';
UNIT_STATUS_ENFORCED_OFF.type = 'parameter';

if Solving_Initial_Models == 1
    GEN_FORCED_OUT.val = zeros(ngen,1);
else
    GEN_FORCED_OUT.val = GEN_FORCED_OUT_VAL;
end
GEN_FORCED_OUT.name = 'GEN_FORCED_OUT';
GEN_FORCED_OUT.uels = {GEN_VAL'};        
GEN_FORCED_OUT.form = 'full';
GEN_FORCED_OUT.type = 'parameter';

PUMPING_ENFORCED_ON.name = 'PUMPING_ENFORCED_ON';
PUMPING_ENFORCED_ON.val = PUMPING_ENFORCED_ON_VAL;
PUMPING_ENFORCED_ON.uels = {GEN_VAL' INTERVAL_VAL'};
PUMPING_ENFORCED_ON.form = 'full';
PUMPING_ENFORCED_ON.type = 'parameter';

PUMPING_ENFORCED_OFF.name = 'PUMPING_ENFORCED_OFF';
PUMPING_ENFORCED_OFF.val = PUMPING_ENFORCED_OFF_VAL;
PUMPING_ENFORCED_OFF.uels = {GEN_VAL' INTERVAL_VAL'};
PUMPING_ENFORCED_OFF.form = 'full';
PUMPING_ENFORCED_OFF.type = 'parameter';

STARTUP_PERIOD.name = 'STARTUP_PERIOD';
STARTUP_PERIOD.val = STARTUP_PERIOD_VAL;
STARTUP_PERIOD.uels ={GEN_VAL'};
STARTUP_PERIOD.form = 'full';
STARTUP_PERIOD.type = 'parameter';

SHUTDOWN_PERIOD.name = 'SHUTDOWN_PERIOD';
SHUTDOWN_PERIOD.val = SHUTDOWN_PERIOD_VAL;
SHUTDOWN_PERIOD.uels ={GEN_VAL'};
SHUTDOWN_PERIOD.form = 'full';
SHUTDOWN_PERIOD.type = 'parameter';

PREVIOUS_UNIT_STARTUP.name = 'PREVIOUS_UNIT_STARTUP';
PREVIOUS_UNIT_STARTUP.val = PREVIOUS_UNIT_STARTUP_VAL;
PREVIOUS_UNIT_STARTUP.uels ={GEN_VAL'};
PREVIOUS_UNIT_STARTUP.form = 'full';
PREVIOUS_UNIT_STARTUP.type = 'parameter';

INTERVALS_STARTED_AGO.name = 'INTERVALS_STARTED_AGO';
INTERVALS_STARTED_AGO.val = INTERVALS_STARTED_AGO_VAL;
INTERVALS_STARTED_AGO.uels ={GEN_VAL'};
INTERVALS_STARTED_AGO.form = 'full';
INTERVALS_STARTED_AGO.type = 'parameter';

PUMPUP_PERIOD.name = 'PUMPUP_PERIOD';
PUMPUP_PERIOD.val = PUMPUP_PERIOD_VAL;
PUMPUP_PERIOD.uels ={STORAGE_UNITS'};
PUMPUP_PERIOD.form = 'full';
PUMPUP_PERIOD.type = 'parameter';

PUMPDOWN_PERIOD.name = 'PUMPDOWN_PERIOD';
PUMPDOWN_PERIOD.val = PUMPDOWN_PERIOD_VAL;
PUMPDOWN_PERIOD.uels ={STORAGE_UNITS'};
PUMPDOWN_PERIOD.form = 'full';
PUMPDOWN_PERIOD.type = 'parameter';

PREVIOUS_UNIT_PUMPUP.name = 'PREVIOUS_UNIT_PUMPUP';
PREVIOUS_UNIT_PUMPUP.val = PREVIOUS_UNIT_PUMPUP_VAL;
PREVIOUS_UNIT_PUMPUP.uels ={GEN_VAL'};
PREVIOUS_UNIT_PUMPUP.form = 'full';
PREVIOUS_UNIT_PUMPUP.type = 'parameter';

INTERVALS_PUMPUP_AGO.name = 'INTERVALS_PUMPUP_AGO';
INTERVALS_PUMPUP_AGO.val = INTERVALS_PUMPUP_AGO_VAL;
INTERVALS_PUMPUP_AGO.uels ={STORAGE_UNITS'};
INTERVALS_PUMPUP_AGO.form = 'full';
INTERVALS_PUMPUP_AGO.type = 'parameter';

ACTUAL_GEN_OUTPUT.name = 'ACTUAL_GEN_OUTPUT';
ACTUAL_GEN_OUTPUT_VAL(ACTUAL_GEN_OUTPUT_VAL~=0)=ACTUAL_GEN_OUTPUT_VAL(ACTUAL_GEN_OUTPUT_VAL~=0)+eps;
ACTUAL_GEN_OUTPUT.val = ACTUAL_GEN_OUTPUT_VAL;
ACTUAL_GEN_OUTPUT.uels ={GEN_VAL'};
ACTUAL_GEN_OUTPUT.form = 'full';
ACTUAL_GEN_OUTPUT.type = 'parameter';

LAST_GEN_SCHEDULE.name = 'LAST_GEN_SCHEDULE';
LAST_GEN_SCHEDULE_VAL(LAST_GEN_SCHEDULE_VAL~=0)=LAST_GEN_SCHEDULE_VAL(LAST_GEN_SCHEDULE_VAL~=0)+eps;
LAST_GEN_SCHEDULE.val = LAST_GEN_SCHEDULE_VAL;
LAST_GEN_SCHEDULE.uels ={GEN_VAL'};
LAST_GEN_SCHEDULE.form = 'full';
LAST_GEN_SCHEDULE.type = 'parameter';

RAMP_SLACK_UP.name = 'RAMP_SLACK_UP';
RAMP_SLACK_UP.val = RAMP_SLACK_UP_VAL;
RAMP_SLACK_UP.uels ={GEN_VAL'};
RAMP_SLACK_UP.form = 'full';
RAMP_SLACK_UP.type = 'parameter';

RAMP_SLACK_DOWN.name = 'RAMP_SLACK_DOWN';
RAMP_SLACK_DOWN.val = RAMP_SLACK_DOWN_VAL;
RAMP_SLACK_DOWN.uels ={GEN_VAL'};
RAMP_SLACK_DOWN.form = 'full';
RAMP_SLACK_DOWN.type = 'parameter';

LAST_STATUS.name = 'LAST_STATUS';
LAST_STATUS.val = LAST_STATUS_VAL;
LAST_STATUS.uels = {GEN_VAL'};
LAST_STATUS.form = 'full';
LAST_STATUS.type = 'parameter';

LAST_STATUS_ACTUAL.name = 'LAST_STATUS_ACTUAL';
LAST_STATUS_ACTUAL.val = LAST_STATUS_ACTUAL_VAL;
LAST_STATUS_ACTUAL.uels = {GEN_VAL'};
LAST_STATUS_ACTUAL.form = 'full';
LAST_STATUS_ACTUAL.type = 'parameter';

ACTUAL_PUMP_OUTPUT.name = 'ACTUAL_PUMP_OUTPUT';
ACTUAL_PUMP_OUTPUT.val = ACTUAL_PUMP_OUTPUT_VAL;
ACTUAL_PUMP_OUTPUT.uels ={STORAGE_UNITS'};
ACTUAL_PUMP_OUTPUT.form = 'full';
ACTUAL_PUMP_OUTPUT.type = 'parameter';

LAST_PUMP_SCHEDULE.name = 'LAST_PUMP_SCHEDULE';
LAST_PUMP_SCHEDULE.val = LAST_PUMP_SCHEDULE_VAL;
LAST_PUMP_SCHEDULE.uels ={STORAGE_UNITS'};
LAST_PUMP_SCHEDULE.form = 'full';
LAST_PUMP_SCHEDULE.type = 'parameter';

LAST_PUMPSTATUS.name = 'LAST_PUMPSTATUS';
LAST_PUMPSTATUS.val = LAST_PUMPSTATUS_VAL;
LAST_PUMPSTATUS.uels = {STORAGE_UNITS'};
LAST_PUMPSTATUS.form = 'full';
LAST_PUMPSTATUS.type = 'parameter';

LAST_PUMPSTATUS_ACTUAL.name = 'LAST_PUMPSTATUS_ACTUAL';
LAST_PUMPSTATUS_ACTUAL.val = LAST_PUMPSTATUS_ACTUAL_VAL;
LAST_PUMPSTATUS_ACTUAL.uels = {STORAGE_UNITS'};
LAST_PUMPSTATUS_ACTUAL.form = 'full';
LAST_PUMPSTATUS_ACTUAL.type = 'parameter';

END_STORAGE_PENALTY_PLUS_PRICE.form = 'full';
END_STORAGE_PENALTY_PLUS_PRICE.type = 'parameter';
END_STORAGE_PENALTY_PLUS_PRICE.uels = {GEN_VAL'};
END_STORAGE_PENALTY_PLUS_PRICE.name = 'END_STORAGE_PENALTY_PLUS_PRICE';

END_STORAGE_PENALTY_MINUS_PRICE.form = 'full';
END_STORAGE_PENALTY_MINUS_PRICE.type = 'parameter';
END_STORAGE_PENALTY_MINUS_PRICE.uels = {GEN_VAL'};
END_STORAGE_PENALTY_MINUS_PRICE.name = 'END_STORAGE_PENALTY_MINUS_PRICE';

INITIAL_DISPATCH_SLACK_SET.val = [1;1];
INITIAL_DISPATCH_SLACK_SET.name = 'INITIAL_DISPATCH_SLACK_SET';
INITIAL_DISPATCH_SLACK_SET.form = 'full';
INITIAL_DISPATCH_SLACK_SET.uels = {'IGNORE_ACTUAL' 'IGNORE_BP'};
INITIAL_DISPATCH_SLACK_SET.type = 'set';

%This is a gams parameter to avoid using the time 0 ramp constraints.
if Solving_Initial_Models == 1
    INITIAL_DISPATCH_SLACK.val = [1;1] ; 
else
    INITIAL_DISPATCH_SLACK.val = [0;0] ; 
end;
INITIAL_DISPATCH_SLACK.name = 'INITIAL_DISPATCH_SLACK';
INITIAL_DISPATCH_SLACK.form = 'full';
INITIAL_DISPATCH_SLACK.uels = INITIAL_DISPATCH_SLACK_SET.uels;
INITIAL_DISPATCH_SLACK.type = 'parameter';

clear BUS_DELIVERY_FACTORS GEN_DELIVERY_FACTORS;

GEN_DELIVERY_FACTORS.val=RTC_GEN_DELIVERY_FACTORS_VAL(:,1:H);
GEN_DELIVERY_FACTORS.name='GEN_DELIVERY_FACTORS';
GEN_DELIVERY_FACTORS.form='full';
GEN_DELIVERY_FACTORS.type='parameter';
GEN_DELIVERY_FACTORS.uels={GEN_VAL' INTERVAL_VAL'};

BUS_DELIVERY_FACTORS.val=RTC_BUS_DELIVERY_FACTORS_VAL(:,1:H);
BUS_DELIVERY_FACTORS.name='BUS_DELIVERY_FACTORS';
BUS_DELIVERY_FACTORS.form='full';
BUS_DELIVERY_FACTORS.type='parameter';
BUS_DELIVERY_FACTORS.uels={BUS_VAL' INTERVAL_VAL'};

if Solving_Initial_Models == 1
    LOSS_BIAS.val = 0;
else
    LOSS_BIAS.val = storelosses(max(1,AGC_interval_index-1),1)-abs(RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index-1,2));
end
LOSS_BIAS.name = 'LOSS_BIAS';
LOSS_BIAS.form = 'full';
LOSS_BIAS.uels = cell(1,0);
LOSS_BIAS.type = 'parameter';

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


sttemp=ACTUAL_GEN_OUTPUT.val<eps&LAST_GEN_SCHEDULE.val>=eps;
UNIT_STARTUP_ACTUAL.val=zeros(ngen,1);
UNIT_STARTUP_ACTUAL.name='UNIT_STARTUP_ACTUAL';
UNIT_STARTUP_ACTUAL.form='full';
UNIT_STARTUP_ACTUAL.type='parameter';
UNIT_STARTUP_ACTUAL.uels={GEN_VAL'};
UNIT_STARTUP_ACTUAL.val(sttemp)=1;
sttemp=ACTUAL_PUMP_OUTPUT.val<eps & LAST_PUMP_SCHEDULE.val>=eps;
UNIT_PUMPUP_ACTUAL.val=zeros(nESR,1);
UNIT_PUMPUP_ACTUAL.name='UNIT_PUMPUP_ACTUAL';
UNIT_PUMPUP_ACTUAL.form='full';
UNIT_PUMPUP_ACTUAL.type='parameter';
UNIT_PUMPUP_ACTUAL.uels={STORAGE_UNITS'};
UNIT_PUMPUP_ACTUAL.val(sttemp)=1;

LAST_STARTUP.name='LAST_STARTUP';
LAST_STARTUP.form='full';
LAST_STARTUP.type='parameter';
LAST_STARTUP.uels={GEN_VAL'};
LAST_STARTUP.val=max(zeros(ngen,1),LAST_STATUS.val-LAST_STATUS_ACTUAL.val);
LAST_SHUTDOWN.name='LAST_SHUTDOWN';
LAST_SHUTDOWN.form='full';
LAST_SHUTDOWN.type='parameter';
LAST_SHUTDOWN.uels={GEN_VAL'};
LAST_SHUTDOWN.val=max(zeros(ngen,1),LAST_STATUS_ACTUAL.val-LAST_STATUS.val);

gt1=GENVALUE.val(:,pucost);
gt2=GENVALUE.val(:,gen_type);
cond1=gt1==1;
cond2=gt2==7|gt2==10|gt2==16;
cond3=cond1&cond2;
if isempty(VG_FORECAST.val)
    cond4=zeros(ngen,1);
else
    cond4=(VG_FORECAST.val(1,:)<1)';
end;
cond5=cond4&cond3;
offset_temp1=max(zeros(ngen,1),LAST_GEN_SCHEDULE.val-GENVALUE.val(:,ramp_rate).*IRTC);
offset_temp2=max(offset_temp1,ACTUAL_GEN_OUTPUT.val-GENVALUE.val(:,ramp_rate).*(IRTC+PRTC));
offset_temp2(~cond3)=0;
offset_temp2(~cond5)=0;
PUCOST_BLOCK_OFFSET.name='PUCOST_BLOCK_OFFSET';
PUCOST_BLOCK_OFFSET.form='full';
PUCOST_BLOCK_OFFSET.type='parameter';
PUCOST_BLOCK_OFFSET.uels={GEN_VAL'};
PUCOST_BLOCK_OFFSET.val=offset_temp2;

GENVALUE.val=GENVALUE_VAL;
STORAGEVALUE.val=STORAGEVALUE_VAL;
BRANCHDATA.val=BRANCHDATA_VAL;
RESERVEVALUE.val=RESERVEVALUE_VAL;
SYSTEMVALUE.val=SYSTEMVALUE_VAL;
