function[Cost_Result,DARevenue_Result,DARevenue_Result_Energy,DARevenue_Result_AS,RTRevenue_Result,RTRevenue_Result_Energy,RTRevenue_Result_AS,...
    Revenue_Result,Profit_Result,Total_SU_Costs,Total_Cum_Costs] = GetCostsandRevenues(ACTUAL_GENERATION,RTSCEDBINDINGLMP,RTSCEDBINDINGRESERVE,RTSCEDBINDINGRESERVEPRICE,...
    DASCUCSCHEDULE,DASCUCLMP,DASCUCRESERVE,DASCUCRESERVEPRICE,COST,BLOCK,GENVALUE,ngen,nreserve,GENBUS,cost_hours,t_AGC,IRTD,IDAC)


%Options
DA2RTInterval_Lining = 2;
RT2ACTInterval_Lining = 3;
%{
1: Real-time intervals balance schedule with day-ahead from top of
interval. Ex. if hourly DASCUC, 1:05, 1:10... 1:55, 2:00 real=time 
intervals balance off 1:00 DASCUC interval.
2: Real-time intervals balance schedule with day-ahead from middle of
interval. Ex. if hourly DASCUC, 0:35, 0:40, 0:45... 1:25, 1:30 real=time 
intervals balance off 1:00 DASCUC interval.
3: Real-time intervals balance schedule with day-ahead from bottom of
interval. Ex. if hourly DASCUC, 0:05, 0:10, 0:15... 0:50, 0:55 real=time 
intervals balance off 1:00 DASCUC interval.
Similar cases are for actual intervals aligning to real-time dispatch.
%}

DA_size = size(DASCUCSCHEDULE,1);
ACT_size = size(ACTUAL_GENERATION,1);
RT_size = size(RTSCEDBINDINGLMP,1);
Cost_Result = zeros(cost_hours,ngen);
DARevenue_Result = zeros(DA_size,ngen);
DARevenue_Result_Energy = zeros(DA_size,ngen);
DARevenue_Result_AS = zeros(DA_size,ngen,nreserve);
RTRevenue_Result = zeros(RT_size,ngen);
RTRevenue_Result_Energy = zeros(RT_size,ngen);
RTRevenue_Result_AS = zeros(RT_size,ngen,nreserve);
max_price = 1000;
Total_SU_Costs=0;
Total_Cum_Costs=zeros(ACT_size,1);

%Genparam
global inc_cost capacity noload_cost su_cost mr_time md_time ramp_rate min_gen gen_type su_time agc_qualified initial_storage storage_max ...
    efficiency storage_value max_starts initial_status initial_hour initial_MW forced_outage_rate mttr variable_start behavior_rate;

No_Load_Cost = GENVALUE(:,noload_cost);
Startup_Cost = GENVALUE(:,su_cost); %Currently this will not be correct for variable startupcost.
Initial_Status = GENVALUE(:,initial_status);
nblock = size(COST,2);
genbus1(:,1)=1+GENBUS(:,1);
for i=1:ngen
    % Day-Ahead Revenue
    for t2=1:DA_size
        DARevenue_Result_Energy(t2,i) =  DASCUCSCHEDULE(t2,i+1)*max(-max_price,min(max_price,DASCUCLMP(t2,genbus1(i))))*IDAC;
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
  Positive_generation(1,:)= (ACTUAL_GENERATION(t,plus1) > eps) ;
   tfirst = (t==1);
    initial_status_off(:,1) = Initial_Status(:,1) == 0;
    Cost_Result(h,:) = Cost_Result(h,:)...
        + Positive_generation.* No_Load_Cost(:,1)'*(t_AGC/3600)...
        ;
   for i=1:ngen
        %if ACTUAL_GENERATION(t,i+1) > eps
        %    Cost_Result(h,i) = Cost_Result(h,i) + No_Load_Cost(i,1)*(t_AGC/3600);
        %end;
        if tfirst
            if Positive_generation(i) && initial_status_off(i) ;
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
            if ACTUAL_GENERATION(t,i+1) <= BLOCK(i,k)
                if k == 1
                    prev_block = 0;
                else
                    prev_block = BLOCK(i,k-1);
                end;
                Cost_Result(h,i) = Cost_Result(h,i) + (ACTUAL_GENERATION(t,i+1) - prev_block)*COST(i,k)*(t_AGC/3600);
                k=nblock;
            else
                if k == 1
                    prev_block = 0;
                else
                    prev_block = BLOCK(i,k-1);
                end;
                Cost_Result(h,i) = Cost_Result(h,i) + (BLOCK(i,k) - prev_block)*COST(i,k)*(t_AGC/3600);
            end;
            k=k+1;
        end;
    end; % i=1:ngen
        RTRevenue_Result_Energy_TMP_(1,:) = ...
          (ACTUAL_GENERATION(t,plus1)-DASCUCSCHEDULE(minDA,plus1)).* ...
            max(-max_price,min(max_price,RTSCEDBINDINGLMP(minRT,genbus1(:))))*(t_AGC/3600);
        RTRevenue_Result_Energy(minRT,:) = RTRevenue_Result_Energy(minRT,:) + ...
            RTRevenue_Result_Energy_TMP_;
        Diff_(:,:)=RTSCEDBINDINGRESERVE(minRT,plus1,1:nreserve)-DASCUCRESERVE(minDA,plus1,:);
        RTRevenue_Result_AS_TMP_=zeros(size(Diff_));
        for i=1:ngen; RTRevenue_Result_AS_TMP_(i,:) =  ...
            (Diff_(i,:).*RTSCEDBINDINGRESERVEPRICE(minRT,2:end))*(t_AGC/3600); end % i=1:ngen
        RTRevenue_Result(minRT,:) = RTRevenue_Result(minRT,:)+RTRevenue_Result_Energy_TMP_(1,:);
        RTRevenue_Result_AS(minRT,1:ngen,:) = RTRevenue_Result_AS_TMP_(:,:);
         sumRTrev_=sum(RTRevenue_Result_AS_TMP_,2)';
          RTRevenue_Result(minRT,:) = RTRevenue_Result(minRT,:) + sumRTrev_;
        Revenue_Result(minDA,:) = Revenue_Result(minDA,:) + RTRevenue_Result_Energy_TMP_ + sumRTrev_;
        
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

end
