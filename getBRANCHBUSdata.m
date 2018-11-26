%[BRANCHBUS_VAL,BRANCHBUS_CALC_VAL,BRANCHBUS_STRING]
    %% Create the BRANCHBUS variable for GAMS
    % Read in BRANCHDATA tab and seperate buses
    if useHDF5==0
        [~,FULL_BRANCH_STRING]=xlsread(inputPath,'BRANCHDATA','A2:B10000');
    else
        x=h5read(fileName,'/Main Input File/BRANCHDATA');
        FULL_BRANCH_STRING=[x.NAME1 x.BRANCHBUS];
    end

    listofbuses=cell(size(FULL_BRANCH_STRING,1),1);
    listoffrombuses=cell(size(FULL_BRANCH_STRING,1),1);
    listoftobuses=cell(size(FULL_BRANCH_STRING,1),1);
    SEPERATED_BRANCHBUS_STRING=cell(size(FULL_BRANCH_STRING,1),3);

    for i=1:size(FULL_BRANCH_STRING,1)
        [~,temp2]=strtok(FULL_BRANCH_STRING{i,2},'.');
        listofbuses(i,1)={temp2(1,2:end)};
    end
    for i=1:size(FULL_BRANCH_STRING,1)
        [temp1,temp2]=strtok(listofbuses{i,1},'.');
        listoffrombuses(i,1)={temp1};
        listoftobuses(i,1)={temp2(1,2:end)};
    end
    SEPERATED_BRANCHBUS_STRING(:,1)=FULL_BRANCH_STRING(:,1);
    SEPERATED_BRANCHBUS_STRING(:,2)=listoffrombuses(:,1);
    SEPERATED_BRANCHBUS_STRING(:,3)=listoftobuses(:,1);

    %% Set up the BRANCHBUS variable
    uniquefromids=unique(SEPERATED_BRANCHBUS_STRING(:,2));
    uniquetoids=unique(SEPERATED_BRANCHBUS_STRING(:,3));

    BRANCHBUS_STRING={FULL_BRANCH_STRING(:,1)',uniquefromids',uniquetoids'};
    BRANCHBUS_VAL=zeros(size(FULL_BRANCH_STRING,1),size(uniquefromids,1),size(uniquetoids,1));
    BRANCHBUS_CALC_VAL = zeros(size(BRANCHBUS_STRING,1),3);
    
    %% Fill in branch locations
    for a=1:size(FULL_BRANCH_STRING,1)
        for b=1:size(uniquefromids,1)
            if strcmp(uniquefromids(b,1),SEPERATED_BRANCHBUS_STRING(a,2))
                for c=1:size(uniquetoids,1)
                    if strcmp(uniquetoids(c,1),SEPERATED_BRANCHBUS_STRING(a,3))
                        BRANCHBUS_VAL(a,b,c)=1;
                    end
                end
            end
        end
    end


for l=1:size(FULL_BRANCH_STRING,1)
    l2=1;
    while l2<=nbranch
        if strcmp(BRANCH.uels(1,l2),SEPERATED_BRANCHBUS_STRING(l,1))
            BRANCHBUS_CALC_VAL(l,1) = l2;
            l2=nbranch;
        end;
        l2=l2+1;
    end;
    n=1;
    while n<=nbus
        if strcmp(BUS.uels(1,n),SEPERATED_BRANCHBUS_STRING(l,2))
            BRANCHBUS_CALC_VAL(l,2) = n;
            n=nbus;
        end;
        n=n+1;
    end;
    n=1;
    while n<=nbus
        if strcmp(BUS.uels(1,n),SEPERATED_BRANCHBUS_STRING(l,3))
            BRANCHBUS_CALC_VAL(l,3) = n;
            n=nbus;
        end;
        n=n+1;
    end;
end;

