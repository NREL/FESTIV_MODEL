% GAMS Variables
GEN_FORCED_OUT_VAL=zeros(ngen,1);
UNIT_STATUS_ENFORCED_ON_VAL=zeros(ngen,HRTC);
PUMPING_ENFORCED_ON_VAL=zeros(ngen,HRTC);
UNIT_STATUS_ENFORCED_OFF_VAL=zeros(ngen,HRTC);
PUMPING_ENFORCED_OFF_VAL=zeros(ngen,HRTC);
RAMP_SLACK_UP_VAL=zeros(ngen,1);
RAMP_SLACK_DOWN_VAL=zeros(ngen,1);
STARTUP_PERIOD_VAL=zeros(ngen,1);
SHUTDOWN_PERIOD_VAL=zeros(ngen,1);
PUMPUP_PERIOD_VAL=zeros(nESR,1);
PUMPDOWN_PERIOD_VAL=zeros(nESR,1);
PREVIOUS_UNIT_STARTUP_VAL=zeros(ngen,1);
INTERVALS_STARTED_AGO_VAL=zeros(ngen,1);
STARTUP_MINGEN_HELPER_VAL=zeros(ngen,1);
PREVIOUS_UNIT_PUMPUP_VAL=zeros(nESR,1);
INTERVALS_PUMPUP_AGO_VAL=zeros(nESR,1);
PUMPUP_MINGEN_HELPER_VAL=zeros(nESR,1);
UNIT_STATUS_VAL=zeros(ngen,HRTD);
UNIT_STARTINGUP_VAL=zeros(ngen,HRTD);
UNIT_SHUTTINGDOWN_VAL=zeros(ngen,HRTD);
PUMPING_VAL=zeros(ngen,HRTD);
UNIT_PUMPINGUP_VAL=zeros(nESR,HRTD);
UNIT_PUMPINGDOWN_VAL=zeros(nESR,HRTD);
UNIT_STARTUPMINGENHELP_VAL=zeros(nESR,1);
UNIT_PUMPUPMINGENHELP_VAL=zeros(nESR,1);
ACTUAL_GEN_OUTPUT_VAL=zeros(ngen,1);
LAST_GEN_SCHEDULE_VAL=zeros(ngen,1);
LAST_STATUS_VAL=zeros(ngen,1);  
LAST_STATUS_ACTUAL_VAL=zeros(ngen,1); 
ACTUAL_PUMP_OUTPUT_VAL =zeros(nESR,1);
LAST_PUMP_SCHEDULE_VAL =zeros(nESR,1);   
LAST_PUMPSTATUS_VAL=zeros(nESR,1);
LAST_PUMPSTATUS_ACTUAL_VAL=zeros(nESR,1);
RTDFINALSTORAGEIN=[];
RTCFINALSTORAGEIN=[];

% Execution Variables
sdcount=zeros(ngen,1);
pumpsdcount=zeros(nESR,1);
delayedshutdown=zeros(ngen,1);
delayedpumpdown=zeros(ngen,1);
delayedrtcindex=zeros(ngen,1);
numberofintervals=zeros(ngen,1);
totaltime=zeros(ngen,1);
indexofunitsSD=zeros(ngen,1);
indexofunitsSD2=zeros(ngen,1);
rtctotaltime=zeros(ngen,1);
rtctotalramp=zeros(ngen,1);
rtcminimumpossible=zeros(ngen,1);

% DASCUC Variables
DASCUCSCHEDULE=zeros(1/IDAC*24*daystosimulate,ngen+1);
DASCUCMARGINALLOSS=zeros(1/IDAC*24*daystosimulate,2);
DASCUCPUMPSCHEDULE=zeros(1/IDAC*24*daystosimulate,nESR+1);
DASCUCLMP=zeros(1/IDAC*24*daystosimulate,nbus+1);
DASCUCRESERVE=zeros(1/IDAC*24*daystosimulate,ngen+1,nreserve);
DASCUCRESERVEPRICE=zeros(1/IDAC*24*daystosimulate,nreserve+1);
RESERVELEVELS=zeros(1/IDAC*24*daystosimulate,nreserve);
DASCUCCURTAILMENT=zeros(1/IDAC*24*daystosimulate,ngen+1);
PSHBIDCOST_VAL=zeros(1/IDAC*24*daystosimulate,ngen);
DASCUCSTORAGELEVEL=zeros(1/IDAC*24*daystosimulate,ngen+1);

% RTSCUC Variables
RTSCUCBINDINGSTARTUP=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTSCUCBINDINGCOMMITMENT=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTSCUCBINDINGSCHEDULE=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTSCUCBINDINGPUMPING=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTSCUCBINDINGSHUTDOWN=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTSCUCBINDINGPUMPSCHEDULE=zeros((60/IRTC*24*daystosimulate)+HRTC,nESR+1);
RTSCUCBINDINGLMP=zeros((60/IRTC*24*daystosimulate)+HRTC,nbus+1);
RTSCUCSTORAGELEVEL2=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTPSHBIDCOST_VAL=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
RTSCUCBINDINGRESERVESCHEDULE=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1,nreserve);
RTSCUCBINDINGRESERVEPRICE=zeros((60/IRTC*24*daystosimulate)+HRTC,nreserve+1);
RTSCUCBINDINGINSUFFICIENTRESERVE=zeros((60/IRTC*24*daystosimulate)+HRTC,nreserve+1);
RTSCUCBINDINGLOSSLOAD=zeros((60/IRTC*24*daystosimulate)+HRTC,2);
RTSCUCBINDINGOVERGENERATION=zeros((60/IRTC*24*daystosimulate)+HRTC,2);
RTSCUCMARGINALLOSS=zeros((60/IRTC*24*daystosimulate)+HRTC,2);

% RTSCED Variables
RTSCEDBINDINGMCC=zeros(60/IRTD*24*daystosimulate+1,nbus+1);
RTSCEDBINDINGMLC=zeros(60/IRTD*24*daystosimulate+1,nbus+1);
RTSCEDBINDINGLMP=zeros(60/IRTD*24*daystosimulate+1,nbus+1);
RTSCEDBINDINGRESERVEPRICE=zeros(60/IRTD*24*daystosimulate+1,nreserve+1);
RTSCEDBINDINGLOSSLOAD=zeros(60/IRTD*24*daystosimulate+1,2);
RTSCEDBINDINGINSUFFICIENTRESERVE=zeros(60/IRTD*24*daystosimulate+1,nreserve+1);
RTSCEDBINDINGOVERGENERATION=zeros(60/IRTD*24*daystosimulate+1,2);
RTSCEDMARGINALLOSS=zeros(60/IRTD*24*daystosimulate+1,2);
RTSCEDSTORAGELEVEL=zeros(60/IRTD*24*daystosimulate+1,nESR+1);
DISPATCH=zeros(60/IRTD*24*daystosimulate+1,ngen+1);
PUMPDISPATCH=zeros(60/IRTD*24*daystosimulate+1,nESR+1);
RESERVE=zeros(60/IRTD*24*daystosimulate+1,ngen+1,nreserve);
RESERVEPRICE=zeros(60/IRTD*24*daystosimulate+1,nreserve+1);
RTSCEDBINDINGSCHEDULE=zeros(60/IRTD*24*daystosimulate+1,ngen+1);
RTSCEDBINDINGPUMPSCHEDULE=zeros(60/IRTD*24*daystosimulate+1,nESR+1);
RTD_LF=zeros(60/IRTD*24*daystosimulate,nbranch); 
RTSCEDBINDINGRESERVE=zeros((60/IRTD*24*daystosimulate)+1,ngen+1,nreserve); 

% AGC Variables
AGC_SCHEDULE=zeros((60/t_AGC*60*24*daystosimulate),ngen+1);
ACTUAL_STORAGE_LEVEL=zeros((60/t_AGC*60*24*daystosimulate),nESR+1);
ACTUAL_GENERATION=zeros((60/t_AGC*60*24*daystosimulate),ngen+1);
ACTUAL_PUMP=zeros((60/t_AGC*60*24*daystosimulate),nESR+1);
ACE=zeros((60/t_AGC*60*24*daystosimulate),6);
storelosses=zeros(60/t_AGC*60*24*daystosimulate,1);
ACTUAL_START_TIME = inf.*ones(ngen,1);
ACTUAL_PUMPUP_TIME = inf.*ones(nESR,1);

%Starting off the day
DASCUC_binding_interval_index = 1;
RTSCUC_binding_interval_index = 1;
RTSCED_binding_interval_index = 1;
RPU_binding_interval_index = 1;
dascuc_running = 0;
rtscuc_running = 0;
rtsced_running = 0;
rpu_running = 0;
day_beginning = 0;
hour_beginning = 0;
minute_beginning = 0;
second_beginning = 0;
start_time = hour_beginning + minute_beginning/60 + second_beginning/3600;
hour = hour_beginning;
minute = minute_beginning;
second = second_beginning;
day = day_beginning;
time = start_time;


%gams run commands
DASCUC_GAMS_CALL = ['gams ..', filesep, 'DASCUC.gms Lo=2 Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USE_INTEGER="',USE_INTEGER,'" --USE_DEFAULT="',use_Default_DASCUC,'" --USEGAMS="',USEGAMS,'"', gams_mip_flag];
RTSCUC_GAMS_CALL = ['gams ..', filesep, 'RTSCUC.gms Lo=2 Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USE_INTEGER="',USE_INTEGER,'" --USEGAMS="',USEGAMS,'"', gams_mip_flag];
RTSCED_GAMS_CALL = ['gams ..', filesep, 'RTSCED.gms Lo=2 Cdir="',DIRECTORY,'TEMP" --DIRECTORY="',DIRECTORY,'" --INPUT_FILE="',inputPath,'" --NETWORK_CHECK="',NETWORK_CHECK,'" --CONTINGENCY_CHECK="',CONTINGENCY_CHECK,'" --USEGAMS="',USEGAMS,'"', gams_lp_flag];

rtscuc_commitment_multiplier = max(1,floor(60*IDAC/IRTC));
rtscuc_I_perhour = floor(60/IRTC);

rtscuc_debug=0;
