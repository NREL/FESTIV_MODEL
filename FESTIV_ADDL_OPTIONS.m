%Use Default Sub-Models. If "NO" then FESTIV will skip the running of the
%sub-model, and if an additional sub-model is used in its place (e.g., from
%a different program other than GAMS), then a functional mod must be put in
%place either before or after the sub-model.
use_Default_DASCUC = 'YES';
use_Default_RTSCUC = 'YES';
use_Default_RTSCED = 'YES';
use_Default_SCRPU  = 'YES';
use_Default_AGC    = 'YES';

%How to define starts for RTSCUC. RTC Default is 1, RPU default is 2. Any
%other value is user-defined, and requires modification to RTSCUCSTART.m.
RTSCUCSTART_MODE_RTC = 1;
RTSCUCSTART_MODE_RPU = 2;

%How to define how an RPU is triggered. Default is 1. Any other value is
%user-defined and requires modification to RPU_TRIGGER.m.
RPU_TRIGGER_MODE = 1;

%Whether to stop with a breakpoint if there are any infeasibilities.
Stop_for_Infeasibilities = 1;

%Absolute Line Flow Exceedance in Energy (ALFEE) Monitoring. ALFEE
%calculations can take substantial computation time and should only be
%monitored if a focus is to look at the exceedance in actual time
%resolution.
monitor_ALFEE = 0;

%Pump parameters. Fix_RT_Pump of 1 if the real-time RTSCUC fixes the PSH (GEN_TYPE = 6) mode in
%real-time mode from the DASCUC solution. A value of 0 allows for RTSCUC to
%modify the commitment of the PSH from the DASCUC solution.
Fix_RT_Pump = 1;

reg_proportion = 2; %1 by ramp rate, 2 by reg schedule, 3 from model rule

%Settlement Options
DA2RTInterval_Lining = 2;
RT2ACTInterval_Lining = 3;
%{
1: Real-time intervals balance schedule with day-ahead from top of
interval. Ex. if hourly DASCUC, 1:05, 1:10... 1:55, 2:00 real-time 
intervals balance off 1:00 DASCUC interval.
2: Real-time intervals balance schedule with day-ahead from middle of
interval. Ex. if hourly DASCUC, 0:35, 0:40, 0:45... 1:25, 1:30 real-time 
intervals balance off 1:00 DASCUC interval.
3: Real-time intervals balance schedule with day-ahead from bottom of
interval. Ex. if hourly DASCUC, 0:05, 0:10, 0:15... 0:50, 0:55 real-time 
intervals balance off 1:00 DASCUC interval.
Similar cases are for actual intervals aligning to real-time dispatch.
%}
max_price = 1000; %This caps the price only for settlement purposes.

%Forecast error when using forecast creation type of 4, in % actual
%Note that these are the standard deviation based on the energy level
%for example if value is .1, then forecast is actual + randn()*.1*actual
dac_vg_error = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
dac_load_error = [0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0 0]';
rtc_vg_error = [0 0 0 0 0 0 0 0 0 0]';
rtc_load_error = [0 0 0 0 0 0 0 0 0 0]';
rtd_vg_error = [0 0 0 0 0]';
rtd_load_error = [0 0 0 0 0]';

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