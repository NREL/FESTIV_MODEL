%Create a PTDF matrix for use for the rest of the study.

%Suppress singular matrix warning
warning('off','MATLAB:singularMatrix')

X=BRANCHDATA_VAL(:,branch_type);
Y=(X==2|X==3);
Z=BRANCHBUS_CALC_VAL(Y,:);
bgamma=zeros(nbus,nbranch);fromadmittances=0;toadmittances=0;
for i=1:size(Z,1)
    for j=1:nbus
        if j==BRANCHBUS_CALC_VAL(Z(i),2)
            fromadmittances=fromadmittances+(1/BRANCHDATA_VAL(Z(i),reactance));
        end
        if j==BRANCHBUS_CALC_VAL(Z(i),3)
            toadmittances=toadmittances+(1/BRANCHDATA_VAL(Z(i),reactance));
        end
        bgamma(j,Z(i))=-fromadmittances+toadmittances;
        fromadmittances=0;
        toadmittances=0;
    end
end

%Determine slack bus for analysis
n = 1; %if there are any problems with the string then will default to the first bus.
if isa(SYSTEMVALUE_VAL(slack_bus,1),'numeric')
    if SYSTEMVALUE_VAL(slack_bus,1) <= nbus && SYSTEMVALUE_VAL(slack_bus,1) >=1
        slack=SYSTEMVALUE_VAL(slack_bus,1);
    else
        slack=1;
    end;
else
    slack = 1;
    while(n<=nbus)
        if (strcmp(BUS.uels(1,n),BUS_VAL{SYSTEMVALUE_VAL(slack_bus,1)}))
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
branch(:,1:2) = BRANCHBUS_CALC_VAL(:,2:3);
branch(:,4) = BRANCHDATA_VAL(:,reactance);
for b=1:nbranch
    if(BRANCHDATA_VAL(b,branch_type) == HVDC_branch_type_index)
        branch(b,11) = 0;
    else
        branch(b,11) = 1;
    end;
end;
PTDF_VAL = makePTDF(SYSTEMVALUE_VAL(mva_pu,1),bus,branch,slack);
PTDF.name = 'PTDF';
PTDF.val = PTDF_VAL;
PTDF.uels = {BRANCH.uels BUS.uels};
PTDF.type = 'parameter';
PTDF.form = 'full';
DEFAULT_DATA.PTDF=PTDF;

%PTDF for phase angle regulators
for b=1:nbranch
    if(BRANCHDATA_VAL(b,branch_type) == fixed_par_branch_type_index || BRANCHDATA_VAL(b,branch_type) == adj_par_branch_type_index)
        B = makeB(SYSTEMVALUE_VAL(mva_pu,1),bus,branch,2);
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
                PTDF_PAR_VAL(b1,b) = (theta(branch(b1,1),1) - theta(branch(b1,2),1) - 1)/BRANCHDATA_VAL(b1,reactance);
            else
                PTDF_PAR_VAL(b1,b) = (theta(branch(b1,1),1) - theta(branch(b1,2),1))/BRANCHDATA_VAL(b1,reactance);
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
    B_ctgc = makeB(SYSTEMVALUE_VAL(mva_pu,1),bus,branch_ctgc,2);
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
            LODF_VAL(b,b1) = (theta(branch(b1,1),1) - theta(branch(b1,2),1))/BRANCHDATA_VAL(b1,reactance);
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

BUS_HVDC.name='BUS_HVDC';
BUS_HVDC.uels={BUS.uels};
BUS_HVDC.form='full';
BUS_HVDC.type='set';
BUS_HVDC_VAL = zeros(nbus,1);
for l=1:nbranch
    if BRANCHDATA_VAL(l,branch_type)==HVDC_branch_type_index
        BUS_HVDC_VAL(BRANCHBUS_CALC_VAL(l,2),1)=1;
        BUS_HVDC_VAL(BRANCHBUS_CALC_VAL(l,3),1)=1;
    end;
end;
BUS_HVDC.val=BUS_HVDC_VAL;
DEFAULT_DATA.BUS_HVDC=BUS_HVDC;

BUS_PAR.name='BUS_PAR';
BUS_PAR.uels={BUS.uels};
BUS_PAR.form='full';
BUS_PAR.type='set';
BUS_PAR_VAL = zeros(nbus,1);
for l=1:nbranch
    if BRANCHDATA_VAL(l,branch_type)==fixed_par_branch_type_index || BRANCHDATA_VAL(l,branch_type)==adj_par_branch_type_index
        BUS_PAR_VAL(BRANCHBUS_CALC_VAL(l,2),1)=1;
        BUS_PAR_VAL(BRANCHBUS_CALC_VAL(l,3),1)=1;
    end;
end;
BUS_PAR.val=BUS_PAR_VAL;
DEFAULT_DATA.BUS_PAR=BUS_PAR;

