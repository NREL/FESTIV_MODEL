%Creates steady state frequency with linear relationship to ACE
%The frequency is always steady-state and assumes all governors and load
%response have fully responded between the timeframes. User can either use
%Bias as a system wide value, similar to what is used in ACE equation, or
%find individual contribution of resources and load so that system
%conditions will impact frequency, and the linear relationship between ACE
%and Frequency Deviation is changing during every interval.
%
%Use After ACE Calculation.

%{
USE:    AFTER ACE CALCULATION
%}

%System Bias is a strictly linear relationship between ACE and Frequency.
%Therefore it does not account for individual contributions or system
%conditions. Without system bias, more accurate steady-state frequency
Use_System_Bias = 0;
System_Bias = 200; %MW/Hz
FREQUENCY(AGC_interval_index,1)=time;
if Use_System_Bias
   Beta = System_Bias;
    FREQUENCY(AGC_interval_index,2) = SYSTEMVALUE_VAL(frequency,1) + ACE_raw/Beta;
else
clear FREQUENCY_dev_tmp;
freq_iteration_limit =30;
freq_calc_ferr_tolerance = 0.001;
freq_calc_MWerr_tolerance = 0.1;
PFR_MW_imbalance = freq_calc_MWerr_tolerance*10;
freq_calc_tolerance_converge_help=0.5;
droops = GENVALUE_VAL(:,droop);
droops(droops==0) = .05;
freq_calc_iteration =2;
%for now ignoring VER
PFR_DF_at_PMAX=zeros(ngen,1);
PFR_DF_at_PMIN=zeros(ngen,1);
PFR_enabled = (1-unit_startup_agc(:,1)).*(1-unit_shutdown_agc(:,1)).*UNIT_STATUS_VAL(:,1);
PFR_enabled(GENVALUE_VAL(:,gen_type) == 7) =0;
PFR_enabled(GENVALUE_VAL(:,gen_type) == 10) =0;
PFR_Headroom_By_Unit = (GENVALUE_VAL(:,capacity)-ACTUAL_GENERATION(AGC_interval_index,2:end)').*PFR_enabled;
PFR_DF_at_PMAX = -1.*(PFR_Headroom_By_Unit./(1./(droops*SYSTEMVALUE_VAL(frequency,1)./GENVALUE_VAL(:,capacity))) + GENVALUE_VAL(:,gov_db));
PFR_DF_at_PMAX(PFR_Headroom_By_Unit==0)=0;
PFR_DF_MAX_at_PMAX=min(PFR_DF_at_PMAX);
PFR_UnderFrequency_Max_Load_Response = SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1))*PFR_DF_MAX_at_PMAX;

PFR_Floorroom_By_Unit = (ACTUAL_GENERATION(AGC_interval_index,2:end)'-GENVALUE_VAL(:,min_gen)).*PFR_enabled;
PFR_DF_at_PMIN = PFR_Floorroom_By_Unit./(1./(droops*SYSTEMVALUE_VAL(frequency,1)./GENVALUE_VAL(:,capacity))) + GENVALUE_VAL(:,gov_db);
PFR_DF_at_PMIN(PFR_Floorroom_By_Unit==0)=0;
PFR_DF_MAX_at_PMIN=max(PFR_DF_at_PMIN);
PFR_OverFrequency_Max_Load_Response = SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1))*PFR_DF_MAX_at_PMIN;

PFR_DF_at_noGENPFR_all_Load_Response = ACE_raw/(SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1)));
PFR_min_gov_DB = min(GENVALUE_VAL(PFR_enabled==1,gov_db));
if PFR_min_gov_DB >0
    PFR_noGEN_Min_Load_Response = SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1))*PFR_min_gov_DB;
else
    PFR_noGEN_Min_Load_Response = 0;
end;

if (ACE_raw < -1*sum(PFR_Headroom_By_Unit)-PFR_UnderFrequency_Max_Load_Response)
    PFR_Load_Response_Extreme_ACE = ACE_raw+sum(PFR_Headroom_By_Unit);
    FREQUENCY_dev_tmp(freq_calc_iteration) = PFR_Load_Response_Extreme_ACE/(SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1)));
elseif (ACE_raw > (sum(PFR_Floorroom_By_Unit)+PFR_OverFrequency_Max_Load_Response))
    PFR_Load_Response_Extreme_ACE = ACE_raw - sum(PFR_Floorroom_By_Unit);
    FREQUENCY_dev_tmp(freq_calc_iteration) = PFR_Load_Response_Extreme_ACE/(SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1)));
else
Droop_abs = (-1.*GENVALUE_VAL(:,capacity).*PFR_enabled./droops)./SYSTEMVALUE_VAL(frequency,1);
Frequency_Response_by_Unit=Droop_abs;
Beta = sum(Frequency_Response_by_Unit)-SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1));
FREQUENCY_dev_tmp(1)=0;
FREQUENCY_dev_tmp(freq_calc_iteration) = -1.*ACE_raw/Beta;
for i=1:ngen
    if FREQUENCY_dev_tmp(freq_calc_iteration) < -1.*GENVALUE_VAL(i,gov_db) && PFR_enabled(i,1) == 1 
        PFR_by_Unit(i,1) = min(GENVALUE_VAL(i,capacity) - ACTUAL_GENERATION(AGC_interval_index,1+i),Droop_abs(i)*(FREQUENCY_dev_tmp(freq_calc_iteration)+GENVALUE_VAL(i,gov_db)));
    elseif FREQUENCY_dev_tmp(freq_calc_iteration) > GENVALUE_VAL(i,gov_db) && PFR_enabled(i,1) == 1  
        PFR_by_Unit(i,1) = max(GENVALUE_VAL(i,min_gen)-ACTUAL_GENERATION(AGC_interval_index,1+i),Droop_abs(i)*(FREQUENCY_dev_tmp(freq_calc_iteration)-GENVALUE_VAL(i,gov_db)));
    else
        PFR_by_Unit(i,1) = 0;
    end;
end;
PFR_MW_imbalance(freq_calc_iteration) = -1*(ACE_raw+(sum(PFR_by_Unit)-FREQUENCY_dev_tmp(freq_calc_iteration-1)*SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1))));
while ((abs(FREQUENCY_dev_tmp(freq_calc_iteration) - FREQUENCY_dev_tmp(freq_calc_iteration-1)) > freq_calc_ferr_tolerance || abs(PFR_MW_imbalance(freq_calc_iteration)) > freq_calc_MWerr_tolerance) || freq_calc_iteration == 2) ...
        && freq_calc_iteration < freq_iteration_limit 
    for i=1:ngen
        if FREQUENCY_dev_tmp(freq_calc_iteration) < -1.*GENVALUE_VAL(i,gov_db) && PFR_enabled(i,1) == 1 
            PFR_by_Unit(i,1) = min(GENVALUE_VAL(i,capacity) - ACTUAL_GENERATION(AGC_interval_index,1+i),Droop_abs(i)*(FREQUENCY_dev_tmp(freq_calc_iteration)+GENVALUE_VAL(i,gov_db)));
        elseif FREQUENCY_dev_tmp(freq_calc_iteration) > GENVALUE_VAL(i,gov_db) && PFR_enabled(i,1) == 1  
            PFR_by_Unit(i,1) = max(GENVALUE_VAL(i,min_gen)-ACTUAL_GENERATION(AGC_interval_index,1+i),Droop_abs(i)*(FREQUENCY_dev_tmp(freq_calc_iteration)-GENVALUE_VAL(i,gov_db)));
        else
            PFR_by_Unit(i,1) = 0;
        end;
    end;
    Frequency_Response_by_Unit = PFR_by_Unit/FREQUENCY_dev_tmp(freq_calc_iteration);
    Beta = sum(Frequency_Response_by_Unit)-SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1));
    freq_calc_iteration = freq_calc_iteration+1;
    PFR_MW_imbalance(freq_calc_iteration) = -1*(ACE_raw+(sum(PFR_by_Unit)-FREQUENCY_dev_tmp(freq_calc_iteration-1)*SYSTEMVALUE_VAL(load_damping,1)*ACTUAL_LOAD_FULL(AGC_interval_index,2)/(.01*SYSTEMVALUE_VAL(frequency,1))));
    if freq_calc_iteration <=3
        FREQUENCY_dev_tmp(freq_calc_iteration) = FREQUENCY_dev_tmp(freq_calc_iteration-1)-PFR_MW_imbalance(freq_calc_iteration)/System_Bias;
    else
        PFR_f_calc_slope= (PFR_MW_imbalance(freq_calc_iteration) - PFR_MW_imbalance(freq_calc_iteration-1))/(FREQUENCY_dev_tmp(freq_calc_iteration-1)- FREQUENCY_dev_tmp(freq_calc_iteration-2));
        PFR_f_calc_intercept = PFR_MW_imbalance(freq_calc_iteration) - PFR_f_calc_slope*FREQUENCY_dev_tmp(freq_calc_iteration-1);
        FREQUENCY_dev_tmp(freq_calc_iteration) = -1*PFR_f_calc_intercept/PFR_f_calc_slope;
    end;
    %FREQUENCY_dev_tmp(freq_calc_iteration) = -1*ACE_raw/Beta;
    %if freq_calc_iteration >= 4 && abs((FREQUENCY_dev_tmp(freq_calc_iteration) - FREQUENCY_dev_tmp(freq_calc_iteration-1)) - (FREQUENCY_dev_tmp(freq_calc_iteration-1) - FREQUENCY_dev_tmp(freq_calc_iteration-2))) > ...
            %freq_calc_tolerance_converge_help*FREQUENCY_dev_tmp(freq_calc_iteration)
        %FREQUENCY_dev_tmp(freq_calc_iteration) = mean(FREQUENCY_dev_tmp(freq_calc_iteration-1:freq_calc_iteration));
    %end;
    Beta;
end;
end;
FREQUENCY(AGC_interval_index,2)=SYSTEMVALUE_VAL(frequency,1)+FREQUENCY_dev_tmp(freq_calc_iteration); 

end;

