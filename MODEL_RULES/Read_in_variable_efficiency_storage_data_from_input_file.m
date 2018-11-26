%Read variable efficiency storage data in from excel
%
%post data initialization
%

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
