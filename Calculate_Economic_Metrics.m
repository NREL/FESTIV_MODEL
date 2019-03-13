

DA_size = size(DASCUCSCHEDULE,1);
ACT_size = size(ACTUAL_GENERATION,1);
RT_size = size(RTSCEDBINDINGLMP,1);
Cost_Result = zeros(round(end_time)/IDAC,ngen);
DARevenue_Result = zeros(DA_size,ngen);
DARevenue_Result_Energy = zeros(DA_size,ngen);
DARevenue_Result_AS = zeros(DA_size,ngen,nreserve);
RTRevenue_Result = zeros(RT_size,ngen);
RTRevenue_Result_Energy = zeros(RT_size,ngen);
RTRevenue_Result_AS = zeros(RT_size,ngen,nreserve);
Total_SU_Costs=0;
Total_Cum_Costs=zeros(ACT_size,1);

No_Load_Cost = GENVALUE_VAL(:,noload_cost);
Startup_Cost = GENVALUE_VAL(:,su_cost); %Currently this will not be correct for variable startupcost.
Initial_Status = GENVALUE_VAL(:,initial_status);
nblock = size(BLOCK_COST_VAL,2);
genbus1=1+GENBUS_CALCS_VAL(:,2);
for i=1:ngen
    % Day-Ahead Revenue
    for t2=1:DA_size
        DARevenue_Result_Energy(t2,i) =  (DASCUCSCHEDULE(t2,i+1)-(gen_to_storage_index(i,1)>0)*DASCUCPUMPSCHEDULE(t2,gen_to_storage_index(i,1)+1)) *max(-max_price,min(max_price,DASCUCLMP(t2,genbus1(i))))*IDAC;
        DASCUCRESERVESCHEDULE_TMP(1,:)=DASCUCRESERVE(t2,i+1,1:nreserve);
        DARevenue_Result_AS(t2,i,:) = DARevenue_Result_AS(t2,i) + (DASCUCRESERVESCHEDULE_TMP.*DASCUCRESERVEPRICE(t2,2:end))*IDAC;
        DARevenue_Result(t2,i) = DARevenue_Result_Energy(t2,i);
        %for r=1:nreserve
            DARevenue_Result(t2,i) = DARevenue_Result(t2,i) + sum(DARevenue_Result_AS(t2,i,:));
        %end;
        Revenue_Result(t2,i) = DARevenue_Result(t2,i);
    end;
end

if feature('ShowFigureWindows'); wb=waitbar(0,'Calculating Costs and Revenues...'); end
%COSTS
h=1; plus1=2:ngen+1;
for t=1:ACT_size
        % Real Time Revenue; VD: switches pulled outside the for i=1:ngen loop
        switch DA2RTInterval_Lining
            case 1
                day_ahead_index = floor(ACTUAL_GENERATION(t,1)/IDAC)+1;
            case 2
                day_ahead_index = round(ACTUAL_GENERATION(t,1)/IDAC)+1;
            case 3
                day_ahead_index = ceil(ACTUAL_GENERATION(t,1)/IDAC)+1;
        end;
        switch RT2ACTInterval_Lining
            case 1
                real_time_index = floor(ACTUAL_GENERATION(t,1)/(IRTD/60))+1;
            case 2
                real_time_index = round(ACTUAL_GENERATION(t,1)/(IRTD/60))+1;
            case 3
                real_time_index = ceil(ACTUAL_GENERATION(t,1)/(IRTD/60))+1;
        end;
          minRT=min(RT_size,real_time_index);
            minDA=min(DA_size,day_ahead_index);
  Positive_generation= (ACTUAL_GENERATION(t,plus1) > eps) ;
   tfirst = (t==1);
    initial_status_off = Initial_Status(:,1) == 0;
    Cost_Result(h,:) = Cost_Result(h,:)...
        + Positive_generation.* No_Load_Cost(:,1)'*(t_AGC/3600)...
        ;
   for i=1:ngen
        %if ACTUAL_GENERATION(t,i+1) > eps
        %    Cost_Result(h,i) = Cost_Result(h,i) + No_Load_Cost(i,1)*(t_AGC/3600);
        %end;
        if tfirst
            if Positive_generation(i) && initial_status_off(i) 
                Cost_Result(h,i) = Cost_Result(h,i) + Startup_Cost(i,1);
                Total_SU_Costs = Total_SU_Costs + Startup_Cost(i,1);
            end;
        else
            if Positive_generation(i) && ACTUAL_GENERATION(t-1,i+1) < eps
                Cost_Result(h,i) = Cost_Result(h,i) + Startup_Cost(i,1);
                Total_SU_Costs = Total_SU_Costs + Startup_Cost(i,1);
            end;
        end;
        k=1;
        while k <=nblock
            if ACTUAL_GENERATION(t,i+1) <= BLOCK_CAP_VAL(i,k)
                if k == 1
                    prev_block = 0;
                else
                    prev_block = BLOCK_CAP_VAL(i,k-1);
                end;
                Cost_Result(h,i) = Cost_Result(h,i) + (ACTUAL_GENERATION(t,i+1) - prev_block)*BLOCK_COST_VAL(i,k)*(t_AGC/3600);
                k=nblock;
            else
                if k == 1
                    prev_block = 0;
                else
                    prev_block = BLOCK_CAP_VAL(i,k-1);
                end;
                Cost_Result(h,i) = Cost_Result(h,i) + (BLOCK_CAP_VAL(i,k) - prev_block)*BLOCK_COST_VAL(i,k)*(t_AGC/3600);
            end;
            k=k+1;
        end;
        bus_index = 1+GENBUS_CALCS_VAL(find(GENBUS_CALCS_VAL(:,1)==i),2);
        participation_factor_index = GENBUS_CALCS_VAL(find(GENBUS_CALCS_VAL(:,1)==i),3);
        RTRevenue_Result_Energy_TMP_ = ...
          ((ACTUAL_GENERATION(t,i+1)-(gen_to_storage_index(i,1)>0)*ACTUAL_PUMP(t,gen_to_storage_index(i,1)+1))-(DASCUCSCHEDULE(minDA,i+1)-(gen_to_storage_index(i,1)>0)*DASCUCPUMPSCHEDULE(minDA,gen_to_storage_index(i,1)+1))).* ...
            max(-max_price,min(max_price,RTSCEDBINDINGLMP(minRT,bus_index)*participation_factor_index))*(t_AGC/3600);
        RTRevenue_Result_Energy(minRT,i) = RTRevenue_Result_Energy(minRT,i) + ...
            RTRevenue_Result_Energy_TMP_;
        RTRevenue_Result_AS_TMP_=0;
        for r=1:nreserve
            Diff_=RTSCEDBINDINGRESERVE(minRT,1+i,r)-DASCUCRESERVE(minDA,1+i,r);
            RTRevenue_Result_AS_TMP_=zeros(size(Diff_));
            RTRevenue_Result_AS_TMP_ =  RTRevenue_Result_AS_TMP_ + ...
                (Diff_.*RTSCEDBINDINGRESERVEPRICE(minRT,1+r))*(t_AGC/3600);
        end
        RTRevenue_Result_AS(minRT,i) = RTRevenue_Result_AS_TMP_;
        RTRevenue_Result(minRT,i) = RTRevenue_Result(minRT,i) + RTRevenue_Result_Energy_TMP_ + RTRevenue_Result_AS_TMP_;
        Revenue_Result(minDA,i) = Revenue_Result(minDA,i) + RTRevenue_Result_Energy_TMP_ + RTRevenue_Result_AS_TMP_;
    end; % i=1:ngen
    Total_Cum_Costs(t,1)=sum(sum(Cost_Result(1:h,:)));
    if t > 1 && (mod(ACTUAL_GENERATION(t,1),IDAC) - 0 < eps || 1-mod(ACTUAL_GENERATION(t,1),IDAC) < eps)
        h = h+1;
    end;
    if mod(t,100)==0 || t == ACT_size
        if feature('ShowFigureWindows'); waitbar(t/ACT_size,wb); end
    end
end;
if feature('ShowFigureWindows'); close(wb); end


Profit_Result = Revenue_Result(1:size(Cost_Result,1),:) - Cost_Result;

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
if size(STORAGE_UNITS,1) > 0 
    costperMWh=adjusted_cost/(sum(ACTUAL_LOAD_FULL(:,2))/(3600/t_AGC));
    stotemp=ACTUAL_STORAGE_LEVEL(end,2:end);stotemp=stotemp(stotemp~=0);
    tempcostadjustment=0;
    for st=1:size(stotemp,2)
        tempcostadjustment = ((storageforadjustedcostcalculation(st) - stotemp(st))*costperMWh)+tempcostadjustment;
    end
    adjusted_storage_cost=adjusted_cost+tempcostadjustment;
end



