function[PRODCOST,GENSCHEDULE,LMP,UNITSTATUS,UNITSTARTUP,UNITSHUTDOWN,GENRESERVESCHEDULE,RCP,LOADDIST,...
    GENVALUE,STORAGEVALUE,VGCURTAILMENT,LOAD,RESERVEVALUE,RESERVELEVEL,BRANCHDATA,BLOCKCOST,BLOCKCAP,BPRIME,BGAMMA,LOSSLOAD,INSUFFRESERVE,...
    GEN,BUS,INTERVAL,BRANCH,RESERVETYPE,SLACKBUS,GENBUS,BRANCHBUS,PUMPSCHEDULE,STORAGELEVEL,PUMPING] ...
    = getgamsdata(inputfile,MODEL,CONTINGENCY,GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM)


PRODCOST=[];GENSCHEDULE=[];LMP=[];UNITSTATUS=[];UNITSTARTUP=[];UNITSHUTDOWN=[];GENRESERVESCHEDULE=[];RCP=[];
LOADIST=[];GENVALUE=[];MVAPERUNIT=[];VGCURTAILMENT=[];RESERVEVALUE=[];BRANCHDATA=[];BLOCKCOST=[];BLOCKCAP=[];
BPRIME=[];BGAMMA=[];LOSSLOAD=[];PUMPSCHEDULE=[];STORAGELEVEL=[];PUMPING=[];LMP2=[];

GENVALUE=evalin('base','GENVALUE');
STORAGEVALUE=evalin('base','STORAGEVALUE');
BRANCHDATA=evalin('base','BRANCHDATA');
COST_CURVE=evalin('base','COST_CURVE');
PUMPEFFICIENCYVALUE=evalin('base','PUMPEFFICIENCYVALUE');
GENEFFICIENCYVALUE=evalin('base','GENEFFICIENCYVALUE');
DEFAULT_DATA=evalin('base','DEFAULT_DATA');
SYSTEMVALUE=evalin('base','SYSTEMVALUE');
INTERCHANGE=evalin('base','INTERCHANGE');
capacity=evalin('base','capacity');
min_gen=evalin('base','min_gen');
ramp_rate=evalin('base','ramp_rate');
initial_MW=evalin('base','initial_MW');
storage_max=evalin('base','storage_max');
initial_storage=evalin('base','initial_storage');
final_storage=evalin('base','final_storage');
max_pump=evalin('base','max_pump');
min_pump=evalin('base','min_pump');
pump_ramp_rate=evalin('base','pump_ramp_rate');
initial_pump_mw=evalin('base','initial_pump_mw');
line_rating=evalin('base','line_rating');
ste_rating=evalin('base','ste_rating');
mva_pu=evalin('base','mva_pu');
slack_bus=evalin('base','slack_bus');
LOAD2=evalin('base','LOAD');
RESERVELEVEL=evalin('base','RESERVELEVEL');
VG_FORECAST=evalin('base','VG_FORECAST');
LOSS_BIAS=evalin('base','LOSS_BIAS');

GENVALUE.val(:,capacity)=GENVALUE.val(:,capacity).*SYSTEMVALUE.val(mva_pu);
GENVALUE.val(:,min_gen)=GENVALUE.val(:,min_gen).*SYSTEMVALUE.val(mva_pu);
GENVALUE.val(:,ramp_rate)=GENVALUE.val(:,ramp_rate).*SYSTEMVALUE.val(mva_pu);
GENVALUE.val(:,initial_MW)=GENVALUE.val(:,initial_MW).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,storage_max)=STORAGEVALUE.val(:,storage_max).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,initial_storage)=STORAGEVALUE.val(:,initial_storage).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,final_storage)=STORAGEVALUE.val(:,final_storage).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,max_pump)=STORAGEVALUE.val(:,max_pump).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,min_pump)=STORAGEVALUE.val(:,min_pump).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,pump_ramp_rate)=STORAGEVALUE.val(:,pump_ramp_rate).*SYSTEMVALUE.val(mva_pu);
STORAGEVALUE.val(:,initial_pump_mw)=STORAGEVALUE.val(:,initial_pump_mw).*SYSTEMVALUE.val(mva_pu);
LOAD2.val=LOAD2.val.*SYSTEMVALUE.val(mva_pu);
RESERVELEVEL.val=RESERVELEVEL.val.*SYSTEMVALUE.val(mva_pu);
BRANCHDATA.val(:,line_rating)=BRANCHDATA.val(:,line_rating).*SYSTEMVALUE.val(mva_pu);
BRANCHDATA.val(:,ste_rating)=BRANCHDATA.val(:,ste_rating).*SYSTEMVALUE.val(mva_pu);
VG_FORECAST.val=VG_FORECAST.val.*SYSTEMVALUE.val(mva_pu);
INTERCHANGE.val=INTERCHANGE.val.*SYSTEMVALUE.val(mva_pu);
LOSS_BIAS.val=LOSS_BIAS.val.*SYSTEMVALUE.val(mva_pu);
COST_CURVE.val(:,[2 4 6 8])=COST_CURVE.val(:,[2 4 6 8]).*SYSTEMVALUE.val(mva_pu);
if ~isempty(PUMPEFFICIENCYVALUE.val)
    PUMPEFFICIENCYVALUE.val(:,[2 4 6])=PUMPEFFICIENCYVALUE.val(:,[2 4 6]).*SYSTEMVALUE.val(mva_pu);
    GENEFFICIENCYVALUE.val(:,[2 4 6])=GENEFFICIENCYVALUE.val(:,[2 4 6]).*SYSTEMVALUE.val(mva_pu);
end
DEFAULT_DATA.GENVALUE=GENVALUE;
DEFAULT_DATA.STORAGEVALUE=STORAGEVALUE;
DEFAULT_DATA.BRANCHDATA=BRANCHDATA;
DEFAULT_DATA.COST_CURVE=COST_CURVE;
DEFAULT_DATA.PUMPEFFICIENCYVALUE=PUMPEFFICIENCYVALUE;
DEFAULT_DATA.GENEFFICIENCYVALUE=GENEFFICIENCYVALUE;

assignin('base','LOAD',LOAD2);
assignin('base','GENVALUE',GENVALUE);
assignin('base','RESERVELEVEL',RESERVELEVEL);
assignin('base','VG_FORECAST',VG_FORECAST);
assignin('base','LOSS_BIAS',LOSS_BIAS);
assignin('base','INTERCHANGE',INTERCHANGE);
assignin('base','STORAGEVALUE',STORAGEVALUE);
assignin('base','DEFAULT_DATA',DEFAULT_DATA);
assignin('base','PUMPEFFICIENCYVALUE',PUMPEFFICIENCYVALUE);
assignin('base','GENEFFICIENCYVALUE',GENEFFICIENCYVALUE);
assignin('base','BRANCHDATA',BRANCHDATA);
assignin('base','COST_CURVE',COST_CURVE);

input1 = ['TEMP',filesep,inputfile];
% outputcostparam_gdx.name = 'OUTPUTCOSTPARAM';
% OUTPUTCOSTPARAM_TMP = rgdx(input1,outputcostparam_gdx);
gen_rgdx.name = 'GEN';
GENSET_TMP = rgdx(input1,gen_rgdx);
ALLSET = GENSET_TMP.uels{1,1};
interval_rgdx.name = 'INTERVAL';
INTERVALSET_TMP = rgdx(input1,interval_rgdx);
bus_rgdx.name = 'BUS';
BUSSET_TMP = rgdx(input1,bus_rgdx);
reservetype_rgdx.name = 'RESERVETYPE';
RESERVETYPESET_TMP = rgdx(input1,reservetype_rgdx);
genbus_rgdx.name = 'GENBUS';
GENBUSSET_TMP = rgdx(input1,genbus_rgdx);
branch_rgdx.name = 'BRANCH';
BRANCHSET_TMP = rgdx(input1,branch_rgdx);
block_rgdx.name = 'BLOCK';
BLOCKSET_TMP = rgdx(input1,block_rgdx);
branchbus_rgdx.name = 'BRANCHBUS';
BRANCHBUSSET_TMP = rgdx(input1,branchbus_rgdx);
slackbus_rgdx.name = 'SLACKBUS';
SLACKBUS_TMP = rgdx(input1,slackbus_rgdx);
ctgc_rgdx.name = 'CTGC_BRANCH';
ctgc_rgdx = rgdx(input1,ctgc_rgdx);






% outputcosts_rgdx.form = 'full';
% outputcosts_rgdx.name = 'OUTPUTCOSTS';
% outputcosts_rgdx.uels = {ALLSET(OUTPUTCOSTPARAM_TMP.val)};
% PRODCOST = rgdx(input1,outputcosts_rgdx);
genschedule_rgdx.form = 'full';
genschedule_rgdx.name = 'GEN_SCHEDULE';
genschedule_rgdx.uels = {GEN.uels INTERVAL.uels};
GENSCHEDULE = rgdx(input1,genschedule_rgdx);
GENSCHEDULE.val=GENSCHEDULE.val.*SYSTEMVALUE.val(mva_pu);
% lmp_rgdx.form = 'full';
% lmp_rgdx.name = 'LMP';
% lmp_rgdx.uels = {BUS.uels INTERVAL.uels};
% LMP = rgdx(input1,lmp_rgdx);
if strcmp(MODEL,'RTSCED')
    UNITSTARTUP = 0;
    UNITSHUTDOWN = 0;
    UNITSTATUS = 0;
    PUMPING = 0;
else
    unit_startup_rgdx.form = 'full';
    unit_startup_rgdx.name = 'UNIT_STARTUP';
    unit_startup_rgdx.uels = {GEN.uels INTERVAL.uels};
    UNITSTARTUP = rgdx(input1,unit_startup_rgdx);
    unit_shutdown_rgdx.form = 'full';
    unit_shutdown_rgdx.name = 'UNIT_SHUTDOWN';
    unit_shutdown_rgdx.uels = {GEN.uels INTERVAL.uels};
    UNITSHUTDOWN = rgdx(input1,unit_shutdown_rgdx);
    unit_status_rgdx.form = 'full';
    unit_status_rgdx.name = 'UNIT_STATUS';
    unit_status_rgdx.uels = {GEN.uels INTERVAL.uels};
    UNITSTATUS = rgdx(input1,unit_status_rgdx);
    pumping_rgdx.form = 'full';
    pumping_rgdx.name = 'PUMPING';
    pumping_rgdx.uels = {GEN.uels INTERVAL.uels};
    PUMPING = rgdx(input1,pumping_rgdx);
end;
genreserveschedule_rgdx.form = 'full';
genreserveschedule_rgdx.name = 'GEN_RESERVE_SCHEDULE';
genreserveschedule_rgdx.uels = {GEN.uels INTERVAL.uels RESERVETYPE.uels};
GENRESERVESCHEDULE = rgdx(input1,genreserveschedule_rgdx);
GENRESERVESCHEDULE.val=GENRESERVESCHEDULE.val.*SYSTEMVALUE.val(mva_pu);
% rcp_rgdx.form = 'full';
% rcp_rgdx.name = 'RCP';
% rcp_rgdx.uels = {RESERVETYPE.uels INTERVAL.uels};
% RCP = rgdx(input1,rcp_rgdx);
loaddist_rgdx.form = 'full';
loaddist_rgdx.name = 'LOAD_DIST';
loaddist_rgdx.uels = {BUS.uels};
LOADDIST = rgdx(input1,loaddist_rgdx);
load_rgdx.form = 'full';
load_rgdx.name = 'LOAD';
load_rgdx.uels = {INTERVAL.uels};
LOAD = rgdx(input1,load_rgdx);
LOAD.val=LOAD.val.*SYSTEMVALUE.val(mva_pu);
pumpschedule_rgdx.form = 'full';
pumpschedule_rgdx.name = 'PUMP_SCHEDULE';
pumpschedule_rgdx.uels = {GEN.uels INTERVAL.uels};
PUMPSCHEDULE = rgdx(input1,pumpschedule_rgdx);
PUMPSCHEDULE.val=PUMPSCHEDULE.val.*SYSTEMVALUE.val(mva_pu);
storagelevel_rgdx.form = 'full';
storagelevel_rgdx.name = 'STORAGE_LEVEL';
storagelevel_rgdx.uels = {GEN.uels INTERVAL.uels};
STORAGELEVEL = rgdx(input1,storagelevel_rgdx);
STORAGELEVEL.val=STORAGELEVEL.val.*SYSTEMVALUE.val(mva_pu);

%{
$set matout2 "'DASCUCOUTPUTSOL2.gdx',,,,,,QSC10,QSC30,
BPRIME_CTGC,,,,VG_FORECAST,STORAGE_LEVEL,PUMP_SCHEDULE,,
NC_STORAGE_GEN_SCHEDULE,PUMPING,RESERVE_COST";
%}

vgcurtailment_rgdx.form = 'full';
vgcurtailment_rgdx.name = 'VG_CURTAILMENT';
vgcurtailment_rgdx.uels = {GEN.uels INTERVAL.uels};
VGCURTAILMENT = rgdx(input1,vgcurtailment_rgdx);
VGCURTAILMENT.val=VGCURTAILMENT.val.*SYSTEMVALUE.val(mva_pu);
reservevalue_rgdx.form = 'full';
reservevalue_rgdx.name = 'RESERVEVALUE';
reservevalue_rgdx.uels = {RESERVETYPE.uels RESERVEPARAM.uels};
RESERVEVALUE = rgdx(input1,reservevalue_rgdx);
reservelevel_rgdx.form = 'full';
reservelevel_rgdx.name = 'RESERVELEVEL';
reservelevel_rgdx.uels = {INTERVAL.uels RESERVETYPE.uels};
RESERVELEVEL = rgdx(input1,reservelevel_rgdx);
branchdata_rgdx.form = 'full';
branchdata_rgdx.name = 'BRANCHDATA';
branchdata_rgdx.uels = {BRANCH.uels BRANCHPARAM.uels};
%BRANCHDATA = rgdx(input1,branchdata_rgdx);
blockcost_rgdx.form = 'full';
blockcost_rgdx.name = 'BLOCK_COST';
blockcost_rgdx.uels = {GEN.uels ALLSET(BLOCKSET_TMP.val)};
BLOCKCOST = rgdx(input1,blockcost_rgdx);
blockcap_rgdx.form = 'full';
blockcap_rgdx.name = 'BLOCK_CAP';
blockcap_rgdx.uels = {GEN.uels ALLSET(BLOCKSET_TMP.val)};
BLOCKCAP = rgdx(input1,blockcap_rgdx);
BLOCKCAP.val=BLOCKCAP.val.*SYSTEMVALUE.val(mva_pu);
% if strcmp(MODEL,'DASCUC')
%     bprime_rgdx.form = 'full';
%     bprime_rgdx.name = 'BPRIME';
%     bprime_rgdx.uels = {BUS.uels BUS.uels};
%     BPRIME = rgdx(input1,bprime_rgdx);
%     bgamma_rgdx.form = 'full';
%     bgamma_rgdx.name = 'BGAMMA';
%     bgamma_rgdx.uels = {BUS.uels BRANCH.uels};
%     BGAMMA = rgdx(input1,bgamma_rgdx);
% end;
lossload_rgdx.form = 'full';
lossload_rgdx.name = 'LOSS_LOAD';
lossload_rgdx.uels = {INTERVAL.uels};
LOSSLOAD = rgdx(input1,lossload_rgdx);
LOSSLOAD.val=LOSSLOAD.val.*SYSTEMVALUE.val(mva_pu);
insuffreserve_rgdx.form = 'full';
insuffreserve_rgdx.name = 'INSUFFICIENT_RESERVE';
insuffreserve_rgdx.uels = {INTERVAL.uels RESERVETYPE.uels};
INSUFFRESERVE = rgdx(input1,insuffreserve_rgdx);
INSUFFRESERVE.val=INSUFFRESERVE.val.*SYSTEMVALUE.val(mva_pu);
genvalue_rgdx.form = 'full';
genvalue_rgdx.name = 'GENVALUE';
genvalue_rgdx.uels = {GEN.uels GENPARAM.uels};
%GENVALUE = rgdx(input1,genvalue_rgdx);
storagevalue_rgdx.form = 'full';
storagevalue_rgdx.name = 'STORAGEVALUE';
storagevalue_rgdx.uels = {GEN.uels STORAGEPARAM.uels};
%STORAGEVALUE = rgdx(input1,storagevalue_rgdx);
%{
if strcmp(MODEL,'DASCUC')
    ENDSTORAGEPENALTYPLUS=[];
    ENDSTORAGEPENALTYMINUS=[];
else
    endstoragepenaltyplus_rgdx.form = 'full';
    endstoragepenaltyplus_rgdx.name = 'END_STORAGE_PENALTY_PLUS';
    endstoragepenaltyplus_rgdx.uels = {GEN.uels};
    ENDSTORAGEPENALTYPLUS = rgdx(input1,endstoragepenaltyplus_rgdx);
    endstoragepenaltyminus_rgdx.form = 'full';
    endstoragepenaltyminus_rgdx.name = 'END_STORAGE_PENALTY_MINUS';
    endstoragepenaltyminus_rgdx.uels = {GEN.uels};
    ENDSTORAGEPENALTYMINUS = rgdx(input1,endstoragepenaltyminus_rgdx);
end;
%}

TMP = {ALLSET(GENSET_TMP.val)};
GEN.val = TMP{1,1}';
GEN.name = GENSET_TMP.name;
TMP = {ALLSET(INTERVALSET_TMP.val)};
INTERVAL.val = TMP{1,1}';
INTERVAL.name = INTERVALSET_TMP.name;
TMP = {ALLSET(BUSSET_TMP.val)};
BUS.val = TMP{1,1}';
BUS.name = BUSSET_TMP.name;
TMP = {ALLSET(RESERVETYPESET_TMP.val)};
RESERVETYPE.val = TMP{1,1}';
RESERVETYPE.name = RESERVETYPESET_TMP.name;

TMP = {ALLSET(SLACKBUS_TMP.val)};
SLACKBUS.val = TMP{1,1}';
SLACKBUS.name = SLACKBUS_TMP.name;
TMP = {ALLSET(BRANCHSET_TMP.val)};
BRANCH.val = TMP{1,1}';
BRANCH.name = BRANCHSET_TMP.name;

ng = size(GEN.uels,2);
nb = size(BUS.uels,2);
for i=1:ng
    for i2=1:ng
        if strcmp(GEN.uels(1,i2),ALLSET{GENBUSSET_TMP.val(i,2)})
            GENBUS.val(i,2) = i2;
        end;
    end;
    for n=1:nb
        if strcmp(BUS.uels(1,n),ALLSET{GENBUSSET_TMP.val(i,1)})
            GENBUS.val(i,1) = n;
        end;
    end;
end;
GENBUS.name = GENBUSSET_TMP.name;

nl = size(BRANCH.uels,2);
for l=1:nl
    for l2=1:nl
        if strcmp(BRANCH.uels(1,l2),ALLSET{BRANCHBUSSET_TMP.val(l,1)})
            BRANCHBUS.val(l,1) = l2;
        end;
    end;
    for n=1:nb
        if strcmp(BUS.uels(1,n),ALLSET{BRANCHBUSSET_TMP.val(l,2)})
            BRANCHBUS.val(l,2) = n;
        end;
    end;
    for n=1:nb
        if strcmp(BUS.uels(1,n),ALLSET{BRANCHBUSSET_TMP.val(l,3)})
            BRANCHBUS.val(l,3) = n;
        end;
    end;
end;
BRANCHBUS.name = BRANCHBUSSET_TMP.name;

solvestatus_rgdx.name='MSS';
solvestatus_rgdx.form='full';
solvestatus=rgdx(input1,solvestatus_rgdx);
assignin('caller','modelSolveStatus',solvestatus.val);

numinfes_rgdx.name='INFEASIBILITIES';
numinfes_rgdx.form='full';
infeasibilities2=rgdx(input1,numinfes_rgdx);
assignin('caller','numberOfInfes',infeasibilities2.val);

solverstatus_rgdx.name='SS';
solverstatus_rgdx.form='full';
solverstatus=rgdx(input1,solverstatus_rgdx);
assignin('caller','solverStatus',solverstatus.val);

try
lineflow_rgdx.name = 'LINEFLOW';
lineflow_rgdx.form = 'full';
lineflow_rgdx.uels = {BRANCH.uels INTERVAL.uels};
lineflow=rgdx(input1,lineflow_rgdx);
assignin('caller','LINEFLOWS',lineflow.val.*SYSTEMVALUE.val(mva_pu));
catch
end

try
netenergy_rgdx.name = 'NET_ENERGY';
netenergy_rgdx.form = 'full';
netenergy_rgdx.uels = {BUS.uels INTERVAL.uels};
netenergy=rgdx(input1,netenergy_rgdx);
assignin('caller','NETENERGY',netenergy.val.*SYSTEMVALUE.val(mva_pu));
catch
end

try
    relativegap_rgdx.name='RG';
    relativegap_rgdx.form='full';
    relativegap=rgdx(input1,relativegap_rgdx);
    assignin('caller','relativeGap',relativegap.val);
catch
end;

try
    overgeneration_rgdx.name='ADDITIONAL_LOAD_SLACK';
    overgeneration_rgdx.form='full';
    overgeneration_rgdx.uels = {INTERVAL.uels};
    overgeneration=rgdx(input1,overgeneration_rgdx);
    assignin('caller','OVERGENERATION',overgeneration.val.*SYSTEMVALUE.val(mva_pu));
catch
end;

% try
%     MCC_rgdx.name='MCC';
%     MCC_rgdx.form='full';
%     MCC_rgdx.uels = {BUS.uels INTERVAL.uels};
%     MCC=rgdx(input1,MCC_rgdx);
%     assignin('caller','MCC',MCC.val);
% catch
% end;
% 
% try
%     MLC_rgdx.name='MLC';
%     MLC_rgdx.form='full';
%     MLC_rgdx.uels = {BUS.uels INTERVAL.uels};
%     MLC=rgdx(input1,MLC_rgdx);
%     assignin('caller','MLC',MLC.val);
% catch
% end;

test=evalin('caller','DASCUC_binding_interval_index');
if test == 1
    partf_rgdx.name = 'PARTICIPATION_FACTORS';
    partf_rgdx.form = 'full';
    partf_rgdx.uels = {BUS.uels GEN.uels};
    PARTF_TMP = rgdx(input1,partf_rgdx);
    i=1;
    while i<=size(PARTF_TMP.val,1)
        if sum(PARTF_TMP.val(i,:)) < 0.0001
            PARTF_TMP.val(i,:)=[];
            PARTF_TMP.uels{1, 1}=PARTF_TMP.uels{1, 1}(~strcmp(PARTF_TMP.uels{1, 1},PARTF_TMP.uels{1, 1}(1,i)));
            i=i-1;
        end
        i=i+1;
    end
    x=sort(PARTF_TMP.uels{1, 2});
    y=zeros(1,size(x,2));
    for i=1:size(x,2)
        for j=1:size(x,2)
            if strcmp(PARTF_TMP.uels{1, 2}(1,j),x(1,i))
                y(1,i)=j;
            end
        end
    end
    PARTF_TMP.uels{1, 2}=PARTF_TMP.uels{1, 2}(1,y);
    PARTF_TMP.val=PARTF_TMP.val(:,y);
    assignin('caller','PARTICIPATION_FACTORS',PARTF_TMP);
    GENBUS2.name='GENBUS';
    GENBUS2.form='full';
    GENBUS2.type='set';
    GENBUS2.uels=PARTF_TMP.uels;
    GENBUS2.val=double(PARTF_TMP.val~=0);
    assignin('caller','GENBUS2',GENBUS2);
end


if strcmp(MODEL,'DASCUC')
    HLMP=evalin('base','HDAC');
    ILMP=evalin('base','IDAC');
elseif strcmp(MODEL,'RTSCUC')
    HLMP=evalin('base','HRTC');
    ILMP=evalin('base','IRTC');
else
    HLMP=evalin('base','HRTD');
    ILMP=evalin('base','IRTD');
end

tetemp=(sum(GENSCHEDULE.val)'-sum(PUMPSCHEDULE.val)'-LOAD.val+LOSSLOAD.val-overgeneration.val.*SYSTEMVALUE.val(mva_pu)-LOSS_BIAS.val.*ones(HLMP,1))./SYSTEMVALUE.val(mva_pu);
assignin('caller','marginalLoss',tetemp);

BUS_DELIVERY_FACTORS=evalin('base','BUS_DELIVERY_FACTORS');
nbus=evalin('base','nbus');
nbranch=evalin('base','nbranch');
PTDF=evalin('base','PTDF');
LODF=evalin('base','LODF');
NETWORK_CHECK=evalin('base','NETWORK_CHECK');
CONTINGENCY_CHECK=evalin('base','CONTINGENCY_CHECK');

LMP_temp=zeros(HLMP,nbus);
MEC=zeros(HLMP,nbus);
MCC=zeros(HLMP,nbus);
MLC=zeros(HLMP,nbus);
MCC_CTGC=zeros(HLMP,nbus);

Q_LOAD_BALANCE_rgdx.form = 'full';
Q_LOAD_BALANCE_rgdx.name = 'Q_LOAD_BALANCE';
Q_LOAD_BALANCE_rgdx.field = 'm';
Q_LOAD_BALANCE_rgdx.uels = {INTERVAL.uels};
Q_LOAD_BALANCE = rgdx(input1,Q_LOAD_BALANCE_rgdx);

if strcmp(NETWORK_CHECK,'YES')
    Q_TRANSMISSION_CONSTRAINT1_rgdx.form = 'full';
    Q_TRANSMISSION_CONSTRAINT1_rgdx.name = 'Q_TRANSMISSION_CONSTRAINT1';
    Q_TRANSMISSION_CONSTRAINT1_rgdx.field = 'm';
    Q_TRANSMISSION_CONSTRAINT1_rgdx.uels = {BRANCH.uels INTERVAL.uels};
    Q_TRANSMISSION_CONSTRAINT1 = rgdx(input1,Q_TRANSMISSION_CONSTRAINT1_rgdx);
    Q_TRANSMISSION_CONSTRAINT2_rgdx.form = 'full';
    Q_TRANSMISSION_CONSTRAINT2_rgdx.name = 'Q_TRANSMISSION_CONSTRAINT2';
    Q_TRANSMISSION_CONSTRAINT2_rgdx.field = 'm';
    Q_TRANSMISSION_CONSTRAINT2_rgdx.uels = {BRANCH.uels INTERVAL.uels};
    Q_TRANSMISSION_CONSTRAINT2 = rgdx(input1,Q_TRANSMISSION_CONSTRAINT2_rgdx);
end;

 if strcmp(CONTINGENCY_CHECK,'YES')
     Q_TRANSMISSION_CONSTRAINT1_CTGC_rgdx.form = 'full';
     Q_TRANSMISSION_CONSTRAINT1_CTGC_rgdx.name = 'Q_TRANSMISSION_CONSTRAINT1_CTGC';
     Q_TRANSMISSION_CONSTRAINT1_CTGC_rgdx.field = 'm';
     Q_TRANSMISSION_CONSTRAINT1_CTGC_rgdx.uels = {BRANCH.uels BRANCH.uels INTERVAL.uels};
     Q_TRANSMISSION_CONSTRAINT1_CTGC = rgdx(input1,Q_TRANSMISSION_CONSTRAINT1_CTGC_rgdx);
     Q_TRANSMISSION_CONSTRAINT2_CTGC_rgdx.form = 'full';
     Q_TRANSMISSION_CONSTRAINT2_CTGC_rgdx.name = 'Q_TRANSMISSION_CONSTRAINT2_CTGC';
     Q_TRANSMISSION_CONSTRAINT2_CTGC_rgdx.field = 'm';
     Q_TRANSMISSION_CONSTRAINT2_CTGC_rgdx.uels = {BRANCH.uels BRANCH.uels INTERVAL.uels};
     Q_TRANSMISSION_CONSTRAINT2_CTGC = rgdx(input1,Q_TRANSMISSION_CONSTRAINT2_CTGC_rgdx);
 end

if strcmp(MODEL,'DASCUC')
    INTERVAL_SCALAR=ILMP.*ones(HLMP,1);
elseif strcmp(MODEL,'RTSCUC')
    INTERVAL_SCALAR=ILMP/60.*ones(HLMP,1);
else
    INTERVAL_MINUTES=evalin('base','INTERVAL_MINUTES');
    INTERVAL_SCALAR=INTERVAL_MINUTES.val/60;
end
if strcmp(NETWORK_CHECK,'YES')
    LMP_temp(:,SYSTEMVALUE.val(slack_bus))=Q_LOAD_BALANCE.val./(INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu));
    MEC(:,SYSTEMVALUE.val(slack_bus))=LMP_temp(:,SYSTEMVALUE.val(slack_bus));
    MLC(:,SYSTEMVALUE.val(slack_bus))=(Q_LOAD_BALANCE.val./(INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu))).*(BUS_DELIVERY_FACTORS.val(SYSTEMVALUE.val(slack_bus),:)-1)';
    notslack=ones(nbus,1);
    notslack(SYSTEMVALUE.val(slack_bus))=0;
    notslack=find(notslack);
    MEC(:,notslack) = repmat(LMP_temp(:,SYSTEMVALUE.val(slack_bus)),1,nbus-1);
    MLC(:,notslack)=((repmat(Q_LOAD_BALANCE.val,1,nbus-1))./repmat((INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu)),1,nbus-1)).*(BUS_DELIVERY_FACTORS.val(notslack,:)-1)';
    %LMP_temp(:,notslack)=(repmat(Q_LOAD_BALANCE.val,1,nbus-1)-Q_NETENERGY.val(notslack,:)')./repmat((INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu)),1,nbus-1);
    %NOTE EE: I believe the right hand side of the net energy does not
    %account for losses, so currently this is incorrect. There is a better
    %way of calculating but for now the below just adds the components.
    MCC(:,:)=(PTDF.val'*(Q_TRANSMISSION_CONSTRAINT1.val+Q_TRANSMISSION_CONSTRAINT2.val))'./repmat((INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu)),1,nbus);
    if strcmp(CONTINGENCY_CHECK,'YES')
        for l=1:nbranch %note that this does every branch, should really only do ctgc_monitored branches. Currently wasn't a indexing mechanisms to do that.
            mcc_ctgc_shadow_price_tmp = zeros(nbranch,HLMP);
            for h=1:HLMP
                mcc_ctgc_shadow_price_tmp(:,h)=(Q_TRANSMISSION_CONSTRAINT1_CTGC.val(l,:,h)+Q_TRANSMISSION_CONSTRAINT2_CTGC.val(l,:,h));
            end;
            MCC_CTGC(:,:)=MCC_CTGC(:,:) + ((PTDF.val'+PTDF.val(l,:)'*LODF.val(l,:))*(mcc_ctgc_shadow_price_tmp))'./repmat((INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu)),1,nbus);
        end;
    end;
    LMP_temp = MEC + MCC + MLC + MCC_CTGC;
else
    LMP_temp(:,:)=repmat(Q_LOAD_BALANCE.val./(INTERVAL_SCALAR.*SYSTEMVALUE.val(mva_pu)),1,nbus);
end
LMP.val=LMP_temp';
assignin('caller','MCC',MCC');
assignin('caller','MLC',MLC');

nreserve=evalin('base','nreserve');
RESERVEVALUE=evalin('base','RESERVEVALUE');
res_inclusive=evalin('base','res_inclusive');
RESERVETYPE_VAL=evalin('base','RESERVETYPE_VAL');
RCP_temp=zeros(nreserve,HLMP);
Q_RESERVE_BALANCE_rgdx.form = 'full';
Q_RESERVE_BALANCE_rgdx.name = 'Q_RESERVE_BALANCE';
Q_RESERVE_BALANCE_rgdx.field = 'm';
Q_RESERVE_BALANCE_rgdx.uels = {INTERVAL.uels RESERVETYPE_VAL'};
Q_RESERVE_BALANCE = rgdx(input1,Q_RESERVE_BALANCE_rgdx);
RCP_temp(:,:)=((Q_RESERVE_BALANCE.val)./repmat(INTERVAL_SCALAR,1,nreserve)./SYSTEMVALUE.val(mva_pu))';
for rr=1:nreserve
    if RESERVEVALUE.val(rr,res_inclusive) ~= 0
        RCP_temp(RESERVEVALUE.val(rr,res_inclusive),:)=RCP_temp(RESERVEVALUE.val(rr,res_inclusive),:)+RCP_temp(rr,:);
    end
end
RCP.val=RCP_temp;

voll=evalin('base','voll');
res_voir=evalin('base','res_voir');
reservoir_value=evalin('base','reservoir_value');
gen_type=evalin('base','gen_type');
obj_func_rgdx.form = 'full';
obj_func_rgdx.name = 'PRODCOST';
obj_func = rgdx(input1,obj_func_rgdx);
lost_load_cost=sum(LOSSLOAD.val)*SYSTEMVALUE.val(voll);
additional_load_cost=sum(overgeneration.val.*SYSTEMVALUE.val(mva_pu))*SYSTEMVALUE.val(voll);
insuf_reserve_cost=sum((sum(INSUFFRESERVE.val))'.*RESERVEVALUE.val(:,res_voir));
if ~isempty(PUMPEFFICIENCYVALUE.val)
    reservoir_value_kept=sum(STORAGELEVEL.val(:,end).*SYSTEMVALUE.val(mva_pu).*STORAGEVALUE.val(:,reservoir_value));
else
    reservoir_value_kept=0;
end
total_cost = obj_func.val + reservoir_value_kept - lost_load_cost - additional_load_cost - insuf_reserve_cost;
if strcmp(NETWORK_CHECK,'YES')
    PHASE_SHIFTER_ANGLE1_rgdx.name='PHASE_SHIFTER_ANGLE1';
    PHASE_SHIFTER_ANGLE1_rgdx.form='full';
    PHASE_SHIFTER_ANGLE1_rgdx.uels={BRANCH.uels INTERVAL.uels};
    PHASE_SHIFTER_ANGLE1 = rgdx(input1,PHASE_SHIFTER_ANGLE1_rgdx);
    PHASE_SHIFTER_ANGLE2_rgdx.name='PHASE_SHIFTER_ANGLE1';
    PHASE_SHIFTER_ANGLE2_rgdx.form='full';
    PHASE_SHIFTER_ANGLE2_rgdx.uels={BRANCH.uels INTERVAL.uels};
    PHASE_SHIFTER_ANGLE2 = rgdx(input1,PHASE_SHIFTER_ANGLE2_rgdx);
    total_cost = total_cost + sum(sum(PHASE_SHIFTER_ANGLE1.val+PHASE_SHIFTER_ANGLE2.val))*0.005;
end
if sum(double(GENVALUE.val(:,gen_type)==9)) > 0
    NC_STORAGE_GEN_SCHEDULE_rgdx.name='NC_STORAGE_GEN_SCHEDULE';
    NC_STORAGE_GEN_SCHEDULE_rgdx.form='full';
    NC_STORAGE_GEN_SCHEDULE_rgdx.uels={GEN.uels INTERVAL.uels};
    NC_STORAGE_GEN_SCHEDULE=rgdx(input1,NC_STORAGE_GEN_SCHEDULE_rgdx);    
    NC_STORAGE_PUMP_SCHEDULE_rgdx.name='NC_STORAGE_PUMP_SCHEDULE';
    NC_STORAGE_PUMP_SCHEDULE_rgdx.form='full';
    NC_STORAGE_PUMP_SCHEDULE_rgdx.uels={GEN.uels INTERVAL.uels};
    NC_STORAGE_PUMP_SCHEDULE=rgdx(input1,NC_STORAGE_PUMP_SCHEDULE_rgdx);  
    total_cost = total_cost + sum(sum(NC_STORAGE_GEN_SCHEDULE.val+NC_STORAGE_PUMP_SCHEDULE.val))*0.005;
end
if strcmp(MODEL,'RTSCED')
    DEVIATION_HELP_rgdx.name='DEVIATION_HELP';
    DEVIATION_HELP_rgdx.form='full';
    DEVIATION_HELP_rgdx.uels={GEN.uels};
    DEVIATION_HELP=rgdx(input1,DEVIATION_HELP_rgdx);
    total_cost = total_cost - (sum(DEVIATION_HELP.val)*0.05*SYSTEMVALUE.val(mva_pu)*ILMP/60);
end
total_cost_with_penalties = total_cost + insuf_reserve_cost + lost_load_cost;
PRODCOST.val=[obj_func.val;reservoir_value_kept;lost_load_cost;additional_load_cost;insuf_reserve_cost;total_cost;total_cost_with_penalties];


end
