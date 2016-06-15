fullinputfilepath=evalin('caller','inputPath');
[inputfilepath,inputfilename,inputfileextension]=fileparts(fullinputfilepath);
fileName = [inputfilepath,filesep,inputfilename,'.h5'];

if useHDF5==0
    [~,SYSPARAM_VAL] = xlsread(inputPath,'SYSTEM','A2:A15');
else
    x=h5read(fileName,'/Main Input File/SYSTEM');
    SYSPARAM_VAL=x.Property;
end
SYSPARAM.uels = SYSPARAM_VAL';
SYSPARAM.val = ones(size(SYSPARAM.uels,2),1);
SYSPARAM.name = 'SYSPARAM';
SYSPARAM.form = 'full';
SYSPARAM.type = 'set';
DEFAULT_DATA.SYSPARAM=SYSPARAM;

if useHDF5==0
    SYSTEMVALUE.val = xlsread(inputPath,'SYSTEM','B2:B15');
else
    SYSTEMVALUE.val = x.Value;
end
SYSTEMVALUE.uels = {SYSPARAM.uels};
SYSTEMVALUE.name = 'SYSTEMVALUE';
SYSTEMVALUE.form = 'full';
SYSTEMVALUE.type = 'parameter';
DEFAULT_DATA.SYSTEMVALUE=SYSTEMVALUE;

if useHDF5==0
    [~,GEN_VAL] = xlsread(inputPath,'GEN','A2:A1000');
else
    x=h5read(fileName,'/Main Input File/GEN');
    GEN_VAL=x.Generator;
end
GEN.uels = GEN_VAL';
ngen = size(GEN.uels,2);
GEN.val = ones(ngen,1);
GEN.name = 'GEN';
GEN.form = 'full';
GEN.type = 'set';
DEFAULT_DATA.GEN=GEN;

if useHDF5==0
    [~, GENPARAM_VAL] = xlsread(inputPath,'GEN','B1:AH1');
else
    y=fieldnames(x)';
    GENPARAM_VAL=y(1,2:end);
end
GENPARAM.uels = GENPARAM_VAL;
GENPARAM.val = ones(size(GENPARAM.uels,2),1);
GENPARAM.name = 'GENPARAM';
GENPARAM.form = 'full';
GENPARAM.type = 'set';
DEFAULT_DATA.GENPARAM=GENPARAM;

if useHDF5==0
    GENVALUE.val = xlsread(inputPath,'GEN','B2:AH1000');
else
    temp=zeros(ngen,size(GENPARAM_VAL,2));
    for i=1:size(GENPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',GENPARAM_VAL{i}));
    end
    GENVALUE.val = temp;
end
GENVALUE.uels = {GEN.uels GENPARAM.uels};
GENVALUE.name = 'GENVALUE';
GENVALUE.form = 'full';
GENVALUE.type = 'parameter';
for a =1:size(GENVALUE.val,1)
    for b=1:size(GENVALUE.val,2)
        if isfinite(GENVALUE.val(a,b)) == 0
            GENVALUE.val(a,b) = 0;
        end;
    end;
end;
for i=1:size(GENVALUE.val,1) % make sure min run times make sense
    if GENVALUE.val(i,mr_time) < GENVALUE.val(i,su_time) + GENVALUE.val(i,sd_time) && GENVALUE.val(i,gen_type) ~= 7 && GENVALUE.val(i,gen_type) ~= 10 && GENVALUE.val(i,gen_type) ~= 15 && GENVALUE.val(i,gen_type) ~= 16
        GENVALUE.val(i,mr_time) = GENVALUE.val(i,su_time) + GENVALUE.val(i,sd_time);
        GENVALUE.val(i,mr_time) = ceil(GENVALUE.val(i,mr_time)/(IRTC/60))*(IRTC/60);
    end
end
DEFAULT_DATA.GENVALUE=GENVALUE;

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
STORAGEPARAM.uels = STORAGEPARAM_VAL;
STORAGEPARAM.val = ones(size(STORAGEPARAM.uels,2),1);
STORAGEPARAM.name = 'STORAGEPARAM';
STORAGEPARAM.form = 'full';
STORAGEPARAM.type = 'set';
DEFAULT_DATA.STORAGEPARAM=STORAGEPARAM;

if useHDF5==0
    [~,STORAGE_UNITS] = xlsread(inputPath,'STORAGE','A2:A100');
else
    if ~strcmp(x.Generator{1},'None')
        STORAGE_UNITS=x.Generator;
    else
        STORAGE_UNITS={};
    end
end
DEFAULT_DATA.STORAGE_UNITS=STORAGE_UNITS;

if useHDF5==0
    STORAGEVALUE.val = xlsread(inputPath,'STORAGE','B2:AH100');
else
    temp=zeros(size(STORAGE_UNITS,1),size(STORAGEPARAM_VAL,2));
    if ~strcmp(fieldnames(x),'None')
        for i=1:size(STORAGEPARAM_VAL,2)
            temp(:,i)=x.(sprintf('%s',STORAGEPARAM_VAL{i}));
        end
        STORAGEVALUE.val = temp;
    else
        STORAGEVALUE.val = [];
    end
end
STORAGEVALUE.uels = {STORAGE_UNITS' STORAGEPARAM.uels};
STORAGEVALUE.name = 'STORAGEVALUE';
STORAGEVALUE.form = 'full';
STORAGEVALUE.type = 'parameter';
for a =1:size(STORAGEVALUE.val,1)
    for b=1:size(STORAGEVALUE.val,2)
        if isfinite(STORAGEVALUE.val(a,b)) == 0
            STORAGEVALUE.val(a,b) = 0;
        end;
    end;
end;
tempval=zeros(ngen,size(STORAGEPARAM.uels,2));
try
    pshunitindicies=find(GENVALUE.val(:,gen_type)==6);
    tempval(pshunitindicies,:)=STORAGEVALUE.val;
catch
end
STORAGEVALUE.val=tempval;
STORAGEVALUE.uels={GEN.uels STORAGEPARAM.uels};
DEFAULT_DATA.STORAGEVALUE=STORAGEVALUE;

if size(STORAGE_UNITS,1) > 0
storageforadjustedcostcalculation=STORAGEVALUE.val(:,final_storage);
end

if useHDF5==0
    [~, BUS_VAL] = xlsread(inputPath,'BUS','A2:A10000');
else
    x=h5read(fileName,'/Main Input File/BUS');
    BUS_VAL=x.BUSES;
end
BUS.uels = BUS_VAL';
nbus = size(BUS.uels,2);
BUS.val = ones(nbus,1);
BUS.name = 'BUS';
BUS.form = 'full';
BUS.type = 'set';
DEFAULT_DATA.BUS=BUS;

if useHDF5==0
    [~, BRANCH_VAL] = xlsread(inputPath,'BRANCHDATA','A2:A10000');
else
    x=h5read(fileName,'/Main Input File/BRANCHDATA');
    BRANCH_VAL=x.NAME1;
end
BRANCH.uels = BRANCH_VAL';
nbranch = size(BRANCH.uels,2);
BRANCH.val = ones(nbranch,1);
BRANCH.name = 'BRANCH';
BRANCH.form = 'full';
BRANCH.type = 'set';
DEFAULT_DATA.BRANCH=BRANCH;

if nbranch <= 1000 && ngen <= 250
    BRANCHBUS2=getBRANCHBUS(inputPath);
    PARTICIPATION_FACTORS=getParticipatoinFactors(inputPath);
    TEMP=PARTICIPATION_FACTORS.val;
    TEMP=double(TEMP~=0);
    GENBUS2.name='GENBUS';
    GENBUS2.form='full';
    GENBUS2.type='set';
    GENBUS2.uels=PARTICIPATION_FACTORS.uels;
    GENBUS2.val=TEMP;
    USEGAMS='NO';
else
    % Branch Bus Data
    if exist(['TEMP',filesep,'BRANCHBUS2.inc'],'file') == 2
        delete(['TEMP',filesep,'BRANCHBUS2.inc']);
    end
    if useHDF5==0
        [~,branchbusstrings]=xlsread(inputPath,'BRANCHDATA','B2:B10000');
    else
        branchbusstrings=x.BRANCHBUS;
    end
    fid=fopen(['TEMP',filesep,'BRANCHBUS2.inc'],'w+');
    for i=1:size(branchbusstrings,1)
        fprintf(fid,branchbusstrings{i,1});
        fprintf(fid,'\r\n');
    end
    fclose(fid);
    BRANCHBUS2.val = 0;
    BRANCHBUS2.name = 'BRANCHBUS2';
    BRANCHBUS2.form = 'full';
    BRANCHBUS2.uels = cell(1,0);
    BRANCHBUS2.type = 'parameter';
    % Participation Factor Data
    if exist(['TEMP',filesep,'PARTF2.inc'],'file') == 2
        delete(['TEMP',filesep,'PARTF2.inc']);
    end
    if useHDF5==0
        [genbusvalues,genbusstrings]=xlsread(inputPath,'GENBUS','A2:B10000');
    else
        x=h5read(fileName,'/Main Input File/GENBUS');
        genbusstrings=x.GENBUS;
        genbusvalues=x.PARTICIPATION_FACTOR;
    end
    myformat='%s %.05f';
    fid=fopen(['TEMP',filesep,'PARTF2.inc'],'w+');
    for i=1:size(genbusstrings,1)
        fprintf(fid,myformat,genbusstrings{i,1},genbusvalues(i,1));
        fprintf(fid,'\r\n');
    end
    fclose(fid);
    PARTICIPATION_FACTORS.val = 0;
    PARTICIPATION_FACTORS.name = 'PARTICIPATION_FACTORS';
    PARTICIPATION_FACTORS.form = 'full';
    PARTICIPATION_FACTORS.uels = cell(1,0);
    PARTICIPATION_FACTORS.type = 'parameter';
    % Gen Bus Data
    if exist(['TEMP',filesep,'GENBUSSET2.inc'],'file') == 2
        delete(['TEMP',filesep,'GENBUSSET2.inc']);
    end
    fid=fopen(['TEMP',filesep,'GENBUSSET2.inc'],'w+');
    for i=1:size(genbusstrings,1)
        fprintf(fid,genbusstrings{i,1});
        fprintf(fid,'\r\n');
    end
    fclose(fid);
    GENBUS2.val = 0;
    GENBUS2.name = 'GENBUS2';
    GENBUS2.form = 'full';
    GENBUS2.uels = cell(1,0);
    GENBUS2.type = 'parameter';
    USEGAMS='YES';
end
DEFAULT_DATA.GENBUS2=GENBUS2;
DEFAULT_DATA.BRANCHBUS2=BRANCHBUS2;
DEFAULT_DATA.PARTICIPATION_FACTORS=PARTICIPATION_FACTORS;

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
BRANCHPARAM.val = ones(size(BRANCHPARAM.uels,2),1);
BRANCHPARAM.name = 'BRANCHPARAM';
BRANCHPARAM.form = 'full';
BRANCHPARAM.type = 'set';
DEFAULT_DATA.BRANCHPARAM=BRANCHPARAM;

if useHDF5==0
    BRANCHDATA.val = xlsread(inputPath,'BRANCHDATA','B2:X10000');
else
    temp=zeros(nbranch,size(BRANCHPARAM_VAL,2));
    for i=1:size(BRANCHPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',BRANCHPARAM_VAL{i}));
    end
    BRANCHDATA.val = temp;
end
BRANCHDATA.uels = {BRANCH.uels BRANCHPARAM.uels};
BRANCHDATA.name = 'BRANCHDATA';
BRANCHDATA.form = 'full';
BRANCHDATA.type = 'parameter';
for a =1:size(BRANCHDATA.val,1)
    for b=1:size(BRANCHDATA.val,2)
        if isfinite(BRANCHDATA.val(a,b)) == 0
            BRANCHDATA.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.BRANCHDATA=BRANCHDATA;

if useHDF5==0
    [~, RESERVETYPE_VAL] = xlsread(inputPath,'RESERVEPARAM','A2:A15');
else
    x=h5read(fileName,'/Main Input File/RESERVEPARAM');
    RESERVETYPE_VAL=x.ReserveName;
end
RESERVETYPE.uels = RESERVETYPE_VAL';
nreserve = size(RESERVETYPE.uels,2);
RESERVETYPE.val = ones(nreserve,1);
RESERVETYPE.name = 'RESERVETYPE';
RESERVETYPE.form = 'full';
RESERVETYPE.type = 'set';
DEFAULT_DATA.RESERVETYPE=RESERVETYPE;

if useHDF5==0
    [~, RESERVEPARAM_VAL] = xlsread(inputPath,'RESERVEPARAM','B1:K1');
else
    y=fieldnames(x);
    RESERVEPARAM_VAL=y(2:end,1)';
end
RESERVEPARAM.uels = RESERVEPARAM_VAL;
RESERVEPARAM.val = ones(size(RESERVEPARAM.uels,2),1);
RESERVEPARAM.name = 'RESERVEPARAM';
RESERVEPARAM.form = 'full';
RESERVEPARAM.type = 'set';
DEFAULT_DATA.RESERVEPARAM=RESERVEPARAM;

if useHDF5==0
    RESERVEVALUE.val = xlsread(inputPath,'RESERVEPARAM','B2:K15');
else
    temp=zeros(nreserve,size(RESERVEPARAM_VAL,2));
    for i=1:size(RESERVEPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',RESERVEPARAM_VAL{i}));
    end
    RESERVEVALUE.val = temp;
end
RESERVEVALUE.uels = {RESERVETYPE.uels RESERVEPARAM.uels};
RESERVEVALUE.name = 'RESERVEVALUE';
RESERVEVALUE.form = 'full';
RESERVEVALUE.type = 'parameter';
for a =1:size(RESERVEVALUE.val,1)
    for b=1:size(RESERVEVALUE.val,2)
        if isfinite(RESERVEVALUE.val(a,b)) == 0
            RESERVEVALUE.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.RESERVEVALUE=RESERVEVALUE;

if useHDF5==0
    [LOAD_DIST_VAL, LOAD_DIST_STRING] = xlsread(inputPath,'LOAD_DIST','A2:B10000');
else
    x=h5read(fileName,'/Main Input File/LOAD_DIST');
    LOAD_DIST_STRING=x.BUS;
    LOAD_DIST_VAL=x.LOAD;    
end
LOAD_DIST.val = LOAD_DIST_VAL;
LOAD_DIST.uels = LOAD_DIST_STRING';
LOAD_DIST.name = 'LOAD_DIST';
LOAD_DIST.form = 'full';
LOAD_DIST.type = 'parameter';
for a =1:size(LOAD_DIST.val,1)
    for b=1:size(LOAD_DIST.val,2)
        if isfinite(LOAD_DIST.val(a,b)) == 0
            LOAD_DIST.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.LOAD_DIST=LOAD_DIST;

if size(LOAD_DIST.val,1) ~= nbus
    fullLoadDist=zeros(nbus,1);
    for i=1:size(LOAD_DIST.val,1)
        found=0;j=1;
        while found==0
            if strcmp(LOAD_DIST.uels{i},BUS_VAL{j})
                fullLoadDist(j)=LOAD_DIST.val(i);
                found=1;
            else
                j=j+1;
            end
        end
    end
else
    fullLoadDist=LOAD_DIST.val;
end

if useHDF5==0
    [~, COSTCURVEPARAM_VAL] = xlsread(inputPath,'COST','B1:W1');
else
    x=h5read(fileName,'/Main Input File/COST');
    y=fieldnames(x);
    COSTCURVEPARAM_VAL=y(2:end,1)';
end
COSTCURVEPARAM.uels = COSTCURVEPARAM_VAL;
COSTCURVEPARAM.val = ones(size(COSTCURVEPARAM.uels,2),1);
COSTCURVEPARAM.name = 'COSTCURVEPARAM';
COSTCURVEPARAM.form = 'full';
COSTCURVEPARAM.type = 'set';
DEFAULT_DATA.COSTCURVEPARAM=COSTCURVEPARAM;

if useHDF5==0
    [COST_CURVE_VAL, COST_CURVE_STRING] = xlsread(inputPath,'COST','A2:W1000');
else
    COST_CURVE_STRING=x.Generator;
    temp=zeros(ngen,size(COSTCURVEPARAM_VAL,2));
    for i=1:size(COSTCURVEPARAM_VAL,2)
        temp(:,i)=x.(sprintf('%s',COSTCURVEPARAM_VAL{i}));
    end
    COST_CURVE_VAL = temp;
end
COST_CURVE_VAL(56:end,2)=COST_CURVE_VAL(56:end,2);
COST_CURVE.val = COST_CURVE_VAL;
COST_CURVE.uels = {COST_CURVE_STRING' COSTCURVEPARAM.uels};
COST_CURVE.name = 'COST_CURVE';
COST_CURVE.form = 'full';
COST_CURVE.type = 'parameter';
for a =1:size(COST_CURVE.val,1)
    for b=1:size(COST_CURVE.val,2)
        if isfinite(COST_CURVE.val(a,b)) == 0
            COST_CURVE.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.COST_CURVE=COST_CURVE;

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
DEFAULT_DATA.GENBLOCK=GENBLOCK;

BLOCK_COST.name='BLOCK_COST';
BLOCK_COST.uels={COST_CURVE_STRING' BLOCK2.uels};
BLOCK_COST.form='FULL';
BLOCK_COST.type='parameter';
BLOCK_COST.val=COST_CURVE.val(:,[1 3 5 7]);
DEFAULT_DATA.BLOCK_COST=BLOCK_COST;

BLOCK_CAP.name='BLOCK_CAP';
BLOCK_CAP.uels={COST_CURVE_STRING' BLOCK2.uels};
BLOCK_CAP.form='FULL';
BLOCK_CAP.type='parameter';
BLOCK_CAP.val=COST_CURVE.val(:,[2 4 6 8])./SYSTEMVALUE.val(mva_pu);
DEFAULT_DATA.BLOCK_CAP=BLOCK_CAP;

if useHDF5==0
    [~, PUMP_EFF_VAL] = xlsread(inputPath,'PUMPEFFICIENCY','B1:W1');
else
    x=h5read(fileName,'/Main Input File/PUMPEFFICIENCY');
    if ~strcmp(fieldnames(x),'None')
        y=fieldnames(x)';
        PUMP_EFF_VAL=y(1,2:end);
    else
        PUMP_EFF_VAL={'EFFICIENCY1','MW1','EFFICIENCY2','MW2','EFFICIENCY3','MW3'};
    end
end
PUMPEFFPARAM.uels = PUMP_EFF_VAL;
PUMPEFFPARAM.val = ones(size(PUMPEFFPARAM.uels,2),1);
PUMPEFFPARAM.name = 'PUMPEFFPARAM';
PUMPEFFPARAM.form = 'full';
PUMPEFFPARAM.type = 'set';
DEFAULT_DATA.PUMPEFFPARAM=PUMPEFFPARAM;

if useHDF5==0
    [PUMPEFFICIENCYVALUE_VAL, PUMPEFFICIENCYVALUE_STRING] = xlsread(inputPath,'PUMPEFFICIENCY','A2:W1000');
else
    if ~strcmp(fieldnames(x),'None')
        PUMPEFFICIENCYVALUE_STRING=x.Generator;
        temp=zeros(size(PUMPEFFICIENCYVALUE_STRING,1),size(PUMP_EFF_VAL,2));
        for i=1:size(PUMP_EFF_VAL,2)
            temp(:,i)=x.(sprintf('%s',PUMP_EFF_VAL{i}));
        end
        PUMPEFFICIENCYVALUE_VAL = temp;
    else
        PUMPEFFICIENCYVALUE_VAL=[];
        PUMPEFFICIENCYVALUE_STRING={};
    end
end
PUMPEFFICIENCYVALUE.val = PUMPEFFICIENCYVALUE_VAL;
PUMPEFFICIENCYVALUE.uels = {PUMPEFFICIENCYVALUE_STRING' PUMPEFFPARAM.uels};
PUMPEFFICIENCYVALUE.name = 'PUMPEFFICIENCYVALUE';
PUMPEFFICIENCYVALUE.form = 'full';
PUMPEFFICIENCYVALUE.type = 'parameter';
for a =1:size(PUMPEFFICIENCYVALUE.val,1)
    for b=1:size(PUMPEFFICIENCYVALUE.val,2)
        if isfinite(PUMPEFFICIENCYVALUE.val(a,b)) == 0
            PUMPEFFICIENCYVALUE.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.PUMPEFFICIENCYVALUE=PUMPEFFICIENCYVALUE;

if useHDF5==0
    [~, GEN_EFF_VAL] = xlsread(inputPath,'GENEFFICIENCY','B1:W1');
else
    x=h5read(fileName,'/Main Input File/GENEFFICIENCY');
    if ~strcmp(fieldnames(x),'None')
        y=fieldnames(x)';
        GEN_EFF_VAL=y(1,2:end);
    else
        GEN_EFF_VAL={'EFFICIENCY1','MW1','EFFICIENCY2','MW2','EFFICIENCY3','MW3'};
    end
end
GENEFFPARAM.uels = GEN_EFF_VAL;
GENEFFPARAM.val = ones(size(GENEFFPARAM.uels,2),1);
GENEFFPARAM.name = 'GENEFFPARAM';
GENEFFPARAM.form = 'full';
GENEFFPARAM.type = 'set';
DEFAULT_DATA.GENEFFPARAM=GENEFFPARAM;

if useHDF5==0
    [GENEFFICIENCYVALUE_VAL, GENEFFICIENCYVALUE_STRING] = xlsread(inputPath,'GENEFFICIENCY','A2:W1000');
else
    if ~strcmp(fieldnames(x),'None')
        GENEFFICIENCYVALUE_STRING=x.Generator;
        temp=zeros(size(GENEFFICIENCYVALUE_STRING,1),size(GEN_EFF_VAL,2));
        for i=1:size(GEN_EFF_VAL,2)
            temp(:,i)=x.(sprintf('%s',GEN_EFF_VAL{i}));
        end
        GENEFFICIENCYVALUE_VAL = temp;
    else
        GENEFFICIENCYVALUE_VAL=[];
        GENEFFICIENCYVALUE_STRING={};
    end
end
GENEFFICIENCYVALUE.val = GENEFFICIENCYVALUE_VAL;
GENEFFICIENCYVALUE.uels = {GENEFFICIENCYVALUE_STRING' GENEFFPARAM.uels};
GENEFFICIENCYVALUE.name = 'GENEFFICIENCYVALUE';
GENEFFICIENCYVALUE.form = 'full';
GENEFFICIENCYVALUE.type = 'parameter';
for a =1:size(GENEFFICIENCYVALUE.val,1)
    for b=1:size(GENEFFICIENCYVALUE.val,2)
        if isfinite(GENEFFICIENCYVALUE.val(a,b)) == 0
            GENEFFICIENCYVALUE.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.GENEFFICIENCYVALUE=GENEFFICIENCYVALUE;

if useHDF5==0
    RESERVE_COST.val = xlsread(inputPath,'ASC','B2:P1000');
    [~, RESERVE_COST_STRING1] = xlsread(inputPath,'ASC','A2:A1000');
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
    RESERVE_COST.val = temp;
end
RESERVE_COST.uels = {RESERVE_COST_STRING1' RESERVE_COST_STRING2};
RESERVE_COST.name = 'RESERVE_COST';
RESERVE_COST.form = 'full';
RESERVE_COST.type = 'parameter';
for a =1:size(RESERVE_COST.val,1)
    for b=1:size(RESERVE_COST.val,2)
        if isfinite(RESERVE_COST.val(a,b)) == 0
            RESERVE_COST.val(a,b) = 0;
        end;
    end;
end;
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
START_PARAMETER.val = ones(size(START_PARAMETER.uels,2),1);
START_PARAMETER.name = 'START_PARAMETER';
START_PARAMETER.form = 'full';
START_PARAMETER.type = 'set';
DEFAULT_DATA.START_PARAMETER=START_PARAMETER;

if useHDF5==0
    STARTUP_VALUE.val = xlsread(inputPath,'STARTUP','B2:K1000');
    [~, STARTUP_VALUE_STRING1] = xlsread(inputPath,'STARTUP','A2:A1000');
    [~, STARTUP_VALUE_STRING2] = xlsread(inputPath,'STARTUP','B1:K1');
else
    if ~strcmp(fieldnames(x),'None')
        STARTUP_VALUE_STRING2={'OFF_HOT','COST_HOT','OFF_WARM','COST_WARM','OFF_COLD','COST_COLD'};
        STARTUP_VALUE_STRING1=x.Generator;
        temp=zeros(size(STARTUP_VALUE_STRING1,1),size(STARTUP_VALUE_STRING2,2));
        for i=1:size(STARTUP_VALUE_STRING2,2)
            temp(:,i)=x.(sprintf('%s',STARTUP_VALUE_STRING2{i}));
        end
        STARTUP_VALUE.val = temp;
    else
        STARTUP_VALUE.val=[];
        STARTUP_VALUE_STRING1={};
        STARTUP_VALUE_STRING2={'OFF_HOT','COST_HOT','OFF_WARM','COST_WARM','OFF_COLD','COST_COLD'};
    end
end
STARTUP_VALUE.uels = {STARTUP_VALUE_STRING1' STARTUP_VALUE_STRING2};
STARTUP_VALUE.name = 'STARTUP_VALUE';
STARTUP_VALUE.form = 'full';
STARTUP_VALUE.type = 'parameter';
for a =1:size(STARTUP_VALUE.val,1)
    for b=1:size(STARTUP_VALUE.val,2)
        if isfinite(STARTUP_VALUE.val(a,b)) == 0
            STARTUP_VALUE.val(a,b) = 0;
        end;
    end;
end;
DEFAULT_DATA.STARTUP_VALUE=STARTUP_VALUE;

ngen = size(GEN.uels ,2);
nbranch = size(BRANCH.uels,2);
nbus = size(BUS.uels,2);
nreserve = size(RESERVETYPE.uels,2);
nvg=0; %variable generation, resources with variable output
nvcr = 0; %variable capacity resources, resources with variable capacity
for i=1:ngen
    if GENVALUE.val(i,gen_type) == 7 || GENVALUE.val(i,gen_type) == 10 || GENVALUE.val(i,gen_type) == 11 
        nvg = nvg+1;
        nvcr = nvcr+1;
%     elseif GENVALUE.val(i,gen_type) == 14 || GENVALUE.val(i,gen_type) == 16
    elseif GENVALUE.val(i,gen_type) == 16
        nvcr = nvcr + 1;
    end;
end;

npar = 0;
for l=1:nbranch
    if BRANCHDATA.val(l,branch_type) ==2 || BRANCHDATA.val(l,branch_type) == 3
        npar = npar+1;
    end;
end;
nhvdc = 0;
for l=1:nbranch
    if BRANCHDATA.val(l,branch_type) ==4 
        nhvdc = nhvdc+1;
    end;
end;
nctgc = 0;
for l=1:nbranch
    if BRANCHDATA.val(l,ctgc_monitor) ==1 
        nctgc = nctgc+1;
    end;
end;