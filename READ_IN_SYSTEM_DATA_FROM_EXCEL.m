[pathstr, name, ext] = fileparts(inputPath);
inputfilename=strcat(name,ext);
fullinputfilepath=evalin('caller','inputPath');
[inputfilepath,inputfilename,inputfileextension]=fileparts(fullinputfilepath);
fileName = [inputfilepath,filesep,inputfilename,'.h5'];

%global data for easy use within functions
global ngen nbus nvg nvcr nESR nbranch npar nhvdc nctgc nblock nreserve storage_to_gen_index gen_to_storage_index

%VG AND LOAD DATA
fprintf('Input File: %s\n',inputfilename);
fprintf('Reading Input Files...')

%actuals
if useHDF5==0
    try
        [~, actual_load_input_file] = xlsread(inputPath,'ACTUAL_LOAD_REF','A2:A400');
        actual_load_input_file=actual_load_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(actual_load_input_file,1)
            actual_load_input_file(d,1)=strcat(pathstr, filesep, 'TIMESERIES', filesep,actual_load_input_file(d,1));
        end;
    catch
        actual_load_input_file=0;
        helpdlg('Data not assigned to Actual Load');
    end
    try
        [~, actual_vg_input_file] = xlsread(inputPath,'ACTUAL_VG_REF','A2:A400');
        actual_vg_input_file=actual_vg_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(actual_vg_input_file,1)
            actual_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,actual_vg_input_file(d,1));
        end;
    catch
        actual_vg_input_file=0;
        helpdlg('Data not assigned to Actual VG');
    end
end

%DASCUC inputs
if useHDF5==0
    try
        [~, dac_load_input_file] = xlsread(inputPath,'DA_LOAD_REF','A2:A400');
        dac_load_input_file=dac_load_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(dac_load_input_file,1)
            dac_load_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,dac_load_input_file(d,1));
        end;
    catch
        dac_load_input_file = 0;
    end;
    try
        [~, dac_vg_input_file] = xlsread(inputPath,'DA_VG_REF','A2:A400');
        dac_vg_input_file=dac_vg_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(dac_vg_input_file,1)
            dac_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,dac_vg_input_file(d,1));
        end;
    catch
        dac_vg_input_file = 0;
    end;
end

%RTSCUC inputs
if useHDF5==0
    try
        [~, rtc_load_input_file] = xlsread(inputPath,'RTC_LOAD_REF','A2:A400');
        rtc_load_input_file=rtc_load_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(rtc_load_input_file,1)
            rtc_load_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtc_load_input_file(d,1));
        end;
    catch
        rtc_load_input_file = 0;
    end;
    try
        [~, rtc_vg_input_file] = xlsread(inputPath,'RTC_VG_REF','A2:A400');
        rtc_vg_input_file=rtc_vg_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(rtc_vg_input_file,1)
            rtc_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtc_vg_input_file(d,1));
        end;
    catch
        rtc_vg_input_file = 0;
    end;
end

%RTSCED inputs
if useHDF5==0
    try
        [~, rtd_load_input_file] = xlsread(inputPath,'RTD_LOAD_REF','A2:A400');
        rtd_load_input_file=rtd_load_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(rtd_load_input_file,1)
            rtd_load_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtd_load_input_file(d,1));
        end;
    catch
        rtd_load_input_file = 0;
    end;
    try
        [~, rtd_vg_input_file] = xlsread(inputPath,'RTD_VG_REF','A2:A400');
        rtd_vg_input_file=rtd_vg_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(rtd_vg_input_file,1)
            rtd_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtd_vg_input_file(d,1));
        end;
    catch
        rtd_vg_input_file = 0;
    end;
end

%Reserve inputs
if useHDF5==0
    try
        [~,dac_reserve_input_file]= xlsread(inputPath,'DA_RESERVE_REF','A2:A400');
        dac_reserve_input_file=dac_reserve_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(dac_reserve_input_file,1)
            dac_reserve_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,dac_reserve_input_file(d,1));
        end;
    catch
        dac_reserve_input_file=0;
    end;
    try
        [~,rtc_reserve_input_file]= xlsread(inputPath,'RTC_RESERVE_REF','A2:A400');
        rtc_reserve_input_file=rtc_reserve_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(rtc_reserve_input_file,1)
            rtc_reserve_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtc_reserve_input_file(d,1));
        end;
    catch
        rtc_reserve_input_file=0;
    end;
    try
        [~,rtd_reserve_input_file] = xlsread(inputPath,'RTD_RESERVE_REF','A2:A400');
        rtd_reserve_input_file=rtd_reserve_input_file(start_date:start_date+daystosimulate-1);
        for d=1:size(rtd_reserve_input_file,1)
            rtd_reserve_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtd_reserve_input_file(d,1));
        end;
    catch
        rtd_reserve_input_file=0;
    end;
end

if useHDF5==0
    [~,SYSPARAM_VAL] = xlsread(inputPath,'SYSTEM','A2:A15');
else
    x=h5read(fileName,'/Main Input File/SYSTEM');
    SYSPARAM_VAL=x.Property;
end
SYSPARAM.uels = SYSPARAM_VAL';
SYSPARAM.val = ones(size(SYSPARAM_VAL,1),1);
SYSPARAM.name = 'SYSPARAM';
SYSPARAM.form = 'full';
SYSPARAM.type = 'set';
DEFAULT_DATA.SYSPARAM=SYSPARAM;

if useHDF5==0
    SYSTEMVALUE_VAL = xlsread(inputPath,'SYSTEM','B2:B15');
else
    SYSTEMVALUE_VAL = x.Value;
end
SYSTEMVALUE.val = SYSTEMVALUE_VAL;
SYSTEMVALUE.uels = {SYSPARAM_VAL'};
SYSTEMVALUE.name = 'SYSTEMVALUE';
SYSTEMVALUE.form = 'full';
SYSTEMVALUE.type = 'parameter';
DEFAULT_DATA.SYSTEMVALUE=SYSTEMVALUE;

if useHDF5==0
    [~,GEN_VAL] = xlsread(inputPath,'GEN','A2:A10000');
else
    x=h5read(fileName,'/Main Input File/GEN');
    GEN_VAL=x.Generator;
end
GEN.uels = GEN_VAL';
GEN.name = 'GEN';
GEN.form = 'full';
GEN.type = 'set';
ngen = size(GEN_VAL,1);
GEN.val = ones(ngen,1);
DEFAULT_DATA.GEN=GEN;

if useHDF5==0
    [~, GENPARAM_VAL] = xlsread(inputPath,'GEN','B1:AH1');
else
    y=fieldnames(x)';
    GENPARAM_VAL=y(1,2:end);
end
GENPARAM.uels = GENPARAM_VAL;
GENPARAM.val = ones(size(GENPARAM_VAL,2),1);
GENPARAM.name = 'GENPARAM';
GENPARAM.form = 'full';
GENPARAM.type = 'set';
DEFAULT_DATA.GENPARAM=GENPARAM;

if useHDF5==0
    GENVALUE_VAL = xlsread(inputPath,'GEN','B2:AH10000');
else
    temp=zeros(ngen,size(GENPARAM_VAL,2));
    for i=1:size(GENPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',GENPARAM_VAL{i}));
    end
    GENVALUE_VAL = temp;
end
GENVALUE.uels = {GEN_VAL' GENPARAM_VAL};
GENVALUE.name = 'GENVALUE';
GENVALUE.form = 'full';
GENVALUE.type = 'parameter';
GENVALUE_VAL(isfinite(GENVALUE_VAL) == 0) = 0;GENVALUE.val = GENVALUE_VAL;
DEFAULT_DATA.GENVALUE=GENVALUE;


try
if useHDF5==0
    [~, STORAGEPARAM_VAL] = xlsread(inputPath,'STORAGE','B1:AH1');
else
    x=h5read(fileName,'/Main Input File/STORAGE');
    if ~strcmp(fieldnames(x),'None')
        y=fieldnames(x)';
        STORAGEPARAM_VAL=y(1,2:end);
    else
        STORAGEPARAM_VAL={'MAX_PUMP','MIN_PUMP','MIN_PUMP_TIME','PUMP_STARTUP_TIME','PUMP_SHUTDOWN_TIME','PUMP_RAMP_RATE','INITIAL_STORAGE','FINAL_STORAGE','STORAGE_MAX','EFFICIENCY','RESERVOIR_VALUE','INITIAL_PUMP_STATUS','INITIAL_PUMP_MW','INITIAL_PUMP_HOUR','VARIABLE_EFFICIENCY','ENFORCE_FINAL_STORAGE'};
    end
end
catch
STORAGEPARAM_VAL={'MAX_PUMP','MIN_PUMP','MIN_PUMP_TIME','PUMP_STARTUP_TIME','PUMP_SHUTDOWN_TIME','PUMP_RAMP_RATE','INITIAL_STORAGE','FINAL_STORAGE','STORAGE_MAX','EFFICIENCY','RESERVOIR_VALUE','INITIAL_PUMP_STATUS','INITIAL_PUMP_MW','INITIAL_PUMP_HOUR','VARIABLE_EFFICIENCY','ENFORCE_FINAL_STORAGE'};
end
STORAGEPARAM.uels = STORAGEPARAM_VAL;
STORAGEPARAM.val = ones(size(STORAGEPARAM_VAL,2),1);
STORAGEPARAM.name = 'STORAGEPARAM';
STORAGEPARAM.form = 'full';
STORAGEPARAM.type = 'set';
DEFAULT_DATA.STORAGEPARAM=STORAGEPARAM;

try
if useHDF5==0
    [~,STORAGE_UNITS] = xlsread(inputPath,'STORAGE','A2:A100');
else
    if ~strcmp(x.Generator{1},'None')
        STORAGE_UNITS=x.Generator;
    else
        STORAGE_UNITS={};
    end
end
catch
STORAGE_UNITS={};
end

try
if useHDF5==0
    STORAGEVALUE_VAL = xlsread(inputPath,'STORAGE','B2:AH100');
else
    temp=zeros(size(STORAGE_UNITS,1),size(STORAGEPARAM_VAL,2));
    if ~strcmp(fieldnames(x),'None')
        for i=1:size(STORAGEPARAM_VAL,2)
     
            temp(:,i)=x.(sprintf('%s',STORAGEPARAM_VAL{i}));
        end
        STORAGEVALUE_VAL = temp;
    else
        STORAGEVALUE_VAL = [];
    end
end
catch
STORAGEVALUE_VAL = [];
end
STORAGEVALUE_VAL(isfinite(STORAGEVALUE_VAL) == 0) = 0;
STORAGEVALUE.uels = {STORAGE_UNITS' STORAGEPARAM.uels};
STORAGEVALUE.name = 'STORAGEVALUE';
STORAGEVALUE.form = 'full';
STORAGEVALUE.type = 'parameter';
STORAGEVALUE.val=STORAGEVALUE_VAL;

storage_yes=zeros(size(STORAGE_UNITS));
for e=1:size(STORAGE_UNITS,1)
    i=1;
    while i<=ngen
        if strcmp(GEN_VAL(i,1),STORAGE_UNITS(e,1))
            if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index
                storage_yes(e,1)=1;
            else
                storage_yes(e,1)=0;
            end
            i=ngen;
        elseif i==ngen
            storage_yes(e,1)=0;
        end
        i=i+1;
    end
end
STORAGE_UNITS=STORAGE_UNITS(find(storage_yes==1),:);
STORAGEVALUE_VAL=STORAGEVALUE_VAL(find(storage_yes==1),:);
STORAGEVALUE.val=STORAGEVALUE_VAL;
STORAGEVALUE.uels = {STORAGE_UNITS' STORAGEPARAM.uels};
DEFAULT_DATA.STORAGE_UNITS=STORAGE_UNITS;
DEFAULT_DATA.STORAGEVALUE=STORAGEVALUE;

if size(STORAGE_UNITS,1) > 0
storageforadjustedcostcalculation=STORAGEVALUE_VAL(:,final_storage);
end

if useHDF5==0
    [~, BUS_VAL] = xlsread(inputPath,'BUS','A2:A10000');
else
    x=h5read(fileName,'/Main Input File/BUS');
    BUS_VAL=x.BUSES;
end
BUS.uels = BUS_VAL';
BUS.name = 'BUS';
BUS.form = 'full';
BUS.type = 'set';
DEFAULT_DATA.BUS=BUS;
nbus = size(BUS_VAL,1);
BUS.val = ones(nbus,1);

try
if useHDF5==0
    [~, BRANCH_VAL] = xlsread(inputPath,'BRANCHDATA','A2:A10000');
else
    x=h5read(fileName,'/Main Input File/BRANCHDATA');
    BRANCH_VAL=x.NAME1;
end
catch
BRANCH_VAL = [];
end



BRANCH.uels = BRANCH_VAL';
BRANCH.name = 'BRANCH';
BRANCH.form = 'full';
BRANCH.type = 'set';
DEFAULT_DATA.BRANCH=BRANCH;
nbranch = size(BRANCH_VAL,1);
BRANCH.val = ones(nbranch,1);

getGENBUSdata;
INJECTION_FACTOR.name='INJECTION_FACTOR';
INJECTION_FACTOR.form='full';
INJECTION_FACTOR.type='parameter';
INJECTION_FACTOR.val=INJECTION_FACTOR_VAL;
INJECTION_FACTOR.uels = GENBUS_STRING;
GENBUS.name='GENBUS';
GENBUS.form='full';
GENBUS.type='set';
GENBUS.uels=GENBUS_STRING;
GENBUS.val=GENBUS_VAL;
USEGAMS='NO';

getBRANCHBUSdata;
BRANCHBUS.val = BRANCHBUS_VAL;
BRANCHBUS.name = 'BRANCHBUS';
BRANCHBUS.form = 'full';
BRANCHBUS.uels = BRANCHBUS_STRING;
BRANCHBUS.type = 'parameter';


DEFAULT_DATA.GENBUS=GENBUS;
DEFAULT_DATA.BRANCHBUS=BRANCHBUS;
DEFAULT_DATA.INJECTION_FACTOR=INJECTION_FACTOR;

if useHDF5==0
    [~, BRANCHPARAM_VAL] = xlsread(inputPath,'BRANCHDATA','C1:X1');
else
    x=h5read(fileName,'/Main Input File/BRANCHDATA');
    y=fieldnames(x);
    i=1;
    while i<=size(y,1)
       if strcmp(y{i},'REACTANCE')
           startind=i;
           i=size(y,1);
       end
       i=i+1;
    end
    BRANCHPARAM_VAL=y(startind:end,1)';
end
if strcmp(BRANCHPARAM_VAL{1},'')
     BRANCHPARAM_VAL=BRANCHPARAM_VAL(2:end);
end
BRANCHPARAM.uels = BRANCHPARAM_VAL;
BRANCHPARAM.val = ones(size(BRANCHPARAM_VAL,2),1);
BRANCHPARAM.name = 'BRANCHPARAM';
BRANCHPARAM.form = 'full';
BRANCHPARAM.type = 'set';
DEFAULT_DATA.BRANCHPARAM=BRANCHPARAM;

if useHDF5==0
    BRANCHDATA_VAL = xlsread(inputPath,'BRANCHDATA','B2:X10000');
else
    temp=zeros(nbranch,size(BRANCHPARAM_VAL,2));
    for i=1:size(BRANCHPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',BRANCHPARAM_VAL{i}));
    end
    BRANCHDATA_VAL = temp;
end
BRANCHDATA.uels = {BRANCH_VAL' BRANCHPARAM_VAL};
BRANCHDATA.name = 'BRANCHDATA';
BRANCHDATA.form = 'full';
BRANCHDATA.type = 'parameter';
BRANCHDATA_VAL(isfinite(BRANCHDATA_VAL) == 0) = 0;
if strcmp(NETWORK_CHECK,'NO')
    BRANCHDATA_VAL(:,resistance)=0;
end;



BRANCHDATA.val = BRANCHDATA_VAL;
DEFAULT_DATA.BRANCHDATA=BRANCHDATA;

if useHDF5==0
    [~, RESERVETYPE_VAL] = xlsread(inputPath,'RESERVEPARAM','A2:A15');
else
    x=h5read(fileName,'/Main Input File/RESERVEPARAM');
    RESERVETYPE_VAL=x.ReserveName;
end
RESERVETYPE.uels = RESERVETYPE_VAL';
RESERVETYPE.name = 'RESERVETYPE';
RESERVETYPE.form = 'full';
RESERVETYPE.type = 'set';
DEFAULT_DATA.RESERVETYPE=RESERVETYPE;
nreserve = size(RESERVETYPE_VAL,1);
RESERVETYPE.val = ones(nreserve,1);

if useHDF5==0
    [~, RESERVEPARAM_VAL] = xlsread(inputPath,'RESERVEPARAM','B1:K1');
else
    y=fieldnames(x);
    RESERVEPARAM_VAL=y(2:end,1)';
end
RESERVEPARAM.uels = RESERVEPARAM_VAL;
RESERVEPARAM.val = ones(size(RESERVEPARAM_VAL,2),1);
RESERVEPARAM.name = 'RESERVEPARAM';
RESERVEPARAM.form = 'full';
RESERVEPARAM.type = 'set';
DEFAULT_DATA.RESERVEPARAM=RESERVEPARAM;

if useHDF5==0
    RESERVEVALUE_VAL = xlsread(inputPath,'RESERVEPARAM','B2:K15');
else
    temp=zeros(nreserve,size(RESERVEPARAM_VAL,2));
    for i=1:size(RESERVEPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',RESERVEPARAM_VAL{i}));
    end
    RESERVEVALUE_VAL = temp;
end
RESERVEVALUE.uels = {RESERVETYPE_VAL' RESERVEPARAM_VAL};
RESERVEVALUE.name = 'RESERVEVALUE';
RESERVEVALUE.form = 'full';
RESERVEVALUE.type = 'parameter';
RESERVEVALUE_VAL(isfinite(RESERVEVALUE_VAL) == 0) = 0;
RESERVEVALUE.val = RESERVEVALUE_VAL;
DEFAULT_DATA.RESERVEVALUE=RESERVEVALUE;

if useHDF5==0
    [LOAD_DIST_VAL, LOAD_DIST_STRING] = xlsread(inputPath,'LOAD_DIST','A2:B10000');
else
    x=h5read(fileName,'/Main Input File/LOAD_DIST');
    LOAD_DIST_STRING=x.BUS;
    LOAD_DIST_VAL=x.LOAD;    
end
LOAD_DIST.uels = LOAD_DIST_STRING';
LOAD_DIST.name = 'LOAD_DIST';
LOAD_DIST.form = 'full';
LOAD_DIST.type = 'parameter';
LOAD_DIST_VAL(isfinite(LOAD_DIST_VAL) == 0) = 0;
LOAD_DIST.val = LOAD_DIST_VAL;
DEFAULT_DATA.LOAD_DIST=LOAD_DIST;

if size(LOAD_DIST_VAL,1) ~= nbus
    fullLoadDist=zeros(nbus,1);
    for i=1:size(LOAD_DIST_VAL,1)
        found=0;j=1;
        while found==0
            if strcmp(LOAD_DIST.uels{i},BUS_VAL{j})
                fullLoadDist(j)=LOAD_DIST_VAL(i);
                found=1;
            else
                j=j+1;
            end
        end
    end
else
    fullLoadDist=LOAD_DIST_VAL;
end

if useHDF5==0
    [~, COSTCURVEPARAM_VAL] = xlsread(inputPath,'COST','B1:W1');
else
    x=h5read(fileName,'/Main Input File/COST');
    y=fieldnames(x);
    COSTCURVEPARAM_VAL=y(2:end,1)';
end
COSTCURVEPARAM.uels = COSTCURVEPARAM_VAL;
COSTCURVEPARAM.val = ones(size(COSTCURVEPARAM_VAL,2),1);
COSTCURVEPARAM.name = 'COSTCURVEPARAM';
COSTCURVEPARAM.form = 'full';
COSTCURVEPARAM.type = 'set';
DEFAULT_DATA.COSTCURVEPARAM=COSTCURVEPARAM;

if useHDF5==0
    [COST_CURVE_VAL, COST_CURVE_STRING] = xlsread(inputPath,'COST','A2:W10000');
else
    COST_CURVE_STRING=x.Generator;
    temp=zeros(ngen,size(COSTCURVEPARAM_VAL,2));
    for i=1:size(COSTCURVEPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',COSTCURVEPARAM_VAL{i}));
    end
    COST_CURVE_VAL = temp;
end
COST_CURVE.uels = {COST_CURVE_STRING' COSTCURVEPARAM_VAL};
COST_CURVE.name = 'COST_CURVE';
COST_CURVE.form = 'full';
COST_CURVE.type = 'parameter';
COST_CURVE_VAL(isfinite(COST_CURVE_VAL) == 0) = 0;
COST_CURVE.val = COST_CURVE_VAL;
DEFAULT_DATA.COST_CURVE=COST_CURVE;

nblock=size(COST_CURVE_VAL,2)/2;
for k=1:nblock
    BLOCK_STRING{k}=strcat('BLOCK',num2str(k));
end;
BLOCK.uels = BLOCK_STRING;
BLOCK.name='BLOCK';
BLOCK.type='SET';
BLOCK.form='FULL';
BLOCK.val=ones(nblock,1);

GENBLOCK.uels = {COST_CURVE_STRING' BLOCK.uels};
BLOCK_CAP_VAL=COST_CURVE_VAL(:,[2:2:nblock*2]);
GENBLOCK_VAL(:,1) = ones(size(BLOCK_CAP_VAL,1),1);
for k=2:nblock
    GENBLOCK_VAL(:,k) = BLOCK_CAP_VAL(:,k)>BLOCK_CAP_VAL(:,k-1);
end;
GENBLOCK.val = GENBLOCK_VAL;
GENBLOCK.name = 'GENBLOCK';
GENBLOCK.form = 'full';
GENBLOCK.type = 'set';
DEFAULT_DATA.GENBLOCK=GENBLOCK;

BLOCK_COST.name='BLOCK_COST';
BLOCK_COST.uels={COST_CURVE_STRING' BLOCK_STRING};
BLOCK_COST.form='FULL';
BLOCK_COST.type='parameter';
BLOCK_COST_VAL=COST_CURVE_VAL(:,[1:2:nblock*2]);
BLOCK_COST.val = BLOCK_COST_VAL;
DEFAULT_DATA.BLOCK_COST=BLOCK_COST;

BLOCK_CAP.name='BLOCK_CAP';
BLOCK_CAP.uels={COST_CURVE_STRING' BLOCK.uels};
BLOCK_CAP.form='FULL';
BLOCK_CAP.type='parameter';
BLOCK_CAP.val=BLOCK_CAP_VAL;
DEFAULT_DATA.BLOCK_CAP=BLOCK_CAP;


if useHDF5==0
    RESERVE_COST_VAL = xlsread(inputPath,'ASC','B2:P10000');
    [~, RESERVE_COST_STRING1] = xlsread(inputPath,'ASC','A2:A10000');
    [~, RESERVE_COST_STRING2] = xlsread(inputPath,'ASC','B1:P1');
else
    x=h5read(fileName,'/Main Input File/ASC');
    y=fieldnames(x);
    RESERVE_COST_STRING1=x.Generator;
    RESERVE_COST_STRING2=y(2:end,1)';
    temp=zeros(ngen,size(RESERVE_COST_STRING2,2));
    for i=1:size(RESERVE_COST_STRING2,2)
        temp(:,i)=x.(sprintf('%s',RESERVE_COST_STRING2{i}));
    end
    RESERVE_COST_VAL = temp;
end
RESERVE_COST.uels = {RESERVE_COST_STRING1' RESERVE_COST_STRING2};
RESERVE_COST.name = 'RESERVE_COST';
RESERVE_COST.form = 'full';
RESERVE_COST.type = 'parameter';
RESERVE_COST_VAL(isfinite(RESERVE_COST_VAL) == 0)=0;
RESERVE_COST.val = RESERVE_COST_VAL;
DEFAULT_DATA.RESERVE_COST=RESERVE_COST;

if useHDF5==0
    [~, START_PARAMETER_VAL] = xlsread(inputPath,'STARTUP','B1:K1');
else
    x=h5read(fileName,'/Main Input File/STARTUP');
    if ~strcmp(fieldnames(x),'None')
        y=fieldnames(x)';
        START_PARAMETER_VAL=y(1,2:end);
    else
        START_PARAMETER_VAL={'OFF_HOT','COST_HOT','OFF_WARM','COST_WARM','OFF_COLD','COST_COLD'};
    end
end
START_PARAMETER.uels = START_PARAMETER_VAL;
START_PARAMETER.val = ones(size(START_PARAMETER_VAL,2),1);
START_PARAMETER.name = 'START_PARAMETER';
START_PARAMETER.form = 'full';
START_PARAMETER.type = 'set';
DEFAULT_DATA.START_PARAMETER=START_PARAMETER;

try
if useHDF5==0
    STARTUP_VALUE_VAL = xlsread(inputPath,'STARTUP','B2:K10000');
    [~, STARTUP_VALUE_STRING1] = xlsread(inputPath,'STARTUP','A2:A10000');
    [~, STARTUP_VALUE_STRING2] = xlsread(inputPath,'STARTUP','B1:K1');
else
    if ~strcmp(fieldnames(x),'None')
        STARTUP_VALUE_STRING2={'OFF_HOT','COST_HOT','OFF_WARM','COST_WARM','OFF_COLD','COST_COLD'};
        STARTUP_VALUE_STRING1=x.Generator;
        temp=zeros(size(STARTUP_VALUE_STRING1,1),size(STARTUP_VALUE_STRING2,2));
        for i=1:size(STARTUP_VALUE_STRING2,2)
            temp(:,i)=x.(sprintf('%s',STARTUP_VALUE_STRING2{i}));
        end
        STARTUP_VALUE_VAL = temp;
    else
        STARTUP_VALUE_VAL=[];
        STARTUP_VALUE_STRING1={};
        STARTUP_VALUE_STRING2={'OFF_HOT','COST_HOT','OFF_WARM','COST_WARM','OFF_COLD','COST_COLD'};
    end
end
catch

STARTUP_VALUE_VAL=[];
end;
STARTUP_VALUE.uels = {STARTUP_VALUE_STRING1' STARTUP_VALUE_STRING2};
STARTUP_VALUE.name = 'STARTUP_VALUE';
STARTUP_VALUE.form = 'full';
STARTUP_VALUE.type = 'parameter';
STARTUP_VALUE_VAL(isfinite(STARTUP_VALUE_VAL) == 0) = 0;
STARTUP_VALUE.val=STARTUP_VALUE_VAL;

DEFAULT_DATA.STARTUP_VALUE=STARTUP_VALUE;

if ~isempty(STARTUP_VALUE_VAL)
    OFFLINE_BLOCK_VAL=STARTUP_VALUE_VAL(:,[1:2:size(STARTUP_VALUE_VAL,2)]);
    STARTUP_COST_BLOCK_VAL=STARTUP_VALUE_VAL(:,[2:2:size(STARTUP_VALUE_VAL,2)]);
else
    OFFLINE_BLOCK_VAL=[];
    STARTUP_COST_BLOCK_VAL=[];
end
OFFLINE_BLOCK.val = OFFLINE_BLOCK_VAL;
OFFLINE_BLOCK.name='OFFLINE_BLOCK';
OFFLINE_BLOCK.uels={STARTUP_VALUE_STRING1' STARTUP_VALUE_STRING2};
OFFLINE_BLOCK.form='FULL';
OFFLINE_BLOCK.type='parameter';

STARTUP_COST_BLOCK.val=STARTUP_COST_BLOCK_VAL;
STARTUP_COST_BLOCK.name='STARTUP_COST_BLOCK';
STARTUP_COST_BLOCK.uels={STARTUP_VALUE_STRING1' STARTUP_VALUE_STRING2};
STARTUP_COST_BLOCK.form='FULL';
STARTUP_COST_BLOCK.type='parameter';

nvg=0; %variable generation, resources with variable output
nvcr = 0; %variable capacity resources, resources with variable capacity
nESR = 0; %storage resources
for i=1:ngen
    if GENVALUE_VAL(i,gen_type) == wind_gen_type_index || GENVALUE_VAL(i,gen_type) == PV_gen_type_index || GENVALUE_VAL(i,gen_type) == CSP_gen_type_index 
        nvg = nvg+1;
        nvcr = nvcr+1;
    elseif GENVALUE_VAL(i,gen_type) == variable_dispatch_gen_type_index
        nvcr = nvcr + 1;
    elseif GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index
        nESR=nESR+1;
    end;
end;

npar = 0;
for l=1:nbranch
    if BRANCHDATA_VAL(l,branch_type) == fixed_par_branch_type_index || BRANCHDATA_VAL(l,branch_type) == adj_par_branch_type_index
        npar = npar+1;
    end;
end;
nhvdc = 0;
for l=1:nbranch
    if BRANCHDATA_VAL(l,branch_type) == HVDC_branch_type_index 
        nhvdc = nhvdc+1;
    end;
end;
nctgc = 0;
for l=1:nbranch
    if BRANCHDATA_VAL(l,ctgc_monitor) == 1 
        nctgc = nctgc+1;
    end;
end;


%match indices of storage to generator
storage_to_gen_index=zeros(nESR,1);
gen_to_storage_index = zeros(ngen,1);
for e=1:nESR
    for i=1:ngen
        if strcmp(GEN_VAL{i,1},STORAGE_UNITS{e,1})
            storage_to_gen_index(e,1) = i;
            gen_to_storage_index(i,1) = e;
        end;
    end;
end;

%How FESTIV AGC knows what can provide
regulation_up_index=[];
regulation_down_index=[];
for r=1:nreserve
    if RESERVEVALUE_VAL(r,res_agc) == 1
        if RESERVEVALUE_VAL(r,res_dir) == 1 || RESERVEVALUE_VAL(r,res_dir) == 3
            regulation_up_index = [regulation_up_index;r];
        end;
        if RESERVEVALUE_VAL(r,res_dir) == 2 || RESERVEVALUE_VAL(r,res_dir) == 3
            regulation_down_index = [regulation_down_index;r];
        end;
    end;
end;

%Create GDX for data used across all models
wgdx(['TEMP', filesep, 'GENERAL_MODEL_INPUT'],GEN,BUS,GENPARAM,RESERVEPARAM,BRANCHPARAM,COSTCURVEPARAM,BRANCH,...
    SYSPARAM,RESERVETYPE,STORAGEPARAM,BLOCK,GENBLOCK,SYSTEMVALUE); 

