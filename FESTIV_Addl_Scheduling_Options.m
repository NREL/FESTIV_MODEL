%Use Default Models
use_Default_DASCUC = 'YES';
use_Default_RTSCUC = 'YES';
use_Default_RTSCED = 'YES';
use_Default_SCRPU  = 'YES';
use_Default_AGC    = 'YES';

%How to define starts for RTSCUC
RTSCUCSTART_MODE_RTC = 1;
RTSCUCSTART_MODE_RPU = 2;

%Whether to stop with a breakpoint if there are any infeasibilities.
Stop_for_Infeasibilities = 1;

%ALFEE Monitoring
monitor_ALFEE = 0;

%Pump parameters. Fix_RT_Pump of 1 if the real-time RTSCUC fixes the PSH mode in
%real-time mode from the DASCUC solution
Fix_RT_Pump = 1;

reg_proportion = 2; %1 by ramp rate, 2 by reg schedule, 3 from model rule

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