function[PRODCOST,GENSCHEDULE,LMP,UNITSTATUS,UNITSTARTUP,UNITSHUTDOWN,GENRESERVESCHEDULE,RCP,...
    VGCURTAILMENT,LOSSLOAD,INSUFFRESERVE,PUMPSCHEDULE,STORAGELEVEL,PUMPING] ...
    = getgamsdata(inputfile,MODEL,CONTINGENCY,GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,SYSTEMVALUE_VAL,RESERVEVALUE_VAL,GENPARAM,STORAGEVALUE,BRANCHPARAM)


PRODCOST=[];GENSCHEDULE=[];LMP=[];UNITSTATUS=[];UNITSTARTUP=[];UNITSHUTDOWN=[];GENRESERVESCHEDULE=[];RCP=[];
MVAPERUNIT=[];VGCURTAILMENT=[];LOSSLOAD=[];PUMPSCHEDULE=[];STORAGELEVEL=[];PUMPING=[];LMP2=[];
global capacity min_gen ramp_rate initial_MW storage_max initial_storage final_storage max_pump min_pump pump_ramp_rate initial_pump_mw line_rating ste_rating mva_pu slack_bus nESR

LOSS_BIAS=evalin('base','LOSS_BIAS');


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
branch_rgdx.name = 'BRANCH';
BRANCHSET_TMP = rgdx(input1,branch_rgdx);
block_rgdx.name = 'BLOCK';
BLOCKSET_TMP = rgdx(input1,block_rgdx);
ctgc_rgdx.name = 'CTGC_BRANCH';
ctgc_rgdx = rgdx(input1,ctgc_rgdx);
STORAGE_UNITS_TMP=STORAGEVALUE.uels{1,1};
STORAGE_PARAM_TMP=STORAGEVALUE.uels{1,2};





genschedule_rgdx.form = 'full';
genschedule_rgdx.name = 'GEN_SCHEDULE';
genschedule_rgdx.uels = {GEN.uels INTERVAL.uels};
GENSCHEDULE = rgdx(input1,genschedule_rgdx);
GENSCHEDULE.val=GENSCHEDULE.val.*SYSTEMVALUE_VAL(mva_pu);
% lmp_rgdx.form = 'full';
% lmp_rgdx.name = 'LMP';
% lmp_rgdx.uels = {BUS.uels INTERVAL.uels};
% LMP = rgdx(input1,lmp_rgdx);
if strcmp(MODEL,'RTSCED')
    UNITSTARTUP = [];
    UNITSHUTDOWN = [];
    UNITSTATUS = [];
    PUMPING = [];
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
GENRESERVESCHEDULE.val=GENRESERVESCHEDULE.val.*SYSTEMVALUE_VAL(mva_pu);
pumpschedule_rgdx.form = 'full';
pumpschedule_rgdx.name = 'PUMP_SCHEDULE';
pumpschedule_rgdx.uels = {STORAGE_UNITS_TMP INTERVAL.uels};
PUMPSCHEDULE = rgdx(input1,pumpschedule_rgdx);
PUMPSCHEDULE.val=PUMPSCHEDULE.val.*SYSTEMVALUE_VAL(mva_pu);
storagelevel_rgdx.form = 'full';
storagelevel_rgdx.name = 'STORAGE_LEVEL';
storagelevel_rgdx.uels = {STORAGE_UNITS_TMP INTERVAL.uels};
STORAGELEVEL = rgdx(input1,storagelevel_rgdx);
STORAGELEVEL.val=STORAGELEVEL.val.*SYSTEMVALUE_VAL(mva_pu);

%{
$set matout2 "'DASCUCOUTPUTSOL2.gdx',,,,,,QSC10,QSC30,
BPRIME_CTGC,,,,VG_FORECAST,STORAGE_LEVEL,PUMP_SCHEDULE,,
NC_STORAGE_GEN_SCHEDULE,PUMPING,RESERVE_COST";
%}

vgcurtailment_rgdx.form = 'full';
vgcurtailment_rgdx.name = 'VG_CURTAILMENT';
vgcurtailment_rgdx.uels = {GEN.uels INTERVAL.uels};
VGCURTAILMENT = rgdx(input1,vgcurtailment_rgdx);
VGCURTAILMENT.val=VGCURTAILMENT.val.*SYSTEMVALUE_VAL(mva_pu);
lossload_rgdx.form = 'full';
lossload_rgdx.name = 'LOSS_LOAD';
lossload_rgdx.uels = {INTERVAL.uels};
LOSSLOAD = rgdx(input1,lossload_rgdx);
LOSSLOAD.val=LOSSLOAD.val.*SYSTEMVALUE_VAL(mva_pu);
insuffreserve_rgdx.form = 'full';
insuffreserve_rgdx.name = 'INSUFFICIENT_RESERVE';
insuffreserve_rgdx.uels = {INTERVAL.uels RESERVETYPE.uels};
INSUFFRESERVE = rgdx(input1,insuffreserve_rgdx);
INSUFFRESERVE.val=INSUFFRESERVE.val.*SYSTEMVALUE_VAL(mva_pu);

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

TMP = {ALLSET(BRANCHSET_TMP.val)};
BRANCH.val = TMP{1,1}';
BRANCH.name = BRANCHSET_TMP.name;



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
assignin('caller','LINEFLOWS',lineflow.val.*SYSTEMVALUE_VAL(mva_pu));
catch
end

try
netenergy_rgdx.name = 'NET_ENERGY';
netenergy_rgdx.form = 'full';
netenergy_rgdx.uels = {BUS.uels INTERVAL.uels};
netenergy=rgdx(input1,netenergy_rgdx);
assignin('caller','NETENERGY',netenergy.val.*SYSTEMVALUE_VAL(mva_pu));
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
    assignin('caller','OVERGENERATION',overgeneration.val.*SYSTEMVALUE_VAL(mva_pu));
catch
end;


if strcmp(MODEL,'DASCUC')
    HLMP=evalin('base','HDAC');
    ILMP=evalin('base','IDAC');
elseif strcmp(MODEL,'RTSCUC')
    HLMP=evalin('base','HRTC');
    ILMP=evalin('base','IRTC');
elseif strcmp(MODEL,'RTSCED')
    HLMP=evalin('base','HRTD');
    ILMP=evalin('base','IRTD');
else
    HLMP=evalin('base','HRPU');
    ILMP=evalin('base','IRPU');
end

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
elseif strcmp(MODEL,'RTSCUC') || strcmp(MODEL,'RPU')
    INTERVAL_SCALAR=ILMP/60.*ones(HLMP,1);
else
    INTERVAL_MINUTES=evalin('base','INTERVAL_MINUTES');
    INTERVAL_SCALAR=INTERVAL_MINUTES.val/60;
end
if strcmp(NETWORK_CHECK,'YES')
    LMP_temp(:,SYSTEMVALUE_VAL(slack_bus))=Q_LOAD_BALANCE.val./(INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu));
    MEC(:,SYSTEMVALUE_VAL(slack_bus))=LMP_temp(:,SYSTEMVALUE_VAL(slack_bus));
    MLC(:,SYSTEMVALUE_VAL(slack_bus))=(Q_LOAD_BALANCE.val./(INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu))).*(BUS_DELIVERY_FACTORS.val(SYSTEMVALUE_VAL(slack_bus),:)-1)';
    notslack=ones(nbus,1);
    notslack(SYSTEMVALUE_VAL(slack_bus))=0;
    notslack=find(notslack);
    MEC(:,notslack) = repmat(LMP_temp(:,SYSTEMVALUE_VAL(slack_bus)),1,nbus-1);
    MLC(:,notslack)=((repmat(Q_LOAD_BALANCE.val,1,nbus-1))./repmat((INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu)),1,nbus-1)).*(BUS_DELIVERY_FACTORS.val(notslack,:)-1)';
    %LMP_temp(:,notslack)=(repmat(Q_LOAD_BALANCE.val,1,nbus-1)-Q_NETENERGY.val(notslack,:)')./repmat((INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu)),1,nbus-1);
    %NOTE EE: I believe the right hand side of the net energy does not
    %account for losses, so currently this is incorrect. There is a better
    %way of calculating but for now the below just adds the components.
    MCC(:,:)=(PTDF.val'*(Q_TRANSMISSION_CONSTRAINT1.val+Q_TRANSMISSION_CONSTRAINT2.val))'./repmat((INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu)),1,nbus);
    if strcmp(CONTINGENCY_CHECK,'YES')
        for l=1:nbranch %note that this does every branch, should really only do ctgc_monitored branches. Currently wasn't a indexing mechanisms to do that.
            mcc_ctgc_shadow_price_tmp = zeros(nbranch,HLMP);
            for h=1:HLMP
                mcc_ctgc_shadow_price_tmp(:,h)=(Q_TRANSMISSION_CONSTRAINT1_CTGC.val(l,:,h)+Q_TRANSMISSION_CONSTRAINT2_CTGC.val(l,:,h));
            end;
            MCC_CTGC(:,:)=MCC_CTGC(:,:) + ((PTDF.val'+PTDF.val(l,:)'*LODF.val(l,:))*(mcc_ctgc_shadow_price_tmp))'./repmat((INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu)),1,nbus);
        end;
    end;
    LMP_temp = MEC + MCC + MLC + MCC_CTGC;
else
    LMP_temp(:,:)=repmat(Q_LOAD_BALANCE.val./(INTERVAL_SCALAR.*SYSTEMVALUE_VAL(mva_pu)),1,nbus);
end
LMP.val=LMP_temp';
assignin('caller','MCC',MCC');
assignin('caller','MLC',MLC');

nreserve=evalin('base','nreserve');
res_inclusive=evalin('base','res_inclusive');
RESERVETYPE_VAL=evalin('base','RESERVETYPE_VAL');
RCP_temp=zeros(nreserve,HLMP);
Q_RESERVE_BALANCE_rgdx.form = 'full';
Q_RESERVE_BALANCE_rgdx.name = 'Q_RESERVE_BALANCE';
Q_RESERVE_BALANCE_rgdx.field = 'm';
Q_RESERVE_BALANCE_rgdx.uels = {INTERVAL.uels RESERVETYPE_VAL'};
Q_RESERVE_BALANCE = rgdx(input1,Q_RESERVE_BALANCE_rgdx);
RCP_temp(:,:)=((Q_RESERVE_BALANCE.val)./repmat(INTERVAL_SCALAR,1,nreserve)./SYSTEMVALUE_VAL(mva_pu))';
for rr=1:nreserve
    if RESERVEVALUE_VAL(rr,res_inclusive) ~= 0
        RCP_temp(RESERVEVALUE_VAL(rr,res_inclusive),:)=RCP_temp(RESERVEVALUE_VAL(rr,res_inclusive),:)+RCP_temp(rr,:);
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
lost_load_cost=sum(LOSSLOAD.val)*SYSTEMVALUE_VAL(voll);
additional_load_cost=sum(overgeneration.val.*SYSTEMVALUE_VAL(mva_pu))*SYSTEMVALUE_VAL(voll);
insuf_reserve_cost=sum((sum(INSUFFRESERVE.val))'.*RESERVEVALUE_VAL(:,res_voir));
if nESR>0
    reservoir_value_kept=sum(STORAGELEVEL.val(:,end).*STORAGEVALUE.val(:,reservoir_value));
else
    reservoir_value_kept=0;
end;
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
total_cost_with_penalties = total_cost + insuf_reserve_cost + lost_load_cost;
PRODCOST.val=[obj_func.val;reservoir_value_kept;lost_load_cost;additional_load_cost;insuf_reserve_cost;total_cost;total_cost_with_penalties];

load_rgdx.form = 'full';
load_rgdx.name = 'LOAD';
load_rgdx.uels = {INTERVAL.uels};
LOAD = rgdx(input1,load_rgdx);
LOAD.val=LOAD.val.*SYSTEMVALUE_VAL(mva_pu);
tetemp=(sum(GENSCHEDULE.val)'-sum(PUMPSCHEDULE.val)'-LOAD.val+LOSSLOAD.val-overgeneration.val.*SYSTEMVALUE_VAL(mva_pu)-LOSS_BIAS.val.*ones(HLMP,1).*SYSTEMVALUE_VAL(mva_pu));
assignin('caller','marginalLoss',tetemp);

end
