%Create a PTDF matrix for use for the rest of the study.

SLACKBUS = SYSTEMVALUE.val(slack_bus,1);
MVA_PERUNIT = SYSTEMVALUE.val(mva_pu,1);

BRANCHBUS=zeros(nbranch,3);
if useHDF5==0
    [~,BRANCH_DATA]=xlsread(inputPath,'BRANCHDATA','A2:B10000'); 
else
    x=h5read(fileName,'/Main Input File/BRANCHDATA');
    BRANCH_DATA=[x.NAME1 x.BRANCHBUS];
end
listofbuses=cell(size(BRANCH_DATA,1),1);
listoffrombuses=cell(size(BRANCH_DATA,1),1);
listoftobuses=cell(size(BRANCH_DATA,1),1);
SEPERATED_BRANCH_DATA=cell(size(BRANCH_DATA,1),3);
for i=1:size(BRANCH_DATA,1)
    [~,rem2]=strtok(BRANCH_DATA{i,2},'.');
    listofbuses(i,1)={rem2(1,2:end)};
end
for i=1:size(BRANCH_DATA,1)
    [tok,rem2]=strtok(listofbuses{i,1},'.');
    listoffrombuses(i,1)={tok};
    listoftobuses(i,1)={rem2(1,2:end)};
end
SEPERATED_BRANCH_DATA(:,1)=BRANCH_DATA(:,1);
SEPERATED_BRANCH_DATA(:,2)=listoffrombuses(:,1);
SEPERATED_BRANCH_DATA(:,3)=listoftobuses(:,1);
for i=1:nbranch
    BRANCHBUS(i,1)=i;
    for j=1:nbus
        if strcmp(SEPERATED_BRANCH_DATA(i,2),BUS_VAL(j,1))
            BRANCHBUS(i,2)=j;
        end
    end
    for j=1:nbus
        if strcmp(SEPERATED_BRANCH_DATA(i,3),BUS_VAL(j,1))
            BRANCHBUS(i,3)=j;
        end
    end
end

X=BRANCHDATA.val(:,branch_type);
Y=(X==2|X==3);
Z=BRANCHBUS(Y,:);
bgamma=zeros(nbus,nbranch);fromadmittances=0;toadmittances=0;
for i=1:size(Z,1)
    for j=1:nbus
        if j==BRANCHBUS(Z(i),2)
            fromadmittances=fromadmittances+(1/BRANCHDATA.val(Z(i),reactance));
        end
        if j==BRANCHBUS(Z(i),3)
            toadmittances=toadmittances+(1/BRANCHDATA.val(Z(i),reactance));
        end
        bgamma(j,Z(i))=-fromadmittances+toadmittances;
        fromadmittances=0;
        toadmittances=0;
    end
end

%Determine slack bus for analysis
n = 1; %if there are any problems with the string then will default to the first bus.
if isa(SLACKBUS,'numeric')
    if SLACKBUS <= nbus && SLACKBUS >=1
        slack=SLACKBUS;
    else
        slack=1;
    end;
else
    slack = 1;
    while(n<=nbus)
        if (strcmp(BUS.uels(1,n),BUS_VAL{SLACKBUS}))
            slack = n;
            n=nbus;
        end;
        n = n+1;
    end;
end;

%PTDF for branch bus injections
bus = zeros(nbus,13);
bus(:,1) = (1:nbus)';
branch = zeros(nbranch,11);
branch(:,1:2) = BRANCHBUS(:,2:3);
branch(:,4) = BRANCHDATA.val(:,reactance);
for b=1:nbranch
    if(BRANCHDATA.val(b,branch_type) == 4)
        branch(b,11) = 0;
    else
        branch(b,11) = 1;
    end;
end;
PTDF_VAL = makePTDF(MVA_PERUNIT,bus,branch,slack);
PTDF.name = 'PTDF';
PTDF.val = PTDF_VAL;
PTDF.uels = {BRANCH.uels BUS.uels};
PTDF.type = 'parameter';
PTDF.form = 'full';
DEFAULT_DATA.PTDF=PTDF;

%PTDF for phase angle regulators
for b=1:nbranch
    if(BRANCHDATA.val(b,branch_type) == 2 || BRANCHDATA.val(b,branch_type) == 3)
        B = makeB(MVA_PERUNIT,bus,branch,2);
        B_adj = B;
        B_adj(slack,:) =[];
        B_adj(:,slack) = [];
%         B_G = SCUCBGAMMA.val(:,b);
        B_G = bgamma(:,b);
        B_G_adj = B_G;
        B_G_adj(slack,:) = [];
        theta_adj = B_adj\(-1.*B_G_adj);
        if(slack ==1)
            theta = [0; theta_adj];
        else
            theta(1:slack-1,1) = theta_adj(1:slack-1,1);
            theta(slack,1) = 0;
            theta(slack+1:nbus,1) = theta_adj(slack:nbus-1,1);
        end;
        for b1=1:nbranch
            if(b1==b)
                PTDF_PAR_VAL(b1,b) = (theta(branch(b1,1),1) - theta(branch(b1,2),1) - 1)/BRANCHDATA.val(b1,reactance);
            else
                PTDF_PAR_VAL(b1,b) = (theta(branch(b1,1),1) - theta(branch(b1,2),1))/BRANCHDATA.val(b1,reactance);
            end;
        end;                
    else
        PTDF_PAR_VAL(nbranch,b) = 0;
    end;
end;
PTDF_PAR.val = PTDF_PAR_VAL;
PTDF_PAR.name = 'PTDF_PAR';
PTDF_PAR.uels = {BRANCH.uels BRANCH.uels};
PTDF_PAR.type = 'parameter';
PTDF_PAR.form = 'full';
DEFAULT_DATA.PTDF_PAR=PTDF_PAR;

%create LODF matrix for the rest of the study. 
%Should make sure this works for PARS and HVDC, I believe it does but
%should run sensitivities to make sure.
LODF_VAL = zeros(nbranch,nbranch);
for b=1:nbranch
    branch_ctgc = branch;
    branch_ctgc(b,11) = 0;
    B_ctgc = makeB(MVA_PERUNIT,bus,branch_ctgc,2);
    B_ctgc_adj = B_ctgc;
    B_ctgc_adj(slack,:) =[];
    B_ctgc_adj(:,slack) = [];
    deltaP = zeros(nbus,1);
    deltaP(branch(b,1),1) = 1;
    deltaP(branch(b,2),1) = -1;
    deltaP(slack,:) = [];
    theta_adj = B_ctgc_adj\deltaP;
    if(slack ==1)
        theta = [0; theta_adj];
    else
        theta(1:slack-1,1) = theta_adj(1:slack-1,1);
        theta(slack,1) = 0;
        theta(slack+1:nbus,1) = theta_adj(slack:nbus-1,1);
    end;
    for b1=1:nbranch
        if(b1==b)
            LODF_VAL(b,b1) = -1;
        else
            LODF_VAL(b,b1) = (theta(branch(b1,1),1) - theta(branch(b1,2),1))/BRANCHDATA.val(b1,reactance);
        end;
    end;                
end;

LODF.name = 'LODF';
LODF.val = LODF_VAL;
LODF.uels = {BRANCH.uels BRANCH.uels};
LODF.type = 'parameter';
LODF.form = 'full';
DEFAULT_DATA.LODF=LODF;
DEFAULT_DATA=orderfields(DEFAULT_DATA);

