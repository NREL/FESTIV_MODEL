tStart = tic;
DIRECTORY = [pwd,filesep];
%add path for unique model characteristics.
addpath(strcat(DIRECTORY,filesep, 'MODEL_RULES'));  %savepath; 

[pathstr, name, ext] = fileparts(inputPath);
inputfilename=strcat(name,ext);
%Suppress singular matrix warning
warning('off','MATLAB:singularMatrix')

%VG AND LOAD DATA
fprintf('Input File: %s\n',inputfilename);
fprintf('Reading Input Files...')
%actuals
if useHDF5==0
    [~, actual_load_input_file] = xlsread(inputPath,'ACTUAL_LOAD_REF','A2:A400');
    for d=1:size(actual_load_input_file,1)
        actual_load_input_file(d,1)=strcat(pathstr, filesep, 'TIMESERIES', filesep,actual_load_input_file(d,1));
    end;
    [~, actual_vg_input_file] = xlsread(inputPath,'ACTUAL_VG_REF','A2:A400');
    for d=1:size(actual_vg_input_file,1)
        actual_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,actual_vg_input_file(d,1));
    end;
end

%DASCUC inputs
if useHDF5==0
    try
        [~, dac_load_input_file] = xlsread(inputPath,'DA_LOAD_REF','A2:A400');
        for d=1:size(dac_load_input_file,1)
            dac_load_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,dac_load_input_file(d,1));
        end;
    catch
        dac_load_input_file = 0;
    end;
    try
        [~, dac_vg_input_file] = xlsread(inputPath,'DA_VG_REF','A2:A400');
        for d=1:size(dac_vg_input_file,1)
            dac_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,dac_vg_input_file(d,1));
        end;
    catch
        dac_vg_input_file = 0;
    end;
end
%1 - from data file, 2 create perfect forecast, 3 create persistence
%forecast, 4 with predefined normally distributed error
dac_load_data_create = DAC_load_forecast_data_create_in;
dac_vg_data_create = DAC_vg_forecast_data_create_in;

%for using 4. Size must be = HDAC;
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual
dac_vg_error = ones(24,1).*0;
dac_load_error = [0 0 0 0 0 0 0 0 0 0]';

%RTSCUC inputs
if useHDF5==0
    try
        [~, rtc_load_input_file] = xlsread(inputPath,'RTC_LOAD_REF','A2:A400');
        for d=1:size(rtc_load_input_file,1)
            rtc_load_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtc_load_input_file(d,1));
        end;
    catch
        rtc_load_input_file = 0;
    end;
    try
        [~, rtc_vg_input_file] = xlsread(inputPath,'RTC_VG_REF','A2:A400');
        for d=1:size(rtc_vg_input_file,1)
            rtc_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtc_vg_input_file(d,1));
        end;
    catch
        rtc_vg_input_file = 0;
    end;
end
%1 - from data file, 2 create perfect forecast, 3 create persistence
%forecast, 4 with predefined normally distributed error
rtc_load_data_create = RTC_load_forecast_data_create_in;
rtc_vg_data_create = RTC_vg_forecast_data_create_in;

%for using 4. Size must be = HRTC;
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual
rtc_vg_error = [0 0.05 0.05 0.06 0.07 0.08 0.08 0.08 0.1 0.1]';
rtc_load_error = [0 0 0 0 0 0 0 0 0 0]';

%RTSCED inputs
if useHDF5==0
    try
        [~, rtd_load_input_file] = xlsread(inputPath,'RTD_LOAD_REF','A2:A400');
        for d=1:size(rtd_load_input_file,1)
            rtd_load_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtd_load_input_file(d,1));
        end;
    catch
        rtd_load_input_file = 0;
    end;
    try
        [~, rtd_vg_input_file] = xlsread(inputPath,'RTD_VG_REF','A2:A400');
        for d=1:size(rtd_vg_input_file,1)
            rtd_vg_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtd_vg_input_file(d,1));
        end;
    catch
        rtd_vg_input_file = 0;
    end;
end
%rtd_load_input_file = 'rtd_load_5bus_ERCOT_scaled_1_1_08.xlsx';
%rtd_vg_input_file = 'rtd_wind_118bus_75.xlsx';
%1 - from data file, 2 create perfect forecast, 3 create persistence
%forecast, 4 with predefined normally distributed error
rtd_load_data_create = RTD_load_forecast_data_create_in;
rtd_vg_data_create = RTD_vg_forecast_data_create_in;

%for using 4. Size must be = HRTD
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual
rtd_vg_error = [0 0 0 0 0]';
rtd_load_error = [0 0 0 0 0]';

%Reserve inputs
if useHDF5==0
    try
        [~,dac_reserve_input_file]= xlsread(inputPath,'DA_RESERVE_REF','A2:A400');
        for d=1:size(dac_reserve_input_file,1)
            dac_reserve_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,dac_reserve_input_file(d,1));
        end;
    catch
        dac_reserve_input_file=0;
    end;
    try
        [~,rtc_reserve_input_file]= xlsread(inputPath,'RTC_RESERVE','A2:A400');
        for d=1:size(rtc_reserve_input_file,1)
            rtc_reserve_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtc_reserve_input_file(d,1));
        end;
    catch
        rtc_reserve_input_file=0;
    end;
    try
        [~,rtd_reserve_input_file] = xlsread(inputPath,'RTD_RESERVE','A2:A400');
        for d=1:size(rtd_reserve_input_file,1)
            rtd_reserve_input_file(d,1)=strcat(pathstr,filesep, 'TIMESERIES', filesep,rtd_reserve_input_file(d,1));
        end;
    catch
        rtd_reserve_input_file=0;
    end;
end

DAC_RESERVE_FORECAST_MODE=DAC_RESERVE_FORECAST_MODE_in;
RTC_RESERVE_FORECAST_MODE=RTC_RESERVE_FORECAST_MODE_in;
RTD_RESERVE_FORECAST_MODE=RTD_RESERVE_FORECAST_MODE_in;

%%%                     INITIALIZATION                                  %%%

%How long the simulation is run for
day_beginning = 0;
hour_beginning = 0;
minute_beginning = 0;
second_beginning = 0;
start_time = hour_beginning + minute_beginning/60 + second_beginning/3600;

%NOTE THAT FOR DA TIMING PARAMETERS, THE DATA IN THE ORIGINAL SPREADSHEET
%NEEDS TO BE ADJUSTED, UNLIKE REAL-TIME PARAMETERS
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
DAHORIZON:
(1) Fixed Horizon, variable endpoint, variable startpoint
(2)Fixed Endpoint, fixed startpoint, this will always start at hour 0
(3)Fixed endpoint, variable startpoint horizon greater than or equal,
(4)Fixed endpoint, variable startpoint, horizon less than or equal.
%}
tDAC = tDAC_in;
IDAC = IDAC_in;
HDAC = HDAC_in;
PDAC = PDAC_in;
GDAC = GDAC_in;
DAHORIZONTYPE = DAHORIZONTYPE_in;

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
HRTD = HRTD_in;  %number of intervals in optimization horizon.
IRTD = IRTD_in;
tRTD = tRTD_in;
IRTDADV = IRTDADV_in; %Note that advisory length must be greater than or equal to rtd interval length.
PRTD = PRTD_in;

%{
trtc: time between updates of RTSCUC
Irtc: time resolution of first interval of RTSCUC
Prtc: time it takes to solve RTSCUC
Hrtc: amount of intervals in RTSCUC optimization horizon
Notes:
%}
HRTC = HRTC_in;  %number of intervals in optimization horizon.
IRTC = IRTC_in;
tRTC = tRTC_in;
PRTC = PRTC_in;
%trtcstart: For what units are allowed to be started by RTC in hours.
%Could also use an equation with interval length and nrtcinterval.
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

%tagc
%t_AGC = tAGC_in; %Make sure this aligns with your vg and load data

%How is AGC performed
%{
    1: Blind AGC, no AGC, only ramping dispatch using interpolation from one RTD to next.
    2: Fast AGC, AGC based on raw ACE. Follow instantaneous ACE
    3: Smooth AGC, AGC with filter and integrator. Follow ACE but filter to ignore noise, and integrate to follow if persistent deviation. (still needs work)
    4: Lazy AGC, AGC optimal CPS2 compliance, only follow if CPS2 will be violated. combination of 1 and 3.
    5: Use gen specific modes
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
%ALFEE Monitoring
monitor_ALFEE = 0;

%Pump parameters. Fix_RT_Pump of 1 if the real-time RTSCUC fixes the PSH mode in
%real-time mode from the DASCUC solution
Fix_RT_Pump = 1;

%Dispatch Schedule Type (CURRENTLY NOT COMPLETE)
%{
1: normal for dispatch that ramps continuously to meet schedule.
2: ramp to schedule early and stay, like how is done in WECC
%}
Dispatch_Schedule_Type = 2;
Dispatch_Schedule_Type2_begin = 10;
Dispatch_Schedule_Type2_end = 10;

%Printing results kills a lot of time. For now use this to say whether or
%not you would like to have all results thrown onto excel spreadsheet. Test
%inputs inside the loop would be a much timelier method if only certain
%results are of interest. At end of simulation there is chance to print
%only binding results.
RTCPrintResults = 0;
RTDPrintResults = 0;

eps = 0.0000001;
