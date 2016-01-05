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
PUMPUP_PERIOD_VAL=zeros(ngen,1);
PUMPDOWN_PERIOD_VAL=zeros(ngen,1);
INITIAL_STARTUP_PERIODS_VAL=zeros(ngen,1);
INTERVALS_STARTED_AGO_VAL=zeros(ngen,1);
STARTUP_MINGEN_HELPER_VAL=zeros(ngen,1);
INITIAL_PUMPUP_PERIODS_VAL=zeros(ngen,1);
INTERVALS_PUMPUP_AGO_VAL=zeros(ngen,1);
PUMPUP_MINGEN_HELPER_VAL=zeros(ngen,1);
UNIT_STATUS_VAL=zeros(ngen,HRTD);
UNIT_STARTINGUP_VAL=zeros(ngen,HRTD);
UNIT_SHUTTINGDOWN_VAL=zeros(ngen,HRTD);
PUMPING_VAL=zeros(ngen,HRTD);
UNIT_PUMPINGUP_VAL=zeros(ngen,HRTD);
UNIT_PUMPINGDOWN_VAL=zeros(ngen,HRTD);
UNIT_STARTUPMINGENHELP_VAL=zeros(ngen,1);
UNIT_PUMPUPMINGENHELP_VAL=zeros(ngen,1);
ALL_RAMP_UP_DUAL = [];
ALL_RAMP_PRICE = [];

% Execution Variables
sdcount=zeros(ngen,1);
pumpsdcount=zeros(ngen,1);
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
DASCUCPUMPSCHEDULE=zeros(1/IDAC*24*daystosimulate,ngen+1);
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
RTSCUCBINDINGPUMPSCHEDULE=zeros((60/IRTC*24*daystosimulate)+HRTC,ngen+1);
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
RTSCEDSTORAGELEVEL=zeros(60/IRTD*24*daystosimulate+1,ngen);
DISPATCH=zeros(60/IRTD*24*daystosimulate+1,ngen+1);
PUMPDISPATCH=zeros(60/IRTD*24*daystosimulate+1,ngen+1);
RESERVE=zeros(60/IRTD*24*daystosimulate+1,ngen+1,nreserve);
RESERVEPRICE=zeros(60/IRTD*24*daystosimulate+1,nreserve+1);
RTSCEDBINDINGSCHEDULE=zeros(60/IRTD*24*daystosimulate+1,ngen+1);
RTSCEDBINDINGPUMPSCHEDULE=zeros(60/IRTD*24*daystosimulate+1,ngen+1);
RTD_LF=zeros(60/IRTD*24*daystosimulate,nbranch); 
RTSCEDBINDINGRESERVE=zeros((60/IRTD*24*daystosimulate)+1,ngen+1,nreserve); 

% AGC Variables
AGC_SCHEDULE=zeros((60/t_AGC*60*24*daystosimulate),ngen+1);
ACTUAL_STORAGE_LEVEL=zeros((60/t_AGC*60*24*daystosimulate),ngen+1);
ACTUAL_GENERATION=zeros((60/t_AGC*60*24*daystosimulate),ngen+1);
ACTUAL_PUMP=zeros((60/t_AGC*60*24*daystosimulate),ngen+1);
ACE=zeros((60/t_AGC*60*24*daystosimulate),6);
storelosses=zeros(60/t_AGC*60*24*daystosimulate,1);