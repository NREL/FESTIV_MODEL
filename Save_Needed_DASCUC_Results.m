%Save all default needed DASCUC results 
%Schedules
DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCGENSCHEDULE.val)';
DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCPUMPSCHEDULE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nESR+1) = (SCUCPUMPSCHEDULE.val)';
DASCUCCOMMITMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1)=DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCCOMMITMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1)=SCUCUNITSTATUS.val';
for r=1:nreserve
    DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1,r)=DAC_LOOKAHEAD_INTERVAL_VAL;
    DASCUCRESERVE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1,r) = SCUCGENRESERVESCHEDULE.val(:,:,r)';
end;
%losses
DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCMARGINALLOSS((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2) = marginalLoss;
%prices
DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCLMP((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nbus+1) = SCUCLMP.val';
DASCUCRESERVEPRICE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL; 
DASCUCRESERVEPRICE((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nreserve+1) = SCUCRCP.val';
%other default
if nESR>0
DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1)=DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCSTORAGELEVEL((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:nESR+1)=SCUCSTORAGELEVEL.val';
end
DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,1) = DAC_LOOKAHEAD_INTERVAL_VAL;
DASCUCCURTAILMENT((DASCUC_binding_interval_index-1)*HDAC+1:HDAC+(DASCUC_binding_interval_index-1)*HDAC,2:ngen+1) = (SCUCVGCURTAILMENT.val)';

%Assign DASCUC Commitments
for h=1:NDACINTERVAL.val
    status_index=(DASCUC_binding_interval_index-1)*HDAC+h;
    STATUS(rtscuc_commitment_multiplier*(status_index)-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*(status_index)-1+1,1)=(DAC_LOOKAHEAD_INTERVAL_VAL(h):IRTC/60:DAC_LOOKAHEAD_INTERVAL_VAL(h)+IDAC-eps)';
    PUMPSTATUS(rtscuc_commitment_multiplier*(status_index)-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*(status_index)-1+1,1)=(DAC_LOOKAHEAD_INTERVAL_VAL(h):IRTC/60:DAC_LOOKAHEAD_INTERVAL_VAL(h)+IDAC-eps)';
    for i=1:ngen
        for h1 = 1:rtscuc_commitment_multiplier
            if round(SCUCUNITSTATUS.val(i,min(NDACINTERVAL.val,h+1)))-round(SCUCUNITSTATUS.val(i,h)) == 1
                startuptime_needed_index = min(0,max(rtscuc_commitment_multiplier-1,ceil(GENVALUE_VAL(i,su_time)*rtscuc_I_perhour)-1));
                STATUS(rtscuc_commitment_multiplier*(status_index)-rtscuc_commitment_multiplier+1,1+i) = round(SCUCUNITSTATUS.val(i,h));
                STATUS(rtscuc_commitment_multiplier*(status_index)-startuptime_needed_index+1:rtscuc_commitment_multiplier*(status_index)+1,1+i) ...
                    = round(SCUCUNITSTATUS.val(i,h+1));
            else
                STATUS(rtscuc_commitment_multiplier*(status_index)-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*(status_index)-1+1,1+i) ...
                    = round(SCUCUNITSTATUS.val(i,h));
            end;
            if round(SCUCPUMPING.val(i,min(NDACINTERVAL.val,h+1)))-round(SCUCPUMPING.val(i,h)) == 1
                startuptime_needed_index = min(0,max(rtscuc_commitment_multiplier-1,ceil(STORAGEVALUE_VAL(find(storage_to_gen_index==i),pump_su_time)*rtscuc_I_perhour)-1));
                PUMPSTATUS(rtscuc_commitment_multiplier*(status_index)-rtscuc_commitment_multiplier+1,1+i) = round(SCUCPUMPING.val(i,h));
                PUMPSTATUS(rtscuc_commitment_multiplier*(status_index)-startuptime_needed_index+1:rtscuc_commitment_multiplier*(status_index)-1+1,1+i) ...
                    = round(SCUCPUMPING.val(i,h+1));
            else
                PUMPSTATUS(rtscuc_commitment_multiplier*(status_index)-rtscuc_commitment_multiplier+1:rtscuc_commitment_multiplier*(status_index)-1+1,1+i) ...
                    = round(SCUCPUMPING.val(i,h));
            end;
        end;
    end;
end;

if lossesCheck > eps
    [DAC_BUS_DELIVERY_FACTORS_VAL,DAC_GEN_DELIVERY_FACTORS_VAL,DAC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HDAC,nbus,ngen,GEN_VAL,BRANCHBUS_CALC_VAL,PTDF_VAL,repmat(initialLineFlows,1,HDAC),SYSTEMVALUE_VAL(mva_pu,1),BRANCHDATA_VAL(:,resistance),INJECTION_FACTOR.uels,GENBUS_VAL,BUS_VAL,INJECTION_FACTOR_VAL,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    DAC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HDAC);
    DAC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HDAC);
    DAC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HDAC);
end
    

