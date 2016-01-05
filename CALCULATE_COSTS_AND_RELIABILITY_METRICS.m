for x=1:size(RELIABILITY_PRE_in,1)
    try run(RELIABILITY_PRE_in{x,1});catch;end;
end;

% Calculate ALFEE
if monitor_ALFEE == 1
bus_injection = zeros(nbus,1);

for t=1:AGC_interval_index-1
    for n=1:nbus
        bus_injection(n,1) = -1*RTDLOADDIST.val(n,1)*ACTUAL_LOAD_FULL(t,2);
    end;
    for i=1:ngen
        bus_injection(GENBUS(i,1),1)= bus_injection(GENBUS(i,1),1) + ACTUAL_GENERATION(t,1+i);
    end;
    LF_violation(t,1) = ACE(t,ACE_time_index);
    LF_violation_exceedance(t,1) = ACE(t,ACE_time_index);
    %ALFEE_Monitor_sort = sortrows(ALFEE_Monitor);
    for l=1:nbranch
        ACTUAL_LF(l,1) = PTDF_VAL(l,:)*bus_injection;
        if ACTUAL_LF(l,1) > BRANCHDATA.val(l,line_rating) || ACTUAL_LF(l,1) < -1*BRANCHDATA.val(l,line_rating)
            LF_violation(t,l+1) = 1;
            LF_violation_exceedance(t,l+1) = max(ACTUAL_LF(l,1) - BRANCHDATA.val(l,line_rating),(-1)*BRANCHDATA.val(l,line_rating) - ACTUAL_LF(l,1) );
        else
            LF_violation(t,l+1) = 0;
            LF_violation_exceedance(t,l+1) = 0;
        end;
    end;
end;
ALFEE = sum(LF_violation_exceedance(:,2:nbranch+1)).*(t_AGC/60/60);
end;

% Calculate Generator Cycles
generator_cycles = 0;
last_gen_change = 0;
for i=1:ngen
    if GENVALUE.val(i,gen_type) == 7 || GENVALUE.val(i,gen_type) == 10 || GENVALUE.val(i,gen_type) == 14 || GENVALUE.val(i,gen_type) == 16
    else
    for t=2:AGC_interval_index-1
        gen_change = ACTUAL_GENERATION(t,1+i)-ACTUAL_GENERATION(t-1,1+i);
        if gen_change*last_gen_change < -1*eps
            generator_cycles = generator_cycles + 1;
        end;
        last_gen_change = gen_change;
    end;
    end;
end;

% Calculate Reliability Metrics
CPS2_violations = 0;
eps = 0.00001;
for t1=2:AGC_interval_index-1
    if mod(ACE(t1,1)*60,CPS2_interval)- 0 < eps || CPS2_interval - mod(ACE(t1,1)*60,CPS2_interval) < eps
        if abs(ACE(t1-1,CPS2_ACE_index)) > L10
            CPS2_violations = CPS2_violations + 1;
        end;
    end;
end;
nCPS2_interval = ceil((time - start_time)*60/CPS2_interval);
CPS2 = 1-CPS2_violations/nCPS2_interval;
Total_MWH_Absolute_ACE = ACE(AGC_interval_index-1,AACEE_index);
sigma_ACE = std(ACE(:,raw_ACE_index));
inadvertent_interchange=ACE(AGC_interval_index-1,integrated_ACE_index);

for x=1:size(RELIABILITY_POST_in,1)
    try run(RELIABILITY_POST_in{x,1});catch;end;
end;


for x=1:size(COST_PRE_in,1)
    try run(COST_PRE_in{x,1});catch;end;
end;

puidx=GENVALUE.val(:,pucost);
if sum(puidx) > 0
    BLOCK(find(puidx),:)=BLOCK(find(puidx),:).*repmat(GENVALUE.val(find(puidx),capacity),1,4);
end

% Production Costs
[Cost_Result,DARevenue_Result,DARevenue_Result_Energy,DARevenue_Result_AS,RTRevenue_Result,RTRevenue_Result_Energy,RTRevenue_Result_AS,...
    Revenue_Result,Profit_Result,Total_SU_Costs,Total_Cum_Costs] = GetCostsandRevenues(ACTUAL_GENERATION,RTSCEDBINDINGLMP,RTSCEDBINDINGRESERVE,RTSCEDBINDINGRESERVEPRICE,...
    DASCUCSCHEDULE,DASCUCLMP,DASCUCRESERVE,DASCUCRESERVEPRICE,COST,BLOCK,GENVALUE.val,ngen,nreserve,GENBUS,round(end_time)/IDAC,t_AGC,IRTD,IDAC);
Cost_Result_Total = sum(sum(Cost_Result));
Revenue_Result_Total = sum(sum(Revenue_Result));
Profit_Result_Total = sum(sum(Profit_Result));

lmpsum=0;
count=0;
a=size(RTSCEDBINDINGLMP);
b=a(1);
for i=1:b
    for j=1:nbus
        if abs(RTSCEDBINDINGLMP(i,j+1)) < 100
            lmpsum = lmpsum + RTSCEDBINDINGLMP(i,j+1);
            count=count+1;
        end
    end
end
adjusted_cost =  Cost_Result_Total - (lmpsum/count)*ACE(AGC_interval_index-1,integrated_ACE_index);
if size(STORAGE_UNITS,1) > 0 && sum(GENVALUE.val(:,gen_type)==6) > 0
    costperMWh=adjusted_cost/(sum(ACTUAL_LOAD_FULL(:,2))/(3600/t_AGC));
    stotemp=ACTUAL_STORAGE_LEVEL(end,2:end);stotemp=stotemp(stotemp~=0);
    tempcostadjustment=0;
    for st=1:size(stotemp,2)
        tempcostadjustment = ((storageforadjustedcostcalculation(st) - stotemp(st))*costperMWh)+tempcostadjustment;
    end
    adjusted_storage_cost=adjusted_cost+tempcostadjustment;
end


for x=1:size(COST_POST_in,1)
    try run(COST_POST_in{x,1});catch;end;
end;

disp(['Unadjusted Production Cost: ',convert2currency(Cost_Result_Total)])
disp(['Unadjusted Revenue (load payment): ',convert2currency(Revenue_Result_Total)])
disp(['Profit: ',convert2currency(Profit_Result_Total)])
disp(['Adjusted for Inadvertent Interchange:   ',convert2currency(adjusted_cost)]);
try disp(['Adjusted for Storage Level: ',convert2currency(adjusted_storage_cost)]);catch;end;
try disp(['Start-Up Costs: ',convert2currency(Total_SU_Costs)]);catch;end;

try disp(['ALFEE: ',num2str(ALFEE)]);catch;end;
disp(['Generator Cycles: ',num2str(generator_cycles)])
disp(['CPS2 Violations: ',num2str(CPS2_violations)])
disp(['CPS2: ',sprintf('%.02f %%',CPS2*100)])
disp(['Absolute ACE in Energy (AACEE): ',num2str(Total_MWH_Absolute_ACE)])
disp(['Max Reg Limit Hit: ',num2str(Max_Reg_Limit_Hit)])
disp(['Min Reg Limit Hit: ',num2str(Min_Reg_Limit_Hit)])
disp(['ACE Standard Deviation: ',num2str(sigma_ACE)])
disp(['Mean-Absolute ACE: ',num2str(mean(abs(ACE(:,raw_ACE_index))))])
disp(['Inadvertent Interchange: ',num2str(inadvertent_interchange)]);
disp(' ')