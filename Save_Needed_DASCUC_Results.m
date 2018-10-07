    DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCGENSCHEDULE.val)';
    DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2) = marginalLoss;

    DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nESR+1) = (SCUCPUMPSCHEDULE.val)';
    DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nbus+1) = SCUCLMP.val';
    DASCUCCOMMITMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1)=DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCCOMMITMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1)=SCUCUNITSTATUS.val';
    for r=1:nreserve
        DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1,r)=DAC_LOOKAHEAD_INTERVAL_VAL;
        DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1,r) = SCUCGENRESERVESCHEDULE.val(:,:,r)';
    end;
    DASCUCRESERVEPRICE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL; 
    DASCUCRESERVEPRICE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nreserve+1) = SCUCRCP.val';
    DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1)=DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nESR+1)=SCUCSTORAGELEVEL.val';
    DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCVGCURTAILMENT.val)';

    if lossesCheck > eps
        [DAC_BUS_DELIVERY_FACTORS_VAL,DAC_GEN_DELIVERY_FACTORS_VAL,DAC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HDAC,nbus,ngen,GEN_VAL,BRANCHBUS_CALC_VAL,PTDF_VAL,repmat(initialLineFlows,1,HDAC),SYSTEMVALUE_VAL(mva_pu,1),BRANCHDATA_VAL(:,resistance),INJECTION_FACTOR.uels,GENBUS_VAL,BUS_VAL,INJECTION_FACTOR_VAL,LOAD_DIST_VAL,LOAD_DIST_STRING);    
    else
        DAC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HDAC);
        DAC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HDAC);
        DAC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HDAC);
    end


