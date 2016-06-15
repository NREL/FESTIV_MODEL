%This unique model is for a project that is evaluating a new way to price
%ramping. The anticipated ramp price comes from finding the marginal cost
%of the current interval due to increment of demand in future intervals.

%{
USE:        AFTER RTSCED
%}

ngen=evalin('base','ngen');
    Q_RAMP_RATE_UP0_BP_rgdx.form = 'full';
    Q_RAMP_RATE_UP0_BP_rgdx.name = 'Q_RAMP_RATE_UP0_BP';
    Q_RAMP_RATE_UP0_BP_rgdx.field = 'm';
    Q_RAMP_RATE_UP0_BP_rgdx.uels = {GEN.uels INTERVAL.uels};
    Q_RAMP_RATE_UP0_BP = rgdx(input1,Q_RAMP_RATE_UP0_BP_rgdx);
    Q_RAMP_RATE_UP0_ACTUAL_rgdx.form = 'full';
    Q_RAMP_RATE_UP0_ACTUAL_rgdx.name = 'Q_RAMP_RATE_UP0_ACTUAL';
    Q_RAMP_RATE_UP0_ACTUAL_rgdx.field = 'm';
    Q_RAMP_RATE_UP0_ACTUAL_rgdx.uels = {GEN.uels INTERVAL.uels};
    Q_RAMP_RATE_UP0_ACTUAL = rgdx(input1,Q_RAMP_RATE_UP0_ACTUAL_rgdx);
    Q_RAMP_RATE_DOWN0_BP_rgdx.form = 'full';
    Q_RAMP_RATE_DOWN0_BP_rgdx.name = 'Q_RAMP_RATE_DOWN0_BP';
    Q_RAMP_RATE_DOWN0_BP_rgdx.field = 'm';
    Q_RAMP_RATE_DOWN0_BP_rgdx.uels = {GEN.uels INTERVAL.uels};
    Q_RAMP_RATE_DOWN0_BP = rgdx(input1,Q_RAMP_RATE_DOWN0_BP_rgdx);
    Q_RAMP_RATE_DOWN0_ACTUAL_rgdx.form = 'full';
    Q_RAMP_RATE_DOWN0_ACTUAL_rgdx.name = 'Q_RAMP_RATE_DOWN0_ACTUAL';
    Q_RAMP_RATE_DOWN0_ACTUAL_rgdx.field = 'm';
    Q_RAMP_RATE_DOWN0_ACTUAL_rgdx.uels = {GEN.uels INTERVAL.uels};
    Q_RAMP_RATE_DOWN0_ACTUAL = rgdx(input1,Q_RAMP_RATE_DOWN0_ACTUAL_rgdx);
    Q_RAMP_RATE_UP_rgdx.form = 'full';
    Q_RAMP_RATE_UP_rgdx.name = 'Q_RAMP_RATE_UP';
    Q_RAMP_RATE_UP_rgdx.field = 'm';
    Q_RAMP_RATE_UP_rgdx.uels = {GEN.uels INTERVAL.uels};
    Q_RAMP_RATE_UP = rgdx(input1,Q_RAMP_RATE_UP_rgdx);
    Q_RAMP_RATE_DOWN_rgdx.form = 'full';
    Q_RAMP_RATE_DOWN_rgdx.name = 'Q_RAMP_RATE_DOWN';
    Q_RAMP_RATE_DOWN_rgdx.field = 'm';
    Q_RAMP_RATE_DOWN_rgdx.uels = {GEN.uels INTERVAL.uels};
    Q_RAMP_RATE_DOWN = rgdx(input1,Q_RAMP_RATE_DOWN_rgdx);
    RAMP_UP_DUAL.val=zeros(ngen,HLMP);
    RAMP_DOWN_DUAL.val=zeros(ngen,HLMP);
    RAMP_UP_DUAL.val(:,1)=(Q_RAMP_RATE_UP0_BP.val(:,1)+Q_RAMP_RATE_UP0_ACTUAL.val(:,1))./SYSTEMVALUE.val(mva_pu);
    RAMP_DOWN_DUAL.val(:,1)=(Q_RAMP_RATE_DOWN0_BP.val(:,1)+Q_RAMP_RATE_DOWN0_ACTUAL.val(:,1))./SYSTEMVALUE.val(mva_pu);
    if HLMP > 1
        RAMP_UP_DUAL.val(:,2:end)=Q_RAMP_RATE_UP.val(:,2:end)./SYSTEMVALUE.val(mva_pu);
        RAMP_DOWN_DUAL.val(:,2:end)=Q_RAMP_RATE_DOWN.val(:,2:end)./SYSTEMVALUE.val(mva_pu);
    end
    assignin('base','RAMP_DOWN_DUAL',RAMP_DOWN_DUAL);
try
%     rampupdual_rgdx.form = 'full';
%     rampupdual_rgdx.name = 'RAMP_UP_DUAL';
%     rampupdual_rgdx.uels = {GEN.uels INTERVAL.uels};
%     RAMP_UP_DUAL = rgdx(input1,rampupdual_rgdx);
    rampdowndual_rgdx.form = 'full';
    %rampdowndual_rgdx.name = 'RAMP_DOWN_DUAL';
    %rampdowndual_rgdx.uels = {GEN.uels INTERVAL.uels};
    rampdowndual_rgdx.name = 'RAMP_PRICE_B';
    rampdowndual_rgdx.uels = {GEN.uels INTERVAL.uels};
    INTERTEMPORAL_RAMP_PRICE = rgdx(input1,rampdowndual_rgdx);
catch
    RAMP_UP_DUAL=[];
    INTERTEMPORAL_RAMP_PRICE=[];
end;

if exist('ALL_RAMP_UP_DUAL','var')
else
    ALL_RAMP_UP_DUAL = [];
end;
if exist('ALL_RAMP_PRICE','var')
else
    ALL_RAMP_PRICE = [];
end;
if exist('ALL_RAMP_PRICE2','var')
else
    ALL_RAMP_PRICE2 = [];
end;
if exist('ALL_RAMP_PRICE3','var')
else
    ALL_RAMP_PRICE3 = [];
end;
%ALL_RAMP_UP_DUAL = [ALL_RAMP_UP_DUAL; ones(HRTD,1).*RTSCED_binding_interval_index RTDRAMP_UP_DUAL.val'];

ITRP_1=RTDRAMP_DOWN_DUAL.val;
ITRP_Interval=1;
for t=2:HRTD
    if size(find(ITRP_1(:,t)>0),1)>= 1
        ITRP_Interval = t;
        ITRP_A2 =find(ITRP_1(:,t)>0);
        ITRP_A3 = COST(ITRP_A2,:);
        clear ITRP_A4;
        clear ITRP_A5;
        for g=1:size(ITRP_A2,1)
            try
                ITRP_A4(g,1) = find(RTDBLOCKMW.val(ITRP_A2(g,1),:)>=RTDGENSCHEDULE.val(ITRP_A2(g,1),1),1,'first');
            catch
                ITRP_A4(g,1) = 1;
            end;
            ITRP_A5(g,:)=[ITRP_A2(g,1) ITRP_A3(g,ITRP_A4(g,1))];
        end;
        ITRP_A5=sortrows(ITRP_A5,2);
        ITRP_1(ITRP_A5(2:end,1),t)=0;
    else
        ITRP_1(:,t)=0;
    end;
    if size(find(ITRP_1(:,t)<0),1)>= 1
        ITRP_B2 =find(ITRP_1(:,t)<0);
        ITRP_B3 = COST(ITRP_B2,:);
        clear ITRP_B4;
        clear ITRP_B5;
        for g=1:size(ITRP_B2,1)
            try
                ITRP_B4(g,1) = find(RTDBLOCKMW.val(ITRP_B2(g,1),:)>=RTDGENSCHEDULE.val(ITRP_B2(g,1),1),1,'first');
            catch
                ITRP_B4(g,1) = 1;
            end;
            ITRP_B5(g,:)=[ITRP_B2(g,1) ITRP_B3(g,ITRP_B4(g,1))];
        end;
        ITRP_B5=sortrows(ITRP_B5,-2);
        ITRP_1(ITRP_B5(2:end,1),t)=0;
    end;
end;
NEW_COST = COST(:,1);
try
NEW_COST(ITRP_A5(:,1),1)=ITRP_A5(:,2);
NEW_COST(ITRP_B5(:,1),1)=ITRP_B5(:,2);
catch;end;
ITRP = sum(sum(-1.*ITRP_1(:,2:HRTD).*(RTDRAMP_UP_DUAL.val(:,2:HRTD)-RTDRAMP_UP_DUAL.val(:,1:HRTD-1))))/(IRTD/60);
ITRP2= sum(ITRP_1(:,2:HRTD)'*NEW_COST);
ITRP3= sum(-1.*(ITRP_1(:,2:HRTD)'*RTDRAMP_UP_DUAL.val(:,2))./(IRTD/60));
ALL_RAMP_PRICE = [ALL_RAMP_PRICE; RTD_LOOKAHEAD_INTERVAL_VAL(1,1) ITRP];
ALL_RAMP_PRICE2 = [ALL_RAMP_PRICE2; RTD_LOOKAHEAD_INTERVAL_VAL(1,1) ITRP2]; 
ALL_RAMP_PRICE3 = [ALL_RAMP_PRICE3; RTD_LOOKAHEAD_INTERVAL_VAL(1,1) ITRP3];
RTDGENRESERVESCHEDULE.val(:,1,1) = RTDGENSCHEDULE.val(:,ITRP_Interval);
RTDRCP.val(1,1) = ITRP3;

