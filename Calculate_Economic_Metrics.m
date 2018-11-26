
puidx=GENVALUE_VAL(:,pucost);
if sum(puidx) > 0
    BLOCK_CAP_VAL(find(puidx),:)=BLOCK_CAP_VAL(find(puidx),:).*repmat(GENVALUE_VAL(find(puidx),capacity),1,4);
end

% Production Costs
[Cost_Result,DARevenue_Result,DARevenue_Result_Energy,DARevenue_Result_AS,RTRevenue_Result,RTRevenue_Result_Energy,RTRevenue_Result_AS,...
    Revenue_Result,Profit_Result,Total_SU_Costs,Total_Cum_Costs] = GetCostsandRevenues(ACTUAL_GENERATION,RTSCEDBINDINGLMP,RTSCEDBINDINGRESERVE,RTSCEDBINDINGRESERVEPRICE,...
    DASCUCSCHEDULE,DASCUCLMP,DASCUCRESERVE,DASCUCRESERVEPRICE,BLOCK_COST_VAL,BLOCK_CAP_VAL,GENVALUE_VAL,ngen,nreserve,GENBUS_CALCS_VAL,round(end_time)/IDAC,t_AGC,IRTD,IDAC);
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
if size(STORAGE_UNITS,1) > 0 && sum(GENVALUE_VAL(:,gen_type)==pumped_storage_gen_type_index) > 0
    costperMWh=adjusted_cost/(sum(ACTUAL_LOAD_FULL(:,2))/(3600/t_AGC));
    stotemp=ACTUAL_STORAGE_LEVEL(end,2:end);stotemp=stotemp(stotemp~=0);
    tempcostadjustment=0;
    for st=1:size(stotemp,2)
        tempcostadjustment = ((storageforadjustedcostcalculation(st) - stotemp(st))*costperMWh)+tempcostadjustment;
    end
    adjusted_storage_cost=adjusted_cost+tempcostadjustment;
end



