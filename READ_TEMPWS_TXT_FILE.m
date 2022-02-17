% Add before data initialization

%tempwsPath=[pwd,filesep,'tempws.txt']

%addpath([pwd,filesep,'MODEL_RULES']);
tempwsPath=[pwd,filesep,'tempws.txt']


% Simulation Options
inputPath = char(char(inifile(tempwsPath,'read',{'','','inputPath',''})));
daystosimulate = str2double(char(inifile(tempwsPath,'read',{'','','daystosimulate',''})));
hours_to_simulate_in = str2double(char(inifile(tempwsPath,'read',{'','','hours_to_simulate_in',''})));
minutes_to_simulate_in = str2double(char(inifile(tempwsPath,'read',{'','','minutes_to_simulate_in',''})));
seconds_to_simulate_in = str2double(char(inifile(tempwsPath,'read',{'','','seconds_to_simulate_in',''})));
start_date_in = str2double(char(inifile(tempwsPath,'read',{'','','start_date_in',''})));

% DASCUC Options
DAC_RESERVE_FORECAST_MODE_in = str2double(char(inifile(tempwsPath,'read',{'','','DAC_RESERVE_FORECAST_MODE_in',''})));
DAC_load_forecast_data_create_in = str2double(char(inifile(tempwsPath,'read',{'','','DAC_load_forecast_data_create_in',''})));
DAC_vg_forecast_data_create_in = str2double(char(inifile(tempwsPath,'read',{'','','DAC_vg_forecast_data_create_in',''})));
GDAC_in = str2double(char(inifile(tempwsPath,'read',{'','','GDAC_in',''})));
HDAC_in = str2double(char(inifile(tempwsPath,'read',{'','','HDAC_in',''})));
IDAC_in = str2double(char(inifile(tempwsPath,'read',{'','','IDAC_in',''})));
PDAC_in = str2double(char(inifile(tempwsPath,'read',{'','','PDAC_in',''})));
tDAC_in = str2double(char(inifile(tempwsPath,'read',{'','','tDAC_in',''})));
DAHORIZONTYPE_in = str2double(char(inifile(tempwsPath,'read',{'','','DAHORIZONTYPE_in',''})));

% RTSCUC Options
RTC_RESERVE_FORECAST_MODE_in = str2double(char(inifile(tempwsPath,'read',{'','','RTC_RESERVE_FORECAST_MODE_in',''})));
RTC_load_forecast_data_create_in = str2double(char(inifile(tempwsPath,'read',{'','','RTC_load_forecast_data_create_in',''})));
RTC_vg_forecast_data_create_in = str2double(char(inifile(tempwsPath,'read',{'','','RTC_vg_forecast_data_create_in',''})));
HRTC_in = str2double(char(inifile(tempwsPath,'read',{'','','HRTC_in',''})));
IRTC_in = str2double(char(inifile(tempwsPath,'read',{'','','IRTC_in',''})));
tRTC_in = str2double(char(inifile(tempwsPath,'read',{'','','tRTC_in',''})));
tRTCSTART_in = str2double(char(inifile(tempwsPath,'read',{'','','tRTCSTART_in',''})));
PRTC_in = str2double(char(inifile(tempwsPath,'read',{'','','PRTC_in',''})));

% RTSCED Options
RTD_RESERVE_FORECAST_MODE_in = str2double(char(inifile(tempwsPath,'read',{'','','RTD_RESERVE_FORECAST_MODE_in',''})));
RTD_load_forecast_data_create_in = str2double(char(inifile(tempwsPath,'read',{'','','RTD_load_forecast_data_create_in',''})));
RTD_vg_forecast_data_create_in = str2double(char(inifile(tempwsPath,'read',{'','','RTD_vg_forecast_data_create_in',''})));
HRTD_in = str2double(char(inifile(tempwsPath,'read',{'','','HRTD_in',''})));
PRTD_in = str2double(char(inifile(tempwsPath,'read',{'','','PRTD_in',''})));
tRTD_in = str2double(char(inifile(tempwsPath,'read',{'','','tRTD_in',''})));
IRTDADV_in = str2double(char(inifile(tempwsPath,'read',{'','','IRTDADV_in',''})));
IRTD_in = str2double(char(inifile(tempwsPath,'read',{'','','IRTD_in',''})));

% RPU Options
ALLOW_RPU_in = char(inifile(tempwsPath,'read',{'','','ALLOW_RPU_in',''}));
ACE_RPU_THRESHOLD_MW_in = str2double(char(inifile(tempwsPath,'read',{'','','ACE_RPU_THRESHOLD_MW_in',''})));
ACE_RPU_THRESHOLD_T_in = str2double(char(inifile(tempwsPath,'read',{'','','ACE_RPU_THRESHOLD_T_in',''})));
HRPU_in = str2double(char(inifile(tempwsPath,'read',{'','','HRPU_in',''})));
IRPU_in = str2double(char(inifile(tempwsPath,'read',{'','','IRPU_in',''})));
PRPU_in = str2double(char(inifile(tempwsPath,'read',{'','','PRPU_in',''})));
restrict_multiple_rpu_time_in = str2double(char(inifile(tempwsPath,'read',{'','','restrict_multiple_rpu_time_in',''})));

% Post Processing Options
CPS2_interval_in = str2double(char(inifile(tempwsPath,'read',{'','','CPS2_interval_in',''})));
Type3_integral_in = str2double(char(inifile(tempwsPath,'read',{'','','Type3_integral_in',''})));
K1_in = str2double(char(inifile(tempwsPath,'read',{'','','K1_in',''})));
K2_in = str2double(char(inifile(tempwsPath,'read',{'','','K2_in',''})));
L10_in = str2double(char(inifile(tempwsPath,'read',{'','','L10_in',''})));

% Model Rules
DASCUC_RULES_PRE_in = split(char(inifile(tempwsPath,'read',{'','','DASCUC_RULES_PRE_in',''})),',');
DASCUC_RULES_POST_in = split(char(inifile(tempwsPath,'read',{'','','DASCUC_RULES_POST_in',''})),',');
RTSCUC_RULES_PRE_in = split(char(inifile(tempwsPath,'read',{'','','RTSCUC_RULES_PRE_in',''})),',');
RTSCUC_RULES_POST_in = split(char(inifile(tempwsPath,'read',{'','','RTSCUC_RULES_POST_in',''})),',');
RTSCED_RULES_PRE_in = split(char(inifile(tempwsPath,'read',{'','','RTSCED_RULES_PRE_in',''})),',');
RTSCED_RULES_POST_in = split(char(inifile(tempwsPath,'read',{'','','RTSCED_RULES_POST_in',''})),',');
AGC_RULES_PRE_in = split(char(inifile(tempwsPath,'read',{'','','AGC_RULES_PRE_in',''})),',');
AGC_RULES_POST_in = split(char(inifile(tempwsPath,'read',{'','','AGC_RULES_POST_in',''})),',');
RPU_RULES_PRE_in = split(char(inifile(tempwsPath,'read',{'','','RPU_RULES_PRE_in',''})),',');
RPU_RULES_POST_in = split(char(inifile(tempwsPath,'read',{'','','RPU_RULES_POST_in',''})),',');
POST_PROCESSING_PRE_in = split(char(inifile(tempwsPath,'read',{'','','POST_PROCESSING_PRE_in',''})),',');
POST_PROCESSING_POST_in = split(char(inifile(tempwsPath,'read',{'','','POST_PROCESSING_POST_in',''})),',');
DATA_INITIALIZE_PRE_in = split(char(inifile(tempwsPath,'read',{'','','DATA_INITIALIZE_PRE_in',''})),',');
DATA_INITIALIZE_POST_in = split(char(inifile(tempwsPath,'read',{'','','DATA_INITIALIZE_POST_in',''})),',');
FORECASTING_PRE_in = split(char(inifile(tempwsPath,'read',{'','','FORECASTING_PRE_in',''})),',');
FORECASTING_POST_in = split(char(inifile(tempwsPath,'read',{'','','FORECASTING_POST_in',''})),',');
RT_LOOP_PRE_in = split(char(inifile(tempwsPath,'read',{'','','RT_LOOP_PRE_in',''})),',');
RT_LOOP_POST_in = split(char(inifile(tempwsPath,'read',{'','','RT_LOOP_POST_in',''})),',');
ACE_PRE_in = split(char(inifile(tempwsPath,'read',{'','','ACE_PRE_in',''})),',');
ACE_POST_in = split(char(inifile(tempwsPath,'read',{'','','ACE_POST_in',''})),',');
FORCED_OUTAGE_PRE_in = split(char(inifile(tempwsPath,'read',{'','','FORCED_OUTAGE_PRE_in',''})),',');
FORCED_OUTAGE_POST_in = split(char(inifile(tempwsPath,'read',{'','','FORCED_OUTAGE_POST_in',''})),',');
SHIFT_FACTOR_PRE_in = split(char(inifile(tempwsPath,'read',{'','','SHIFT_FACTOR_PRE_in',''})),',');
SHIFT_FACTOR_POST_in = split(char(inifile(tempwsPath,'read',{'','','SHIFT_FACTOR_POST_in',''})),',');
ACTUAL_OUTPUT_PRE_in = split(char(inifile(tempwsPath,'read',{'','','ACTUAL_OUTPUT_PRE_in',''})),',');
ACTUAL_OUTPUT_POST_in = split(char(inifile(tempwsPath,'read',{'','','ACTUAL_OUTPUT_POST_in',''})),',');
RELIABILITY_PRE_in = split(char(inifile(tempwsPath,'read',{'','','RELIABILITY_PRE_in',''})),',');
RELIABILITY_POST_in = split(char(inifile(tempwsPath,'read',{'','','RELIABILITY_POST_in',''})),',');
COST_PRE_in = split(char(inifile(tempwsPath,'read',{'','','COST_PRE_in',''})),',');
COST_POST_in = split(char(inifile(tempwsPath,'read',{'','','COST_POST_in',''})),',');
SAVING_PRE_in = split(char(inifile(tempwsPath,'read',{'','','SAVING_PRE_in',''})),',');
SAVING_POST_in = split(char(inifile(tempwsPath,'read',{'','','SAVING_POST_in',''})),',');

% AGC Options
agcmode = str2double(char(inifile(tempwsPath,'read',{'','','agcmode',''})));
agc_deadband_in = str2double(char(inifile(tempwsPath,'read',{'','','agc_deadband_in',''})));

% Contingency Options
SIMULATE_CONTINGENCIES_in = char(inifile(tempwsPath,'read',{'','','SIMULATE_CONTINGENCIES_in',''}));
Contingency_input_check_in = str2double(char(inifile(tempwsPath,'read',{'','','Contingency_input_check_in',''})));
contingencycheck = char(inifile(tempwsPath,'read',{'','','contingencycheck',''}));
checkthenetwork = char(inifile(tempwsPath,'read',{'','','checkthenetwork',''}));
gen_outage_time_in = str2double(char(inifile(tempwsPath,'read',{'','','gen_outage_time_in',''})));
multiplefilecheck = str2double(char(inifile(tempwsPath,'read',{'','','multiplefilecheck',''})));
multiplerunscheckvalue = str2double(char(inifile(tempwsPath,'read',{'','','multiplerunscheckvalue',''})));

% Debug Options
debugcheck_in = str2double(char(inifile(tempwsPath,'read',{'','','debugcheck_in',''})));
autosavecheck = str2double(char(inifile(tempwsPath,'read',{'','','autosavecheck',''})));
suppress_plots_in = char(inifile(tempwsPath,'read',{'','','suppress_plots_in',''}));
timefordebugstop_in = str2double(char(inifile(tempwsPath,'read',{'','','timefordebugstop_in',''})));
useHDF5 = str2double(char(inifile(tempwsPath,'read',{'','','useHDF5',''})));
USE_INTEGER_in = char(inifile(tempwsPath,'read',{'','','USE_INTEGER_in',''}));
solver_in = char(inifile(tempwsPath,'read',{'','','solver_in',''}));
