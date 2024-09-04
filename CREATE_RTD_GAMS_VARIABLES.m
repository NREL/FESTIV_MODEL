% Create GAMS variables for RTSCED model solved

INTERVAL.name = 'INTERVAL';
INTERVAL_VAL = {'1'};
for t=2:HRTD
    INTERVAL_VAL = [INTERVAL_VAL; num2str(t)];
end
INTERVAL.uels = INTERVAL_VAL';
INTERVAL.val = ones(HRTD,1);
INTERVAL.form = 'full';

LOAD.val = LOAD_VAL;
LOAD.name = 'LOAD';
LOAD.uels = INTERVAL_VAL';
LOAD.form = 'full';
LOAD.type = 'parameter';
RTD_LOAD = LOAD;

VG_FORECAST.name = 'VG_FORECAST';
VG_FORECAST.val = VG_FORECAST_VAL;
VG_FORECAST.uels = {INTERVAL_VAL' GEN_VAL'};
VG_FORECAST.form = 'full';
VG_FORECAST.type = 'parameter';

RESERVELEVEL.val = RESERVELEVEL_VAL;
RESERVELEVEL.name = 'RESERVELEVEL';
RESERVELEVEL.uels = {INTERVAL_VAL' RTD_RESERVE_FIELD(3:end)};
RESERVELEVEL.form = 'full';
RESERVELEVEL.type = 'parameter';

NRTDINTERVAL.val = HRTD;
NRTDINTERVAL.name = 'NUMINTERVAL';
NRTDINTERVAL.form = 'full';
NRTDINTERVAL.uels = cell(1,0);
NRTDINTERVAL.type = 'parameter';

RTDINTERVAL_LENGTH.val = IRTD/60;
RTDINTERVAL_LENGTH.name = 'INTERVAL_LENGTH';
RTDINTERVAL_LENGTH.form = 'full';
RTDINTERVAL_LENGTH.uels = cell(1,0);
RTDINTERVAL_LENGTH.type = 'parameter';

RTDINTERVAL_ADVISORY_LENGTH.val = IRTDADV/60;
RTDINTERVAL_ADVISORY_LENGTH.name = 'INTERVAL_ADVISORY_LENGTH';
RTDINTERVAL_ADVISORY_LENGTH.form = 'full';
RTDINTERVAL_ADVISORY_LENGTH.uels = cell(1,0);
RTDINTERVAL_ADVISORY_LENGTH.type = 'parameter';

RTDINTERVAL_UPDATE.val = tRTD/60;
RTDINTERVAL_UPDATE.name = 'INTERVAL_UPDATE';
RTDINTERVAL_UPDATE.form = 'full';
RTDINTERVAL_UPDATE.uels = cell(1,0);
RTDINTERVAL_UPDATE.type = 'parameter';

if Solving_Initial_Models == 1
    RTD_PROCESS_TIME.val = IDAC-IRTD/60;
else
    RTD_PROCESS_TIME.val = PRTD/60;
end
RTD_PROCESS_TIME.name = 'PROCESS_TIME';
RTD_PROCESS_TIME.form = 'full';
RTD_PROCESS_TIME.uels = cell(1,0);
RTD_PROCESS_TIME.type = 'parameter';

INTERVAL_MINUTES.name = 'INTERVAL_MINUTES';
INTERVAL_MINUTES.val = INTERVAL_MINUTES_VAL;
INTERVAL_MINUTES.uels = {INTERVAL_VAL'};
INTERVAL_MINUTES.form = 'full';
INTERVAL_MINUTES.type = 'parameter';

UNIT_STATUS.name = 'UNIT_STATUS';
UNIT_STATUS.val = UNIT_STATUS_VAL;
UNIT_STATUS.uels = {GEN_VAL' INTERVAL_VAL'};
UNIT_STATUS.form = 'full';
UNIT_STATUS.type = 'parameter';

if Solving_Initial_Models == 1
    GEN_FORCED_OUT.val = zeros(ngen,1);
else
    GEN_FORCED_OUT.val = GEN_FORCED_OUT_VAL;
end
GEN_FORCED_OUT.name = 'GEN_FORCED_OUT';
GEN_FORCED_OUT.uels = {GEN_VAL'};        
GEN_FORCED_OUT.form = 'full';
GEN_FORCED_OUT.type = 'parameter';

UNIT_STARTINGUP.name = 'UNIT_STARTINGUP';
UNIT_STARTINGUP.val = UNIT_STARTINGUP_VAL;
UNIT_STARTINGUP.uels = {GEN_VAL' INTERVAL_VAL' };
UNIT_STARTINGUP.form = 'full';
UNIT_STARTINGUP.type = 'parameter';

if Solving_Initial_Models == 1
%     UNIT_STARTUPMINGENHELP.val = zeros(ngen,HRTD);
    UNIT_STARTUPMINGENHELP.val = max(0,UNIT_STARTUPMINGENHELP_VAL-repmat((ones(ngen,1).*IRTD./60./GENVALUE.val(:,su_time)).*GENVALUE.val(:,min_gen),1,HRTD));
else
    UNIT_STARTUPMINGENHELP.val = UNIT_STARTUPMINGENHELP_VAL;
end
UNIT_STARTUPMINGENHELP.name = 'UNIT_STARTUPMINGENHELP';
UNIT_STARTUPMINGENHELP.uels = {GEN_VAL' INTERVAL_VAL'};
UNIT_STARTUPMINGENHELP.form = 'full';
UNIT_STARTUPMINGENHELP.type = 'parameter';

UNIT_SHUTTINGDOWN.name = 'UNIT_SHUTTINGDOWN';
UNIT_SHUTTINGDOWN.val = UNIT_SHUTTINGDOWN_VAL;
UNIT_SHUTTINGDOWN.uels = {GEN_VAL' INTERVAL_VAL'};
UNIT_SHUTTINGDOWN.form = 'full';
UNIT_SHUTTINGDOWN.type = 'parameter';

PUMPING.name = 'PUMPING';
PUMPING.val = PUMPING_VAL;
PUMPING.uels = {GEN_VAL' INTERVAL_VAL'};
PUMPING.form = 'full';
PUMPING.type = 'parameter';

UNIT_PUMPINGUP.name = 'UNIT_PUMPINGUP';
UNIT_PUMPINGUP.val = UNIT_PUMPINGUP_VAL;
UNIT_PUMPINGUP.uels = {STORAGE_UNITS' INTERVAL_VAL'};
UNIT_PUMPINGUP.form = 'full';
UNIT_PUMPINGUP.type = 'parameter';

if Solving_Initial_Models == 1
    UNIT_PUMPUPMINGENHELP.val = zeros(nESR,HRTD);
else
    UNIT_PUMPUPMINGENHELP.val = UNIT_PUMPUPMINGENHELP_VAL;
end
UNIT_PUMPUPMINGENHELP.name = 'UNIT_PUMPUPMINGENHELP';
UNIT_PUMPUPMINGENHELP.uels = {STORAGE_UNITS' INTERVAL_VAL'};
UNIT_PUMPUPMINGENHELP.form = 'full';
UNIT_PUMPUPMINGENHELP.type = 'parameter';

UNIT_PUMPINGDOWN.name = 'UNIT_PUMPINGDOWN';
UNIT_PUMPINGDOWN.val = UNIT_PUMPINGDOWN_VAL;
UNIT_PUMPINGDOWN.uels = {STORAGE_UNITS' INTERVAL_VAL'};
UNIT_PUMPINGDOWN.form = 'full';
UNIT_PUMPINGDOWN.type = 'parameter';

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
LAST_STATUS.uels ={GEN_VAL'};
LAST_STATUS.form = 'full';
LAST_STATUS.type = 'parameter';

LAST_STATUS_ACTUAL.name = 'LAST_STATUS_ACTUAL';
LAST_STATUS_ACTUAL.val = LAST_STATUS_ACTUAL_VAL;
LAST_STATUS_ACTUAL.uels ={GEN_VAL'};
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
LAST_PUMPSTATUS.uels ={STORAGE_UNITS'};
LAST_PUMPSTATUS.form = 'full';
LAST_PUMPSTATUS.type = 'parameter';

LAST_PUMPSTATUS_ACTUAL.name = 'LAST_PUMPSTATUS_ACTUAL';
LAST_PUMPSTATUS_ACTUAL.val = LAST_PUMPSTATUS_ACTUAL_VAL;
LAST_PUMPSTATUS_ACTUAL.uels ={STORAGE_UNITS'};
LAST_PUMPSTATUS_ACTUAL.form = 'full';
LAST_PUMPSTATUS_ACTUAL.type = 'parameter';

STARTUP_PERIOD.name = 'STARTUP_PERIOD';
STARTUP_PERIOD.val = STARTUP_PERIOD_VAL;
STARTUP_PERIOD.uels ={GEN_VAL'};
STARTUP_PERIOD.form = 'full';
STARTUP_PERIOD.type = 'parameter';

INITIAL_DISPATCH_SLACK.val = INITIAL_DISPATCH_SLACK_VAL;
INITIAL_DISPATCH_SLACK.name = 'INITIAL_DISPATCH_SLACK';
INITIAL_DISPATCH_SLACK.form = 'full';
INITIAL_DISPATCH_SLACK.uels = INITIAL_DISPATCH_SLACK_SET.uels;
INITIAL_DISPATCH_SLACK.type = 'parameter';

clear BUS_DELIVERY_FACTORS GEN_DELIVERY_FACTORS;

GEN_DELIVERY_FACTORS.val=RTD_GEN_DELIVERY_FACTORS_VAL;
GEN_DELIVERY_FACTORS.name='GEN_DELIVERY_FACTORS';
GEN_DELIVERY_FACTORS.form='full';
GEN_DELIVERY_FACTORS.type='parameter';
GEN_DELIVERY_FACTORS.uels={GEN_VAL' INTERVAL_VAL'};

BUS_DELIVERY_FACTORS.val=RTD_BUS_DELIVERY_FACTORS_VAL;
BUS_DELIVERY_FACTORS.name='BUS_DELIVERY_FACTORS';
BUS_DELIVERY_FACTORS.form='full';
BUS_DELIVERY_FACTORS.type='parameter';
BUS_DELIVERY_FACTORS.uels={BUS_VAL' INTERVAL_VAL'};

if Solving_Initial_Models == 1 || time <= eps
    %     LOSS_BIAS.val = 0;
    % transmission losses = flow^2 * R
    load_injection=-1*fullLoadDist*ACTUAL_LOAD_FULL(1,2);
    if ~exist('losses_temp','var')
        geninjection_temp=zeros(nbus,ngen);temp2=sortrows(GENBUS_CALCS_VAL,1);
        for i=1:ngen
            geninjection_temp(temp2(find(temp2(:,1)==i),2),i)=temp2(find(temp2(:,1)==i),3);
        end
    end
    bus_injection=geninjection_temp*RTSCUCBINDINGSCHEDULE(1,2:end)' + load_injection;
    ACTUAL_LF = (PTDF_VAL*bus_injection);
    LOSS_BIAS.val=sum(ACTUAL_LF(:,1).*ACTUAL_LF(:,1).*BRANCHDATA_VAL(:,resistance))./SYSTEMVALUE_VAL(mva_pu,1);
else
    LOSS_BIAS.val = storelosses(max(1,AGC_interval_index-1),1)-abs(RTSCEDMARGINALLOSS(RTSCED_binding_interval_index-1,2));
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

UNIT_SHUTTINGDOWN_ACTUAL.name='UNIT_SHUTTINGDOWN_ACTUAL';
UNIT_SHUTTINGDOWN_ACTUAL.form='full';
UNIT_SHUTTINGDOWN_ACTUAL.type='parameter';
UNIT_SHUTTINGDOWN_ACTUAL.uels={GEN_VAL'};
UNIT_SHUTTINGDOWN_ACTUAL.val=UNIT_SHUTTINGDOWN_ACTUAL_VAL;
UNIT_PUMPINGDOWN_ACTUAL.name='UNIT_PUMPINGDOWN_ACTUAL';
UNIT_PUMPINGDOWN_ACTUAL.form='full';
UNIT_PUMPINGDOWN_ACTUAL.type='parameter';
UNIT_PUMPINGDOWN_ACTUAL.uels={STORAGE_UNITS'};
UNIT_PUMPINGDOWN_ACTUAL.val=UNIT_PUMPINGDOWN_ACTUAL_VAL;

UNIT_STARTINGUP_ACTUAL.val=UNIT_STARTINGUP_ACTUAL_VAL;
UNIT_STARTINGUP_ACTUAL.name='UNIT_STARTINGUP_ACTUAL';
UNIT_STARTINGUP_ACTUAL.form='full';
UNIT_STARTINGUP_ACTUAL.type='parameter';
UNIT_STARTINGUP_ACTUAL.uels={GEN_VAL'};
UNIT_PUMPINGUP_ACTUAL.val=UNIT_PUMPINGUP_ACTUAL_VAL;
UNIT_PUMPINGUP_ACTUAL.name='UNIT_PUMPINGUP_ACTUAL';
UNIT_PUMPINGUP_ACTUAL.form='full';
UNIT_PUMPINGUP_ACTUAL.type='parameter';
UNIT_PUMPINGUP_ACTUAL.uels={STORAGE_UNITS'};

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
offset_temp1=max(zeros(ngen,1),LAST_GEN_SCHEDULE.val-GENVALUE.val(:,ramp_rate).*IRTD);
offset_temp2=max(offset_temp1,ACTUAL_GEN_OUTPUT.val-GENVALUE.val(:,ramp_rate).*(IRTD+PRTD));
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

