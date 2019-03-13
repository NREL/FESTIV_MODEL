%This script initializes variables coming from the GUI input.


%1 - from data file, 2 create perfect forecast, 3 create persistence
%forecast, 4 with predefined normally distributed error
dac_load_data_create = DAC_load_forecast_data_create_in;
dac_vg_data_create = DAC_vg_forecast_data_create_in;

%for using 4. Size must be = HDAC;
%VALUES SHOULD BE ADDED In SEPARATE MOD BEFORE FORECAST CREATION AND NOT
%HERE
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual
dac_vg_error = ones(24,1).*0;
dac_load_error = [0 0 0 0 0 0 0 0 0 0]';

%1 - from data file, 2 create perfect forecast, 3 create persistence
%forecast, 4 with predefined normally distributed error
rtc_load_data_create = RTC_load_forecast_data_create_in;
rtc_vg_data_create = RTC_vg_forecast_data_create_in;

%for using 4. Size must be = HRTC; 
%VALUES SHOULD BE ADDED In SEPARATE MOD BEFORE FORECAST CREATION AND NOT
%HERE
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual
rtc_vg_error = [0 0 0 0 0 0 0 0 0 0]';
rtc_load_error = [0 0 0 0 0 0 0 0 0 0]';

%1 - from data file, 2 create perfect forecast, 3 create persistence
%forecast, 4 with predefined normally distributed error
rtd_load_data_create = RTD_load_forecast_data_create_in;
rtd_vg_data_create = RTD_vg_forecast_data_create_in;

%for using 4. Size must be = HRTD
%VALUES SHOULD BE ADDED In SEPARATE MOD BEFORE FORECAST CREATION AND NOT
%HERE
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual.
rtd_vg_error = [0 0 0 0 0]';
rtd_load_error = [0 0 0 0 0]';


DAC_RESERVE_FORECAST_MODE=DAC_RESERVE_FORECAST_MODE_in;
RTC_RESERVE_FORECAST_MODE=RTC_RESERVE_FORECAST_MODE_in;
RTD_RESERVE_FORECAST_MODE=RTD_RESERVE_FORECAST_MODE_in;

hour_end = hours_to_simulate_in;
minute_end = minutes_to_simulate_in;
second_end = seconds_to_simulate_in;
end_time = (daystosimulate)*24 + hour_end + minute_end/60 + second_end/3600;
simulation_days=ceil(end_time/24);

%%SUB-MODEL INTERVAL DEFINITIONS%%

%{
tDAC:time between updates of DASCUC in hours
IDAC: time resolution of intervals of DASCUC in hours
HDAC:amount of intervals in DASCUC optimization horizon
PDAC: time it takes to solve DASCUC in hours
GDAC: the first market gate (time of day in hour) of DASCUC. If tDAC is
anything other than 24 this will only represent the first start time.
%}
tDAC = tDAC_in;
IDAC = IDAC_in;
HDAC = HDAC_in;
PDAC = PDAC_in;
GDAC = GDAC_in;

%{
trtd: time between updates of RTSCED
Irtd: time resolution of first interval of RTSCED
Irtdadv: time resolution of other intervals of RTSCED
Prtd: time it takes to solve RTSCED
Hrtd: amount of intervals in RTSCED optimization horizon
Notes:
The interval horizon of RTSCED should be less than or equal to RTSCUC
IRTDADV should be greater than or equal IRTD
%}
HRTD = HRTD_in;  
IRTD = IRTD_in;
tRTD = tRTD_in;
IRTDADV = IRTDADV_in; %Note that advisory length must be greater than or equal to rtd interval length.
PRTD = PRTD_in;
if abs(tRTD-IRTD)>0.01
    fprintf('Warning: FESTIV Not currently tested for case where IRTD does not equal tRTD!')
end;

%{
trtc: time between updates of RTSCUC
Irtc: time resolution of first interval of RTSCUC
Prtc: time it takes to solve RTSCUC
Hrtc: amount of intervals in RTSCUC optimization horizon
Notes:
%}
HRTC = HRTC_in; 
IRTC = IRTC_in;
tRTC = tRTC_in;
PRTC = PRTC_in;
if abs(tRTC-IRTC)>0.01
    fprintf('Warning: FESTIV Not currently tested for case where IRTC does not equal tRTC!')
end;

%trtcstart: For what units are allowed to be started by RTC in hours.
tRTCstart = tRTCSTART_in;

%{
Irpu: time resolution of RPU interval
HRPU: amount of intervals in RPU optimization horizon
PRUP: time it takes to solve RPU
%}
HRPU = HRPU_in;
IRPU = IRPU_in;
PRPU = PRPU_in;

ALLOW_RPU = ALLOW_RPU_in; %Whether it can happen at all
ACE_RPU_THRESHOLD_MW = ACE_RPU_THRESHOLD_MW_in; %ACE exceedance where the operator will run RPU. If only ctgc, make number very large.
ACE_RPU_THRESHOLD_T = ACE_RPU_THRESHOLD_T_in; %in tagc intervals
ACE_CRTD_THRESHOLD = 50; %not used yet
RPU_RESERVE_ALLOWANCE = 2; %not used yet
restrict_multiple_rpu_time = restrict_multiple_rpu_time_in; %in minutes, don't start another RPU if one started this recently.
rpu_time = -100;

%How is AGC performed
%{
    1: Blind AGC, no AGC, only ramping dispatch using interpolation from one RTD to next.
    2: Fast AGC, AGC based on raw ACE. Follow instantaneous ACE
    3: Smooth AGC, AGC with filter and integrator. Follow ACE but filter to ignore noise, and integrate to follow if persistent deviation. (still needs work)
    4: Lazy AGC, AGC optimal CPS2 compliance, only follow if CPS2 will be violated. combination of 1 and 3.
    5: Use gen specific modes
    6: Other; requires AGC Mod
%}
AGC_MODE = agcmode;

%For evaluating performance
CPS2_interval = CPS2_interval_in; %The interval length evaluated for ACE performance
L10 = L10_in; %ACE limit (NERC defined L10 value for CPS2 violations)
%Parameters for SACE
Type3_integral = Type3_integral_in; %Number of seconds integrated over
%K1 and K2 used in agc_mode 3 where it describes the weighting of the
%current ace and the integral of previous aces, respectively.
K1 = K1_in;
K2 = K2_in;
%deadband for AGC. if ACE lower, no control
agc_deadband = agc_deadband_in;

% time to stop for debugging
timefordebugstop=timefordebugstop_in;
debugcheck=debugcheck_in;

%Use integers for RTC. Should select yes unless troubleshooting.
USE_INTEGER = USE_INTEGER_in;

%NETWORK_CHECK = YES if network should be checked through program, NO if not.
%MUST BE CAPITAL YES OR NO.
NETWORK_CHECK = checkthenetwork;

%CONTINGENCY_CHECK = YES if contingencies should be checked through program,
%NO if not. MUST BE CAPITAL YES OR0 NO.
CONTINGENCY_CHECK = contingencycheck;

if strcmp(NETWORK_CHECK,'NO') == 1
    CONTINGENCY_CHECK = 'NO';
end;

%Simulate actual contingencies on system.
SIMULATE_CONTINGENCIES = SIMULATE_CONTINGENCIES_in;
%contingency input check. 0 if forced out randomly, 1 if input contingency
%info.
Contingency_input_check = Contingency_input_check_in;


