%% FESTIV
%
% Flexible Energy Scheduling Tool for Integration of Variable generation
% 
% FESTIV is a steady-state power system operations tool that covers all
% temporal horizons in the scheduling process starting from the day-ahead
% unit commitment all the way through automatic generation control to
% correct the actual area control error occuring every few seconds.
%
% For more information, see <a href="matlab: 
% web('http://www.nrel.gov/electricity/transmission/festiv.html')">the FESTIV homepage</a>.
%
% To get started, just run 'FESTIV'

%% Detect peregrine so you can set no-gui mode, set gams solver flags, and 
%  modify workspace paths
clear;

% these can now be set to any combination (on-hpc does not imply no-gui)
use_gui = 1;    % default is use gui
on_hpc  = 0;    % default is no hpc

% running on hpc?
[~,sysout] = system('dnsdomainname'); 
sysout = strtrim(sysout);
if strcmp(sysout, 'hpc.nrel.gov')
  fprintf('Detected host hpc.nrel.gov\n')
  on_hpc = 1;  % hpc flag
end

% is it even an option to use the gui?
if use_gui && ~feature('ShowFigureWindows')
  fprintf('Warning: use_gui was set to 1 but cannot open figure windows.\n')
  use_gui = 0;
end
if ~use_gui
  fprintf('No-gui mode enabled (use_gui = 0).\n')
end

% set gams solver flags
if on_hpc
  gams_mip_flag = ' mip=gurobi ';
  fprintf(['Set gams MIP flag : ', gams_mip_flag, '\n'])
  gams_lp_flag = ' lp=gurobi ';
  fprintf(['Set gams LP flag : ', gams_lp_flag, '\n'])
else
  gams_mip_flag = ' ';
  gams_lp_flag = ' ';
end

%% Input Prompt
try load tempws;catch;end;
if isunix
  hpc_convert_windows_paths;
end

if feature('ShowFigureWindows') && use_gui
cancel=1;
FESTIV_GUI 
uiwait(gcf)
pause on
pause(0.1)
pause off
else
cancel=0;
end
%clc;
finishedrunningFESTIV=0;numberofFESTIVrun=1;gamspath=getgamspath();
while(finishedrunningFESTIV ~= 1)
if cancel==0
festivBanner;
RTDFINALSTORAGEIN=[];RTCFINALSTORAGEIN=[];

qq=strcat('tempws',num2str(numberofFESTIVrun));
if exist('multiplefilecheck')==1
    if multiplefilecheck == 0
        inputPath = char(inifile(['Input', filesep, 'FESTIV.inp'],'read',{'','','inputPath',''}));
    else
        load(qq);
        inputPath=completeinputpathname;      
    end
else
    inputPath = char(inifile(['Input', filesep, 'FESTIV.inp'],'read',{'','','inputPath',''}));
end
if not(isempty(gamspath))
    addpath(gamspath); 
    %savepath;
end
if isunix
  hpc_convert_windows_paths;
end
%start_execution is a rarely used feature to continue a FESTIV run from
%where it has just previously stopped. Question if this is still a
%necessary feature.
start_execution = char(inifile(['Input', filesep, 'FESTIV.inp'],'read',{'','','start_execution',''}));
if isempty(start_execution) == 0
    if start_execution == 1 && (mod(time*60,tRTC) - 0 < eps) || (tRTC - mod(time*60,tRTC) < eps)
        RTSCUC_binding_interval_index = RTSCUC_binding_interval_index - 1;
    end;
else
%% Data and Inititialization

for x=1:size(DATA_INITIALIZE_PRE_in,1)
    try run(DATA_INITIALIZE_PRE_in{x,1});catch;end; 
end;

INITIALIZE_VARIABLES_FROM_GUI_INPUTS
DECLARE_INDICES
READ_IN_SYSTEM_DATA_FROM_EXCEL
INPUT_FILE_VALIDATION

for x=1:size(DATA_INITIALIZE_POST_in,1)
    try run(DATA_INITIALIZE_POST_in{x,1});catch;end; 
end;

%% Forcast Inputs

ACTUAL_LOAD_FULL = [];
ACTUAL_VG_FULL = [];
ACTUAL_VG_FIELD = [];

%Retrieve actual load and actual vg through timeseries.
if useHDF5==0
    for d = 1:simulation_days
        ACTUAL_LOAD_FULL_TMP = xlsread(cell2mat(actual_load_input_file(d,1)),'Sheet1','A1:B30000');
        actual_load_multiplier_tmp = zeros(size(ACTUAL_LOAD_FULL_TMP));
        actual_load_multiplier_tmp(:,1) = d-1;
        ACTUAL_LOAD_FULL_TMP = ACTUAL_LOAD_FULL_TMP + actual_load_multiplier_tmp;
        ACTUAL_LOAD_FULL = [ACTUAL_LOAD_FULL; ACTUAL_LOAD_FULL_TMP];
        if nvg > 0
            [ACTUAL_VG_FULL_TMP, ACTUAL_VG_FIELD] = xlsread(cell2mat(actual_vg_input_file(d,1)),'Sheet1');
            actual_vg_multiplier_tmp = zeros(size(ACTUAL_VG_FULL_TMP));
            actual_vg_multiplier_tmp(:,1) = d-1;
            ACTUAL_VG_FULL_TMP = ACTUAL_VG_FULL_TMP + actual_vg_multiplier_tmp;
            ACTUAL_VG_FULL = [ACTUAL_VG_FULL; ACTUAL_VG_FULL_TMP];
        else
            ACTUAL_VG_FIELD = [];
            ACTUAL_VG_FULL = [];
        end;
    end;
end
% Retrieve actual reactive load and bus distributions if possible
try
    [Q_LOAD_DIST_VAL, Q_LOAD_DIST_STRING] = xlsread(inputPath,'Q_LOAD_DIST','A2:B10000'); % Get Q load bus distributions
    for a =1:size(Q_LOAD_DIST_VAL,1)
        for b=1:size(Q_LOAD_DIST_VAL,2)
            if isfinite(Q_LOAD_DIST_VAL(a,b)) == 0
                Q_LOAD_DIST_VAL(a,b) = 0;
            end;
        end;
    end;
    ACTUAL_Q_LOAD_FULL=[];
    for d = 1:simulation_days % Get actual Q demand from 3rd column in actual load timesereies input sheets
        ACTUAL_Q_LOAD_FULL_TMP = xlsread(cell2mat(actual_load_input_file(d,1)),'Sheet1','A1:C30000');
        ACTUAL_Q_LOAD_FULL_TMP = [ACTUAL_Q_LOAD_FULL_TMP(:,1) , ACTUAL_Q_LOAD_FULL_TMP(:,3)];
        actual_load_multiplier_tmp = zeros(size(ACTUAL_Q_LOAD_FULL_TMP));
        actual_load_multiplier_tmp(:,1) = d-1;
        ACTUAL_Q_LOAD_FULL_TMP = ACTUAL_Q_LOAD_FULL_TMP + actual_load_multiplier_tmp;
        ACTUAL_Q_LOAD_FULL = [ACTUAL_Q_LOAD_FULL; ACTUAL_Q_LOAD_FULL_TMP];
    end;
catch
end

if useHDF5 == 1
    CREATE_HDF5_FORECAST_DATA
end

%Declare tAGC
t_AGC=round((ACTUAL_LOAD_FULL(2,1)-ACTUAL_LOAD_FULL(1,1))*60*60*24);

ACTUAL_VG_FULL(:,3:end)=ACTUAL_VG_FULL(:,3:end);
for w=1:nvg
    i = 1;
    while(i<=ngen)
        if(strcmp(GEN.uels(1,i),ACTUAL_VG_FIELD(1,1+w,1)))
            max_data(w,1) = GENVALUE.val(i,capacity); %To make sure that any forecasts are not higher than the max capacity.
            i=ngen;
        end;
        i=i+1;
    end;
end;

if nvg==0
    max_data=0;
end

for x=1:size(FORECASTING_PRE_in,1)
    try run(FORECASTING_PRE_in{x,1});catch;end; 
end;

% Create Interchange forecasts if necessary
DEFINE_INTERCHANGES
% Create DASCUC load,vg,and reserve forecasts
[DAC_LOAD_FULL,DAC_VG_FULL,DAC_VG_FIELD,DAC_RESERVE_FULL,DAC_RESERVE_FIELD]=forecastInputs('DAC',dac_load_data_create,simulation_days,dac_load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,IDAC,tDAC,HDAC,t_AGC,PDAC,dac_load_error,nvcr,nvg,dac_vg_data_create,dac_vg_input_file,max_data,ACTUAL_VG_FIELD,dac_vg_error,IDAC,DAC_RESERVE_FORECAST_MODE,IDAC,eps,nreserve,0,0,dac_reserve_input_file,RESERVETYPE.uels);
% Create RTSCUC load,vg,and reserve forecasts
[RTC_LOAD_FULL,RTC_VG_FULL,RTC_VG_FIELD,RTC_RESERVE_FULL,RTC_RESERVE_FIELD]=forecastInputs('RTC',rtc_load_data_create,simulation_days,rtc_load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,IRTC,tRTC,HRTC,t_AGC,PRTC,rtc_load_error,nvcr,nvg,rtc_vg_data_create,rtc_vg_input_file,max_data,ACTUAL_VG_FIELD,rtc_vg_error,IRTC,RTC_RESERVE_FORECAST_MODE,IDAC,eps,nreserve,DAC_RESERVE_FULL,DAC_RESERVE_FIELD,rtc_reserve_input_file,RESERVETYPE.uels);
% Create RTSCED load,vg,and reserve forecasts
[RTD_LOAD_FULL,RTD_VG_FULL,RTD_VG_FIELD,RTD_RESERVE_FULL,RTD_RESERVE_FIELD]=forecastInputs('RTD',rtd_load_data_create,simulation_days,rtd_load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,IRTD,tRTD,HRTD,t_AGC,PRTD,rtd_load_error,nvcr,nvg,rtd_vg_data_create,rtd_vg_input_file,max_data,ACTUAL_VG_FIELD,rtd_vg_error,IRTDADV,RTD_RESERVE_FORECAST_MODE,IDAC,eps,nreserve,DAC_RESERVE_FULL,DAC_RESERVE_FIELD,rtd_reserve_input_file,RESERVETYPE.uels);
DAC_VG_FULL(DAC_VG_FULL<eps)=0;
RTC_VG_FULL(RTC_VG_FULL<eps)=0;
RTD_VG_FULL(RTD_VG_FULL<eps)=0;
for x=1:size(FORECASTING_POST_in,1)
    try run(FORECASTING_POST_in{x,1});catch;end; 
end;
DAC_VG_FULL(:,1:2)=DAC_LOAD_FULL(:,1:2); 
hour = hour_beginning;
minute = minute_beginning;
second = second_beginning;
day = day_beginning;

%data size
size_DAC_LOAD_FULL = size(DAC_LOAD_FULL,1);
size_RTC_LOAD_FULL = size(RTC_LOAD_FULL,1);
size_RTD_LOAD_FULL = size(RTD_LOAD_FULL,1);
size_ACTUAL_LOAD_FULL = size(ACTUAL_LOAD_FULL,1);

tau=1;
while tau <= size_ACTUAL_LOAD_FULL
    if(abs(ACTUAL_LOAD_FULL(tau,1).*24 -start_time)<eps)
        actual_start_index =tau;
        actual_end_index = size_ACTUAL_LOAD_FULL;
    elseif(abs(ACTUAL_LOAD_FULL(tau,1).*24 - end_time)<eps)
        actual_end_index = tau;
        tau=size_ACTUAL_LOAD_FULL;
    end;
    tau=tau+1;
end;
size_ACTUAL_LOAD_FULL = size(ACTUAL_LOAD_FULL,1);

%data size
size_DAC_VG_FULL = size(DAC_VG_FULL,1);
size_RTC_VG_FULL = size(RTC_VG_FULL,1);
size_RTD_VG_FULL = size(RTD_VG_FULL,1);
size_ACTUAL_VG_FULL = size(ACTUAL_VG_FULL,1);

tau=1;
while tau <= size_ACTUAL_VG_FULL
    if(abs(ACTUAL_VG_FULL(tau,1).*24-start_time)<eps)
        actual_start_index =tau;
        actual_end_index = size_ACTUAL_LOAD_FULL;
    elseif(abs(ACTUAL_VG_FULL(tau,1).*24 - end_time)<eps)
        actual_end_index = tau;
        k=size_ACTUAL_VG_FULL;
    end;
    tau=tau+1;
end;
size_ACTUAL_VG_FULL = size(ACTUAL_VG_FULL,1);

size_DAC_RESERVE_FULL = size(DAC_RESERVE_FULL,1);
size_RTC_RESERVE_FULL = size(RTC_RESERVE_FULL,1);
size_RTD_RESERVE_FULL = size(RTD_RESERVE_FULL,1);

%% Shift Factor and other Calculations

for x=1:size(SHIFT_FACTOR_PRE_in,1)
    try run(SHIFT_FACTOR_PRE_in{x,1});catch;end;
end;

CREATE_SHIFT_FACTORS



%RESERVE TYPES USED THROUGHOUT
%Currently only one regulation, or a regup and regdown. nothing else is
%distinguished throughout the code.
regulation_up_index=0;
regulation_down_index=0;
for r=1:nreserve
    if RESERVEVALUE.val(r,res_agc) == 1
        if RESERVEVALUE.val(r,res_dir) == 1 || RESERVEVALUE.val(r,res_dir) == 3
            regulation_up_index = r;
        end;
        if RESERVEVALUE.val(r,res_dir) == 2 || RESERVEVALUE.val(r,res_dir) == 3
            regulation_down_index = r;
        end;
    end;
end;

RTSCUC_binding_interval_index = 1;
RTSCED_binding_interval_index = 1;
RPU_binding_interval_index = 1;
dascuc_running = 0;
rtscuc_running = 0;
rtsced_running = 0;
rpu_running = 0;


for x=1:size(SHIFT_FACTOR_POST_in,1)
    try run(SHIFT_FACTOR_POST_in{x,1});catch;end;
end;

use_Default_DASCUC = 'YES';
use_Default_RTSCUC = 'YES';
use_Default_RTSCED = 'YES';
use_Default_SCRPU  = 'YES';

INITIALIZE_VARIABLES_FOR_RT

%% Initial Day-Ahead SCUC

tNow = toc(tStart);
fprintf('Complete! (%02.0f min, %05.2f s)\n',floor(tNow/60),rem(tNow,60));
fprintf('Modeling Initial Day-Ahead Unit Commitment...')

DASCUC_binding_interval_index = 1;
Solving_Initial_Models = 1;

dascuc_running = 1;
dac_int=1;
t=1;
if nvcr > 0
    while(t <= size_DAC_VG_FULL && DAC_VG_FULL(t,1)<= DASCUC_binding_interval_index+1)
        if(abs(DAC_VG_FULL(t,1) - DASCUC_binding_interval_index) < eps)
            vg_forecast_tmp(dac_int,:) = DAC_VG_FULL(t,3:end);
            dac_int = dac_int+1;
        end;
        t = t+1;
    end;
else
    vg_forecast_tmp = 0;
end;

clear VG_FORECAST_VAL;
VG_FORECAST_VAL=zeros(HDAC,ngen);
DAC_Field_size = size(DAC_VG_FIELD,2)-2;
i =1;
while(i<=ngen)
    w = 1;
    while(w<=DAC_Field_size)
        if(strcmp(GEN.uels(1,i),DAC_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
            VG_FORECAST_VAL(1:HDAC,i) = vg_forecast_tmp(1:HDAC,w);
            w=DAC_Field_size;
        elseif(w==DAC_Field_size)        %gone through entire list of VG and gen is not included
            VG_FORECAST_VAL(1:HDAC,i) = zeros(HDAC,1);
        end;
        w = w+1;
    end;
    i = i+1;
end;

UNIT_STATUS_ENFORCED_ON_VAL=zeros(ngen,HDAC);
UNIT_STATUS_ENFORCED_OFF_VAL=ones(ngen,HDAC);
for i=1:ngen
    if GENVALUE.val(i,initial_status) == 0
        for t=1:HDAC
            if t <= GENVALUE.val(i,md_time) - GENVALUE.val(i,initial_hour)
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 0;
            else
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            end
        end
    else
        for t=1:HDAC
            if t <= GENVALUE.val(i,mr_time) - GENVALUE.val(i,initial_hour)
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 1;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            else
                UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
            end
        end
    end
    if GENVALUE.val(i,gen_type)==15
        UNIT_STATUS_ENFORCED_OFF_VAL(i,1:HDAC) = 0;
    end
end
PUMPING_ENFORCED_ON_VAL=zeros(ngen,HDAC);
PUMPING_ENFORCED_OFF_VAL=ones(ngen,HDAC);
% pshunitindicies=find(GENVALUE.val(:,gen_type)==6);
if size(STORAGEVALUE.uels{1, 1},1) > 0 && ~isempty(pshunitindicies)
    for i=1:size(pshunitindicies,1)
        if STORAGEVALUE.val(pshunitindicies(i),initial_pump_status) == 0
            for t=1:HDAC
                if t <= GENVALUE.val(pshunitindicies(i),md_time) - STORAGEVALUE.val(pshunitindicies(i),initial_pump_hour)
                    PUMPING_ENFORCED_ON_VAL(pshunitindicies(i),t)  = 0;
                    PUMPING_ENFORCED_OFF_VAL(pshunitindicies(i),t) = 0;
                else
                    PUMPING_ENFORCED_ON_VAL(pshunitindicies(i),t)  = 0;
                    PUMPING_ENFORCED_OFF_VAL(pshunitindicies(i),t) = 1;
                end
            end
        else
            for t=1:HDAC
                if t <= STORAGEVALUE.val(pshunitindicies(i),min_pump_time) - STORAGEVALUE.val(pshunitindicies(i),initial_pump_hour)
                    PUMPING_ENFORCED_ON_VAL(pshunitindicies(i),t)  = 1;
                    PUMPING_ENFORCED_OFF_VAL(pshunitindicies(i),t) = 1;
                else
                    PUMPING_ENFORCED_ON_VAL(pshunitindicies(i),t)  = 0;
                    PUMPING_ENFORCED_OFF_VAL(pshunitindicies(i),t) = 1;
                end
            end
        end
        if GENVALUE.val(pshunitindicies(i),gen_type)==15
            PUMPING_ENFORCED_OFF_VAL(pshunitindicies(i),1:HDAC) = 0;
        end
    end
end
   
% Initialize delivery factors based on initial conditions
lossesCheck = sum(BRANCHDATA.val(:,resistance));
if lossesCheck > eps
    initPowerInj=zeros(nbus,1);    
    for i=1:size(GENBUS2.uels{1, 2},2)
        for c=1:size(GENBUS2.val,1)
            if GENBUS2.val(c,i) > 0
                for b=1:size(BUS_VAL,1)
                    if strcmp(GENBUS2.uels{1, 1}{c},BUS_VAL{b})
                        initPowerInj(b,1)=initPowerInj(b,1)+GENVALUE.val(strcmp(GENBUS2.uels{1, 2}{i},GEN_VAL),initial_MW)*PARTICIPATION_FACTORS.val(c,i);
                    end
                end
            end
        end
    end
    initLoadDist=zeros(nbus,1);    
    for i=1:size(LOAD_DIST_STRING,1)
        initLoadDist(strcmp(LOAD_DIST_STRING{i},BUS_VAL))=LOAD_DIST_VAL(i)*DAC_LOAD_FULL(1,3);
    end
    initialLineFlows=PTDF_VAL*(initPowerInj-initLoadDist);
else
    initialLineFlows=zeros(nbranch,1);
end
if lossesCheck > eps
    [DAC_BUS_DELIVERY_FACTORS_VAL,DAC_GEN_DELIVERY_FACTORS_VAL,DAC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HDAC,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HDAC),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    DAC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HDAC);
    DAC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HDAC);
    DAC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HDAC);
end
CREATE_DAC_GAMS_VARIABLES

for x=1:size(DASCUC_RULES_PRE_in,1)
    try run(DASCUC_RULES_PRE_in{x,1});catch;end;
end;

if strcmp(use_Default_DASCUC,'YES')
    per_unitize;
    wgdx(['TEMP', filesep, 'DASCUCINPUT1'],NDACINTERVAL,DACINTERVAL_LENGTH,INTERVAL,GEN,BUS,GENPARAM,RESERVEPARAM,BRANCHPARAM,COSTCURVEPARAM,START_PARAMETER,BRANCH,...
        SYSPARAM,RESERVETYPE,STORAGEPARAM,PUMPEFFPARAM,GENEFFPARAM,BLOCK2,GENBLOCK,STORAGEGENEFFICIENCYBLOCK,STORAGEPUMPEFFICIENCYBLOCK,SYSTEMVALUE,...
        LOAD_DIST,PTDF,LODF,PTDF_PAR,RESERVEVALUE,BRANCHDATA,BLOCK_COST,BLOCK_CAP,QSC,COST_CURVE,RESERVE_COST,STARTUP_VALUE,...
        PUMPEFFICIENCYVALUE,GENEFFICIENCYVALUE,OFFLINE_BLOCK,STARTUP_COST_BLOCK,STARTUP_PERIOD,SHUTDOWN_PERIOD,PUMPUP_PERIOD,PUMPDOWN_PERIOD,...
        GEN_EFFICIENCY_BLOCK,GEN_EFFICIENCY_MW,PUMP_EFFICIENCY_BLOCK,PUMP_EFFICIENCY_MW,PARTICIPATION_FACTORS,GENBUS2,BRANCHBUS2); 

    wgdx(['TEMP', filesep, 'DASCUCINPUT2'],LOSS_BIAS,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,LOAD,GENVALUE,STORAGEVALUE,UNIT_STATUS_ENFORCED_ON,UNIT_STATUS_ENFORCED_OFF,...
        VG_FORECAST,RESERVELEVEL,INTERCHANGE,END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,PUMPING_ENFORCED_ON,PUMPING_ENFORCED_OFF,...
        GEN_FORCED_OUT,MAX_OFFLINE_TIME,INITIAL_STARTUP_COST_HELPER,INITIAL_STARTUP_PERIODS,INTERVALS_STARTED_AGO,INITIAL_PUMPUP_PERIODS,INTERVALS_PUMPUP_AGO,...
        INITIAL_SHUTDOWN_PERIODS,INTERVALS_SHUTDOWN_AGO,INITIAL_PUMPDOWN_PERIODS,INTERVALS_PUMPDOWN_AGO);

    DASCUC_GAMS_CALL = ['gams ..', filesep, 'DASCUC.gms Lo=2 Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USE_INTEGER="',USE_INTEGER,'" --USE_DEFAULT="',use_Default_DASCUC,'" --USEGAMS="',USEGAMS,'"', gams_mip_flag];

    system(DASCUC_GAMS_CALL);

    [SCUCPRODCOST,SCUCGENSCHEDULE,SCUCLMP,SCUCUNITSTATUS,SCUCUNITSTARTUP,SCUCUNITSHUTDOWN,SCUCGENRESERVESCHEDULE,...
        SCUCRCP,SCUCLOADDIST,SCUCGENVALUE,SCUCSTORAGEVALUE,SCUCVGCURTAILMENT,SCUCLOAD,SCUCRESERVEVALUE,SCUCRESERVELEVEL,SCUCBRANCHDATA,...
        SCUCBLOCKCOST,SCUCBLOCKMW,SCUCBPRIME,SCUCBGAMMA,SCUCLOSSLOAD,SCUCINSUFFRESERVE,SCUCGEN,SCUCBUS,SCUCHOUR,...
        SCUCBRANCH,SCUCRESERVETYPE,SCUCSLACKBUS,SCUCGENBUS,SCUCBRANCHBUS,SCUCPUMPSCHEDULE,SCUCSTORAGELEVEL,SCUCPUMPING] ...
        = getgamsdata('TOTAL_DASCUCOUTPUT','DASCUC','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
end

try
DAModelSolutionStatus=[];
DAModelSolutionStatus=[0 modelSolveStatus numberOfInfes solverStatus relativeGap];
catch
end;
for x=1:size(DASCUC_RULES_POST_in,1)
    try run(DASCUC_RULES_POST_in{x,1});catch;end;
end;

DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (0:IDAC:HDAC*IDAC-IDAC)';
DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCGENSCHEDULE.val)';
DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (0:IDAC:HDAC*IDAC-IDAC)';
DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2) = marginalLoss;

DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (0:IDAC:HDAC*IDAC-IDAC)';
DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCPUMPSCHEDULE.val)';
DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (0:IDAC:HDAC*IDAC-IDAC)';
DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nbus+1) = SCUCLMP.val';
DASCUCCOMMITMENT=SCUCUNITSTATUS.val';
for r=1:nreserve
    DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1,r)=(0:IDAC:HDAC*IDAC-IDAC)';
    DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1,r) = SCUCGENRESERVESCHEDULE.val(:,:,r)';
end;
DASCUCRESERVEPRICE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,:) = [(0:IDAC:HDAC*IDAC-IDAC)' SCUCRCP.val'];
RESERVELEVELS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (0:IDAC:HDAC*IDAC-IDAC)'; 
RESERVELEVELS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nreserve+1) = SCUCRESERVELEVEL.val;
DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1)=(0:IDAC:HDAC*IDAC-IDAC)';
DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1)=SCUCSTORAGELEVEL.val';
pshbid_gdx.name = 'PSHBID';
pshbid_gdx.form = 'full';
pshbid_gdx.uels = GEN.uels;
PSHBIDCOST=rgdx('TEMP/TOTAL_DASCUCOUTPUT',pshbid_gdx);
PSHBIDCOST_VAL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,:) = ones(HDAC,1)*PSHBIDCOST.val';
DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (0:IDAC:HDAC*IDAC-IDAC)';
DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCVGCURTAILMENT.val)';

if lossesCheck > eps
    [DAC_BUS_DELIVERY_FACTORS_VAL,DAC_GEN_DELIVERY_FACTORS_VAL,DAC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HDAC,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HDAC),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    DAC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HDAC);
    DAC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HDAC);
    DAC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HDAC);
end

dascuc_running = 0;
DASCUC_binding_interval_index = DASCUC_binding_interval_index + 1;

%Get rid of string parts so that only values are part of correction.
GENBUS = SCUCGENBUS.val;
SLACKBUS = SYSTEMVALUE.val(slack_bus,1);
BRANCHBUS = SCUCBRANCHBUS.val;
MVA_PERUNIT = SYSTEMVALUE.val(mva_pu,1);
LOAD_DIST = SCUCLOADDIST;
COST = SCUCBLOCKCOST.val;
BLOCK = SCUCBLOCKMW.val;
STORAGEVALUE = SCUCSTORAGEVALUE;

rtscuc_commitment_multiplier = max(1,floor(60*IDAC/IRTC));
rtscuc_I_perhour = floor(60/IRTC);

for h=1:NDACINTERVAL.val
    for i=1:ngen
        for h1 = 1:rtscuc_commitment_multiplier
            if round(SCUCUNITSTATUS.val(i,min(NDACINTERVAL.val,h+1)))-round(SCUCUNITSTATUS.val(i,h)) == 1
                STATUS(rtscuc_commitment_multiplier*h-rtscuc_commitment_multiplier+1,i) = round(SCUCUNITSTATUS.val(i,h));
                STATUS(rtscuc_commitment_multiplier*h-rtscuc_commitment_multiplier+1+1:rtscuc_commitment_multiplier*h+1,i) ...
                    = round(SCUCUNITSTATUS.val(i,h+1));
            else
                STATUS(rtscuc_commitment_multiplier*h-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*h-1+1,i) ...
                    = round(SCUCUNITSTATUS.val(i,h));
            end;
            if round(SCUCPUMPING.val(i,min(NDACINTERVAL.val,h+1)))-round(SCUCPUMPING.val(i,h)) == 1
                PUMPSTATUS(rtscuc_commitment_multiplier*h-rtscuc_commitment_multiplier+1,i) = round(SCUCPUMPING.val(i,h));
                PUMPSTATUS(rtscuc_commitment_multiplier*h-rtscuc_commitment_multiplier+1+1:rtscuc_commitment_multiplier*h+1,i) ...
                    = round(SCUCPUMPING.val(i,h+1));
            else
                PUMPSTATUS(rtscuc_commitment_multiplier*h-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*h-1+1,i) ...
                    = round(SCUCPUMPING.val(i,h));
            end;
        end;
    end;
end;

time = start_time;

%% Real-Time Set up
delete_old_files = char(inifile(['Input', filesep, 'FESTIV.inp'],'read',{'','','delete_old_files',''}));
if (strcmp(delete_old_files,'Yes') ==1 || strcmp(delete_old_files,'yes') ==1 || strcmp(delete_old_files,'YES') ==1)
%Real Time Set up
%{
The unit commitment solution will now be used as an input to the real-time
commitment and dispatch operations. Different commitment constraints can
be placed in on real-time to see how

Everything before midnight of the day is exactly as
the SCUC predicted, there are no ramp problems, no changes in commitment,
no contingencies, the commitments of hour 0 are assumed constant.
%}



%% Initial Real-Time SCUC
%{
RTC for the very first interval
This interval is always perfect, there is no forced outages and it is used just to set up the rest of the day.
%}

tNow = toc(tStart);
fprintf('Complete!\n');
fprintf('Modeling Initial Real-Time Unit Commitment...')

rtscuc_running = 1;
%Get vg and load data
RTC_LOOKAHEAD_INTERVAL_VAL(1:HRTC,1) = RTC_LOAD_FULL(1:HRTC,2)*24; %time must be converted to hours instead of days

clear vg_forecast_tmp
if nvcr > 0
    vg_forecast_tmp(1:HRTC,:) = RTC_VG_FULL(1:HRTC,3:end);
else
    vg_forecast_tmp = RTC_VG_FULL;
end;

i =1;
%This fills in zeros for non-vg and ensures that the right order is set up. If
%for example the order of the rtc sheet and genvalue sheet is different this will correct that.
VG_FORECAST_VAL = [];
RTC_Field_size = size(RTC_VG_FIELD,2)-2;
while(i<=ngen)
    w = 1;
    while(w<=RTC_Field_size)
        if(strcmp(GEN.uels(1,i),RTC_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
            VG_FORECAST_VAL(1:HRTC,i) = vg_forecast_tmp(1:HRTC,w);
            w=RTC_Field_size;
        elseif(w==RTC_Field_size)        %gone through entire list of VG and gen is not included
            VG_FORECAST_VAL(1:HRTC,i) = zeros(HRTC,1);
        end;
        w = w+1;
    end;
    i = i+1;
end;

rtscucinterval_index = round(time*rtscuc_I_perhour) + 1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!

%Setting up the hard commitment constraints for quickstarts and other units.
%Also want to make sure that quickstarts that have not met their min run times or min down times are honored here.
RTSCUCSTART_MODE = 1;
RTSCUCSTART;
for i=1:ngen
    t = 1;
    while(t<=HRTC)
        start_interval = t*IRTC/60;
        lookahead_index = round(RTC_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour) + 1;    %This is based on SCUC starting at hour 0!!!
        if  RTSCUCSTART_YES(i,1) == 1
            UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
        else
            UNIT_STATUS_ENFORCED_ON_VAL(i,t) = STATUS(lookahead_index,i);
        end;
        if RTSCUCSHUT_YES(i,1) == 1
            UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
        else
            UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = STATUS(lookahead_index,i);
        end;
        if  RTSCUCPUMPSTART_YES(i,1) == 1
            PUMPING_ENFORCED_ON_VAL(i,t) = 0;
        else
            PUMPING_ENFORCED_ON_VAL(i,t) = PUMPSTATUS(lookahead_index,i);
        end;
        if RTSCUCPUMPSHUT_YES(i,1) == 1
            PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
        else
            PUMPING_ENFORCED_OFF_VAL(i,t) = PUMPSTATUS(lookahead_index,i);
        end;
        if GENVALUE.val(i,gen_type)==15
            UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
            UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 0;
        end
        t = t+1;
    end;
end;

%This is for interval 0 initial ramping constraints
 ACTUAL_GEN_OUTPUT_VAL = GENVALUE.val(:,initial_MW); %placeholder for initial RTC
 LAST_GEN_SCHEDULE_VAL = GENVALUE.val(:,initial_MW); %placeholder for initial RTC   
 LAST_STATUS_VAL = GENVALUE.val(:,initial_status);  %placeholder
 LAST_STATUS_ACTUAL_VAL = GENVALUE.val(:,initial_status); %placeholder
%ACTUAL_GEN_OUTPUT_VAL = DASCUCSCHEDULE(1,2:end)'; %placeholder for initial RTC
%LAST_GEN_SCHEDULE_VAL = DASCUCSCHEDULE(1,2:end)'; %placeholder for initial RTC   
%LAST_STATUS_VAL = double(DASCUCSCHEDULE(1,2:end)>0)';  %placeholder
%LAST_STATUS_ACTUAL_VAL = double(DASCUCSCHEDULE(1,2:end)>0)'; %placeholder
ACTUAL_PUMP_OUTPUT_VAL = STORAGEVALUE.val(:,initial_pump_mw); %placeholder for initial RTC
LAST_PUMP_SCHEDULE_VAL = STORAGEVALUE.val(:,initial_pump_mw); %placeholder for initial RTC   
LAST_PUMPSTATUS_VAL = STORAGEVALUE.val(:,initial_pump_status);  %placeholder
LAST_PUMPSTATUS_ACTUAL_VAL = STORAGEVALUE.val(:,initial_pump_status); %placeholder
for i=1:ngen
    RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTC+IRTC)*GENVALUE.val(i,ramp_rate)...
        - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTC*GENVALUE.val(i,ramp_rate)));
    RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTC*GENVALUE.val(i,ramp_rate)...
        - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTC+IRTC)*GENVALUE.val(i,ramp_rate)));
end;

%For su and sd trajectories
%Right now this allows for units who have just started up before teh
%DASCUC, but not those who are in the middle of the startup process during the initialD DASCUC 
for i=1:ngen
   STARTUP_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,su_time)*60/IRTC));
   SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,sd_time)*60/IRTC));
   INITIAL_STARTUP_PERIODS_VAL(i,1) = 0;
   INTERVALS_STARTED_AGO_VAL(i,1) = 0;
   startup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-1-STARTUP_PERIOD_VAL(i,1) + 1));
%    for startup_period_check_time = startup_period_check_end:RTSCUC_binding_interval_index-1
%        INITIAL_STARTUP_PERIODS_VAL(i,1) = INITIAL_STARTUP_PERIODS_VAL(i,1) + RTSCUCBINDINGSTARTUP(startup_period_check_time,1+i);
%        if RTSCUCBINDINGSTARTUP(startup_period_check_time,1+i) == 1
%            INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index - startup_period_check_time;
%            STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE.val(i,min_gen)*(time + IRTC/60 - RTSCUCBINDINGSTARTUP(startup_period_check_time,1))/GENVALUE.val(i,su_time);
%        end;
%    end;
    %if SCUCUNITSTARTUP.val(i,1) == 1 && RTSCUCSTART_YES(i,1)
        %INTERVALS_STARTED_AGO_VAL(i,1) = round(LAST_GEN_SCHEDULE_VAL(i,1)/GENVALUE.val(i,min_gen)*STARTUP_PERIOD_VAL(i,1)-1);
        %INITIAL_STARTUP_PERIODS_VAL(i,1) = 1;
        %STARTUP_MINGEN_HELPER_VAL = LAST_GEN_SCHEDULE_VAL(i);
    %end
    %EE 11152015, for now cancel this it thinks it "previously started"
    %because of SCUC, but SCUC is the same interval as this. Needs to be
    %fixed. For now just assume that units are not in startup mode based on
    %initial conditions. either off and starting of on.
end;

for i=1:ngen
   PUMPUP_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_su_time)*60/IRTC));
   PUMPDOWN_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRTC));
   INITIAL_PUMPUP_PERIODS_VAL(i,1) = 0;
   INTERVALS_PUMPUP_AGO_VAL(i,1) = 0;
   pumpup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-1-PUMPUP_PERIOD_VAL(i,1) + 1));
   for pumpup_period_check_time = pumpup_period_check_end:RTSCUC_binding_interval_index-1
       INITIAL_PUMPUP_PERIODS_VAL(i,1) = INITIAL_PUMPUP_PERIODS_VAL(i,1) + max(0,PUMPSTATUS(startup_period_check_time,1+i)-PUMPSTATUS(startup_period_check_time-1,1+i));
       if PUMPSTATUS(startup_period_check_time,1+i)-PUMPSTATUS(startup_period_check_time-1,1+i) == 1
           INTERVALS_PUMPUP_AGO_VAL(i,1) = RTSCUC_binding_interval_index - pumpup_period_check_time;
           %PUMPUP_MINGEN_HELPER_VAL(i,1) = STORAGEVALUE.val(i,min_pump)*(time + IRTC/60 - PUMPSTATUS(pumpup_period_check_time,1))/STORAGEVALUE.val(i,pump_su_time);
       end;
   end;
end;

%Storage value for RTC. Not currently working.
%Basically, figure out the amount of money that the storage unit would
%receive in total dollars for the rest of the day including the end of the
%day. Then figure out that value in $/MWh
RTSCUC_RESERVOIR_VALUE = zeros(ngen,1);
RTSCUC_STORAGE_LEVEL = zeros(ngen,1);
for i=1:ngen
    if GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8  || GENVALUE.val(i,gen_type) == 12
        RTSCUC_STORAGE_LEVEL(i,1) = SCUCSTORAGEVALUE.val(i,initial_storage);
        RTSCUC_RESERVOIR_VALUE(i,1) = ((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
            floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
            +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
            *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + STORAGEVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
            + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    elseif GENVALUE.val(i,gen_type) == 9 || GENVALUE.val(i,gen_type) == 11
        RTSCUC_RESERVOIR_VALUE(i,1) = GENVALUE.val(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
            floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
            +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
            *SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + STORAGEVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
            + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    else
        RTSCUC_RESERVOIR_VALUE(i) = 0;
    end;
end;

%STORAGEVALUE.val(:,reservoir_value) = RTSCUC_RESERVOIR_VALUE;
STORAGEVALUE.val(:,initial_storage) = RTSCUC_STORAGE_LEVEL;
rtc_final_storage_time_index_up = ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
rtc_final_storage_time_index_lo = floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
% STORAGEVALUE.val(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)' ...
%     + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC),1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_up),2:ngen+1)' ...
%     - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)');

ik=1;
while ik ~= size(DASCUCSTORAGELEVEL,1)
    if RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(DASCUCSTORAGELEVEL(:,1))
        STORAGEVALUE.val(:,final_storage) = RTCFINALSTORAGEIN(:,end);
        ik=size(DASCUCSTORAGELEVEL,1)-1;
    elseif DASCUCSTORAGELEVEL(ik,1) > RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps
        STORAGEVALUE.val(:,final_storage) = DASCUCSTORAGELEVEL(ik-1,2:ngen+1)' ...
            + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(ik,2:ngen+1)' ...
            - DASCUCSTORAGELEVEL(ik-1,2:ngen+1)');
        ik=size(DASCUCSTORAGELEVEL,1)-1;
    end
    ik = ik + 1;
end
RTCFINALSTORAGEIN=[RTCFINALSTORAGEIN,STORAGEVALUE.val(:,final_storage)];

END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);
END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);

% Initialize delivery factors based on initial conditions
if lossesCheck > eps
    [RTC_BUS_DELIVERY_FACTORS_VAL,RTC_GEN_DELIVERY_FACTORS_VAL,RTC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTC,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HRTC),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    RTC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTC);
    RTC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTC);
    RTC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTC);
end
UNIT_STATUS_ENFORCED_ON_VAL(GENVALUE.val(:,gen_type)==7|GENVALUE.val(:,gen_type)==10|GENVALUE.val(:,gen_type)==14)=0;
UNIT_STATUS_ENFORCED_OFF_VAL(GENVALUE.val(:,gen_type)==7|GENVALUE.val(:,gen_type)==10|GENVALUE.val(:,gen_type)==14)=1;
        
CREATE_RTC_GAMS_VARIABLES

for x=1:size(RTSCUC_RULES_PRE_in,1)
    try run(RTSCUC_RULES_PRE_in{x,1});catch;end;
end
if strcmp(use_Default_RTSCUC,'YES')
    per_unitize;
    wgdx(['TEMP', filesep, 'RTSCUCINPUT1'],PTDF,BLOCK_COST,BLOCK_CAP,QSC,GEN_EFFICIENCY_BLOCK,GEN_EFFICIENCY_MW,PUMP_EFFICIENCY_BLOCK,PUMP_EFFICIENCY_MW,...
        BLOCK2,GENBLOCK,STORAGEGENEFFICIENCYBLOCK,STORAGEPUMPEFFICIENCYBLOCK,RESERVE_COST,PUMPEFFPARAM,PUMPEFFICIENCYVALUE,GENEFFPARAM,...
        GENEFFICIENCYVALUE,PUMPUP_PERIOD,PUMPDOWN_PERIOD,INTERVAL,GEN,BUS,GENPARAM,RESERVEPARAM,BRANCHPARAM,COSTCURVEPARAM,BRANCH,RESERVETYPE,...
        LOAD_DIST,BRANCHDATA,RESERVEVALUE,COST_CURVE,SYSTEMVALUE,SYSPARAM,STORAGEPARAM,NRTCINTERVAL,RTCINTERVAL_LENGTH,...
        RTC_PROCESS_TIME,RTCINTERVAL_UPDATE,INITIAL_DISPATCH_SLACK_SET,RTCSTART,RTCSHUT,RTCPUMPSTART,RTCPUMPSHUT,LODF,PTDF_PAR,STARTUP_PERIOD,...
        SHUTDOWN_PERIOD,PARTICIPATION_FACTORS,GENBUS2,BRANCHBUS2);

    wgdx(['TEMP', filesep, 'RTSCUCINPUT2'],UNIT_STARTUP_ACTUAL,UNIT_PUMPUP_ACTUAL,LAST_STARTUP,LAST_SHUTDOWN,PUCOST_BLOCK_OFFSET,INTERCHANGE,LOSS_BIAS,...
        DELAYSD,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,PUMPING_ENFORCED_OFF,INITIAL_PUMPUP_PERIODS,...
        INTERVALS_PUMPUP_AGO,PUMPING_ENFORCED_ON,ACTUAL_PUMP_OUTPUT,LAST_PUMP_SCHEDULE,LAST_PUMPSTATUS,LAST_PUMPSTATUS_ACTUAL,INITIAL_DISPATCH_SLACK,...
        LOAD,LAST_STATUS_ACTUAL,GEN_FORCED_OUT,INTERVALS_STARTED_AGO,INITIAL_STARTUP_PERIODS,ACTUAL_GEN_OUTPUT,LAST_GEN_SCHEDULE,RAMP_SLACK_UP,RAMP_SLACK_DOWN,...
        LAST_STATUS,UNIT_STATUS_ENFORCED_ON,UNIT_STATUS_ENFORCED_OFF,RESERVELEVEL,VG_FORECAST,GENVALUE,STORAGEVALUE);

    RTSCUC_GAMS_CALL = ['gams ..', filesep, 'RTSCUC.gms Lo=2 Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USE_INTEGER="',USE_INTEGER,'" --USEGAMS="',USEGAMS,'"', gams_mip_flag];

    system(RTSCUC_GAMS_CALL);
    [RTCPRODCOST,RTCGENSCHEDULE,RTCLMP,RTCUNITSTATUS,RTCUNITSTARTUP,RTCUNITSHUTDOWN,RTCGENRESERVESCHEDULE,...
        RTCRCP,RTCLOADDIST,RTCGENVALUE,RTCSTORAGEVALUE,RTCVGCURTAILMENT,RTCLOAD,RTCRESERVEVALUE,RTCRESERVELEVEL,RTCBRANCHDATA,...
        RTCBLOCKCOST,RTCBLOCKMW,RTCBPRIME,RTCBGAMMA,RTCLOSSLOAD,RTCINSUFFRESERVE,RTCGEN,RTCBUS,RTCHOUR,...
        RTCBRANCH,RTCRESERVETYPE,RTCSLACKBUS,RTCGENBUS,RTCBRANCHBUS,RTCPUMPSCHEDULE,RTCSTORAGELEVEL,RTCPUMPING] ...
        = getgamsdata('TOTAL_RTSCUCOUTPUT','RTSCUC','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
end
try
rtcmodeltracker=1;
rpumodeltracker=1;
RTCModelSolutionStatus=zeros(60/tRTC*24*daystosimulate+1,5);
RTCModelSolutionStatus(rtcmodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
rtcmodeltracker=rtcmodeltracker+1;
catch
end;
for x=1:size(RTSCUC_RULES_POST_in,1)
    try run(RTSCUC_RULES_POST_in{x,1});catch;end;
end;

RTSCUCBINDINGCOMMITMENT(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGSHUTDOWN(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGCOMMITMENT(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCUNITSTATUS.val(:,:)');
RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCPUMPING.val(:,:)');
RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCUNITSTARTUP.val(:,:)');
STATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,:) = round(RTCUNITSTATUS.val(:,:)');
PUMPSTATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,:) = round(RTCPUMPING.val(:,:)');
RTSCUCBINDINGSHUTDOWN(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = round(RTCUNITSHUTDOWN.val(:,:)');
RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = RTCGENSCHEDULE.val(:,:)';
RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = RTCPUMPSCHEDULE.val(:,:)';

RTSCUCBINDINGRESERVESCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGRESERVEPRICE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGINSUFFICIENTRESERVE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGLOSSLOAD(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGOVERGENERATION(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
for r=1:nreserve
    RTSCUCBINDINGRESERVESCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1:1+ngen,r) = [RTC_LOOKAHEAD_INTERVAL_VAL RTCGENRESERVESCHEDULE.val(:,:,r)'];
end;
RTSCUCBINDINGRESERVEPRICE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:nreserve+1) =  RTCRCP.val';
RTSCUCBINDINGINSUFFICIENTRESERVE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:nreserve+1) =  RTCINSUFFRESERVE.val;
RTSCUCBINDINGLOSSLOAD(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) =  RTCLOSSLOAD.val;
RTSCUCBINDINGOVERGENERATION(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) = OVERGENERATION;
RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) = marginalLoss(1,1);

RTSCUC_INITIAL_START_TIME = zeros(ngen,1);
for i=1:ngen
    if RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index,1+i) == 1;
        RTSCUC_INITIAL_START_TIME(i,1) = time - IRTC/60;
    end;
end;
RTSCUC_INITIAL_PUMPUP_TIME = zeros(ngen,1);
for i=1:ngen
    if RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index,1+i) - SCUCSTORAGEVALUE.val(i,initial_pump_status) == 1;
        RTSCUC_INITIAL_PUMPUP_TIME(i,1) = time - IRTC/60;
    end;
end;

RTSCUCSTORAGELEVEL2(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),1)=RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCSTORAGELEVEL2(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),2:ngen+1)=RTCSTORAGELEVEL.val';
pshbid_gdx.name = 'PSHBID';
pshbid_gdx.form = 'full';
pshbid_gdx.uels = GEN.uels;
RTPSHBIDCOST=rgdx('TEMP/TOTAL_RTSCUCOUTPUT',pshbid_gdx);
%         RTPSHBIDCOST_VAL((RTSCUC_binding_interval_index-1)*HRTC+1:HRTC+(RTSCUC_binding_interval_index-1)*HRTC,:) =  ones(HRTC,1)*RTPSHBIDCOST.val';
%         RTPSHBIDCOST_VAL(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),:) =  ones(HRTC,1)*RTPSHBIDCOST.val';
RTPSHBIDCOST_VAL(RTSCUC_binding_interval_index,1)=RTC_LOOKAHEAD_INTERVAL_VAL(1);
RTPSHBIDCOST_VAL(RTSCUC_binding_interval_index,2:ngen+1)=RTPSHBIDCOST.val';
if lossesCheck > eps
    [RTC_BUS_DELIVERY_FACTORS_VAL,RTC_GEN_DELIVERY_FACTORS_VAL,RTC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTC,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HRTC),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    RTC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTC);
    RTC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTC);
    RTC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTC);
end
rtscuc_running = 0;
RTSCUC_binding_interval_index = RTSCUC_binding_interval_index + 1;

if(RTCPrintResults == 1)
    saveRT('RTC',RTSCUC_binding_interval_index,PRTC,hour,minute,RTCPRODCOST.val,RTCGENSCHEDULE.val,RTCLMP.val,RTCUNITSTATUS.val,RTCLINEFLOW.val,RESERVETYPE.uels,nreserve,RTCGENRESERVESCHEDULE.val,RTCRCP.val,nbranch,BRANCHDATA.val,BRANCH.uels,HRTC,RTCLINEFLOWCTGC.val);
end;

%END INITIAL RTSCUC

%% Initial Real-Time SCED
%{
RTSCED for the very first interval
This interval is always perfect, there is no forced outages and it is used just to set up the rest of the day.
%}

tNow = toc(tStart);
fprintf('Complete! \n');
fprintf('Modeling Initial Real-Time Economic Dispatch...')

rtsced_running = 1;
RTD_LOOKAHEAD_INTERVAL_VAL(1:HRTD,1) = RTD_LOAD_FULL(1:HRTD,2)*24;

clear vg_forecast_tmp;
if nvcr > 0
    vg_forecast_tmp(1:HRTD,:) = RTD_VG_FULL(1:HRTD,3:end);
else
    vg_forecast_tmp = RTD_VG_FULL;
end;

i =1;
clear VG_FORECAST_VAL;
VG_FORECAST_VAL = [];
RTD_Field_size = size(RTD_VG_FIELD,2)-2;
while(i<=ngen)
    w = 1;
    while(w<=RTD_Field_size)
        if(strcmp(GEN.uels(1,i),RTD_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
            VG_FORECAST_VAL(1:HRTD,i) = vg_forecast_tmp(1:HRTD,w);
            w=RTD_Field_size;
        elseif(w==RTD_Field_size)            %gone through entire list of vg gens and gen is not included
            VG_FORECAST_VAL(1:HRTD,i) = zeros(HRTD,1);
        end;
        w = w+1;
    end;
    i = i+1;
end;

INTERVAL_MINUTES_VAL = zeros(HRTD,1);
INTERVAL_MINUTES_VAL(1,1) = IRTD;
for t=2:HRTD
    INTERVAL_MINUTES_VAL(t,1) = 60*(RTD_LOOKAHEAD_INTERVAL_VAL(t,1) - RTD_LOOKAHEAD_INTERVAL_VAL(t-1,1));
end;
ACTUAL_START_TIME = inf.*ones(ngen,1);ACTUAL_PUMPUP_TIME = inf.*ones(ngen,1);
for ast=1:ngen
    if RTSCUCBINDINGSCHEDULE(1,1+ast) > 0 && GENVALUE.val(ast,initial_MW) < eps
       ACTUAL_START_TIME(ast,1) = -1*IDAC; 
    end;
    if RTSCUCBINDINGPUMPSCHEDULE(1,1+ast) > 0 && STORAGEVALUE.val(ast,initial_pump_mw) < eps
       ACTUAL_PUMPUP_TIME(ast,1) = -1*IDAC; 
    end;
end;        
%commitment parameters for rtd, they cannot be adjusted in model
for i=1:ngen
    t = 1;
    UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
    UNIT_PUMPUPMINGENHELP_VAL(i,1) = 0;
    for t=1:HRTD
        lookahead_interval_index = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour) + 1;
        lookahead_interval_index = floor(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour+eps)+1;%see RTSCED during day operation.
        UNIT_STATUS_VAL(i,t) = STATUS(lookahead_interval_index,i);
        PUMPING_VAL(i,t) = PUMPSTATUS(lookahead_interval_index,i);
        %SU and SD trajectories
        [UNIT_STARTINGUP_VAL(i,t),UNIT_STARTUPMINGENHELP_VAL(i,t),UNIT_SHUTTINGDOWN_VAL(i,t)]=RTSCED_SUSD_Trajectories(STATUS,UNIT_STATUS_VAL,GENVALUE.val(:,gen_type),GENVALUE,ACTUAL_START_TIME,zeros(1,ngen+1),RTD_LOOKAHEAD_INTERVAL_VAL,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,su_time,sd_time,min_gen,initial_status,i,t,time,1);
        [UNIT_PUMPINGUP_VAL(i,t),UNIT_PUMPUPMINGENHELP_VAL(i,t),UNIT_PUMPINGDOWN_VAL(i,t)]=RTSCED_SUSD_Trajectories(PUMPSTATUS,PUMPING_VAL,GENVALUE.val(:,gen_type),STORAGEVALUE,ACTUAL_PUMPUP_TIME,zeros(1,ngen+1),RTD_LOOKAHEAD_INTERVAL_VAL,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,pump_su_time,pump_sd_time,min_pump,initial_pump_status,i,t,time,1);
    end;
end;

%This is for interval 0 initial ramping constraints
 ACTUAL_GEN_OUTPUT_VAL = GENVALUE.val(:,initial_MW); 
 LAST_GEN_SCHEDULE_VAL = GENVALUE.val(:,initial_MW);      
ACTUAL_PUMP_OUTPUT_VAL = STORAGEVALUE.val(:,initial_pump_mw); 
LAST_PUMP_SCHEDULE_VAL = STORAGEVALUE.val(:,initial_pump_mw);     
%ACTUAL_GEN_OUTPUT_VAL = RTSCUCBINDINGSCHEDULE(1,2:end)'; %placeholder for initial RTC
%LAST_GEN_SCHEDULE_VAL = RTSCUCBINDINGSCHEDULE(1,2:end)'; %placeholder for initial RTC   

for i=1:ngen
    if LAST_GEN_SCHEDULE_VAL(i,1) > 0
        LAST_STATUS_VAL(i,1) = 1;
    else
        LAST_STATUS_VAL(i,1) = 0;
    end;
    if ACTUAL_GEN_OUTPUT_VAL(i,1) > 0
        LAST_STATUS_ACTUAL_VAL(i,1) = 1;
    else
        LAST_STATUS_ACTUAL_VAL(i,1) = 0;
    end;
    if LAST_PUMP_SCHEDULE_VAL(i,1) > 0
        LAST_PUMPSTATUS_VAL(i,1) = 1;
    else
        LAST_PUMPSTATUS_VAL(i,1) = 0;
    end;
    if ACTUAL_PUMP_OUTPUT_VAL(i,1) > 0
        LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 1;
    else
        LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 0;
    end;
end;

for i=1:ngen
    RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTD+IRTD)*GENVALUE.val(i,ramp_rate) ...
        - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTD*GENVALUE.val(i,ramp_rate)));
    RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTD*GENVALUE.val(i,ramp_rate) ...
        - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTD+IRTD)*GENVALUE.val(i,ramp_rate)));
end;

%Storage value for RTD. 
%Basically, figure out the amount of money that the storage unit would
%receive in total dollars for the rest of the day including the end of the
%day. Then figure out that value in $/MWh
RTSCED_RESERVOIR_VALUE = zeros(ngen,1);
RTSCED_STORAGE_LEVEL = zeros(ngen,1);
for i=1:ngen
    if GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8  || GENVALUE.val(i,gen_type) == 12
        RTSCED_STORAGE_LEVEL(i,1) = STORAGEVALUE.val(i,initial_storage);
        RTSCED_RESERVOIR_VALUE(i,1) = ((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
            floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1)) ...
            +(SCUCLMP.val(GENBUS(i,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))...
            *SCUCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))') + STORAGEVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))...
            + sum(SCUCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    elseif GENVALUE.val(i,gen_type) == 9 || GENVALUE.val(i,gen_type) == 11
        RTSCED_RESERVOIR_VALUE(i,1) = GENVALUE.val(i,efficiency)*((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
            floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1)) ...
            +(SCUCLMP.val(GENBUS(i,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))...
            *SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))') + STORAGEVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))...
            + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    else
        RTSCED_RESERVOIR_VALUE(i) = 0;
    end;
end;

%STORAGEVALUE.val(:,reservoir_value) = RTSCED_RESERVOIR_VALUE;
STORAGEVALUE.val(:,initial_storage) = RTSCED_STORAGE_LEVEL;
rtd_final_storage_time_index_up = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
rtd_final_storage_time_index_lo = floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
% STORAGEVALUE.val(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)' ...
%     + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC),1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_up),2:ngen+1)' ...
%     - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)');
% END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price
% END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price and possibly change to negative

ik=1;
while ik ~= size(RTSCUCSTORAGELEVEL2,1)
    if RTD_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(RTSCUCSTORAGELEVEL2(:,1))
        STORAGEVALUE.val(:,final_storage) = RTSCUCSTORAGELEVEL2(end,2:end)';
        ik=size(RTSCUCSTORAGELEVEL2,1)-1;
    elseif RTSCUCSTORAGELEVEL2(ik,1) > RTD_LOOKAHEAD_INTERVAL_VAL(end)+eps
        STORAGEVALUE.val(:,final_storage) = RTSCUCSTORAGELEVEL2(ik-1,2:ngen+1)' ...
            + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps,1).*(RTSCUCSTORAGELEVEL2(ik,2:ngen+1)' ...
            - RTSCUCSTORAGELEVEL2(ik-1,2:ngen+1)');
        ik=size(RTSCUCSTORAGELEVEL2,1)-1;
    end
    ik = ik + 1;
end
RTDFINALSTORAGEIN=[RTDFINALSTORAGEIN,STORAGEVALUE.val(:,final_storage)];
END_STORAGE_PENALTY_PLUS_PRICE.val  = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price
END_STORAGE_PENALTY_MINUS_PRICE.val = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price and possibly change to negative

% sdcount2=[sdcount zeros(ngen,HRTD-1)];
sdcount2=zeros(ngen,HRTD);
for i=1:ngen
    if sum(UNIT_SHUTTINGDOWN_VAL(i,:)) > 0 && GENVALUE.val(i,gen_type) ~= 15 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16
        for tc=1:HRTD
            sdcount2(i,tc)= round((GENVALUE.val(i,sd_time)*60/IRTD))-round((min(GENVALUE.val(i,min_gen),LAST_GEN_SCHEDULE_VAL(i))/GENVALUE.val(i,min_gen))*(GENVALUE.val(i,sd_time)*60/IRTD))+(sum(INTERVAL_MINUTES_VAL(1:tc)'.*UNIT_SHUTTINGDOWN_VAL(i,1:tc))/IRTD);
        end
    end
end
pumpsdcount2=[pumpsdcount zeros(ngen,HRTD-1)];

% for i=1:ngen
%     if LAST_GEN_SCHEDULE_VAL(i) > eps && LAST_GEN_SCHEDULE_VAL(i) < GENVALUE.val(i,min_gen) && GENVALUE.val(i,initial_status) == 0
%         UNIT_STARTINGUP_VAL(i,:)=double((cumsum(INTERVAL_MINUTES_VAL)<=60*GENVALUE.val(i,su_time)*(1-LAST_GEN_SCHEDULE_VAL(i)/GENVALUE.val(i,min_gen)))');
%         LAST_GEN_SCHEDULE_VAL(i)=LAST_GEN_SCHEDULE_VAL(i)-((tRTD*GENVALUE.val(i,min_gen))/(60*GENVALUE.val(i,su_time)));
%     end
% end

% Initialize delivery factors based on initial conditions
if lossesCheck > eps
    [RTD_BUS_DELIVERY_FACTORS_VAL,RTD_GEN_DELIVERY_FACTORS_VAL,RTD_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTD,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HRTD),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    RTD_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTD);
    RTD_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTD);
    RTD_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTD);
end
CREATE_RTD_GAMS_VARIABLES

for x=1:size(RTSCED_RULES_PRE_in,1)
    try run(RTSCED_RULES_PRE_in{x,1});catch;end; 
end;
if strcmp(use_Default_RTSCED,'YES')
    per_unitize;
    wgdx(['TEMP', filesep, 'RTSCEDINPUT1'],PTDF,BRANCHDATA,PARTICIPATION_FACTORS,STORAGEPARAM,GEN,BUS,GENPARAM,RESERVEPARAM,...
        BRANCHPARAM,COSTCURVEPARAM,BRANCH,RESERVETYPE,LODF,PTDF_PAR,RESERVE_COST,BLOCK2,GENBLOCK,GENBUS2,BRANCHBUS2,GAMS_SOLVER,...
        QSC,BLOCK_CAP,BLOCK_COST,BIND_INTERVAL_1,LOAD_DIST,RESERVEVALUE,COST_CURVE,SYSTEMVALUE,SYSPARAM,NRTDINTERVAL,...
        RTDINTERVAL_LENGTH,RTDINTERVAL_ADVISORY_LENGTH,RTD_PROCESS_TIME,RTDINTERVAL_UPDATE,INTERVAL,INITIAL_DISPATCH_SLACK_SET);

    wgdx(['TEMP', filesep, 'RTSCEDINPUT2'],RESERVELEVEL,VG_FORECAST,UNIT_STATUS,UNIT_STARTINGUP,UNIT_STARTUPMINGENHELP,...
         UNIT_SHUTTINGDOWN,INTERVAL_MINUTES,ACTUAL_GEN_OUTPUT,LAST_GEN_SCHEDULE,RAMP_SLACK_UP,RAMP_SLACK_DOWN,...
         LAST_STATUS,LAST_STATUS_ACTUAL,GEN_FORCED_OUT,INITIAL_DISPATCH_SLACK,LOAD,PUMPING,ACTUAL_PUMP_OUTPUT,...
         LAST_PUMP_SCHEDULE,LAST_PUMPSTATUS,LAST_PUMPSTATUS_ACTUAL,UNIT_PUMPINGUP,UNIT_PUMPINGDOWN,UNIT_PUMPUPMINGENHELP,...
         END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,DELAYSD,RTD_SU_TWICE_IND,UNITSDCOUNT,DELAYPUMPSD,...
         PUMPUNITSDCOUNT,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,INTERCHANGE,LOSS_BIAS,UNIT_SHUTTINGDOWN_ACTUAL,...
         UNIT_PUMPINGDOWN_ACTUAL,UNIT_STARTINGUP_ACTUAL,UNIT_PUMPINGUP_ACTUAL,PUCOST_BLOCK_OFFSET,GENVALUE,STORAGEVALUE);

    RTSCED_GAMS_CALL = ['gams ..', filesep, 'RTSCED.gms Lo=2 Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USEGAMS="',USEGAMS,'"', gams_lp_flag];
    system(RTSCED_GAMS_CALL);
    [RTDPRODCOST,RTDGENSCHEDULE,RTDLMP,RTDUNITSTATUS,RTDUNITSTARTUP,RTDUNITSHUTDOWN,RTDGENRESERVESCHEDULE,...
        RTDRCP,RTDLOADDIST,RTDGENVALUE,RTDSTORAGEVALUE,RTDVGCURTAILMENT,RTDLOAD,RTDRESERVEVALUE,RTDRESERVELEVEL,RTDBRANCHDATA,...
        RTDBLOCKCOST,RTDBLOCKMW,RTDBPRIME,RTDBGAMMA,RTDLOSSLOAD,RTDINSUFFRESERVE,RTDGEN,RTDBUS,RTDHOUR,...
        RTDBRANCH,RTDRESERVETYPE,RTDSLACKBUS,RTDGENBUS,RTDBRANCHBUS,RTDPUMPSCHEDULE,RTDSTORAGELEVEL,RTDPUMPING] ...
        = getgamsdata('TOTAL_RTSCEDOUTPUT','RTSCED','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
end
try
rtdmodeltracker=1;
RTDModelSolutionStatus=zeros(60/tRTD*24*daystosimulate+1,4);
RTDModelSolutionStatus(rtdmodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus];
rtdmodeltracker=rtdmodeltracker+1;
catch
end;
for x=1:size(RTSCED_RULES_POST_in,1)
    try run(RTSCED_RULES_POST_in{x,1});catch;end;
end;

%assuming the solution started t minutes ago, and is directing
%units dispatch schedules I minutes ahead for a H hour
%optimization.

%Keep needed results
RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,1:1+ngen) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDGENSCHEDULE.val(:,1)'];
RTSCEDBINDINGLMP(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDLMP.val(:,1)'];
RTSCEDBINDINGMCC(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) MCC(:,1)'];
RTSCEDBINDINGMLC(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) MLC(:,1)'];
RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index,1:1+ngen) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDPUMPSCHEDULE.val(:,1)'];

for r=1:nreserve
    RTSCEDBINDINGRESERVE(RTSCED_binding_interval_index,1:1+ngen,r) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDGENRESERVESCHEDULE.val(:,1,r)'];
end;
RTSCEDBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDRCP.val(:,1)'];
RTSCEDBINDINGLOSSLOAD(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDLOSSLOAD.val(1,1)'];
RTSCEDBINDINGINSUFFICIENTRESERVE(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDINSUFFRESERVE.val(1,:)];
RTSCEDBINDINGOVERGENERATION(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) OVERGENERATION(1,1)'];
RTSCEDMARGINALLOSS(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) marginalLoss(1,1)];

DISPATCH = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,:);
PUMPDISPATCH = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index,:);
RESERVE = RTSCEDBINDINGRESERVE(RTSCED_binding_interval_index,:,:);
RESERVEPRICE = RTSCEDBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:);

RTSCEDSTORAGELEVEL(RTSCED_binding_interval_index,1:ngen)=RTDSTORAGELEVEL.val(:,1)';

if lossesCheck > eps
    [RTD_BUS_DELIVERY_FACTORS_VAL,RTD_GEN_DELIVERY_FACTORS_VAL,RTD_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTD,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HRTD),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    RTD_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTD);
    RTD_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTD);
    RTD_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTD);
end

%need to know if the vg was directed to be curtailed
binding_vg_curtailment = zeros(ngen,1); %Iniitialize here
for i=1:ngen
    if RTDVGCURTAILMENT.val(i,1) > eps && (GENVALUE.val(i,gen_type) == 7 || GENVALUE.val(i,gen_type) == 10)
        binding_vg_curtailment(i,1) = 1;
    else
        binding_vg_curtailment(i,1) = 0;
    end;
end;

rtsced_running = 0;
RTSCED_binding_interval_index = RTSCED_binding_interval_index + 1;
Solving_Initial_Models = 0;

%Print results named after time optimziation started. 
if(RTDPrintResults ==1)
    saveRT('RTD',RTSCED_binding_interval_index,PRTD,hour,minute,RTDPRODCOST.val,RTDGENSCHEDULE.val,RTDLMP.val,RTDUNITSTATUS.val,RTDLINEFLOW.val,RESERVETYPE.uels,nreserve,RTDGENRESERVESCHEDULE.val,RTDRCP.val,nbranch,BRANCHDATA.val,BRANCH.uels,HRTD,RTDLINEFLOWCTGC.val);
end;

%% Data adjust for real-time loop

AGC_interval_index = 1;
ACTUAL_GENERATION(1,:) = RTSCEDBINDINGSCHEDULE(1,:);
ACTUAL_PUMP(1,:) = RTSCEDBINDINGPUMPSCHEDULE(1,:);
ACTUAL_STORAGE_LEVEL(1,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) (RTDSTORAGELEVEL.val(:,1))'];
ACTUAL_START_TIME = inf.*ones(ngen,1);
ACTUAL_PUMPUP_TIME = inf.*ones(ngen,1);
if AGC_MODE ~= 5
    GENVALUE.val(:,gen_agc_mode) = AGC_MODE;
    DEFAULT_DATA.GENVALUE.val(:,gen_agc_mode) = AGC_MODE;
end;

%Get rid of yesterday wind and load to avoid confusion
RTC_LOAD_FULL = RTC_LOAD_FULL(HRTC+1:size_RTC_LOAD_FULL,:);
RTC_RESERVE_FULL = RTC_RESERVE_FULL(HRTC+1:size_RTC_RESERVE_FULL,:);
if nvcr > 0
    RTC_VG_FULL = RTC_VG_FULL(HRTC+1:size_RTC_VG_FULL,:);
end;
RTD_LOAD_FULL = RTD_LOAD_FULL(HRTD+1:size_RTD_LOAD_FULL,:);
RTD_RESERVE_FULL = RTD_RESERVE_FULL(HRTD+1:size_RTD_RESERVE_FULL,:);
if nvcr > 0
    RTD_VG_FULL = RTD_VG_FULL(HRTD+1:size_RTD_VG_FULL,:);
end;
if ninterchange > 0
    RTC_INTERCHANGE_FULL=RTC_INTERCHANGE_FULL(HRTC+1:end,:);
    RTD_INTERCHANGE_FULL=RTD_INTERCHANGE_FULL(HRTD+1:end,:);
end

size_RTC_LOAD_FULL = size(RTC_LOAD_FULL,1);
size_RTC_VG_FULL = size(RTC_VG_FULL,1);
size_RTC_RESERVE_FULL = size(RTC_RESERVE_FULL,1);
size_RTD_LOAD_FULL = size(RTD_LOAD_FULL,1);
size_RTD_VG_FULL = size(RTD_VG_FULL,1);
size_RTD_RESERVE_FULL = size(RTD_RESERVE_FULL,1);
finalvariablescounter=1;
 
%% Forced Outages

for x=1:size(FORCED_OUTAGE_PRE_in,1)
    try run(FORCED_OUTAGE_PRE_in{x,1});catch;end;
end;

DETERMINE_FORCED_GENERATOR_OUTAGES

for x=1:size(FORCED_OUTAGE_POST_in,1)
    try run(FORCED_OUTAGE_POST_in{x,1});catch;end;
end;

else
    time =end_time+1;
end;
end;

% Updates
dascuc_update = start_time + (24-GDAC); 
rtscuc_update = tRTC + 1;
rtsced_update = tRTD + 1;

fprintf('Complete! \n');
fprintf('Beginning FESTIV Simulation...\n');
if use_gui
  fprintf(1,'Study Period: %03d days %02d hours %02d minutes %02d seconds\n',simulation_days+floor((hour_end+eps)/24),rem(hour_end,24),minute_end,second_end);
  fprintf(1,'Simulation Time = %03d days %02d hrs %02d min %02d sec',day,hour,minute,second);
else
  fprintf('Study Period: %03d days %02d hours %02d minutes %02d seconds\n',simulation_days+floor((hour_end+eps)/24),rem(hour_end,24),minute_end,second_end);
end

for x=1:size(RT_LOOP_PRE_in,1)
    try run(RT_LOOP_PRE_in{x,1});catch;end; 
end;

while(time < end_time)
%% Day-Ahead SCUC 
    if dascuc_update + eps >= tDAC
        %{
        DAHORIZON: 
        (1)Fixed Horizon, variable endpoint, variable startpoint 
        (2)Fixed Endpoint, fixed startpoint, this will always start at hour 0
        (3)Fixed endpoint, variable startpoint horizon greater than or equal, 
        (4)Fixed endpoint, variable startpoint, horizon less than or equal.
        %}
        if DAHORIZONTYPE == 1
            dascuc_start_horizon = time + (24-GDAC);
            dascuc_end_horizon = dascuc_start_horizon + IDAC*HDAC;
        elseif DAHORIZONTYPE == 2
            dascuc_end_horizon  = floor((time+eps)/24)+IDAC*HDAC;
            dascuc_start_horizon = dascuc_end_horizon - HDAC;
        elseif DAHORIZONTYPE == 3
            dascuc_end_horizon = IDAC*HDAC*(1+ceil((time+(24-GDAC)-eps)/24));
            dascuc_start_horizon = time + (24-GDAC);
        elseif DAHORIZONTYPE == 4
            dascuc_end_horizon = IDAC*HDAC*(1+floor((time+(24-GDAC)+eps)/24));
            dascuc_start_horizon = time + (24-GDAC);
        else
            dascuc_start_horizon = 0;dascuc_end_horizon = 0;
        end;
        
        if dascuc_end_horizon - eps > end_time
        else    
        dascuc_update = 0;
        dascuc_running = 1;

        NDACINTERVAL.val = floor(dascuc_end_horizon-dascuc_start_horizon);

        clear RESERVELEVEL_VAL
        dac_int=1;
        t=1;
        while(t <= size_DAC_RESERVE_FULL && DAC_RESERVE_FULL(t,1)<= DASCUC_binding_interval_index+1)
            if(abs(DAC_RESERVE_FULL(t,1) - DASCUC_binding_interval_index) < eps)
                RESERVELEVEL_VAL(dac_int,1:size(DAC_RESERVE_FIELD,2)-2) = DAC_RESERVE_FULL(t,3:end);
                dac_int = dac_int+1;
            end;
            t = t+1;
        end;
        
        clear DA_INTERCHANGE_VAL
        dac_int=1;
        t=1;
        while(t <= size_DAC_RESERVE_FULL && DAC_INTERCHANGE_FULL(t,1)<= DASCUC_binding_interval_index+1)
            if(abs(DAC_INTERCHANGE_FULL(t,1) - DASCUC_binding_interval_index) < eps)
                DAC_INTERCHANGE_VAL(dac_int,1:size(DAC_INTERCHANGE_FIELD,2)-2) = DAC_INTERCHANGE_FULL(t,3:end);
                dac_int = dac_int+1;
            end;
            t = t+1;
        end;

        clear vg_forecast_tmp;
        dac_int=1;
        t=1;
        if nvcr > 0
            while(t <= size_DAC_VG_FULL && DAC_VG_FULL(t,1)<= DASCUC_binding_interval_index+1)
                if(abs(DAC_VG_FULL(t,1) - DASCUC_binding_interval_index) < eps)
                    vg_forecast_tmp(dac_int,:) = DAC_VG_FULL(t,3:end);
                    dac_int = dac_int+1;
                end;
                t = t+1;
            end;
        else
            vg_forecast_tmp = 0;
        end;

        clear VG_FORECAST_VAL;
        VG_FORECAST_VAL=zeros(NDACINTERVAL.val,ngen);
        i =1;
        while(i<=ngen)
            w = 1;
            while(w<=DAC_Field_size)
                if(strcmp(GEN.uels(1,i),DAC_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
                    VG_FORECAST_VAL(1:NDACINTERVAL.val,i) = vg_forecast_tmp(1:NDACINTERVAL.val,w);
                    w=DAC_Field_size;
                elseif(w==DAC_Field_size)        %gone through entire list of VG and gen is not included
                    VG_FORECAST_VAL(1:NDACINTERVAL.val,i) = zeros(NDACINTERVAL.val,1);
                end;
                w = w+1;
            end;
            i = i+1;
        end;

        %INITIAL STATUSES
%         GENVALUE              = DEFAULT_DATA.GENVALUE;
        for i=1:ngen
            GENVALUE.val(i,initial_status)=STATUS((dascuc_start_horizon-IDAC)*rtscuc_I_perhour+1,i);
            GENVALUE.val(i,initial_MW) = DASCUCSCHEDULE(dascuc_start_horizon/IDAC,i+1);
            STORAGEVALUE.val(i,initial_pump_status)=PUMPSTATUS((dascuc_start_horizon-IDAC)*rtscuc_I_perhour+1,i);
            STORAGEVALUE.val(i,initial_pump_mw) = DASCUCPUMPSCHEDULE(dascuc_start_horizon/IDAC,i+1);
            h = (dascuc_start_horizon-IDAC)*rtscuc_I_perhour/IDAC+1;
            hr_cnt = 0;
            if GENVALUE.val(i,initial_status) == 1
                while h>1
                    if STATUS(h,i) == 1
                        hr_cnt = hr_cnt + 1/rtscuc_I_perhour/IDAC;
                        h = h-1;
                    else
                        h = 0;
                    end;
                end;
            else
                 while h>1
                    if STATUS(h,i) == 0
                        hr_cnt = hr_cnt + 1/rtscuc_I_perhour/IDAC;
                        h = h-1;
                    else
                        h = 0;
                    end;
                end;
            end;
            GENVALUE.val(i,initial_hour) = hr_cnt;
            h = (dascuc_start_horizon-IDAC)*rtscuc_I_perhour/IDAC+1;
            if (GENVALUE.val(i,gen_type) == 6 ||GENVALUE.val(i,gen_type) == 8 ||GENVALUE.val(i,gen_type) == 11)
                hr_cnt2 = 0;
                if STORAGEVALUE.val(i,initial_pump_status) == 1
                    while h>1
                        if PUMPSTATUS(h,i) == 1
                            hr_cnt2 = hr_cnt2 + 1/rtscuc_I_perhour/IDAC;
                            h = h-1;
                        else
                            h = 0;
                        end;
                    end;
                else
                     while h>1
                        if PUMPSTATUS(h,i) == 0
                            hr_cnt2 = hr_cnt2 + 1/rtscuc_I_perhour/IDAC;
                            h = h-1;
                        else
                            h = 0;
                        end;
                    end;
                end;
                STORAGEVALUE.val(i,initial_pump_hour) = hr_cnt2;
                STORAGEVALUE.val(i,reservoir_value) = SCUCSTORAGEVALUE.val(i,reservoir_value);
                dascucstorage_now_index = floor(time/IDAC+eps)+1; %starting at 0
                STORAGEVALUE.val(i,initial_storage) = max(0,DASCUCSTORAGELEVEL(dascuc_start_horizon/IDAC,1+i) + (ACTUAL_STORAGE_LEVEL(AGC_interval_index-1,1+i) - DASCUCSTORAGELEVEL(dascucstorage_now_index,1+i)));%
                STORAGEVALUE.val(i,final_storage) = SCUCSTORAGEVALUE.val(i,final_storage);
           end;
        end;
        
        for i=1:ngen % round up to nearest IDAC interval
            GENVALUE.val(i,initial_hour)=ceil(GENVALUE.val(i,initial_hour)/IDAC)*IDAC;
        end

        UNIT_STATUS_ENFORCED_ON_VAL=zeros(ngen,HDAC);
        UNIT_STATUS_ENFORCED_OFF_VAL=ones(ngen,HDAC);
        for i=1:ngen
            if GENVALUE.val(i,initial_status) == 0
                for t=1:HDAC
                    if t <= GENVALUE.val(i,md_time) - GENVALUE.val(i,initial_hour)
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 0;
                    else
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
                    end
                end
            else
                for t=1:HDAC
                    if t <= GENVALUE.val(i,mr_time) - GENVALUE.val(i,initial_hour)
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 1;
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
                    else
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t)  = 0;
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
                    end
                end
            end
            if GENVALUE.val(i,gen_type)==15
                UNIT_STATUS_ENFORCED_OFF_VAL(i,1:HDAC) = 0;
            end
        end
        
        PUMPING_ENFORCED_ON_VAL=zeros(ngen,HDAC);
        PUMPING_ENFORCED_OFF_VAL=ones(ngen,HDAC);
        if size(STORAGEVALUE.uels{1, 1},1) > 0
            for i=1:ngen
                if STORAGEVALUE.val(i,initial_pump_status) == 0
                    for t=1:HDAC
                        if t <= GENVALUE.val(i,md_time) - STORAGEVALUE.val(i,initial_pump_hour)
                            PUMPING_ENFORCED_ON_VAL(i,t)  = 0;
                            PUMPING_ENFORCED_OFF_VAL(i,t) = 0;
                        else
                            PUMPING_ENFORCED_ON_VAL(i,t)  = 0;
                            PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
                        end
                    end
                else
                    for t=1:HDAC
                        if t <= STORAGEVALUE.val(i,min_pump_time) - STORAGEVALUE.val(i,initial_pump_hour)
                            PUMPING_ENFORCED_ON_VAL(i,t)  = 1;
                            PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
                        else
                            PUMPING_ENFORCED_ON_VAL(i,t)  = 0;
                            PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
                        end
                    end
                end
                if GENVALUE.val(i,gen_type)==15
                    PUMPING_ENFORCED_OFF_VAL(i,1:HDAC) = 0;
                end
            end
        end
        CREATE_DAC_GAMS_VARIABLES
        
        for x=1:size(DASCUC_RULES_PRE_in,1)
            try run(DASCUC_RULES_PRE_in{x,1});catch;end;
        end;
        if strcmp(use_Default_DASCUC,'YES')
            per_unitize;
            wgdx(['TEMP', filesep, 'DASCUCINPUT2'],LOSS_BIAS,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,LOAD,UNIT_STATUS_ENFORCED_ON,UNIT_STATUS_ENFORCED_OFF,...
                VG_FORECAST,RESERVELEVEL,INTERCHANGE,END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,PUMPING_ENFORCED_ON,PUMPING_ENFORCED_OFF,...
                GEN_FORCED_OUT,MAX_OFFLINE_TIME,INITIAL_STARTUP_COST_HELPER,INITIAL_STARTUP_PERIODS,INTERVALS_STARTED_AGO,INITIAL_PUMPUP_PERIODS,INTERVALS_PUMPUP_AGO,...
                INITIAL_SHUTDOWN_PERIODS,INTERVALS_SHUTDOWN_AGO,INITIAL_PUMPDOWN_PERIODS,INTERVALS_PUMPDOWN_AGO,GENVALUE,STORAGEVALUE);

            system(DASCUC_GAMS_CALL);
         
            [SCUCPRODCOST,SCUCGENSCHEDULE,SCUCLMP,SCUCUNITSTATUS,SCUCUNITSTARTUP,SCUCUNITSHUTDOWN,SCUCGENRESERVESCHEDULE,...
                SCUCRCP,SCUCLOADDIST,SCUCGENVALUE,SCUCSTORAGEVALUE,SCUCVGCURTAILMENT,SCUCLOAD,SCUCRESERVEVALUE,SCUCRESERVELEVEL,SCUCBRANCHDATA,...
                SCUCBLOCKCOST,SCUCBLOCKMW,SCUCBPRIME,SCUCBGAMMA,SCUCLOSSLOAD,SCUCINSUFFRESERVE,SCUCGEN,SCUCBUS,SCUCHOUR,...
                SCUCBRANCH,SCUCRESERVETYPE,SCUCSLACKBUS,SCUCGENBUS,SCUCBRANCHBUS,SCUCPUMPSCHEDULE,SCUCSTORAGELEVEL,SCUCPUMPING] ...
                = getgamsdata('TOTAL_DASCUCOUTPUT','DASCUC','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
        end
        
        try
        DAModelSolutionStatus=[DAModelSolutionStatus;time modelSolveStatus numberOfInfes solverStatus relativeGap];
        if ~isdeployed 
          dbstop if warning stophere:DACinfeasible;
        end
        if numberOfInfes ~= 0 
            DEBUG_DASCUC
            try winopen('TEMP\DASCUC.lst');catch;end;
            warning('stophere:DACinfeasible', 'Infeasible DAC Solution');
        end
        catch
        end;

        for x=1:size(DASCUC_RULES_POST_in,1)
            try run(DASCUC_RULES_POST_in{x,1});catch;end;
        end;
        DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
        DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCGENSCHEDULE.val)';
        DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
        DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2) = marginalLoss;
        DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
        DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCPUMPSCHEDULE.val)';
        DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
        DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nbus+1) = SCUCLMP.val';
        DASCUCCOMMITMENT=[DASCUCCOMMITMENT;SCUCUNITSTATUS.val'];
        for r=1:nreserve
            DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1,r)=(dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
            DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1,r) = SCUCGENRESERVESCHEDULE.val(:,:,r)';
        end;
        
        DASCUCRESERVEPRICE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,:) = [(dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)' SCUCRCP.val'];
        RESERVELEVELS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)'; 
        RESERVELEVELS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nreserve+1) = SCUCRESERVELEVEL.val;
        DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = (dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
        DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCVGCURTAILMENT.val)';

        pshbid_gdx.name = 'PSHBID';
        pshbid_gdx.form = 'full';
        pshbid_gdx.uels = GEN.uels;
        PSHBIDCOST=rgdx('TEMP/TOTAL_DASCUCOUTPUT',pshbid_gdx);
        for i = 1:ngen
            if PSHBIDCOST.val(i,1) < 1 && GENVALUE.val(i,gen_type) == 6
                PSHBIDCOST_VAL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,i) = PSHBIDCOST_VAL((DASCUC_binding_interval_index-1)*HDAC,i);
            else
                PSHBIDCOST_VAL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,i) =  PSHBIDCOST.val(i,1);
            end;
        end;
        
        DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1)=(dascuc_start_horizon:IDAC:dascuc_end_horizon-IDAC)';
        DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1)=SCUCSTORAGELEVEL.val';
        
        if lossesCheck > eps
            [DAC_BUS_DELIVERY_FACTORS_VAL,DAC_GEN_DELIVERY_FACTORS_VAL,DAC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HDAC,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HDAC),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
        else
            DAC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HDAC);
            DAC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HDAC);
            DAC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HDAC);
        end

        for h=1:NDACINTERVAL.val
            for i=1:ngen
                for h1 = 1:rtscuc_commitment_multiplier
                    if round(SCUCUNITSTATUS.val(i,min(NDACINTERVAL.val,h+1)))-round(SCUCUNITSTATUS.val(i,h)) == 1
                        STATUS(rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-rtscuc_commitment_multiplier+1,i) = round(SCUCUNITSTATUS.val(i,h));
                        STATUS(rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-rtscuc_commitment_multiplier+1+1:rtscuc_commitment_multiplier*(h+dascuc_start_horizon)+1,i) ...
                            = round(SCUCUNITSTATUS.val(i,h+1));
                    else
                        STATUS(rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-1+1,i) ...
                            = round(SCUCUNITSTATUS.val(i,h));
                    end;
                    if round(SCUCPUMPING.val(i,min(NDACINTERVAL.val,h+1)))-round(SCUCPUMPING.val(i,h)) == 1
                        PUMPSTATUS(rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-rtscuc_commitment_multiplier+1,i) = round(SCUCPUMPING.val(i,h));
                        PUMPSTATUS(rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-rtscuc_commitment_multiplier+1+1:rtscuc_commitment_multiplier*(h+dascuc_start_horizon)+1,i) ...
                            = round(SCUCPUMPING.val(i,h+1));
                    else
                        PUMPSTATUS(rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*(h+dascuc_start_horizon)-1+1,i) ...
                            = round(SCUCPUMPING.val(i,h));
                    end;
                end;
            end;
        end;
        dascuc_running = 0;
        DASCUC_binding_interval_index = DASCUC_binding_interval_index + 1;
        end;
    end;

%%  Real-Time SCUC  
    if rtscuc_update + eps >= tRTC
        rtscuc_update = 0;
        rtscuc_running = 1;
%         t = 1; 
%         rtc_int = 1;
        
        %Get vg and load data
        clear LOAD;
%         while(t <= size_RTC_LOAD_FULL && RTC_LOAD_FULL(t,1)<= (time/24 +eps))
%             if(abs(RTC_LOAD_FULL(t,1) - time/24) < eps)
%                 RTC_LOOKAHEAD_INTERVAL_VAL(rtc_int,1) = RTC_LOAD_FULL(t,2)*24;
%                 LOAD.val(rtc_int,1) = RTC_LOAD_FULL(t,3);
%                 rtc_int = rtc_int+1;
%             end;
%             t = t+1;
%         end;
        RTC_LOOKAHEAD_INTERVAL_VAL=zeros(HRTC,1);
        RTC_LOOKAHEAD_INTERVAL_VAL(:,1) = RTC_LOAD_FULL(HRTC*(RTSCUC_binding_interval_index-2)+1:HRTC*(RTSCUC_binding_interval_index-2)+HRTC,2)*24;
        LOAD.val=zeros(HRTC,1);
        LOAD.val(:,1)=RTC_LOAD_FULL(HRTC*(RTSCUC_binding_interval_index-2)+1:HRTC*(RTSCUC_binding_interval_index-2)+HRTC,3);
       

        clear vg_forecast_tmp;
%         t=1;
%         rtc_int = 1;
        if nvcr > 0
%             while(t <= size_RTC_VG_FULL && RTC_VG_FULL(t,1)<= (time/24 +eps))
%                 if(abs(RTC_VG_FULL(t,1) - time/24) < eps)
%                     vg_forecast_tmp(rtc_int,:) = RTC_VG_FULL(t,3:end);
%                     rtc_int = rtc_int+1;
%                 end;
%                 t = t+1;
%             end;
            vg_forecast_tmp=zeros(HRTC,nvcr);
            vg_forecast_tmp(:,:)=RTC_VG_FULL(HRTC*(RTSCUC_binding_interval_index-2)+1:HRTC*(RTSCUC_binding_interval_index-2)+HRTC,3:end);
        else
            vg_forecast_tmp = RTC_VG_FULL;
        end;
        
        clear VG_FORECAST_VAL;
        VG_FORECAST_VAL=zeros(HRTC,ngen);
        i =1;
        while(i<=ngen)
            w = 1;
            while(w<=RTC_Field_size)
                if(strcmp(GEN.uels(1,i),RTC_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
                    VG_FORECAST_VAL(1:HRTC,i) = vg_forecast_tmp(1:HRTC,w);
                    w=RTC_Field_size;
                elseif(w==RTC_Field_size)        %gone through entire list of VG and gen is not included
                    VG_FORECAST_VAL(1:HRTC,i) = zeros(HRTC,1);
                end;
                w = w+1;
            end;
            i = i+1;
        end;
       
        %Set up reserve levels 
        clear RESERVELEVEL_VAL
%         t = 1;
%         rtc_int = 1;
%         while(t <= size_RTC_RESERVE_FULL && RTC_RESERVE_FULL(t,1)<= (time/24 +eps))                
%             if(abs(RTC_RESERVE_FULL(t,1) - time/24) < eps)
%                 RESERVELEVEL_VAL(rtc_int,1:size(RTC_RESERVE_FIELD,2)-2) = RTC_RESERVE_FULL(t,3:end);
%                 rtc_int = rtc_int+1;
%             end;
%             t = t+1;
%         end;
        RESERVELEVEL_VAL=zeros(HRTC,nreserve);
        RESERVELEVEL_VAL(:,:)=RTC_RESERVE_FULL(HRTC*(RTSCUC_binding_interval_index-2)+1:HRTC*(RTSCUC_binding_interval_index-2)+HRTC,3:end);
 
        
        clear RTC_INTERCHANGE_VAL;
        RTC_INTERCHANGE_VAL=zeros(HRTC,max(1,ninterchange));
%         t = 1;
%         rtc_int = 1;
%         while(t <= size_RTC_RESERVE_FULL && RTC_INTERCHANGE_FULL(t,1)<= (time/24 +eps))                
%             if(abs(RTC_INTERCHANGE_FULL(t,1) - time/24) < eps)
%                 RTC_INTERCHANGE_VAL(rtc_int,1:size(RTC_INTERCHANGE_FIELD,2)-2) = RTC_INTERCHANGE_FULL(t,3:end);
%                 rtc_int = rtc_int+1;
%             end;
%             t = t+1;
%         end;
        RTC_INTERCHANGE_VAL(:,:)=RTC_INTERCHANGE_FULL(HRTC*(RTSCUC_binding_interval_index-2)+1:HRTC*(RTSCUC_binding_interval_index-2)+HRTC,3:end);
        
        if RTSCUC_binding_interval_index <=2
            INITIAL_DISPATCH_SLACK.val = [1;0];
        else
            INITIAL_DISPATCH_SLACK.val = [0;0];
        end;
        
        rtscucinterval_index = round(time*rtscuc_I_perhour) + 1+1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!
        
        clear UNIT_STATUS_ENFORCED_ON_VAL PUMPING_ENFORCED_ON_VAL UNIT_STATUS_ENFORCED_OFF_VAL PUMPING_ENFORCED_OFF_VAL

        i = 1;
        
        RTSCUCSTART_MODE = 1;
        RTSCUCSTART;

        while(i<=ngen) 
            if gen_outage_time(i,1) <= time - PRTC/60 && gen_repair_time(i,1) >= time -PRTC/60
                rtc_gen_forced_out(i,1) = 1;
            else
                rtc_gen_forced_out(i,1) = 0;
            end;
            t = 1;
            if rtc_gen_forced_out(i,1) == 1
                GEN_FORCED_OUT_VAL(i,1) = 1;
                UNIT_STATUS_ENFORCED_ON_VAL(i,1:HRTC) = 0;
                PUMPING_ENFORCED_ON_VAL(i,1:HRTC) = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,1:HRTC) = 0;
                PUMPING_ENFORCED_OFF_VAL(i,1:HRTC) = 0;
            else
                GEN_FORCED_OUT_VAL(i,1) = 0;
                while(t<=HRTC)
                    start_interval = t*IRTC/60;
                    lookahead_index = min(size(STATUS,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);    %This is based on SCUC starting at hour 0!!!
                    if  RTSCUCSTART_YES(i,t) == 1
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
                    else
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t) = STATUS(lookahead_index,i);
                    end;
                    if RTSCUCSHUT_YES(i,t) == 1
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
                    else
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = STATUS(lookahead_index,i);
                    end;
                    if  RTSCUCPUMPSTART_YES(i,t) == 1
                        PUMPING_ENFORCED_ON_VAL(i,t) = 0;
                    else
                        PUMPING_ENFORCED_ON_VAL(i,t) = PUMPSTATUS(lookahead_index,i);
                    end;
                    if RTSCUCPUMPSHUT_YES(i,t) == 1
                        PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
                    else
                        PUMPING_ENFORCED_OFF_VAL(i,t) = PUMPSTATUS(lookahead_index,i);
                    end;
%                     if HRTC > 1 && t==HRTC && RTSCUCBINDINGSCHEDULE(lookahead_index-1,i+1) > eps*10 && RTSCUCBINDINGSCHEDULE(lookahead_index-1,i+1) + eps < GENVALUE.val(i,min_gen) && RTSCUCBINDINGSCHEDULE(lookahead_index-1,i+1)-RTSCUCBINDINGSCHEDULE(lookahead_index-2,i+1) > 0
%                         UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 1;
%                         UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
%                     end
%                     if HRTC > 1 && t==HRTC && RTSCUCBINDINGPUMPSCHEDULE(lookahead_index-1,i+1) > eps*10 && RTSCUCBINDINGPUMPSCHEDULE(lookahead_index-1,i+1) + eps < STORAGEVALUE.val(i,min_pump) && RTSCUCBINDINGPUMPSCHEDULE(lookahead_index-1,i+1)-RTSCUCBINDINGPUMPSCHEDULE(lookahead_index-2,i+1) > 0
%                         PUMPING_ENFORCED_ON_VAL(i,t) = 1;
%                         PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
%                     end
                    t = t+1;
                end;
            end;
            i=i+1;
        end;
        
        for i=1:ngen
            if RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + eps < GENVALUE.val(i,min_gen) && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1)-RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > eps && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > eps
                numberOfIntervalsLeftInSD=round(RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/GENVALUE.val(i,min_gen)*max(0,ceil(GENVALUE.val(i,sd_time)*60/IRTC)));
                UNIT_STATUS_ENFORCED_OFF_VAL(i,max(1,numberOfIntervalsLeftInSD):min(HRTC,numberOfIntervalsLeftInSD+(GENVALUE.val(i,md_time)/IRTC*60)))=0;
                if numberOfIntervalsLeftInSD > 1 && RTSCUCSHUT_YES(i) == 1 && STATUS(i,RTSCUC_binding_interval_index+numberOfIntervalsLeftInSD)== 0 %EE added third bullet due to sd delay errors
                    UNIT_STATUS_ENFORCED_ON_VAL(i,1:max(1,numberOfIntervalsLeftInSD-1))=1;
                else
                    UNIT_STATUS_ENFORCED_ON_VAL(i,1)=0;
                end
            end
        end
        
        %For initial minimum on and down time constraints
        if(RTSCUC_binding_interval_index>1)
            for i=1:ngen
                if RTSCUCSTART_YES(i,1) || RTSCUCPUMPSTART_YES(i,1)
                    min_down_check_start_time = max(1,RTSCUC_binding_interval_index -GENVALUE.val(i,md_time)*rtscuc_I_perhour+1);
                    min_down_check_end_time = RTSCUC_binding_interval_index - 1;
                    min_down_interval_enforced=0;
                    min_down_check_time = min_down_check_start_time;
                    while min_down_check_time <= min_down_check_end_time
                        if min_down_check_time == 1
                            mindown_last_status = SCUCGENVALUE.val(i,initial_status)+SCUCSTORAGEVALUE.val(i,initial_pump_status);
                        else
                            mindown_last_status = STATUS(min_down_check_time-1,i)+PUMPSTATUS(min_down_check_time-1,i);
                        end;
                        if mindown_last_status - (STATUS(max(1,min_down_check_time),i)+ PUMPSTATUS(max(1,min_down_check_time),i))== 1  
                            min_down_interval_enforced = GENVALUE.val(i,md_time)*rtscuc_I_perhour - (min_down_check_end_time - min_down_check_time)-1;
                            min_down_check_time = min_down_check_end_time + 1;
                        else
                            min_down_interval_enforced = 0;
                            min_down_check_time = min_down_check_time + 1;
                        end;
                    end;
                    if min_down_interval_enforced > 0
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,1:min(HRTC,min_down_interval_enforced)) = 0;
                        PUMPING_ENFORCED_OFF_VAL(i,1:min(HRTC,min_down_interval_enforced)) = 0;
                    end;
                end;
                if RTSCUCSHUT_YES(i,1)
                    min_run_check_start_time = max(1,RTSCUC_binding_interval_index -GENVALUE.val(i,mr_time)*rtscuc_I_perhour+1);
                    min_run_check_end_time = RTSCUC_binding_interval_index - 1;
                    min_run_interval_enforced=0;
                    min_run_check_time = min_run_check_start_time;
                    while min_run_check_time <= min_run_check_end_time
                        if min_run_check_time == 1
                            minrun_last_status = SCUCGENVALUE.val(i,initial_status);
                        else
                            minrun_last_status = STATUS(min_run_check_time-1,i);
                        end;
                        if STATUS(min_run_check_time,i)-minrun_last_status == 1
                            min_run_interval_enforced = GENVALUE.val(i,mr_time)*rtscuc_I_perhour - (min_run_check_end_time - min_run_check_time)-1;
                            min_run_check_time = min_run_check_end_time + 1;
                        else
                            min_run_interval_enforced = 0;
                            min_run_check_time = min_run_check_time + 1;
                        end;
                    end;
                    if min_run_interval_enforced > 0 && rtc_gen_forced_out(i,1) ~= 1
                        UNIT_STATUS_ENFORCED_ON_VAL(i,1:min(HRTC,min_run_interval_enforced)) = 1;
                    end;
                end;
                if RTSCUCPUMPSHUT_YES(i,1)
                    min_pump_check_start_time = max(1,RTSCUC_binding_interval_index -STORAGEVALUE.val(i,min_pump_time)*rtscuc_I_perhour+1);
                    min_pump_check_end_time = RTSCUC_binding_interval_index - 1;
                    min_pump_interval_enforced=0;
                    min_pump_check_time = min_pump_check_start_time;
                    while min_pump_check_time <= min_pump_check_end_time
                        if min_pump_check_time == 1
                            minpump_last_status = SCUCSTORAGEVALUE.val(i,initial_pump_status);
                        else
                            minpump_last_status = PUMPSTATUS(min_pump_check_time-1,i);
                        end;
                        if PUMPSTATUS(min_pump_check_time,i)-minpump_last_status == 1
                            min_pump_interval_enforced = STORAGEVALUE.val(i,min_pump_time)*rtscuc_I_perhour - (min_pump_check_end_time - min_pump_check_time)-1;
                            min_pump_check_time = min_pump_check_end_time + 1;
                        else
                            min_pump_interval_enforced = 0;
                            min_pump_check_time = min_pump_check_time + 1;
                        end;
                    end;
                    if min_pump_interval_enforced > 0
                        PUMPING_ENFORCED_ON_VAL(i,1:min_pump_interval_enforced) = 1;
                    end;
                end;
            end;
        end;
        
        rtcdelaytrack=[];
        if time > 0 && time < daystosimulate*24-IRTC*HRTC/60
            indexofunitsSD=zeros(ngen,1);
            indexofunitsSD2=zeros(ngen,1);
            for i=1:ngen
                for j=1:HRTC-1
                    if (STATUS(RTSCUC_binding_interval_index+j,i)-STATUS(RTSCUC_binding_interval_index+j-1,i)==-1) && ( GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 )
                        indexofunitsSD(i,1)=RTSCUC_binding_interval_index+j;
                        temp=STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,:);
                        indexofunitsSD2(i,1)=find(temp(:,i),1,'last')+1;
                        rtctotaltime(i,1)=IRTC*(indexofunitsSD2(i,1)-1);
                    end
                end
            end

            rtcgennow=ACTUAL_GEN_OUTPUT_VAL;
            rtcstatusnow=LAST_STATUS_ACTUAL_VAL;
            rtctotalramp=GENVALUE.val(:,ramp_rate).*rtctotaltime;
            rtcminimumpossible=max(0,rtcgennow-(rtctotalramp.*rtcstatusnow));
            X=max(0,ceil((rtcminimumpossible-GENVALUE.val(:,min_gen))./(GENVALUE.val(:,ramp_rate)*IRTC)));
            
            for i=1:ngen
                rtcdelaycondition= (indexofunitsSD(i,1) > eps && ((rtcminimumpossible(i,1) > GENVALUE.val(i,min_gen)+eps) && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > GENVALUE.val(i,min_gen)))) && ( GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16);
                rtcdelaycondition2= ceil(((RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC))-eps*10) > eps && sum(STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,i)) < HRTC && (GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16) && GENVALUE.val(i,su_time) > tRTCstart;
                if rtcdelaycondition
                    STATUS(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i)=1;
                    STATUS(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=1;
                    RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=GENVALUE.val(i,min_gen);
                    RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    UNIT_STATUS_ENFORCED_ON_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRTC))=1;
                    UNIT_STATUS_ENFORCED_OFF_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRTC))=1;
                    delayedshutdown(i,1)=1;
                end
                if rtcdelaycondition2
                    STATUS(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1),i)=1;
                    STATUS(indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC))):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1),i+1)=1;
                    RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC))):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1),i+1)=GENVALUE.val(i,min_gen);
                    RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC))):min(size(STATUS,1),indexofunitsSD(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    UNIT_STATUS_ENFORCED_ON_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1,HRTC))=1;
                    UNIT_STATUS_ENFORCED_OFF_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+ceil(((LAST_GEN_SCHEDULE_VAL(i)-GENVALUE.val(i,min_gen))/(GENVALUE.val(i,ramp_rate)*IRTC)))-1,HRTC))=1;
                    delayedshutdown(i,1)=1;
                    rtcdelaytrack=[rtcdelaytrack;i];
                end
            end
        end
                
        for i=1:ngen
            if (RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) - RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > 0 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + 2*eps < GENVALUE.val(i,min_gen) && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) ~= 0) && ( GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16)
                numberOfIntervalsLeftInSD=round(RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/GENVALUE.val(i,min_gen)*max(0,ceil(GENVALUE.val(i,sd_time)*60/IRTC)));
%                 if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD ~= 0
                if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD > 1
                    UNIT_STATUS_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+GENVALUE.val(i,md_time)*60/IRTC))=0;
                end
            end
            if RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-2,i+1) - RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > 0 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + 2*eps < STORAGEVALUE.val(i,min_pump) && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1) ~= 0
                numberOfIntervalsLeftInSD=round(RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/STORAGEVALUE.val(i,min_pump)*max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRTC)));
                if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD > 1
                    PUMPING_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+STORAGEVALUE.val(i,min_pump_time)*60/IRTC))=0;
                    %PUMPING_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+0*60/IRTC))=0;
                end
            end
        end

        %This is for interval 0 initial ramping constraints
        LAST_GEN_SCHEDULE_VAL = RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index -1,2:ngen+1)';
        LAST_PUMP_SCHEDULE_VAL = RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index -1,2:ngen+1)';
        LAST_STATUS_VAL = STATUS(rtscucinterval_index -1,:)';
        LAST_PUMPSTATUS_VAL = PUMPSTATUS(rtscucinterval_index -1,:)';
        if time - PRTC/60 < ACTUAL_GENERATION(1,1)
            ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(1,2:ngen+1)'; 
            ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(1,2:ngen+1)'; 
        else
            ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(AGC_interval_index-round(PRTC*60/t_AGC),2:ngen+1)';
            ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(AGC_interval_index-round(PRTC*60/t_AGC)+1,2:ngen+1)';
        end;
        for i=1:ngen
            if abs(ACTUAL_GEN_OUTPUT_VAL(i,1)) > 0
                LAST_STATUS_ACTUAL_VAL(i,1) = 1;
            else
                LAST_STATUS_ACTUAL_VAL(i,1) = 0;
            end;
        end;
        for i=1:ngen
            if ACTUAL_PUMP_OUTPUT_VAL(i,1) > 0
                LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 1;
            else
                LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 0;
            end;
        end;

        for i=1:ngen
            RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTC+IRTC)*GENVALUE.val(i,ramp_rate)...
                - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTC*GENVALUE.val(i,ramp_rate)));
            RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTC*GENVALUE.val(i,ramp_rate)...
                - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTC+IRTC)*GENVALUE.val(i,ramp_rate)));
        end;

       %For su and sd trajectories
       for i=1:ngen
           STARTUP_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,su_time)*60/IRTC));
           SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,sd_time)*60/IRTC));%SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,sd_time)*60/IRTC)-1);
           PUMPUP_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_su_time)*60/IRTC));
           PUMPDOWN_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRTC));%PUMPDOWN_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRTC)-1);
           INITIAL_STARTUP_PERIODS_VAL(i,1) = 0;
           INTERVALS_STARTED_AGO_VAL(i,1) = 0;
           startup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-(STARTUP_PERIOD_VAL(i,1)-1)));
           STARTUP_MINGEN_HELPER_VAL(i,1) = 0;
           for startup_period_check_time = startup_period_check_end:RTSCUC_binding_interval_index-1
               if startup_period_check_time <=1
                   Initial_RTC_last_startup_check = GENVALUE.val(i,initial_status);
               else
                   Initial_RTC_last_startup_check = STATUS(startup_period_check_time-1,i);
               end;
               if STATUS(startup_period_check_time,i)-Initial_RTC_last_startup_check == 1 
                   if  ACTUAL_GEN_OUTPUT_VAL(i,1) > 0
                       INITIAL_STARTUP_PERIODS_VAL(i,1) =  1;
                   else
                       INITIAL_STARTUP_PERIODS_VAL(i,1) =  0;
                   end;
                   if startup_period_check_time <=1
                       if GENVALUE.val(i,su_time) >= IDAC + time
                           INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index + IDAC*60/IRTC-2;
                           STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE.val(i,min_gen)*(time + IRTC/60 - ...
                               -1*IDAC)/GENVALUE.val(i,su_time);
                       else
                           INTERVALS_STARTED_AGO_VAL(i,1) = 0;
                           INITIAL_STARTUP_PERIODS_VAL(i,1) = 0;
                       end;
                   else
                       INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index - startup_period_check_time;
                       STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE.val(i,min_gen)*(time + IRTC/60 - ...
                           RTSCUCBINDINGSTARTUP(startup_period_check_time,1))/GENVALUE.val(i,su_time);
                   end;
               end;
           end;
           INITIAL_PUMPUP_PERIODS_VAL(i,1) = 0;
           INTERVALS_PUMPUP_AGO_VAL(i,1) = 0;

           pumpup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-(PUMPUP_PERIOD_VAL(i,1)-1)));
           PUMPUP_MINGEN_HELPER_VAL(i,1) = 0;
           for pumpup_period_check_time = pumpup_period_check_end:RTSCUC_binding_interval_index-1
               if pumpup_period_check_time <=1
                   Initial_RTC_last_pumpup_check = STORAGEVALUE.val(i,initial_pump_status);
               else
                   Initial_RTC_last_pumpup_check = PUMPSTATUS(pumpup_period_check_time-1,i);
               end;
               if (PUMPSTATUS(pumpup_period_check_time,i)-Initial_RTC_last_pumpup_check) == 1
                   INITIAL_PUMPUP_PERIODS_VAL(i,1) = 1;
                   if pumpup_period_check_time <=1
                       if STORAGEVALUE.val(i,pump_su_time) >= IDAC + time
                           INTERVALS_PUMPUP_AGO_VAL(i,1) = RTSCUC_binding_interval_index + IDAC*60/IRTC-2;
                           PUMPUP_MINGEN_HELPER_VAL(i,1) = STORAGEVALUE.val(i,min_pump)*(time + IRTC/60 - ...
                               -1*IDAC)/STORAGEVALUE.val(i,pump_su_time);
                       else
                           INTERVALS_PUMPUP_AGO_VAL(i,1) = 0;
                           INITIAL_PUMPUP_PERIODS_VAL(i,1) = 0;
                       end;
                   else
                       INTERVALS_PUMPUP_AGO_VAL(i,1) = RTSCUC_binding_interval_index - pumpup_period_check_time;
                       PUMPUP_MINGEN_HELPER_VAL(i,1) = STORAGEVALUE.val(i,min_pump)*(time + IRTC/60 - ...
                           RTSCUCBINDINGPUMPSCHEDULE(pumpup_period_check_time,1))/STORAGEVALUE.val(i,pump_su_time);
                   end;
               end;
           end;

       end;

        %Storage value for RTC
        %Basically, figure out the amount of money that the storage unit would
        %receive in total dollars for the rest of the day including the end of the
        %day. Then figure out that value in $/MWh
        
        for i=1:ngen
            if GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8  || GENVALUE.val(i,gen_type) == 12
                if AGC_interval_index > round(PRTC*60/t_AGC)
                    RTSCUC_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRTC*60/t_AGC),i+1) - (PRTC/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRTC/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE.val(i,efficiency);
                else
                    RTSCUC_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+i);
                end;
                if ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1) > size(DASCUCLMP,1)
                    RTSCUC_RESERVOIR_VALUE(i,1) = SCUCSTORAGEVALUE.val(i,reservoir_value);
                else
                RTSCUC_RESERVOIR_VALUE(i,1) = mean([SCUCSTORAGEVALUE.val(i,reservoir_value) mean(DASCUCLMP(ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1):end,GENBUS(i,1)))]);
                %{
                RTSCUC_RESERVOIR_VALUE(i,1) = (GENVALUE.val(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps-eps,1))*SCUCLMP.val(GENBUS(i,1),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))')) + GENVALUE.val(i,storage_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
                %}
                end;
            elseif GENVALUE.val(i,gen_type) == 9 || GENVALUE.val(i,gen_type) == 11
                RTSCUC_RESERVOIR_VALUE(i,1) = GENVALUE.val(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + GENVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
            else
                RTSCUC_RESERVOIR_VALUE(i) = 0;
            end;
        end;
        
        %STORAGEVALUE.val(:,reservoir_value) = RTSCUC_RESERVOIR_VALUE;
        STORAGEVALUE.val(:,initial_storage) = RTSCUC_STORAGE_LEVEL;
%         ela(RTSCUC_binding_interval_index,1) = RTSCUC_RESERVOIR_VALUE(end,1);
%         ela2(RTSCUC_binding_interval_index,1) = RTSCUC_STORAGE_LEVEL(end,1);
        rtc_final_storage_time_index_up = ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
        rtc_final_storage_time_index_lo = floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
%         STORAGEVALUE.val(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)' ...
%             + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_up),2:ngen+1)' ...
%             - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)');

        ik=1;
        while ik ~= size(DASCUCSTORAGELEVEL,1)
            if RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(DASCUCSTORAGELEVEL(:,1))
                STORAGEVALUE.val(:,final_storage) = RTCFINALSTORAGEIN(:,end);
                ik=size(DASCUCSTORAGELEVEL,1)-1;
            elseif DASCUCSTORAGELEVEL(ik,1) > RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps
                STORAGEVALUE.val(:,final_storage) = DASCUCSTORAGELEVEL(ik-1,2:ngen+1)' ...
                    + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(ik,2:ngen+1)' ...
                    - DASCUCSTORAGELEVEL(ik-1,2:ngen+1)');
                ik=size(DASCUCSTORAGELEVEL,1)-1;
            end
            ik = ik + 1;
        end        
        END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);
        END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);
        
        RTCFINALSTORAGEIN=[RTCFINALSTORAGEIN,STORAGEVALUE.val(:,final_storage)];

        UNIT_STATUS_ENFORCED_ON_VAL(GENVALUE.val(:,gen_type)==7|GENVALUE.val(:,gen_type)==10|GENVALUE.val(:,gen_type)==14)=0;
        UNIT_STATUS_ENFORCED_OFF_VAL(GENVALUE.val(:,gen_type)==7|GENVALUE.val(:,gen_type)==10|GENVALUE.val(:,gen_type)==14)=1;
        
        CREATE_RTC_GAMS_VARIABLES
        
        for x=1:size(RTSCUC_RULES_PRE_in,1)
            try run(RTSCUC_RULES_PRE_in{x,1});catch; end; 
        end;
        if strcmp(use_Default_RTSCUC,'YES')
            per_unitize;
            wgdx(['TEMP', filesep, 'RTSCUCINPUT2'],UNIT_STARTUP_ACTUAL,UNIT_PUMPUP_ACTUAL,LAST_STARTUP,LAST_SHUTDOWN,PUCOST_BLOCK_OFFSET,INTERCHANGE,LOSS_BIAS,...
                DELAYSD,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,PUMPING_ENFORCED_OFF,INITIAL_PUMPUP_PERIODS,...
                INTERVALS_PUMPUP_AGO,PUMPING_ENFORCED_ON,ACTUAL_PUMP_OUTPUT,LAST_PUMP_SCHEDULE,LAST_PUMPSTATUS,LAST_PUMPSTATUS_ACTUAL,INITIAL_DISPATCH_SLACK,...
                LOAD,LAST_STATUS_ACTUAL,GEN_FORCED_OUT,INTERVALS_STARTED_AGO,INITIAL_STARTUP_PERIODS,ACTUAL_GEN_OUTPUT,LAST_GEN_SCHEDULE,RAMP_SLACK_UP,RAMP_SLACK_DOWN,...
                LAST_STATUS,UNIT_STATUS_ENFORCED_ON,UNIT_STATUS_ENFORCED_OFF,RESERVELEVEL,VG_FORECAST,GENVALUE,STORAGEVALUE);

            system(RTSCUC_GAMS_CALL);
            [RTCPRODCOST,RTCGENSCHEDULE,RTCLMP,RTCUNITSTATUS,RTCUNITSTARTUP,RTCUNITSHUTDOWN,RTCGENRESERVESCHEDULE,...
                RTCRCP,RTCLOADDIST,RTCGENVALUE,RTCSTORAGEVALUE,RTCVGCURTAILMENT,RTCLOAD,RTCRESERVEVALUE,RTCRESERVELEVEL,RTCBRANCHDATA,...
                RTCBLOCKCOST,RTCBLOCKMW,RTCBPRIME,RTCBGAMMA,RTCLOSSLOAD,RTCINSUFFRESERVE,RTCGEN,RTCBUS,RTCHOUR,...
                RTCBRANCH,RTCRESERVETYPE,RTCSLACKBUS,RTCGENBUS,RTCBRANCHBUS,RTCPUMPSCHEDULE,RTCSTORAGELEVEL,RTCPUMPING] ...
                = getgamsdata('TOTAL_RTSCUCOUTPUT','RTSCUC','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
        end
        try
        RTCModelSolutionStatus(rtcmodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
        rtcmodeltracker=rtcmodeltracker+1;
        if ~isdeployed
          dbstop if warning stophere:RTCinfeasible;
        end
        if numberOfInfes ~= 0 && (max(rpu_time) < time - PRTC/60 || max(rpu_time) > time)
            DEBUG_RTSCUC
            try winopen('TEMP\RTSCUC.lst');catch;end;
            warning('stophere:RTCinfeasible', 'Infeasible RTC Solution');
        end
        catch
        end;
        
        for x=1:size(RTSCUC_RULES_POST_in,1)
            try run(RTSCUC_RULES_POST_in{x,1});catch; end; 
        end;

        RTSCUCBINDINGCOMMITMENT(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
        RTSCUCBINDINGSHUTDOWN(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
        RTSCUCBINDINGLMP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
        RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
        RTSCUCSTORAGELEVEL2(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),1)=RTC_LOOKAHEAD_INTERVAL_VAL;
        RTPSHBIDCOST_VAL(RTSCUC_binding_interval_index,1)=RTC_LOOKAHEAD_INTERVAL_VAL(1);
        if max(rpu_time) >= time - PRTC/60 && max(rpu_time) < time
        else
        RTSCUCBINDINGCOMMITMENT(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCUNITSTATUS.val(:,:)');
        RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCPUMPING.val(:,:)');
        RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCUNITSTARTUP.val(:,:)');
        STATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,:) = round(RTCUNITSTATUS.val(:,:)');
        PUMPSTATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,:) = round(RTCPUMPING.val(:,:)');
        RTSCUCBINDINGSHUTDOWN(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = round(RTCUNITSHUTDOWN.val(:,:)');
        RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = RTCGENSCHEDULE.val(:,:)';
        RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = RTCPUMPSCHEDULE.val(:,:)';
        RTSCUCBINDINGLMP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+nbus) = RTCLMP.val(:,:)';
        for i=1:ngen
            if RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index,1+i) == 1;
                RTSCUC_INITIAL_START_TIME(i,1) = time;
            end;
        end;
        for i=1:ngen
            if RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index,1+i) - PUMPSTATUS(RTSCUC_binding_interval_index-1,i) == 1;
                RTSCUC_INITIAL_PUMPUP_TIME(i,1) = time;
            end;
        end;
        RTSCUCBINDINGRESERVESCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGRESERVEPRICE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGINSUFFICIENTRESERVE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGLOSSLOAD(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCBINDINGOVERGENERATION(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
        for r=1:nreserve
            RTSCUCBINDINGRESERVESCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1:1+ngen,r) = [RTC_LOOKAHEAD_INTERVAL_VAL RTCGENRESERVESCHEDULE.val(:,:,r)'];
        end;
        RTSCUCBINDINGRESERVEPRICE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:nreserve+1) =  RTCRCP.val';
        RTSCUCBINDINGINSUFFICIENTRESERVE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:nreserve+1) =  RTCINSUFFRESERVE.val;
        RTSCUCBINDINGLOSSLOAD(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) =  RTCLOSSLOAD.val;
        RTSCUCBINDINGOVERGENERATION(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) = OVERGENERATION;
        RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) = marginalLoss(1,1);
        
        RTSCUCSTORAGELEVEL2(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),2:ngen+1)=RTCSTORAGELEVEL.val';
        
        if lossesCheck > eps
            [RTC_BUS_DELIVERY_FACTORS_VAL,RTC_GEN_DELIVERY_FACTORS_VAL,RTC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTC,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HRTC),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
        else
            RTC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTC);
            RTC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTC);
            RTC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTC);
        end

        pshbid_gdx.name = 'PSHBID';
        pshbid_gdx.form = 'full';
        pshbid_gdx.uels = GEN.uels;
        RTPSHBIDCOST=rgdx('TEMP/TOTAL_RTSCUCOUTPUT',pshbid_gdx);
%         RTPSHBIDCOST_VAL((RTSCUC_binding_interval_index-1)*HRTC+1:HRTC+(RTSCUC_binding_interval_index-1)*HRTC,:) =  ones(HRTC,1)*RTPSHBIDCOST.val';
%         RTPSHBIDCOST_VAL(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),:) =  ones(HRTC,1)*RTPSHBIDCOST.val';
        RTPSHBIDCOST_VAL(RTSCUC_binding_interval_index,2:ngen+1)=RTPSHBIDCOST.val';
        end;
        rtscuc_running = 0;
        
        if ~isempty(rtcdelaytrack)
            delayedshutdown(rtcdelaytrack,1)=0;
        end
        
        RTSCUC_binding_interval_index = RTSCUC_binding_interval_index + 1;
        
        if(RTCPrintResults == 1)
            saveRT('RTC',RTSCUC_binding_interval_index,PRTC,hour,minute,RTCPRODCOST.val,RTCGENSCHEDULE.val,RTCLMP.val,RTCUNITSTATUS.val,RTCLINEFLOW.val,RESERVETYPE.uels,nreserve,RTCGENRESERVESCHEDULE.val,RTCRCP.val,nbranch,BRANCHDATA.val,BRANCH.uels,HRTC,RTCLINEFLOWCTGC.val);
        end;
    end;
    
%% Real-Time SCED
    if rtsced_update + eps >= tRTD  
        rtsced_update = 0;
        rtsced_running = 1;
        
        if ~use_gui
          fprintf('Simulation Time = %02d days %02d hrs %02d min %02d sec\n', day, hour, minute, second);
        end
        
%         t = 1; 
%         rtd_int = 1;

        clear LOAD;
%         while(t <= size_RTD_LOAD_FULL && RTD_LOAD_FULL(t,1)<= (time/24 +eps))
%             if(abs(RTD_LOAD_FULL(t,1) - time/24) < eps)
%                 RTD_LOOKAHEAD_INTERVAL_VAL(rtd_int,1) = RTD_LOAD_FULL(t,2)*24;
%                 LOAD.val(rtd_int,1) = RTD_LOAD_FULL(t,3);
%                 rtd_int = rtd_int+1;
%             end;
%             t = t+1;
%         end;
        RTD_LOOKAHEAD_INTERVAL_VAL=zeros(HRTD,1);
        RTD_LOOKAHEAD_INTERVAL_VAL(:,1) = RTD_LOAD_FULL(HRTD*(RTSCED_binding_interval_index-2)+1:HRTD*(RTSCED_binding_interval_index-2)+HRTD,2)*24;
        LOAD.val=zeros(HRTD,1);
        LOAD.val(:,1)=RTD_LOAD_FULL(HRTD*(RTSCED_binding_interval_index-2)+1:HRTD*(RTSCED_binding_interval_index-2)+HRTD,3);
        
%         t=1;
%         rtd_int = 1;
        clear vg_forecast_tmp;
        if nvcr > 0
%             while(t <= size_RTD_VG_FULL && RTD_VG_FULL(t,1)<= (time/24 +eps))
%                 if(abs(RTD_VG_FULL(t,1) - time/24) < eps)
%                     vg_forecast_tmp(rtd_int,:) = RTD_VG_FULL(t,3:end);
%                     rtd_int = rtd_int+1;
%                 end;
%                 t = t+1;
%             end;
            vg_forecast_tmp=zeros(HRTD,nvcr);
            vg_forecast_tmp(:,:)=RTD_VG_FULL(HRTD*(RTSCED_binding_interval_index-2)+1:HRTD*(RTSCED_binding_interval_index-2)+HRTD,3:end);
        else
            vg_forecast_tmp = RTD_VG_FULL;
        end;
        
        i =1;
        clear VG_FORECAST_VAL;
        VG_FORECAST_VAL=zeros(HRTD,ngen);
        while(i<=ngen)
            w = 1;
            while(w<=RTD_Field_size)
                if(strcmp(GEN.uels(1,i),RTD_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
                %if(strcmp(GEN.uels(1,i),RTD_VG_FIELD(1+w)))%left here just in case but both matlab versions should work on previous now.
                    VG_FORECAST_VAL(1:HRTD,i) = vg_forecast_tmp(1:HRTD,w);
                    w=RTD_Field_size;
                elseif(w==RTD_Field_size)            %gone through entire list of VG and gen is not included
                    VG_FORECAST_VAL(1:HRTD,i) = zeros(HRTD,1);
                end;
                w = w+1;
            end;
            i = i+1;
        end;
        
        %Set up reserve levels based on the hour
        %So far reserve values are the same in RTD as SCUC for all hours
        clear RESERVELEVEL_VAL;
%         t = 1;
%         rtd_int = 1;
%         while(t <= size_RTD_RESERVE_FULL && RTD_RESERVE_FULL(t,1)<= (time/24 +eps))                
%             if(abs(RTD_RESERVE_FULL(t,1) - time/24) < eps)
%                 RESERVELEVEL_VAL(rtd_int,1:size(RTD_RESERVE_FIELD,2)-2) = RTD_RESERVE_FULL(t,3:end);
%                 rtd_int = rtd_int+1;
%             end;
%             t = t+1;
%         end;
        RESERVELEVEL_VAL=zeros(HRTD,nreserve);
        RESERVELEVEL_VAL(:,:)=RTD_RESERVE_FULL(HRTD*(RTSCED_binding_interval_index-2)+1:HRTD*(RTSCED_binding_interval_index-2)+HRTD,3:end);
        
        clear RTD_INTERCHANGE_VAL;
        RTD_INTERCHANGE_VAL=zeros(HRTD,max(1,ninterchange));
%         t = 1;
%         rtd_int = 1;
%         while(t <= size_RTD_RESERVE_FULL && RTD_INTERCHANGE_FULL(t,1)<= (time/24 +eps))                
%             if(abs(RTD_INTERCHANGE_FULL(t,1) - time/24) < eps)
%                 RTD_INTERCHANGE_VAL(rtd_int,1:size(RTD_INTERCHANGE_FIELD,2)-2) = RTD_INTERCHANGE_FULL(t,3:end);
%                 rtd_int = rtd_int+1;
%             end;
%             t = t+1;
%         end;
        RTD_INTERCHANGE_VAL(:,:)=RTD_INTERCHANGE_FULL(HRTD*(RTSCED_binding_interval_index-2)+1:HRTD*(RTSCED_binding_interval_index-2)+HRTD,3:end);
                
        if RTSCED_binding_interval_index <=2
            INITIAL_DISPATCH_SLACK.val = [1;0];
        else
            INITIAL_DISPATCH_SLACK.val = [0;0];
        end;
        
        %for the ramping constraint between interval 1 and 2;
        INTERVAL_MINUTES_VAL = zeros(HRTD,1);
        INTERVAL_MINUTES_VAL(1,1) = IRTD;
        INTERVAL_MINUTES_VAL(2:end,1) = 60.*diff(RTD_LOOKAHEAD_INTERVAL_VAL);
%         for t=2:HRTD
%             INTERVAL_MINUTES_VAL(t,1) = 60*(RTD_LOOKAHEAD_INTERVAL_VAL(t,1) - RTD_LOOKAHEAD_INTERVAL_VAL(t-1,1));
%         end;

        
        %This is for interval 0 initial ramping constraints
        LAST_GEN_SCHEDULE_VAL = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index -1,2:1+ngen)';
        LAST_PUMP_SCHEDULE_VAL = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index -1,2:1+ngen)';
        if time - PRTD/60 < ACTUAL_GENERATION(1,1)
            ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(1,2:end)'; 
            ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(1,2:end)'; 
        else
            ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(AGC_interval_index-round(PRTD*60/t_AGC),2:ngen+1)'; %placeholder
            ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(AGC_interval_index-round(PRTD*60/t_AGC),2:ngen+1)'; %placeholder
        end;

%         for i=1:ngen
%             RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRTD+IRTD)*GENVALUE.val(i,ramp_rate) ...
%                 - (LAST_GEN_SCHEDULE_VAL(i,1) + tRTD*GENVALUE.val(i,ramp_rate)));
%             RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) - tRTD*GENVALUE.val(i,ramp_rate) ...
%                 - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRTD+IRTD)*GENVALUE.val(i,ramp_rate)));
%         end;
        RAMP_SLACK_UP_VAL(:,1) = max(0,ACTUAL_GEN_OUTPUT_VAL-(PRTD+IRTD).*GENVALUE.val(:,ramp_rate)-(LAST_GEN_SCHEDULE_VAL+tRTD.*GENVALUE.val(:,ramp_rate)));
        RAMP_SLACK_DOWN_VAL(:,1) = max(0,LAST_GEN_SCHEDULE_VAL-tRTD.*GENVALUE.val(:,ramp_rate)-(ACTUAL_GEN_OUTPUT_VAL+(PRTD+IRTD).*GENVALUE.val(:,ramp_rate)));

        %Setting up the hard commitment constraints for quickstarts and other units.
        %Also want to make sure that quickstarts that have not met their min run times or min down times are honored here.
        i = 1;
        while(i<=ngen)
            if abs(LAST_GEN_SCHEDULE_VAL(i,1)) > 0
                LAST_STATUS_VAL(i,1) = 1;
            else
                LAST_STATUS_VAL(i,1) = 0;
            end;
            if abs(ACTUAL_GEN_OUTPUT_VAL(i,1)) > 0
                LAST_STATUS_ACTUAL_VAL(i,1) = 1;
            else
                LAST_STATUS_ACTUAL_VAL(i,1) = 0;
            end;
            if LAST_PUMP_SCHEDULE_VAL(i,1) > 0
                LAST_PUMPSTATUS_VAL(i,1) = 1;
            else
                LAST_PUMPSTATUS_VAL(i,1) = 0;
            end;
            if ACTUAL_PUMP_OUTPUT_VAL(i,1) > 0
                LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 1;
            else
                LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 0;
            end;
            if  gen_outage_time(i,1) <= time - PRTD/60 && gen_repair_time(i,1) >= time - PRTD/60
                rtd_gen_forced_out(i,1) = 1;
            else
                rtd_gen_forced_out(i,1) = 0;
            end;
            if time==0
                for ast=1:ngen
                    if RTSCUCBINDINGSCHEDULE(1,1+ast) > 0 && GENVALUE.val(ast,initial_MW) < eps
                       ACTUAL_START_TIME(ast,1) = -1*IDAC; 
                    end;
                    if RTSCUCBINDINGPUMPSCHEDULE(1,1+ast) > 0 && STORAGEVALUE.val(ast,initial_pump_mw) < eps
                       ACTUAL_PUMPUP_TIME(ast,1) = -1*IDAC; 
                    end;
                end;
            end
            if(rtd_gen_forced_out(i,1) == 1)
               GEN_FORCED_OUT_VAL(i,1) = 1;
               UNIT_STATUS_VAL(i,1:HRTD) = 0;
               UNIT_STARTINGUP_VAL(i,1:HRTD) = 0;
               UNIT_SHUTTINGDOWN_VAL(i,1) = LAST_STATUS_VAL(i,1);
               UNIT_SHUTTINGDOWN_VAL(i,2:HRTD) = 0;
               PUMPING_VAL(i,1:HRTD) = 0;
               UNIT_PUMPINGUP_VAL(i,1:HRTD) = 0;
               UNIT_PUMPINGDOWN_VAL(i,1) = LAST_PUMPSTATUS_VAL(i,1);
               UNIT_PUMPINGDOWN_VAL(i,2:HRTD) = 0;
               UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
               UNIT_PUMPUPMINGENHELP_VAL(i,1) = 0;
             else
                GEN_FORCED_OUT_VAL(i,1) = 0;
                t = 1;
                UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
                UNIT_PUMPUPMINGENHELP_VAL(i,1) = 0;
                while(t <= HRTD)
                    lookahead_interval_index_ceil = min(size(STATUS,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);
                    lookahead_interval_index_floor = min(size(STATUS,1),floor(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour+eps) + 1); %fixed was turning units off at the wrong time.
                    %determining what the unit status will be will depend on the RTSCUC status at both sides of its time interval.
                    if GENVALUE.val(i,min_gen) == 0 && (GENVALUE.val(i,gen_type) == 7 || GENVALUE.val(i,gen_type) == 10 || GENVALUE.val(i,gen_type) == 14  || GENVALUE.val(i,gen_type) == 16)
                        UNIT_STATUS_VAL(i,t) = 1; %keeping all vg on
                    elseif STATUS(lookahead_interval_index_ceil,i) == STATUS(lookahead_interval_index_floor,i)
                        UNIT_STATUS_VAL(i,t) = STATUS(lookahead_interval_index_ceil,i);
                    elseif STATUS(lookahead_interval_index_ceil,i) == 1
                        if GENVALUE.val(i,su_time) > RTSCUCBINDINGCOMMITMENT(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                            UNIT_STATUS_VAL(i,t) = 1;
                        else
                            UNIT_STATUS_VAL(i,t) = 0;
                        end;
                    elseif STATUS(lookahead_interval_index_ceil,i) == 0
                        UNIT_STATUS_VAL(i,t) = 1;
                    end;
                    if PUMPSTATUS(lookahead_interval_index_ceil,i) == PUMPSTATUS(lookahead_interval_index_floor,i)
                        PUMPING_VAL(i,t) = PUMPSTATUS(lookahead_interval_index_ceil,i);
                    elseif PUMPSTATUS(lookahead_interval_index_ceil,i) == 1
                        if STORAGEVALUE.val(i,pump_su_time) > RTSCUCBINDINGCOMMITMENT(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                            PUMPING_VAL(i,t) = 1;
                        else
                            PUMPING_VAL(i,t) = 0;
                        end;
                    elseif PUMPSTATUS(lookahead_interval_index_ceil,i) == 0
                        PUMPING_VAL(i,t) = 1;
                    end;
                    %SU and SD trajectories
                    [UNIT_STARTINGUP_VAL(i,t),UNIT_STARTUPMINGENHELP_VAL(i,t),UNIT_SHUTTINGDOWN_VAL(i,t)]=RTSCED_SUSD_Trajectories(STATUS,UNIT_STATUS_VAL,GENVALUE.val(:,gen_type),GENVALUE,ACTUAL_START_TIME,RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,:),RTD_LOOKAHEAD_INTERVAL_VAL,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,su_time,sd_time,min_gen,initial_status,i,t,time,0);
                    [UNIT_PUMPINGUP_VAL(i,t),UNIT_PUMPUPMINGENHELP_VAL(i,t),UNIT_PUMPINGDOWN_VAL(i,t)]=RTSCED_SUSD_Trajectories(PUMPSTATUS,PUMPING_VAL,GENVALUE.val(:,gen_type),STORAGEVALUE,ACTUAL_PUMPUP_TIME,RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1,:),RTD_LOOKAHEAD_INTERVAL_VAL,INTERVAL_MINUTES_VAL,rtscuc_I_perhour,eps,pump_su_time,pump_sd_time,min_pump,initial_pump_status,i,t,time,0);
                    t = t+1;
                end;
            end;
            i = i+1;
        end;
        
        if RTSCED_binding_interval_index == 1
            for ast=1:ngen
                if RTSCUCBINDINGSCHEDULE(1,1+ast) > 0 && GENVALUE.val(ast,initial_MW) < eps
                   ACTUAL_START_TIME(ast,1) = time-1*IDAC; 
                end;
                if RTSCUCBINDINGPUMPSCHEDULE(1,1+ast) > 0 && STORAGEVALUE.val(ast,initial_pump_mw) < eps
                   ACTUAL_PUMPUP_TIME(ast,1) = time-1*IDAC; 
                end;
                UNIT_STARTUPMINGENHELP_VAL(ast,1) = (GENVALUE.val(ast,min_gen)*(time-ACTUAL_START_TIME(ast,1))/GENVALUE.val(ast,su_time));%+(GENVALUE.val(ast,min_gen)/((60*IDAC/IRTD)*GENVALUE.val(ast,su_time)));
                UNIT_STARTUPMINGENHELP_VAL(UNIT_STARTUPMINGENHELP_VAL==-inf)=0;
                UNIT_STARTUPMINGENHELP_VAL(isnan(UNIT_STARTUPMINGENHELP_VAL))=0;
                if UNIT_STARTUPMINGENHELP_VAL(ast,1) >= GENVALUE.val(ast,min_gen)
                    UNIT_STARTUPMINGENHELP_VAL(ast,1) = 0;
                    UNIT_STARTINGUP_VAL(ast,1:HRTD) = 0;
                end;  
            end;
        end
    
        % Check if a unit shutting down needs to be delayed
        if sum(sum(UNIT_SHUTTINGDOWN_VAL)) > 0
            [delayedshutdown,LAST_STATUS_VAL,RTSCUCBINDINGSCHEDULE,RTSCUCBINDINGCOMMITMENT,STATUS,UNIT_SHUTTINGDOWN_VAL,UNIT_STATUS_VAL,UNIT_PUMPINGUP_VAL,PUMPING_VAL,PUMPSTATUS,RTSCUCBINDINGPUMPING,RTSCUCBINDINGPUMPSCHEDULE]=rtdDelayShutdowns(delayedshutdown,ACTUAL_GEN_OUTPUT_VAL,LAST_STATUS_ACTUAL_VAL,LAST_GEN_SCHEDULE_VAL,LAST_STATUS_VAL,UNIT_SHUTTINGDOWN_VAL,INTERVAL_MINUTES_VAL,GENVALUE,ramp_rate,PRTD,min_gen,IRTD,HRTD,IRTC,RTSCEDBINDINGSCHEDULE,UNIT_STATUS_VAL,STATUS,RTSCUC_binding_interval_index,HRTC,RTSCUCBINDINGCOMMITMENT,RTSCUCBINDINGSCHEDULE,LAST_STATUS_VAL,PUMPSTATUS,RTSCUCBINDINGPUMPING,RTSCUCBINDINGPUMPSCHEDULE,UNIT_PUMPINGUP_VAL,PUMPING_VAL,md_time,STORAGEVALUE,min_pump_time,eps,GENVALUE.val(:,gen_type),RTSCED_binding_interval_index);
        end
        if sum(sum(UNIT_PUMPINGDOWN_VAL)) > 0
            [delayedpumpdown,LAST_PUMPSTATUS_VAL,RTSCUCBINDINGPUMPSCHEDULE,RTSCUCBINDINGPUMPING,PUMPSTATUS,UNIT_PUMPINGDOWN_VAL,PUMPING_VAL,UNIT_STARTINGUP_VAL,UNIT_STATUS_VAL,STATUS,RTSCUCBINDINGCOMMITMENT,RTSCUCBINDINGSCHEDULE]=rtdDelayShutdowns(delayedpumpdown,ACTUAL_PUMP_OUTPUT_VAL,LAST_PUMPSTATUS_ACTUAL_VAL,LAST_PUMP_SCHEDULE_VAL,LAST_PUMPSTATUS_VAL,UNIT_PUMPINGDOWN_VAL,INTERVAL_MINUTES_VAL,STORAGEVALUE,pump_ramp_rate,PRTD,min_pump,IRTD,HRTD,IRTC,RTSCEDBINDINGPUMPSCHEDULE,PUMPING_VAL,PUMPSTATUS,RTSCUC_binding_interval_index,HRTC,RTSCUCBINDINGPUMPING,RTSCUCBINDINGPUMPSCHEDULE,LAST_PUMPSTATUS_VAL,STATUS,RTSCUCBINDINGCOMMITMENT,RTSCUCBINDINGSCHEDULE,UNIT_STARTINGUP_VAL,UNIT_STATUS_VAL,0,GENVALUE,mr_time,eps,GENVALUE.val(:,gen_type),RTSCED_binding_interval_index);
        end
        RTD_SU_TWICE_IND_VAL=ones(ngen,1);
        SU_TWICE_CHECK=zeros(ngen,1);
        for i=1:ngen
            for t1=1:HRTD-1
                if UNIT_STATUS_VAL(i,t1+1)-UNIT_STATUS_VAL(i,t1)==-1
                    for t2=t1:HRTD-1
                        if UNIT_STATUS_VAL(i,t2+1)-UNIT_STATUS_VAL(i,t2)==1
                            SU_TWICE_CHECK(i,1)=1;
                        end
                    end
                end
            end
        end
        i=1;
        while i <=ngen
            if GENVALUE.val(i,md_time) <= sum(INTERVAL_MINUTES_VAL)/60 && SU_TWICE_CHECK(i,1)==1
                t=1;
                while t<=HRTD
                    % update unit status for units with Toff < HRTD
                    lookahead_interval_index_ceil = min(size(STATUS,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);
                    lookahead_interval_index_floor = min(size(STATUS,1),floor(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour+eps) + 1); %fixed was turning units off at the wrong time.
                    if GENVALUE.val(i,gen_type) == 7 || GENVALUE.val(i,gen_type) == 10 || GENVALUE.val(i,gen_type) == 14 || GENVALUE.val(i,gen_type) == 16
                        UNIT_STATUS_VAL(i,t) = 1; %keeping all vg on
                    elseif STATUS(lookahead_interval_index_ceil,i) == STATUS(lookahead_interval_index_floor,i)
                        UNIT_STATUS_VAL(i,t) = STATUS(lookahead_interval_index_ceil,i);
                    elseif STATUS(lookahead_interval_index_ceil,i) == 1
                        if GENVALUE.val(i,su_time) > RTSCUCBINDINGCOMMITMENT(lookahead_interval_index_ceil,1)-RTD_LOOKAHEAD_INTERVAL_VAL(t,1)+eps
                            UNIT_STATUS_VAL(i,t) = 1;
                        else
                            UNIT_STATUS_VAL(i,t) = 0;
                        end;
                    elseif STATUS(lookahead_interval_index_ceil,i) == 0
                        UNIT_STATUS_VAL(i,t) = 1;
                    end;
                    % update unit startingup for units with Toff < HRTD 
                    temp=find(not(UNIT_STATUS_VAL(i,:)),1,'first');
                    if isempty(temp)
                       RTD_SU_TWICE_IND_VAL(i,1)=HRTD+1;
                    else
                       RTD_SU_TWICE_IND_VAL(i,1)=temp;
                    end
                    UNIT_STARTINGUP_VAL(i,t) = 0;
                    if (GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16) && ((RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,i+1)+eps < GENVALUE.val(i,min_gen)) || t >= RTD_SU_TWICE_IND_VAL(i,1))
                        earliest_start_index = max(1,ceil((RTD_LOOKAHEAD_INTERVAL_VAL(t,1)-GENVALUE.val(i,su_time))*rtscuc_I_perhour-eps)+1);
                        startup_time_check_index = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1;
                        while(startup_time_check_index >= earliest_start_index)
                            if startup_time_check_index <= 1
                                Initial_RTD_last_startup_check = GENVALUE.val(i,initial_status);
                            else
                                Initial_RTD_last_startup_check = STATUS(startup_time_check_index-1,i);
                            end;
                            if STATUS(startup_time_check_index,i)-Initial_RTD_last_startup_check == 1 && UNIT_STATUS_VAL(i,t) == 1 && (time - ACTUAL_START_TIME(i,1) - GENVALUE.val(i,su_time) < eps)
                                UNIT_STARTINGUP_VAL(i,t) = 1;
                                if ACTUAL_START_TIME(i,1) < time && t==1
                                    UNIT_STARTUPMINGENHELP_VAL(i,1) = GENVALUE.val(i,min_gen)*(time-ACTUAL_START_TIME(i,1))/GENVALUE.val(i,su_time);
                                    if UNIT_STARTUPMINGENHELP_VAL(i,1) >= GENVALUE.val(i,min_gen)
                                        UNIT_STARTUPMINGENHELP_VAL(i,1) = 0;
                                        UNIT_STARTINGUP_VAL(i,1:HRTD) = 0;
                                    end;
                                end;
                            end;
                            startup_time_check_index = startup_time_check_index - 1;
                        end;
                    end;
                    t=t+1;
                end
            end
            i=i+1;
        end
        temp=ones(ngen,HRTD);
        for i=1:ngen
            if RTD_SU_TWICE_IND_VAL(i,1)==HRTD+1;
                RTD_SU_TWICE_IND_VAL(i,1)=1;
            end
            temp(i,RTD_SU_TWICE_IND_VAL(i,1):end)=RTD_SU_TWICE_IND_VAL(i,1);
        end
        RTD_SU_TWICE_IND_VAL=temp;
        if HRTD > 1
             UNIT_STARTUPMINGENHELP_VAL(1:ngen,2:HRTD)=zeros(ngen,HRTD-1);
             UNIT_PUMPUPMINGENHELP_VAL(1:ngen,2:HRTD)=zeros(ngen,HRTD-1);
        end
        
        %Storage value for RTD
        %Basically, figure out the amount of money that the storage unit would
        %receive in total dollars for the rest of the day including the end of the
        %day. Then figure out that value in $/MWh
        
        for i=1:ngen
            if GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8  || GENVALUE.val(i,gen_type) == 12
                if AGC_interval_index > round(PRTD*60/t_AGC)
                    RTSCED_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRTD*60/t_AGC),i+1)- (PRTD/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRTD/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE.val(i,efficiency); %only works for constant efficiency
                else
                    RTSCED_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index,i+1);
                end;
                if ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1) > size(DASCUCLMP,1)
                    RTSCED_RESERVOIR_VALUE(i,1) = SCUCSTORAGEVALUE.val(i,reservoir_value);
                else
                RTSCED_RESERVOIR_VALUE(i,1) = mean([SCUCSTORAGEVALUE.val(i,reservoir_value) mean(DASCUCLMP(ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1):end,GENBUS(i,1)))]);
                %{
                RTSCUC_RESERVOIR_VALUE(i,1) = (GENVALUE.val(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps-eps,1))*SCUCLMP.val(GENBUS(i,1),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))')) + GENVALUE.val(i,storage_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
                %}
                end;
            elseif GENVALUE.val(i,gen_type) == 9 || GENVALUE.val(i,gen_type) == 11
                RTSCED_RESERVOIR_VALUE(i,1) = GENVALUE.val(i,efficiency)*((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
                    floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1)) ...
                    +(SCUCLMP.val(GENBUS(i,1),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))...
                    *SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))') + STORAGEVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))...
                    + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
            else
                RTSCED_RESERVOIR_VALUE(i) = 0;
            end;
        end;
        
        %STORAGEVALUE.val(:,reservoir_value) = RTSCED_RESERVOIR_VALUE;
        
        STORAGEVALUE.val(:,initial_storage) = RTSCED_STORAGE_LEVEL;
        rtd_final_storage_time_index_up = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
        rtd_final_storage_time_index_lo = floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
        STORAGEVALUE.val(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)' ...
            + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_up),2:ngen+1)' ...
            - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)');
        END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price
        END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price and possibly change to negative
        
%         STORAGEVALUE.val(:,initial_storage) = RTSCED_STORAGE_LEVEL;
%         ik=1;
%         while ik ~= size(RTSCUCSTORAGELEVEL2,1)
%             if RTD_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(RTSCUCSTORAGELEVEL2(:,1))
%                 STORAGEVALUE.val(:,final_storage) = RTDFINALSTORAGEIN(:,end);
%                 ik=size(RTSCUCSTORAGELEVEL2,1)-1;
%             elseif RTSCUCSTORAGELEVEL2(ik,1) > RTD_LOOKAHEAD_INTERVAL_VAL(end)+eps
%                 STORAGEVALUE.val(:,final_storage) = RTSCUCSTORAGELEVEL2(ik-1,2:ngen+1)' ...
%                     + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps,1).*(RTSCUCSTORAGELEVEL2(ik,2:ngen+1)' ...
%                     - RTSCUCSTORAGELEVEL2(ik-1,2:ngen+1)');
%                 ik=size(RTSCUCSTORAGELEVEL2,1)-1;
%             end
%             ik = ik + 1;
%         end
        RTDFINALSTORAGEIN=[RTDFINALSTORAGEIN,STORAGEVALUE.val(:,final_storage)];
%         END_STORAGE_PENALTY_PLUS_PRICE.val  = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price
%         END_STORAGE_PENALTY_MINUS_PRICE.val = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price and possibly change to negative
        
        for i=1:ngen
            if  (RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,i+1) <= GENVALUE.val(i,min_gen))
                delayedshutdown(i,1)=0;
            end
            if  (RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index-1,i+1) <= STORAGEVALUE.val(i,min_pump))
                delayedpumpdown(i,1)=0;
            end
        end
        
        sdcount=sdcount+UNIT_SHUTTINGDOWN_VAL(:,1);
        for i=1:ngen
            if sum(UNIT_SHUTTINGDOWN_VAL(i,:)) > 0 && GENVALUE.val(i,gen_type) ~= 15 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16
                for tc=1:HRTD
                    sdcount2(i,tc)= round((GENVALUE.val(i,sd_time)*60/IRTD))-round((min(GENVALUE.val(i,min_gen),LAST_GEN_SCHEDULE_VAL(i))/GENVALUE.val(i,min_gen))*(GENVALUE.val(i,sd_time)*60/IRTD))+(sum(INTERVAL_MINUTES_VAL(1:tc)'.*UNIT_SHUTTINGDOWN_VAL(i,1:tc))/IRTD);
                end
            end
        end
        pumpsdcount=pumpsdcount+UNIT_PUMPINGDOWN_VAL(:,1);
        pumpsdcount2=[pumpsdcount zeros(ngen,HRTD-1)];
        
        CREATE_RTD_GAMS_VARIABLES

        for x=1:size(RTSCED_RULES_PRE_in,1)
            try run(RTSCED_RULES_PRE_in{x,1});catch;end; 
        end;
        if strcmp(use_Default_RTSCED,'YES')
            per_unitize;
            wgdx(['TEMP', filesep, 'RTSCEDINPUT2'],RESERVELEVEL,VG_FORECAST,UNIT_STATUS,UNIT_STARTINGUP,UNIT_STARTUPMINGENHELP,...
                 UNIT_SHUTTINGDOWN,INTERVAL_MINUTES,ACTUAL_GEN_OUTPUT,LAST_GEN_SCHEDULE,RAMP_SLACK_UP,RAMP_SLACK_DOWN,...
                 LAST_STATUS,LAST_STATUS_ACTUAL,GEN_FORCED_OUT,INITIAL_DISPATCH_SLACK,LOAD,PUMPING,ACTUAL_PUMP_OUTPUT,...
                 LAST_PUMP_SCHEDULE,LAST_PUMPSTATUS,LAST_PUMPSTATUS_ACTUAL,UNIT_PUMPINGUP,UNIT_PUMPINGDOWN,UNIT_PUMPUPMINGENHELP,...
                 END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,DELAYSD,RTD_SU_TWICE_IND,UNITSDCOUNT,DELAYPUMPSD,...
                 PUMPUNITSDCOUNT,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,INTERCHANGE,LOSS_BIAS,UNIT_SHUTTINGDOWN_ACTUAL,...
                 UNIT_PUMPINGDOWN_ACTUAL,UNIT_STARTINGUP_ACTUAL,UNIT_PUMPINGUP_ACTUAL,PUCOST_BLOCK_OFFSET,GENVALUE,STORAGEVALUE);

            system(RTSCED_GAMS_CALL);
            [RTDPRODCOST,RTDGENSCHEDULE,RTDLMP,RTDUNITSTATUS,RTDUNITSTARTUP,RTDUNITSHUTDOWN,RTDGENRESERVESCHEDULE,...
                RTDRCP,RTDLOADDIST,RTDGENVALUE,RTDSTORAGEVALUE,RTDVGCURTAILMENT,RTDLOAD,RTDRESERVEVALUE,RTDRESERVELEVEL,RTDBRANCHDATA,...
                RTDBLOCKCOST,RTDBLOCKMW,RTDBPRIME,RTDBGAMMA,RTDLOSSLOAD,RTDINSUFFRESERVE,RTDGEN,RTDBUS,RTDHOUR,...
                RTDBRANCH,RTDRESERVETYPE,RTDSLACKBUS,RTDGENBUS,RTDBRANCHBUS,RTDPUMPSCHEDULE,RTDSTORAGELEVEL,RTDPUMPING] ...
                = getgamsdata('TOTAL_RTSCEDOUTPUT','RTSCED','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
        end
        try
        RTDModelSolutionStatus(rtdmodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus];
        rtdmodeltracker=rtdmodeltracker+1;
        if ~isdeployed
          dbstop if warning stophere:RTDinfeasible;
        end
        if numberOfInfes ~= 0 && max(rpu_time) < time - PRTD/60 && max(rpu_time) < time
            try winopen('TEMP\RTSCED.lst');catch;end;
            warning('stophere:RTDinfeasible', 'Infeasible RTD Solution');
        end
        catch
        end;
        
        for x=1:size(RTSCED_RULES_POST_in,1)
            try run(RTSCED_RULES_POST_in{x,1});catch;end;
        end;

        %assuming the solution started P minutes ago, and is directing
        %units dispatch schedules I minutes ahead for a H minute
        %optimization.
        
        %Save needed RTD results.
        RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,1:1+ngen) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDGENSCHEDULE.val(:,1)'];
        RTSCEDBINDINGLMP(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDLMP.val(:,1)'];
        RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index,1:1+ngen) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDPUMPSCHEDULE.val(:,1)'];
        RTSCEDBINDINGMCC(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) MCC(:,1)'];
        RTSCEDBINDINGMLC(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) MLC(:,1)'];
        
        for i=1:ngen
        if (RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,i+1) > 0) && (RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,i+1)-RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index-1,i+1) > 0) && (RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,i+1) < GENVALUE.val(i,min_gen))
            RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,i+1)=RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,i+1)+eps;
        end
        end
        
        for r=1:nreserve
            RTSCEDBINDINGRESERVE(RTSCED_binding_interval_index,1:1+ngen,r) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDGENRESERVESCHEDULE.val(:,1,r)'];
        end;
        RTSCEDBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDRCP.val(:,1)'];
        RTSCEDBINDINGLOSSLOAD(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDLOSSLOAD.val(1,1)'];
        RTSCEDBINDINGINSUFFICIENTRESERVE(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDINSUFFRESERVE.val(1,:)];
        RTSCEDBINDINGOVERGENERATION(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) OVERGENERATION(1,1)'];
        RTSCEDMARGINALLOSS(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) marginalLoss(1,1)];
        RTD_LF(RTSCED_binding_interval_index-1,:)=LINEFLOWS(:,1)';
        
        finalvariablescounter=finalvariablescounter+1;
        if max(rpu_time) >= time - PRTD/60 && max(rpu_time) < time
        else
            PUMPDISPATCH(RTSCED_binding_interval_index,:) = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index,:);
            DISPATCH(RTSCED_binding_interval_index,:) = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,:);
            RESERVE(RTSCED_binding_interval_index,:,:) = RTSCEDBINDINGRESERVE(RTSCED_binding_interval_index,:,:);
            RESERVEPRICE(RTSCED_binding_interval_index,:) = RTSCEDBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:);
        end;
        
        RTSCEDSTORAGELEVEL(RTSCED_binding_interval_index,1:ngen)=RTDSTORAGELEVEL.val(:,1)';
        for i=1:ngen
            if sdcount2(i,1) == max(1,GENVALUE.val(i,sd_time)*60/IRTD)
                sdcount2(i,:) = 0;
            end
            if pumpsdcount(i,1) == max(1,STORAGEVALUE.val(i,pump_sd_time)*60/IRTD)
                pumpsdcount(i,1) = 0;
            end
            if  (RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,i+1) <= GENVALUE.val(i,min_gen)+eps) 
                delayedshutdown(i,1)=0;
            end
        end   
        
        if lossesCheck > eps
            [RTD_BUS_DELIVERY_FACTORS_VAL,RTD_GEN_DELIVERY_FACTORS_VAL,RTD_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTD,nbus,ngen,GEN.uels,BRANCHBUS,PTDF_VAL,repmat(initialLineFlows,1,HRTD),SYSTEMVALUE.val(mva_pu,1),BRANCHDATA.val(:,resistance),PARTICIPATION_FACTORS.uels,GENBUS2.val,BUS_VAL,PARTICIPATION_FACTORS.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
        else
            RTD_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTD);
            RTD_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTD);
            RTD_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTD);
        end

        %Need to save whether a wind/PV is directed to curtail so it can
        %follow those directions.
        for i=1:ngen
            if RTDVGCURTAILMENT.val(i,1) > eps && (GENVALUE.val(i,gen_type) == 7 || GENVALUE.val(i,gen_type) == 10)
                binding_vg_curtailment(i,1) = 1;
            else
                binding_vg_curtailment(i,1) = 0;
            end;
        end;
        rtsced_running = 0;

        RTSCED_binding_interval_index = RTSCED_binding_interval_index + 1;
        
        if(RTDPrintResults ==1 )
            saveRT('RTD',RTSCED_binding_interval_index,PRTD,hour,minute,RTDPRODCOST.val,RTDGENSCHEDULE.val,RTDLMP.val,RTDUNITSTATUS.val,RTDLINEFLOW.val,RESERVETYPE.uels,nreserve,RTDGENRESERVESCHEDULE.val,RTDRCP.val,nbranch,BRANCHDATA.val,BRANCH.uels,HRTD,RTDLINEFLOWCTGC.val);
        end;
        
    end;

%% Actual Generation


        
    for x=1:size(ACTUAL_OUTPUT_PRE_in,1)
        try run(ACTUAL_OUTPUT_PRE_in{x,1});catch;end;
    end;
    GEN_AGC_MODES=GENVALUE.val(:,gen_agc_mode);
    ACTUAL_GENERATION(AGC_interval_index,1) = time;
    ACTUAL_PUMP(AGC_interval_index,1) = time;
    ACTUAL_STORAGE_LEVEL(AGC_interval_index,1) = time;
    if AGC_interval_index>1
        for i=1:ngen
            if actual_gen_forced_out(i,1) == 1
                ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
                ACTUAL_PUMP(AGC_interval_index,1+i) = 0;
            else
                if AGC_interval_index >2
                    if((GENVALUE.val(i,gen_type) == 10 || GENVALUE.val(i,gen_type) == 7)  )
                        w = 1;
                        while(w<=size(ACTUAL_VG_FIELD,2)-1)
                            if(strcmp(GEN.uels(1,i),ACTUAL_VG_FIELD(1+w)))
                            if binding_vg_curtailment(i,1) == 1
                                ACTUAL_GENERATION(AGC_interval_index,1+i) = min(ACTUAL_VG_FULL(AGC_interval_index,1+w),min(GENVALUE.val(i,capacity),...
                                    max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                                    AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)) ...
                                    + ((1-GENVALUE.val(i,behavior_rate))*randn(1))*(ACTUAL_GENERATION(AGC_interval_index-1,1+i)...
                                    - AGC_SCHEDULE(AGC_interval_index-2,1+i)))));
                                w=size(ACTUAL_VG_FIELD,2);
                            else
                                ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_VG_FULL(AGC_interval_index,1+w);
%                                 ACTUAL_GENERATION(AGC_interval_index,1+i) = min(ACTUAL_GENERATION(AGC_interval_index-1,1+i)+5,ACTUAL_VG_FULL(AGC_interval_index,1+w));
                            end;
                                w=size(ACTUAL_VG_FIELD,2);
                            elseif(w==size(ACTUAL_VG_FIELD,2)-1)        %gone through entire list of VG and gen is not included
                                 ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
                            end;
                            w = w+1;
                        end;
                    elseif GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8 || GENVALUE.val(i,gen_type) == 12
                        if PUMPING_VAL(i,1) == 1 || UNIT_PUMPINGDOWN_VAL(i,1) == 1 || (ACTUAL_PUMP(AGC_interval_index-1,1+i) > eps*10000)
                            ACTUAL_PUMP(AGC_interval_index,1+i) = min(STORAGEVALUE.val(i,max_pump),...
                                max((PUMPING_VAL(i,1)-UNIT_PUMPINGUP_VAL(i,1)-UNIT_PUMPINGDOWN_VAL(i,1))*STORAGEVALUE.val(i,min_pump),...
                                AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)) ...
                                + ((1-GENVALUE.val(i,behavior_rate))*randn(1))*(ACTUAL_PUMP(AGC_interval_index-1,1+i)...
                                - AGC_SCHEDULE(AGC_interval_index-2,1+i))));
                        else
                           ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE.val(i,capacity),...
                                max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                                AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)) ...
                                + ((1-GENVALUE.val(i,behavior_rate))*randn(1))*(ACTUAL_GENERATION(AGC_interval_index-1,1+i)...
                                - AGC_SCHEDULE(AGC_interval_index-2,1+i))));
                        end;
                        ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+i) = min(STORAGEVALUE.val(i,storage_max),ACTUAL_STORAGE_LEVEL(AGC_interval_index-1,1+i) ...
                            - (t_AGC/60/60)*ACTUAL_GENERATION(AGC_interval_index,1+i) + (t_AGC/60/60)*ACTUAL_PUMP(AGC_interval_index,1+i)*STORAGEVALUE.val(i,efficiency));
                        %only works for constant efficiency.
                    elseif GENVALUE.val(i,gen_type) == 14
                        if GENVALUE.val(i,agc_qualified)==0
                            interchangeindices=find(find(interchanges)==i);
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_INTERCHANGE_FULL(AGC_interval_index,interchangeindices+1);
                        else
                       ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE.val(i,capacity),...
                            max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                            AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)) ...
                            + ((1-GENVALUE.val(i,behavior_rate))*randn(1))*(ACTUAL_GENERATION(AGC_interval_index-1,1+i)...
                            - AGC_SCHEDULE(AGC_interval_index-2,1+i))));
                        end
                    else
                       ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE.val(i,capacity),...
                            max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                            AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)) ...
                            + ((1-GENVALUE.val(i,behavior_rate))*randn(1))*(ACTUAL_GENERATION(AGC_interval_index-1,1+i)...
                            - AGC_SCHEDULE(AGC_interval_index-2,1+i))));
                    end;
                elseif AGC_interval_index ==2
                    if((GENVALUE.val(i,gen_type) == 10 || GENVALUE.val(i,gen_type) == 7)  )
                        w = 1;
                        while(w<=nvg)
                            if(strcmp(GEN.uels(1,i),ACTUAL_VG_FIELD(1+w)))
                            if binding_vg_curtailment(i,1) == 1
                                ACTUAL_GENERATION(AGC_interval_index,1+i) = min(ACTUAL_VG_FULL(AGC_interval_index,1+w),min(GENVALUE.val(i,capacity),...
                                    max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                                    AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)))));
                            else
                                ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_VG_FULL(AGC_interval_index,1+w);
                            end;
                            w=nvg;
                            elseif(w==nvg)        %gone through entire list of VG and gen is not included
                                 ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
                            end;
                            w = w+1;
                        end;
                    elseif GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8 || GENVALUE.val(i,gen_type) == 12
                        if PUMPING_VAL(i,1) == 1 || UNIT_PUMPINGDOWN_VAL(i,1) == 1
                            ACTUAL_PUMP(AGC_interval_index,1+i) = min(STORAGEVALUE.val(i,max_pump),...
                                max((PUMPING_VAL(i,1)-UNIT_PUMPINGUP_VAL(i,1)-UNIT_PUMPINGDOWN_VAL(i,1))*STORAGEVALUE.val(i,min_pump),...
                                AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1))));
                        else
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE.val(i,capacity),...
                                max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                                AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)))); 
                        end;
                        ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+i) = min(STORAGEVALUE.val(i,storage_max),ACTUAL_STORAGE_LEVEL(AGC_interval_index-1,1+i) ...
                            - (t_AGC/60/60)*ACTUAL_GENERATION(AGC_interval_index,1+i) + (t_AGC/60/60)*ACTUAL_PUMP(AGC_interval_index,1+i)*STORAGEVALUE.val(i,efficiency));
                        %Only works for constant efficiency.
                    elseif GENVALUE.val(i,gen_type) == 14
                        if GENVALUE.val(i,agc_qualified)==0
                            interchangeindices=find(find(interchanges)==i);
                            ACTUAL_GENERATION(AGC_interval_index,1+i) = ACTUAL_INTERCHANGE_FULL(AGC_interval_index,interchangeindices+1);
                        else
                        ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE.val(i,capacity),...
                            max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                            AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)))); 
                        end
%                         interchangeindices=find(interchanges);
%                     	ACTUAL_GENERATION(AGC_interval_index,1+interchangeindices) = ACTUAL_INTERCHANGE_FULL(AGC_interval_index,2:end);
                    else
                        ACTUAL_GENERATION(AGC_interval_index,1+i) = min(GENVALUE.val(i,capacity),...
                            max((UNIT_STATUS_VAL(i,1)-UNIT_STARTINGUP_VAL(i,1)-UNIT_SHUTTINGDOWN_VAL(i,1))*GENVALUE.val(i,min_gen),...
                            AGC_SCHEDULE(AGC_interval_index-1,1+i)*(1+(1-GENVALUE.val(i,behavior_rate))*randn(1)))); 
                    end;
                end;
            end;
            if ACTUAL_GENERATION(AGC_interval_index,1+i) < eps && GENVALUE.val(i,gen_type) ~= 14 && GENVALUE.val(i,gen_type) ~= 16
                ACTUAL_GENERATION(AGC_interval_index,1+i) = 0;
            end
        end;
        AGC_LAST = AGC_SCHEDULE(AGC_interval_index-1,:);
    else
        AGC_LAST = 0;
        ACE(1,:) = [time 0 0 0 0 0];
        Max_Reg_Limit_Hit=[0 0];
        Min_Reg_Limit_Hit=[0 0];
    end;
        
    for x=1:size(ACTUAL_OUTPUT_POST_in,1)
        try run(ACTUAL_OUTPUT_POST_in{x,1});catch;end;
    end;
    if AGC_interval_index > 1
        for i=1:ngen
            if ACTUAL_GENERATION(AGC_interval_index,1+i) > 0 && ACTUAL_GENERATION(AGC_interval_index-1,1+i) < eps
                ACTUAL_START_TIME(i,1) = ACTUAL_GENERATION(AGC_interval_index-1,1);
            end;
            if ACTUAL_GENERATION(AGC_interval_index,1+i) < eps || ACTUAL_GENERATION(AGC_interval_index,1+i) >= GENVALUE.val(i,min_gen)
                ACTUAL_START_TIME(i,1) = inf;
            end;
            if ACTUAL_PUMP(AGC_interval_index,1+i) > 0 && ACTUAL_PUMP(AGC_interval_index-1,1+i) < eps
                ACTUAL_PUMPUP_TIME(i,1) = ACTUAL_PUMP(AGC_interval_index-1,1);
            end;           
            if ACTUAL_PUMP(AGC_interval_index,1+i) < eps
                ACTUAL_PUMPUP_TIME(i,1) = inf;
            end;
        end;
    else
        for i=1:ngen
            if ACTUAL_GENERATION(AGC_interval_index,1+i) > 0 && GENVALUE.val(i,initial_MW) < eps
               ACTUAL_START_TIME(i,1) = -1*IDAC; 
            end;
            if ACTUAL_PUMP(AGC_interval_index,1+i) > 0 && STORAGEVALUE.val(i,initial_pump_mw) < eps
               ACTUAL_PUMPUP_TIME(i,1) = -1*IDAC; 
            end;
        end;
    end;

    
%% AGC

    j=RTSCED_binding_interval_index-2;
    if time > DISPATCH(RTSCED_binding_interval_index-1,1)
        while j>=1
            if DISPATCH(j,1) > time
                next_RTD = DISPATCH(j,:);
                previous_RTD = DISPATCH(max(1,j-1),:);
                next_pump_RTD = PUMPDISPATCH(j,:);
                j=0;
            else
                j=j-1;
            end;
        end;
    else
        next_RTD = DISPATCH(RTSCED_binding_interval_index-1,:);
        previous_RTD = DISPATCH(max(1,j),:);
        next_pump_RTD = PUMPDISPATCH(RTSCED_binding_interval_index-1,:);
    end;
    if regulation_up_index == 0
        REGULATION_UP = zeros(1,ngen+1);
    else
        REGULATION_UP = RESERVE(RTSCED_binding_interval_index-1,:,regulation_up_index);
    end;
    if regulation_down_index == 0
        REGULATION_DOWN = zeros(1,ngen+1);
    else
        REGULATION_DOWN = RESERVE(RTSCED_binding_interval_index-1,:,regulation_down_index);
    end;
    
    % transmission losses = flow^2 * R
    bus_injection=-1*fullLoadDist*ACTUAL_LOAD_FULL(AGC_interval_index,2);
    if ~exist('losses_temp','var')
        losses_temp=zeros(nbus,ngen);temp2=sortrows(GENBUS,2);
        losses_temp(sub2ind([nbus ngen],temp2(:,1),(1:ngen)'))=1;
    end
    bus_injection=losses_temp*ACTUAL_GENERATION(AGC_interval_index,2:end)' + bus_injection;
    ACTUAL_LF = PTDF_VAL*bus_injection;
    losses=sum(ACTUAL_LF(:,1).*ACTUAL_LF(:,1).*BRANCHDATA.val(:,resistance)/SYSTEMVALUE.val(mva_pu,1));
    storelosses(AGC_interval_index,1)=losses;

    current_gen_agc=ACTUAL_GENERATION(AGC_interval_index,:);
    current_load_agc = ACTUAL_LOAD_FULL(AGC_interval_index,1:2);
    current_pump_agc=ACTUAL_PUMP(AGC_interval_index,:);
    unit_startup_agc=UNIT_STARTINGUP_VAL(:,1);
    unit_shutdown_agc=UNIT_SHUTTINGDOWN_VAL(:,1);
    unit_pumpup_agc=UNIT_PUMPINGUP_VAL(:,1);
    unit_pumpdown_agc=UNIT_PUMPINGDOWN_VAL(:,1);
    unit_pumping_agc=PUMPING_VAL(:,1);

    %What is ACE?
    if AGC_interval_index ==1
        previous_ACE_int = 0;
        previous_CPS2_ACE = 0;
        previous_SACE = 0;
        previous_ACE_ABS = 0;
    else
        previous_ACE_int = ACE(AGC_interval_index - 1,integrated_ACE_index);
        if(mod(time*60,CPS2_interval)- 0 < eps || CPS2_interval - mod(time*60,CPS2_interval) < eps) %Note that some rounding can create some errors here
            previous_CPS2_ACE = 0;
        else
            previous_CPS2_ACE = ACE(AGC_interval_index - 1,CPS2_ACE_index);
        end;
        previous_SACE = ACE(max(1,AGC_interval_index - Type3_integral/t_AGC):AGC_interval_index-1, raw_ACE_index);
        previous_ACE_ABS = ACE(AGC_interval_index - 1,AACEE_index);
    end;
    
    for x=1:size(ACE_PRE_in,1)
        try run(ACE_PRE_in{x,1});catch;end; 
    end;
    
    [ACE_raw,ACE_int,AACEE,ACE_CPS2, SACE] = ACE_calculator(previous_ACE_int,previous_CPS2_ACE,previous_SACE,previous_ACE_ABS,current_gen_agc,current_load_agc,current_pump_agc,...
        CPS2_interval,K1,K2,t_AGC,ngen,losses);

    for x=1:size(ACE_POST_in,1)
        try run(ACE_POST_in{x,1});catch;end; 
    end;

    ACE(AGC_interval_index,ACE_time_index) = time; 
    ACE(AGC_interval_index,raw_ACE_index) = ACE_raw; 
    ACE(AGC_interval_index,integrated_ACE_index) = ACE_int; 
    ACE(AGC_interval_index,CPS2_ACE_index) = ACE_CPS2; 
    ACE(AGC_interval_index,SACE_index) = SACE; 
    ACE(AGC_interval_index,AACEE_index) = AACEE;


    %Filtered_ACE = Kp*(previous_ACE(t-1)) + Ki*sum(previous_ACE);

    %Units starting and stopping will have different ramp rates.
    ramp_agc=zeros(ngen,1);
    for i=1:ngen
        if unit_startup_agc(i,1) == 1
            ramp_agc(i,1) = GENVALUE.val(i,min_gen)/(GENVALUE.val(i,su_time)*60);
        elseif unit_shutdown_agc(i,1) == 1
    %         ramp(i,1) = genvalue(i,min_gen)/15;
            ramp_agc(i,1) = GENVALUE.val(i,min_gen)/(GENVALUE.val(i,sd_time)*60);
        elseif unit_pumpup_agc(i,1) == 1
            ramp_agc(i,1) = STORAGEVALUE.val(i,min_pump)/(STORAGEVALUE.val(i,pump_su_time)*60);
        elseif unit_pumpdown_agc(i,1) == 1
    %         ramp(i,1) = storagevalue(i,min_pump)/15;
            ramp_agc(i,1) = STORAGEVALUE.val(i,min_pump)/(STORAGEVALUE.val(i,pump_sd_time)*60);
        elseif unit_pumping_agc(i,1) == 1
            ramp_agc(i,1) = STORAGEVALUE.val(i,pump_ramp_rate);
        else
            ramp_agc(i,1) = GENVALUE.val(i,ramp_rate);
        end;
    end;
    
    for x=1:size(AGC_RULES_PRE_in,1)
        try run(AGC_RULES_PRE_in{x,1});catch;end;
    end;
    
    AGC;
    
    for x=1:size(AGC_RULES_POST_in,1)
        try run(AGC_RULES_POST_in{x,1});catch;end;
    end;
    
    
    % CTGC RPU
    for i=1:ngen
        if time  >= gen_outage_time(i,1) && time < gen_repair_time(i,1)
            if actual_gen_forced_out(i,1) == 0
                ctgc_start = 1;
                ctgc_start_time = time;
            end;
            actual_gen_forced_out(i,1) = 1;
        else
            actual_gen_forced_out(i,1) = 0;
        end;
    end;
    
    
%% RPU
    
    %{
    Figure out how load and wind data is obtained.
    How reserves are determined for this.
    branch limits at STE?
    no base point ramp limits
    unit commitment initial statuses (might be same as is)
    %}
    if strcmp(ALLOW_RPU,'YES') ==1
        RPU_TRIGGER;
    if RPU_YES
        
        %Get vg and load data
        rpu_running = 1;
        for rpu_int = 1:HRPU
            RPU_LOOKAHEAD_INTERVAL_VAL(rpu_int,1) = time + rpu_int*IRPU/60;
        end;

        clear LOAD
        t = 1; 
        rpu_int = 1;
        if rtd_load_data_create == 1 %if getting from a file will do a weighted average of forecast and actual
        while(t <= size_RTD_LOAD_FULL )
            if t+HRTD <= size_RTD_LOAD_FULL
            if(time/24 - RTD_LOAD_FULL(t,1) >= 0 && time/24 - RTD_LOAD_FULL(t+HRTD,1) < 0)
                RPU_data_create_weighting = max(0,(RTD_LOAD_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
                LOAD.val(1:HRPU,1) = RPU_data_create_weighting*ACTUAL_LOAD_FULL(AGC_interval_index-round(PRPU*60/t_AGC)-1,2) ...
                    + (1 - RPU_data_create_weighting)*RTD_LOAD_FULL(t,3);
                rpu_int = rpu_int+1;
                t=size_RTD_LOAD_FULL;
            end;
            else
            if(time/24 - RTD_LOAD_FULL(t,1) >= 0)
                RPU_data_create_weighting = max(0,(RTD_LOAD_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
                LOAD.val(1:HRPU,1) = RPU_data_create_weighting*ACTUAL_LOAD_FULL(AGC_interval_index-round(PRPU*60/t_AGC)-1,2) ...
                    + (1 - RPU_data_create_weighting)*RTD_LOAD_FULL(t,3);
                rpu_int = rpu_int+1;
                t=size_RTD_LOAD_FULL;
            end;
            end;
            t = t+1;
        end;
        elseif rtd_load_data_create == 2 %perfect RPU forecast
            for rpu_int=1:HRPU
                LOAD.val(rpu_int,1) = mean(ACTUAL_LOAD_FULL(min(size_ACTUAL_LOAD_FULL,max(1,AGC_interval_index + ...
                rpu_int*IRPU*(60/t_AGC)-ceil(IRPU*(60/t_AGC)/2))):min(size_ACTUAL_LOAD_FULL,max(1,AGC_interval_index + rpu_int*IRPU*(60/t_AGC)+ceil(IRPU*(60/t_AGC)/2))),2));
            end;
        elseif rtd_load_data_create ==3 %persistence RPU forecast
            LOAD.val = ones(HRPU,1).*ACTUAL_LOAD_FULL(AGC_interval_index-round(PRPU*60/t_AGC)-1,2);
        end;

        t=1;
        rpu_int=1;
        if nvcr > 0
            if rtd_vg_data_create == 1 %if getting from a file will do a weighted average of forecast and actual
            while(t <= size_RTD_VG_FULL )
                if t+HRTD <= size_RTD_VG_FULL
                if(time/24 - RTD_VG_FULL(t,1) >= 0 && time/24 - RTD_VG_FULL(t+HRTD,1) < 0)
                    RPU_data_create_weighting = max(0,(RTD_VG_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
                    vg_forecast_tmp(1:HRPU,1:nvg) = ones(HRPU,1)*(RPU_data_create_weighting.*ACTUAL_VG_FULL(AGC_interval_index-round(PRPU*60/t_AGC)-1,2:nvg+1) ...
                        + (1 - RPU_data_create_weighting).*RTD_VG_FULL(t,3:3+nvg-1));
                    rpu_int = rpu_int+1;
                    t=size_RTD_VG_FULL;
                end;
                else
                if(time/24 - RTD_VG_FULL(t,1) >= 0 )
                    RPU_data_create_weighting = max(0,(RTD_VG_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
                    vg_forecast_tmp(1:HRPU,1:nvg) = ones(HRPU,1)*(RPU_data_create_weighting.*ACTUAL_VG_FULL(AGC_interval_index-round(PRPU*60/t_AGC)-1,2:nvg+1) ...
                        + (1 - RPU_data_create_weighting).*RTD_VG_FULL(t,3:3+nvg-1));
                    rpu_int = rpu_int+1;
                    t=size_RTD_VG_FULL;
                end;
                end;
                t = t+1;
            end;
            elseif rtd_vg_data_create == 2%perfect RPU forecast
                for rpu_int=1:HRPU
                    vg_forecast_tmp(rpu_int,:) = mean(ACTUAL_VG_FULL(min(size_ACTUAL_VG_FULL,max(1,round(AGC_interval_index + ...
                    rpu_int*IRPU*(60/t_AGC)-IRPU*(60/t_AGC)/2))):min(size_ACTUAL_VG_FULL,max(1,AGC_interval_index + round(rpu_int*IRPU*(60/t_AGC)+IRPU*(60/t_AGC)/2))),2:nvg+1));
                end;
            elseif rtd_vg_data_create ==3%persistence RPU forecast
                 vg_forecast_tmp = ones(HRPU,1)*ACTUAL_VG_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2:nvg+1);
            end;
        end;
        clear VG_FORECAST_VAL;
        VG_FORECAST_VAL=zeros(HRPU,ngen);
        i=1;
        while(i<=ngen)
            w = 1;
            while(w<=nvg)
                if(strcmp(GEN.uels(1,i),RTD_VG_FIELD(2+w))) && GENVALUE.val(i,gen_type) ~= 15
                    VG_FORECAST_VAL(1:HRPU,i) = vg_forecast_tmp(1:HRPU,w);
                    w=nvg;
                elseif(w==nvg)            %gone through entire list of VG and gen is not included
                    VG_FORECAST_VAL(1:HRPU,i) = zeros(HRPU,1);
                end;
                w = w+1;
            end;
            i = i+1;
        end;

        clear RESERVELEVEL_VAL
        t = 1;
        rpu_int = 1;
        while(t <= size_RTD_RESERVE_FULL && RTD_RESERVE_FULL(t,1)<= (time/24 +eps) && rpu_int <= HRPU)                
            if(abs(RTD_RESERVE_FULL(t,1) - time/24) < IRTD/(60*24))
                RESERVELEVEL_VAL(rpu_int,1:size(RTD_RESERVE_FIELD,2)-2) = RTD_RESERVE_FULL(t,3:end);
                rpu_int = rpu_int+1;
            end;
            t = t+1;
        end;
        if rpu_int <= HRPU
            for t=rpu_int:HRPU
                RESERVELEVEL_VAL = [RESERVELEVEL_VAL; RESERVELEVEL_VAL(rpu_int-1,:)];
            end;
        end;
        
        clear RPU_INTERCHANGE_VAL;
        RPU_INTERCHANGE_VAL=zeros(HRPU,max(1,ninterchange));
        t = 1;
        rpu_int = 1;
        while(t <= size_RTD_RESERVE_FULL && RTD_INTERCHANGE_FULL(t,1)<= (time/24 +eps) && rpu_int <= HRPU)                
            if(abs(RTD_INTERCHANGE_FULL(t,1) - time/24) < IRTD/(60*24))
                RPU_INTERCHANGE_VAL(rpu_int,1:size(RTD_INTERCHANGE_FIELD,2)-2) = RTD_INTERCHANGE_FULL(t,3:end);
                rpu_int = rpu_int+1;
            end;
            t = t+1;
        end;
        
        if RTSCUC_binding_interval_index <=2
            INITIAL_DISPATCH_SLACK.val = [1;0];
        else
            INITIAL_DISPATCH_SLACK.val = [0;0];
        end;
        
        rpuinterval_index = round(time*rtscuc_I_perhour) + 1+1; %of the binding rtc interval. This is based on SCUC starting at hour 0!!!
        
        %Setting up the hard commitment constraints for quickstarts and other units.
        clear UNIT_STATUS_ENFORCED_ON_VAL PUMPING_ENFORCED_ON_VAL UNIT_STATUS_ENFORCED_OFF_VAL PUMPING_ENFORCED_OFF_VAL

        RTSCUCSTART_MODE = 2;
        RTSCUCSTART;
        i = 1;
        while(i<=ngen)
            t = 1;
            if gen_outage_time(i,1) <= time - PRPU/60 && gen_repair_time(i,1) >= time -PRPU/60
                rpu_gen_forced_out(i,1) = 1;
            else
                rpu_gen_forced_out(i,1) = 0;
            end;
            if rpu_gen_forced_out(i,1) == 1
                GEN_FORCED_OUT_VAL(i,1) = 1;
                UNIT_STATUS_ENFORCED_ON_VAL(i,1:HRPU) = 0;
                UNIT_STATUS_ENFORCED_OFF_VAL(i,1:HRPU) = 0;
                PUMPING_ENFORCED_OFF_VAL(i,1:HRPU) = 0;
            else
                GEN_FORCED_OUT_VAL(i,1) = 0;
                while(t<=HRPU)
                    start_interval = t*IRPU/60;
                    lookahead_index = min(size(STATUS,1),ceil(RPU_LOOKAHEAD_INTERVAL_VAL(t,1)*rtscuc_I_perhour-eps) + 1);    %This is based on SCUC starting at hour 0!!!
                    if  RTSCUCSTART_YES(i,t) == 1
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t) = 0;
                    else
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t) = STATUS(lookahead_index,i);
                    end;
                    if RTSCUCSHUT_YES(i,t) == 1
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = 1;
                    else
                        UNIT_STATUS_ENFORCED_ON_VAL(i,t) = ceil(STATUS(lookahead_index,i)-.01);
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,t) = floor(STATUS(lookahead_index,i)+.01);
                    end;
                    if  RTSCUCPUMPSTART_YES(i,t) == 1
                        PUMPING_ENFORCED_ON_VAL(i,t) = 0;
                    else
                        PUMPING_ENFORCED_ON_VAL(i,t) = PUMPSTATUS(lookahead_index,i);
                    end;
                    if RTSCUCPUMPSHUT_YES(i,t) == 1
                        PUMPING_ENFORCED_OFF_VAL(i,t) = 1;
                    else
                        PUMPING_ENFORCED_OFF_VAL(i,t) = PUMPSTATUS(lookahead_index,i);
                    end;

                    t = t+1;
                end;
            end;
            i=i+1;
        end;
        
        %For initial minimum on and down time constraints
        %min run time.
        if(RTSCUC_binding_interval_index>1)
            for i=1:ngen
                if RTSCUCSTART_YES(i,1) || RTSCUCPUMPSTART_YES(i,1)
                    min_down_check_start_time = max(1,RTSCUC_binding_interval_index -GENVALUE.val(i,md_time)*rtscuc_I_perhour+1);
                    min_down_check_end_time = RTSCUC_binding_interval_index - 1;
                    min_down_interval_enforced=0;
                    min_down_check_time = min_down_check_start_time;
                    while min_down_check_time <= min_down_check_end_time
                        if (STATUS(max(1,min_down_check_time-1),i)+PUMPSTATUS(max(1,min_down_check_time-1),i)) - (STATUS(max(1,min_down_check_time),i) + PUMPSTATUS(max(1,min_down_check_time),i)) == 1
                            min_down_interval_enforced = GENVALUE.val(i,md_time)*rtscuc_I_perhour - (min_down_check_end_time - min_down_check_time)-1;
                            min_down_check_time = min_down_check_end_time + 1;
                        else
                            min_down_interval_enforced = 0;
                            min_down_check_time = min_down_check_time + 1;
                        end;
                    end;
                    if min_down_interval_enforced > 0
                        UNIT_STATUS_ENFORCED_OFF_VAL(i,1:min_down_interval_enforced) = 0;
                        PUMPING_ENFORCED_OFF_VAL(i,1:min_down_interval_enforced) = 0;
                    end;
                end;
                if RTSCUCSHUT_YES(i,1)
                    min_run_check_start_time = max(1,RTSCUC_binding_interval_index -GENVALUE.val(i,mr_time)*rtscuc_I_perhour+1);
                    min_run_check_end_time = RTSCUC_binding_interval_index - 1;
                    min_run_interval_enforced=0;
                    min_run_check_time = min_run_check_start_time;
                    while min_run_check_time <= min_run_check_end_time
                        if min_run_check_time == 1
                            minrun_last_status = SCUCGENVALUE.val(i,initial_status);
                        else
                            minrun_last_status = STATUS(min_run_check_time-1,i);
                        end;
                        if STATUS(min_run_check_time,i)-minrun_last_status == 1
                            min_run_interval_enforced = GENVALUE.val(i,mr_time)*rtscuc_I_perhour - (min_run_check_end_time - min_run_check_time)-1;
                            min_run_check_time = min_run_check_end_time + 1;
                        else
                            min_run_interval_enforced = 0;
                            min_run_check_time = min_run_check_time + 1;
                        end;
                    end;
                    if min_run_interval_enforced > 0
                        UNIT_STATUS_ENFORCED_ON_VAL(i,1:min(HRPU,min_run_interval_enforced)) = 1;
                    end;
                end;
                if RTSCUCPUMPSHUT_YES(i,1)
                    min_pump_check_start_time = max(1,RTSCUC_binding_interval_index -STORAGEVALUE.val(i,min_pump_time)*rtscuc_I_perhour+1);
                    min_pump_check_end_time = RTSCUC_binding_interval_index - 1;
                    min_pump_interval_enforced=0;
                    min_pump_check_time = min_pump_check_start_time;
                    while min_pump_check_time <= min_pump_check_end_time
                        if min_pump_check_time == 1
                            minpump_last_status = SCUCSTORAGEVALUE.val(i,initial_pump_status);
                        else
                            minpump_last_status = PUMPSTATUS(min_pump_check_time-1,i);
                        end;
                        if PUMPSTATUS(min_pump_check_time,i)-minpump_last_status == 1
                            min_pump_interval_enforced = STORAGEVALUE.val(i,min_pump_time)*rtscuc_I_perhour - (min_pump_check_end_time - min_pump_check_time)-1;
                            min_pump_check_time = min_pump_check_end_time + 1;
                        else
                            min_pump_interval_enforced = 0;
                            min_pump_check_time = min_pump_check_time + 1;
                        end;
                    end;
                    while min_down_check_time <= min_down_check_end_time
                        if min_down_check_time == 1
                            mindown_last_status = SCUCGENVALUE.val(i,initial_status)+SCUCSTORAGEVALUE.val(i,initial_pump_status);
                        else
                            mindown_last_status = STATUS(min_down_check_time-1,i)+PUMPSTATUS(min_down_check_time-1,i);
                        end;
                        if mindown_last_status - (STATUS(max(1,min_down_check_time),i)+ PUMPSTATUS(max(1,min_down_check_time),i))== 1  
                            min_down_interval_enforced = GENVALUE.val(i,md_time)*rtscuc_I_perhour - (min_down_check_end_time - min_down_check_time)-1;
                            min_down_check_time = min_down_check_end_time + 1;
                        else
                            min_down_interval_enforced = 0;
                            min_down_check_time = min_down_check_time + 1;
                        end;
                    end;
                    if min_run_interval_enforced > 0
                        UNIT_STATUS_ENFORCED_ON_VAL(i,1:min(HRPU,min_run_interval_enforced)) = 1;
                    end;
                    if min_pump_interval_enforced > 0
                        PUMPING_ENFORCED_ON_VAL(i,1:min_pump_interval_enforced) = 1;
                    end;
                end;
            end;
        end;
        
        %This is for interval 0 initial ramping constraints
        if (exist('DISPATCH','var') && RTSCED_binding_interval_index > 2)   
            ACTUAL_GEN_OUTPUT_VAL = ACTUAL_GENERATION(AGC_interval_index-round(PRPU*60/t_AGC)-1,2:ngen+1)'; 
            LAST_GEN_SCHEDULE_VAL = DISPATCH(RTSCED_binding_interval_index-1,2:ngen+1)';
            ACTUAL_PUMP_OUTPUT_VAL = ACTUAL_PUMP(AGC_interval_index-round(PRPU*60/t_AGC)-1,2:ngen+1)'; 
            LAST_PUMP_SCHEDULE_VAL = PUMPDISPATCH(RTSCED_binding_interval_index-1,2:ngen+1)';
            for i=1:ngen
                if abs(LAST_GEN_SCHEDULE_VAL(i,1)) > 0
                    LAST_STATUS_VAL(i,1) = 1;
                else
                    LAST_STATUS_VAL(i,1) = 0;
                end;
                if LAST_PUMP_SCHEDULE_VAL(i,1) > 0
                    LAST_PUMPSTATUS_VAL (i,1) = 1;
                else
                    LAST_PUMPSTATUS_VAL (i,1) = 0;
                end;
                if abs(ACTUAL_GEN_OUTPUT_VAL(i,1)) > 0
                    LAST_STATUS_ACTUAL_VAL(i,1) = 1;
                else
                    LAST_STATUS_ACTUAL_VAL(i,1) = 0;
                end;
                if ACTUAL_PUMP_OUTPUT_VAL(i,1) > 0
                    LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 1;
                else
                    LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 0;
                end;
            end;
        elseif(exist('DISPATCH','var') && RTSCED_binding_interval_index > 1)
            ACTUAL_GEN_OUTPUT_VAL = SCUCGENSCHEDULE.val(:,1); 
            LAST_GEN_SCHEDULE_VAL = DISPATCH(RTSCED_binding_interval_index-1,2:ngen+1)';
            ACTUAL_PUMP_OUTPUT_VAL = SCUCPUMPSCHEDULE.val(:,1); 
            LAST_PUMP_SCHEDULE_VAL = PUMPDISPATCH(RTSCED_binding_interval_index-1,2:ngen+1)';
            for i=1:ngen
                if abs(LAST_GEN_SCHEDULE_VAL(i,1)) > 0
                    LAST_STATUS_VAL(i,1) = 1;
                else
                    LAST_STATUS_VAL(i,1) = 0;
                end;
                if LAST_PUMP_SCHEDULE_VAL(i,1) > 0
                    LAST_PUMPSTATUS_VAL (i,1) = 1;
                else
                    LAST_PUMPSTATUS_VAL (i,1) = 0;
                end;
                if abs(ACTUAL_GEN_OUTPUT_VAL(i,1)) > 0
                    LAST_STATUS_ACTUAL_VAL(i,1) = 1;
                else
                    LAST_STATUS_ACTUAL_VAL(i,1) = 0;
                end;
                if ACTUAL_PUMP_OUTPUT_VAL(i,1) > 0
                    LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 1;
                else
                    LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 0;
                end;
            end;
        else
            ACTUAL_GEN_OUTPUT_VAL = SCUCGENSCHEDULE.val(:,1); 
            LAST_GEN_SCHEDULE_VAL = SCUCGENSCHEDULE.val(:,1);      
            LAST_STATUS_VAL = STATUS(rpuinterval_index -1,:)';                        
            ACTUAL_PUMP_OUTPUT_VAL = SCUCPUMPSCHEDULE.val(:,1); 
            LAST_PUMP_SCHEDULE_VAL = SCUCPUMPSCHEDULE.val(:,1);      
            LAST_PUMPSTATUS_VAL = STATUS(rpuinterval_index -1,:)';                        
            for i=1:ngen
                if ACTUAL_GEN_OUTPUT_VAL(i,1) > 0
                    LAST_STATUS_ACTUAL_VAL(i,1) = 1;
                else
                    LAST_STATUS_ACTUAL_VAL(i,1) = 0;
                end;
                if ACTUAL_PUMP_OUTPUT_VAL(i,1) > 0
                    LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 1;
                else
                    LAST_PUMPSTATUS_ACTUAL_VAL(i,1) = 0;
                end;
            end;
        end;
        for i=1:ngen
            RAMP_SLACK_UP_VAL(i,1) = max(0,ACTUAL_GEN_OUTPUT_VAL(i,1) - (PRPU+IRPU)*GENVALUE.val(i,ramp_rate)...
                - (LAST_GEN_SCHEDULE_VAL(i,1) + mod(time,tRTD)*GENVALUE.val(i,ramp_rate)));
            RAMP_SLACK_DOWN_VAL(i,1) = max(0, LAST_GEN_SCHEDULE_VAL(i,1) -  mod(time,tRTD)*GENVALUE.val(i,ramp_rate)...
                - (ACTUAL_GEN_OUTPUT_VAL(i,1) + (PRPU+IRPU)*GENVALUE.val(i,ramp_rate)));
        end;
        
        if time > 0 && time < daystosimulate*24-IRTC*HRTC/60
            indexofunitsSD=zeros(ngen,1);
            indexofunitsSD2=zeros(ngen,1);
            rputotaltime=zeros(ngen,1);
            for i=1:ngen
                for j=1:HRTC-1
                    if (STATUS(RTSCUC_binding_interval_index+j,i)-STATUS(RTSCUC_binding_interval_index+j-1,i)==-1) && ( GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 )
                        indexofunitsSD(i,1)=RTSCUC_binding_interval_index+j;
                        temp=STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,:);
                        indexofunitsSD2(i,1)=find(temp(:,i),1,'last')+1;
                        rputotaltime(i,1)=IRTC*(indexofunitsSD2(i,1)-1);
                    end
                end
            end
            rpugennow=ACTUAL_GEN_OUTPUT_VAL;
            rpustatusnow=LAST_STATUS_ACTUAL_VAL;
            rputotalramp=GENVALUE.val(:,ramp_rate).*rputotaltime;
            rpuminimumpossible=max(0,rpugennow-(rputotalramp.*rpustatusnow));
            X=max(0,ceil((rpuminimumpossible-GENVALUE.val(:,min_gen))./(GENVALUE.val(:,ramp_rate)*IRTC)));
            for i=1:ngen
                    rpudelaycondition= (indexofunitsSD(i,1) > 0 && ((rpuminimumpossible(i,1) > GENVALUE.val(i,min_gen)+eps) && (RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > GENVALUE.val(i,min_gen)))) && ( GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 );
                if rpudelaycondition
                    STATUS(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i)=1;
                    STATUS(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=1;
                    RTSCUCBINDINGCOMMITMENT(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1),i+1)=GENVALUE.val(i,min_gen);
                    RTSCUCBINDINGSCHEDULE(indexofunitsSD(i,1)+X(i,1):min(size(STATUS,1),indexofunitsSD(i,1)+X(i,1)-1+(GENVALUE.val(i,md_time)*60/IRTC)),i)=0;
                    UNIT_STATUS_ENFORCED_ON_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRTC))=1;
                    UNIT_STATUS_ENFORCED_OFF_VAL(i,indexofunitsSD2(i,1):min(indexofunitsSD2(i,1)+X(i,1)-1,HRTC))=1;
                    delayedshutdown(i,1)=1;
                end
            end
        end
        
        for i=1:ngen
            if (RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-2,i+1) - RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > 0 && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + eps < GENVALUE.val(i,min_gen) && RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1) ~= 0) && ( GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 14 )
                numberOfIntervalsLeftInSD=round(RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/GENVALUE.val(i,min_gen)*max(0,ceil(GENVALUE.val(i,sd_time)*60/IRTC)));
                if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD ~= 0
                    UNIT_STATUS_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+GENVALUE.val(i,md_time)*60/IRTC))=0;
                end
            end
            if RTSCUC_binding_interval_index > 2 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-2,i+1) - RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1) > 0 && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1) + eps < STORAGEVALUE.val(i,min_pump) && RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1) ~= 0
                numberOfIntervalsLeftInSD=round(RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index-1,i+1)/STORAGEVALUE.val(i,min_pump)*max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRTC)));
                if numberOfIntervalsLeftInSD < HRTC && numberOfIntervalsLeftInSD ~= 0
                    PUMPING_ENFORCED_OFF_VAL(i,numberOfIntervalsLeftInSD:min(HRTC,numberOfIntervalsLeftInSD-1+STORAGEVALUE.val(i,min_pump_time)*60/IRTC))=0;
                end
            end
        end
        
       %For su and sd trajectories
       for i=1:ngen
           STARTUP_PERIOD_VAL_RTC(i,1) = max(0,ceil(GENVALUE.val(i,su_time)*60/IRTC)); %this is for previous statuses
           PUMPUP_PERIOD_VAL_RTC(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_su_time)*60/IRTC)); %this is for previous statuses
           STARTUP_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,su_time)*60/IRPU)); %this is for the RPU optimization
           SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,sd_time)*60/IRPU));%SHUTDOWN_PERIOD_VAL(i,1) = max(0,ceil(GENVALUE.val(i,sd_time)*60/IRPU)-1);
           PUMPUP_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_su_time)*60/IRPU));
           PUMPDOWN_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRPU));%PUMPDOWN_PERIOD_VAL(i,1) = max(0,ceil(STORAGEVALUE.val(i,pump_sd_time)*60/IRPU)-1);
           INITIAL_STARTUP_PERIODS_VAL(i,1) = 0;
           startup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-(STARTUP_PERIOD_VAL_RTC(i,1)-1)));
           STARTUP_MINGEN_HELPER_VAL(i,1) = 0;
           for startup_period_check_time = startup_period_check_end:RTSCUC_binding_interval_index-1
               if startup_period_check_time <=1
                   Initial_RPU_last_startup_check = GENVALUE.val(i,initial_status);
               else
                   Initial_RPU_last_startup_check = STATUS(startup_period_check_time-1,i);
               end;
               if (STATUS(startup_period_check_time,i)-Initial_RPU_last_startup_check) == 1
                   INITIAL_STARTUP_PERIODS_VAL(i,1) = 1;
                   if startup_period_check_time <=1
                       if GENVALUE.val(i,su_time) >= IDAC + time
                           INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index + IDAC*60/IRTC-2;
                           STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE.val(i,min_gen)*(time + IRTC/60 - ...
                               -1*IDAC)/GENVALUE.val(i,su_time);
                       else
                           INTERVALS_STARTED_AGO_VAL(i,1) = 0;
                           INITIAL_STARTUP_PERIODS_VAL(i,1) = 0;
                       end;
                   else
                       INTERVALS_STARTED_AGO_VAL(i,1) = RTSCUC_binding_interval_index - startup_period_check_time;
                       STARTUP_MINGEN_HELPER_VAL(i,1) = GENVALUE.val(i,min_gen)*(time + IRPU/60 - ...
                           RTSCUCBINDINGSTARTUP(startup_period_check_time,1))/GENVALUE.val(i,su_time);
                   end;
               end;
           end;
           INITIAL_PUMPUP_PERIODS_VAL(i,1) = 0;
           INTERVALS_PUMPUP_AGO_VAL(i,1) = 0;

           pumpup_period_check_end = max(1,min(RTSCUC_binding_interval_index,RTSCUC_binding_interval_index-(PUMPUP_PERIOD_VAL_RTC(i,1)-1)));
           PUMPUP_MINGEN_HELPER_VAL(i,1) = 0;
           for pumpup_period_check_time = pumpup_period_check_end:RTSCUC_binding_interval_index-1
               if pumpup_period_check_time <=1
                   Initial_RPU_last_pumpup_check = STORAGEVALUE.val(i,initial_pump_status);
               else
                   Initial_RPU_last_pumpup_check = PUMPSTATUS(pumpup_period_check_time-1,i);
               end;
               if (PUMPSTATUS(pumpup_period_check_time,i)-Initial_RPU_last_pumpup_check) == 1
                   INITIAL_PUMPUP_PERIODS_VAL(i,1) = 1;
                   if pumpup_period_check_time <=1
                       if STORAGEVALUE.val(i,pump_su_time) >= IDAC + time
                           INTERVALS_PUMPUP_AGO_VAL(i,1) = RTSCUC_binding_interval_index + IDAC*60/IRTC-2;
                           PUMPUP_MINGEN_HELPER_VAL(i,1) = STORAGEVALUE.val(i,min_pump)*(time + IRTC/60 - ...
                               -1*IDAC)/STORAGEVALUE.val(i,pump_su_time);
                       else
                           INTERVALS_PUMPUP_AGO_VAL(i,1) = 0;
                           INITIAL_STARTUP_PERIODS_VAL(i,1) = 0;
                       end;
                   else
                       INTERVALS_PUMPUP_AGO_VAL(i,1) = RTSCUC_binding_interval_index - pumpup_period_check_time;
                       %PUMPUP_MINGEN_HELPER_VAL(i,1) = STORAGEVALUE.val(i,min_pump)*(time + IRPU/60 - ...
                           %RTSCUCBINDINGPUMPSCHEDULE(pumpup_period_check_time,1))/STORAGEVALUE.val(i,pump_su_time);
                   end;
               end;
           end;
       end;
        
        %Storage value for RTC
        %Basically, figure out the amount of money that the storage unit would
        %receive in total dollars for the rest of the day including the end of the
        %day. Then figure out that value in $/MWh
        for i=1:ngen
            if GENVALUE.val(i,gen_type) == 6 || GENVALUE.val(i,gen_type) == 8  || GENVALUE.val(i,gen_type) == 12
                if AGC_interval_index > round(PRPU*60/t_AGC)+1
                    RPU_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRPU*60/t_AGC)-1,i+1) - (PRPU/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRPU/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE.val(i,efficiency);
                else
                    RPU_STORAGE_LEVEL(i,1) = STORAGEVALUE.val(i,initial_storage)- (PRPU/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRPU/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE.val(i,efficiency);
                end;
                if ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1) > size(DASCUCLMP,1)
                    RPU_RESERVOIR_VALUE(i,1) = SCUCSTORAGEVALUE.val(i,reservoir_value);
                else
                    RPU_RESERVOIR_VALUE(i,1) = mean([SCUCSTORAGEVALUE.val(i,reservoir_value) mean(DASCUCLMP(ceil(RPU_LOOKAHEAD_INTERVAL_VAL(HRPU,1)+1):end,GENBUS(i,1)))]);
                %{
                RTSCUC_RESERVOIR_VALUE(i,1) = (GENVALUE.val(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps-eps,1))*SCUCLMP.val(GENBUS(i,1),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))')) + GENVALUE.val(i,storage_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
                %}
                end;
            elseif GENVALUE.val(i,gen_type) == 9 || GENVALUE.val(i,gen_type) == 11
                %TBD
                RPU_RESERVOIR_VALUE(i,1) = GENVALUE.val(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS(i,1),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS(i,1),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + GENVALUE.val(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
            else
                RPU_RESERVOIR_VALUE(i,1) = 0;
                RPU_STORAGE_LEVEL(i,1)=0;
            end;
        end;
        
        STORAGEVALUE.val(:,reservoir_value) = RPU_RESERVOIR_VALUE;
        STORAGEVALUE.val(:,initial_storage) = RPU_STORAGE_LEVEL;
        rpu_final_storage_time_index_up = ceil(RPU_LOOKAHEAD_INTERVAL_VAL(HRPU,1)*(1/IDAC)+eps) + 1; 
        END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rpu_final_storage_time_index_up),:);
        END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rpu_final_storage_time_index_up),:);
        
        CREATE_RPU_GAMS_VARIABLES
        
        for x=1:size(RPU_RULES_PRE_in,1)
            try run(RPU_RULES_PRE_in{x,1});catch;end; 
        end
        if strcmp(use_Default_SCRPU,'YES')
            per_unitize;
            wgdx(['TEMP', filesep, 'RTSCUCINPUT1'],PTDF,BLOCK_COST,BLOCK_CAP,QSC,GEN_EFFICIENCY_BLOCK,GEN_EFFICIENCY_MW,PUMP_EFFICIENCY_BLOCK,PUMP_EFFICIENCY_MW,...
                BLOCK2,GENBLOCK,STORAGEGENEFFICIENCYBLOCK,STORAGEPUMPEFFICIENCYBLOCK,RESERVE_COST,PUMPEFFPARAM,PUMPEFFICIENCYVALUE,GENEFFPARAM,...
                GENEFFICIENCYVALUE,PUMPUP_PERIOD,PUMPDOWN_PERIOD,INTERVAL,GEN,BUS,GENPARAM,RESERVEPARAM,BRANCHPARAM,COSTCURVEPARAM,BRANCH,RESERVETYPE,...
                LOAD_DIST,BRANCHDATA,RESERVEVALUE,COST_CURVE,SYSTEMVALUE,SYSPARAM,STORAGEPARAM,NRTCINTERVAL,RTCINTERVAL_LENGTH,...
                RTC_PROCESS_TIME,RTCINTERVAL_UPDATE,INITIAL_DISPATCH_SLACK_SET,RTCSTART,RTCSHUT,RTCPUMPSTART,RTCPUMPSHUT,LODF,PTDF_PAR,STARTUP_PERIOD,SHUTDOWN_PERIOD);

            wgdx(['TEMP', filesep, 'RTSCUCINPUT2'],UNIT_STARTUP_ACTUAL,UNIT_PUMPUP_ACTUAL,LAST_STARTUP,LAST_SHUTDOWN,PUCOST_BLOCK_OFFSET,INTERCHANGE,LOSS_BIAS,...
                DELAYSD,BUS_DELIVERY_FACTORS,GEN_DELIVERY_FACTORS,END_STORAGE_PENALTY_PLUS_PRICE,END_STORAGE_PENALTY_MINUS_PRICE,PUMPING_ENFORCED_OFF,INITIAL_PUMPUP_PERIODS,...
                INTERVALS_PUMPUP_AGO,PUMPING_ENFORCED_ON,ACTUAL_PUMP_OUTPUT,LAST_PUMP_SCHEDULE,LAST_PUMPSTATUS,LAST_PUMPSTATUS_ACTUAL,INITIAL_DISPATCH_SLACK,...
                LOAD,LAST_STATUS_ACTUAL,GEN_FORCED_OUT,INTERVALS_STARTED_AGO,INITIAL_STARTUP_PERIODS,ACTUAL_GEN_OUTPUT,LAST_GEN_SCHEDULE,RAMP_SLACK_UP,RAMP_SLACK_DOWN,...
                LAST_STATUS,UNIT_STATUS_ENFORCED_ON,UNIT_STATUS_ENFORCED_OFF,RESERVELEVEL,VG_FORECAST,GENVALUE,STORAGEVALUE);

            system(RTSCUC_GAMS_CALL);

            [RPUPRODCOST,RPUGENSCHEDULE,RPULMP,RPUUNITSTATUS,RPUUNITSTARTUP,RPUUNITSHUTDOWN,RPUGENRESERVESCHEDULE,...
                RPURCP,RPULOADDIST,RPUGENVALUE,RPUSTORAGEVALUE,RPUVGCURTAILMENT,RPULOAD,RPURESERVEVALUE,RPURESERVELEVEL,RPUBRANCHDATA,...
                RTCBLOCKCOST,RPUCBLOCKMW,RPUBPRIME,RPUBGAMMA,RPULOSSLOAD,RPUINSUFFRESERVE,RPUGEN,RPUBUS,RPUHOUR,...
                RPUBRANCH,RPURESERVETYPE,RPUSLACKBUS,RPUGENBUS,RPUBRANCHBUS,RPUPUMPSCHEDULE,RPUSTORAGELEVEL,RPUPUMPING] ...
                = getgamsdata('TOTAL_RTSCUCOUTPUT','RTSCUC','YES',GEN,INTERVAL,BUS,BRANCH,RESERVETYPE,RESERVEPARAM,GENPARAM,STORAGEPARAM,BRANCHPARAM);
        end
        try
        RPUModelSolutionStatus(rpumodeltracker,:)=[time modelSolveStatus numberOfInfes solverStatus relativeGap];
        rpumodeltracker=rpumodeltracker+1;
        if numberOfInfes ~= 0
            if ~isdeployed
              dbstop if warning stophere:RPUinfeasible;
            end
            warning('stophere:RPUinfeasible', 'Infeasible RPU Solution');
        end;
        catch
        end;
        
        for x=1:size(RPU_RULES_POST_in,1)
            try run(RPU_RULES_POST_in{x,1});catch;end; 
        end
        
        RPUBINDINGCOMMITMENT(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1) ;
        RPUBINDINGCOMMITMENT(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
        RPUBINDINGSHUTDOWN(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1) ;
        RPUBINDINGSCHEDULE(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
        RPUMARGINALLOSS(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
        RPUBINDINGPUMPING(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
        RPUBINDINGPUMPSCHEDULE(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
        RPUBINDINGCOMMITMENT(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:ngen+1) = round(RPUUNITSTATUS.val(:,:)');
        RPUBINDINGPUMPING(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:ngen+1) = round(RPUPUMPING.val(:,:)');
        RPUBINDINGSTARTUP(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:ngen+1) = round(RPUUNITSTARTUP.val(:,:)');
        for rpu_int=1:HRPU
            STATUS(ceil(RPU_LOOKAHEAD_INTERVAL_VAL(rpu_int,1)*rtscuc_I_perhour) + 1,:) = round(RPUUNITSTATUS.val(:,rpu_int)');
            PUMPSTATUS(ceil(RPU_LOOKAHEAD_INTERVAL_VAL(rpu_int,1)*rtscuc_I_perhour) + 1,:) = round(RPUPUMPING.val(:,rpu_int)');
        end;
        RPUBINDINGSHUTDOWN(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:1+ngen) = round(RPUUNITSHUTDOWN.val(:,:)');
        RPUBINDINGSCHEDULE(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:1+ngen) = RPUGENSCHEDULE.val(:,:)';
        RPUBINDINGPUMPSCHEDULE(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:1+ngen) = RPUPUMPSCHEDULE.val(:,:)';
        RPUMARGINALLOSS(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2) = marginalLoss(1,1);
        
        UNIT_STARTINGUP_VAL = zeros(ngen,1);
        for i=1:ngen
            if INITIAL_STARTUP_PERIODS_VAL(i,1) == 1
                UNIT_STARTINGUP_VAL(i,1) = 1;
            end;
            if RPUBINDINGSTARTUP(RPU_binding_interval_index,1+i) == 1;
                RTSCUC_INITIAL_START_TIME(i,1) = time;
                UNIT_STARTINGUP_VAL(i,1) = 1;
            end;
            if RPUBINDINGSHUTDOWN(RPU_binding_interval_index,1+i) == 1;
                UNIT_SHUTTINGDOWN_VAL(i,1) = 1;
            end;
            if RPUBINDINGPUMPING(RPU_binding_interval_index,1+i) - PUMPSTATUS(RTSCUC_binding_interval_index-1,i) == 1;
                RTSCUC_INITIAL_PUMPUP_TIME(i,1) = time;
            end;
        end;
        
        for r=1:nreserve
            RPUBINDINGRESERVE(RPU_binding_interval_index,1:1+ngen,r) = [RPU_LOOKAHEAD_INTERVAL_VAL(1,1) RPUGENRESERVESCHEDULE.val(:,1,r)'];
        end;
        RPUBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:) = [RPU_LOOKAHEAD_INTERVAL_VAL(1,1) RPURCP.val(:,1)'];

        %Need to save whether a wind/PV is directed to curtail so it can
        %follow those directions.
        for i=1:ngen
            if RPUVGCURTAILMENT.val(i,1) > eps
                binding_vg_curtailment(i,1) = 1;
            else
                binding_vg_curtailment(i,1) = 0;
            end;
        end;
        DISPATCH(RTSCED_binding_interval_index-1,:) = RPUBINDINGSCHEDULE(RPU_binding_interval_index,:);
        PUMPDISPATCH(RTSCED_binding_interval_index-1,:) = RPUBINDINGPUMPSCHEDULE(RPU_binding_interval_index,:);
        RESERVE(RTSCED_binding_interval_index-1,:,:) = RPUBINDINGRESERVE(RPU_binding_interval_index,:,:);
        RESERVEPRICE(RTSCED_binding_interval_index-1,:) = RPUBINDINGRESERVEPRICE(RPU_binding_interval_index,:);

        rpu_running = 0;
        RPU_binding_interval_index = RPU_binding_interval_index + 1;
        
        if(RTCPrintResults == 1)
            saveRT('RPU',RTSCUC_binding_interval_index,PRPU,hour,minute,RTCPRODCOST.val,RTCGENSCHEDULE.val,RTCLMP.val,RTCUNITSTATUS.val,RTCLINEFLOW.val,RESERVETYPE.uels,nreserve,RTCGENRESERVESCHEDULE.val,RTCRCP.val,nbranch,BRANCHDATA.val,BRANCH.uels,HRPU,RTCLINEFLOWCTGC.val);
        end;
    end;
    end;

    %{
    HOW TO DO A RESTORATION OR USE OF REPLACEMENT RESERVES
    Slowly increase the penalty factor of reserves to their nominal levels at 105 (or less) minutes past the start of the contingency.
    %}
    
%% End of Interval
    % End of real time loop rule execution
    %Breakpoints for debugging
    if debugcheck == 1 && ~isdeployed
        if time >= timefordebugstop
           Stack  = dbstack;
           stoppingpoint=Stack.line+4;
           stopcommand=sprintf('dbstop in FESTIV.m at %d',stoppingpoint);
           eval(stopcommand);
           time;
        end;
    end;
    Stop_FESTIV
    if stop == 1 && ~isdeployed
        Stack2  = dbstack;
        stoppingpoint2=Stack2.line+4;
        stopcommand2=sprintf('dbstop in FESTIV.m at %d',stoppingpoint2);
        eval(stopcommand2);
        time;
    end

    %Done with interval, go forward in time
    AGC_interval_index = AGC_interval_index + 1;
    second = second + t_AGC; 
    if(second >= 60)
        second = floor(mod(second+eps,60));
        minute = minute + 1;
    end;
    if(minute >= 60)
        minute = 0;
        hour = hour + 1;
    end;
    if(hour >= 24)
        hour = 0;
        day = day+1;
    end;
    if use_gui
      fprintf(1,'\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b\b %03d days %02d hrs %02d min %02d sec',day,hour,minute,second);
    end
    time = day*24 + hour + minute/60 + second/(60*60);
    rtscuc_update = rtscuc_update + t_AGC/60;
    rtsced_update = rtsced_update + t_AGC/60;
    dascuc_update = dascuc_update + t_AGC/(60*60);
    for x=1:size(RT_LOOP_POST_in,1)
        try run(RT_LOOP_POST_in{x,1});catch;end; 
    end;
    
end;
fprintf('\n')
tEnd = toc(tStart);
fprintf('Simulation Complete! (%02.0f min, %05.2f s)\n',floor(tEnd/60),rem(tEnd,60));
fprintf('\nOutputs\n-------\n')

%% Post Processing
for x=1:size(POST_PROCESSING_PRE_in,1)
    try run(POST_PROCESSING_PRE_in{x,1});catch;end; 
end

CALCULATE_COSTS_AND_RELIABILITY_METRICS

for x=1:size(POST_PROCESSING_POST_in,1)
    try run(POST_PROCESSING_POST_in{x,1});catch;end; 
end

for x=1:size(SAVING_PRE_in,1)
    try run(SAVING_PRE_in{x,1});catch;end;
end;

if ~ispc
  try
    SAVE_OUTPUT_TO_HDF5;  % HPC-HDF5
  catch
    tmp_err = lasterror;
    fprintf('Error calling SAVE_OUTPUT_TO_HDF5\n')
    disp(tmp_err)
  end
else
    SAVE_CURRENT_FESTIV_CASE;  % Windows-Excel
end

if strcmp(suppress_plots_in,'NO')
    CREATE_FESTIV_OUTPUT_PLOTS
end

for x=1:size(SAVING_POST_in,1)
    try run(SAVING_POST_in{x,1});catch;end;
end;

%% Check For FESTIV End
try numberofFESTIVrun=numberofFESTIVrun+1;catch;end;
if exist('multiplefilecheck')==1
    if multiplefilecheck == 0
        finishedrunningFESTIV=1;
    else
        if numberofFESTIVrun <= numofinputfiles
            finishedrunningFESTIV=0;
            clearvars -except 'cancel' 'numberofFESTIVrun' 'finishedrunningFESTIV' 'multiplefilecheck' 'numofinputfiles' 'gamspath' 'on_hpc' 'use_gui' 'gams_mip_flag' 'gams_lp_flag';
        else
            finishedrunningFESTIV=1;
        end
    end
else
    finishedrunningFESTIV=1;
end

else
    finishedrunningFESTIV=1;
end
end;
%End program
