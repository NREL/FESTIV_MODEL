RTSCUCBINDINGCOMMITMENT(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGSHUTDOWN(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGLMP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCBINDINGRESERVESCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGRESERVEPRICE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGINSUFFICIENTRESERVE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGLOSSLOAD(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCBINDINGOVERGENERATION(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;
RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1) = RTC_LOOKAHEAD_INTERVAL_VAL ;

RTSCUCBINDINGCOMMITMENT(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCUNITSTATUS.val(:,:)');
RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCPUMPING.val(:,:)');
RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:ngen+1) = round(RTCUNITSTARTUP.val(:,:)');
if rtscucinterval_index+HRTC-1 > size(STATUS,1)
    STATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,1)=RTC_LOOKAHEAD_INTERVAL_VAL;
end
STATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,2:end) = round(RTCUNITSTATUS.val(:,:)');
PUMPSTATUS(rtscucinterval_index:rtscucinterval_index+HRTC-1,2:end) = round(RTCPUMPING.val(:,:)');
RTSCUCBINDINGSHUTDOWN(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = round(RTCUNITSHUTDOWN.val(:,:)');
RTSCUCBINDINGSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+ngen) = RTCGENSCHEDULE.val(:,:)';
RTSCUCBINDINGPUMPSCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+nESR) = RTCPUMPSCHEDULE.val(:,:)';
RTSCUCBINDINGLMP(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:1+nbus) = RTCLMP.val(:,:)';
for r=1:nreserve
    RTSCUCBINDINGRESERVESCHEDULE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,1:1+ngen,r) = [RTC_LOOKAHEAD_INTERVAL_VAL RTCGENRESERVESCHEDULE.val(:,:,r)'];
end;
RTSCUCBINDINGRESERVEPRICE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:nreserve+1) =  RTCRCP.val';
RTSCUCBINDINGINSUFFICIENTRESERVE(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2:nreserve+1) =  RTCINSUFFRESERVE.val;
RTSCUCBINDINGLOSSLOAD(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) =  RTCLOSSLOAD.val;
RTSCUCBINDINGOVERGENERATION(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) = OVERGENERATION;
RTSCUCMARGINALLOSS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index + HRTC - 1,2) = marginalLoss(1,1);

for i=1:ngen
    if RTSCUCBINDINGSTARTUP(RTSCUC_binding_interval_index,1+i) == 1
        if Solving_Initial_Models
            RTSCUC_INITIAL_START_TIME(i,1) = time - IRTC/60;
        else
            RTSCUC_INITIAL_START_TIME(i,1) = time; 
        end;
    end;
end;

for i=e:nESR
    if RTSCUCBINDINGPUMPING(RTSCUC_binding_interval_index,1+storage_to_gen_index(e,1)) - STORAGEVALUE_VAL(e,initial_pump_status) == 1
        if Solving_Initial_Models
            RTSCUC_INITIAL_PUMPUP_TIME(e,1) = time - IRTC/60;
        else
            RTSCUC_INITIAL_PUMPUP_TIME(e,1) = time;
        end;
    end;
end;

RTSCUCSTORAGELEVEL(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),1)=RTC_LOOKAHEAD_INTERVAL_VAL;
RTSCUCSTORAGELEVEL(RTSCUC_binding_interval_index:HRTC+(RTSCUC_binding_interval_index-1),2:nESR+1)=RTCSTORAGELEVEL.val';
if lossesCheck > eps
    [RTC_BUS_DELIVERY_FACTORS_VAL,RTC_GEN_DELIVERY_FACTORS_VAL,RTC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTC,nbus,ngen,GEN_VAL,BRANCHBUS_CALC_VAL,PTDF_VAL,repmat(initialLineFlows,1,HRTC),SYSTEMVALUE_VAL(mva_pu,1),BRANCHDATA_VAL(:,resistance),INJECTION_FACTOR.uels,GENBUS_VAL,BUS_VAL,INJECTION_FACTOR_VAL,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    RTC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTC);
    RTC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTC);
    RTC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTC);
end
