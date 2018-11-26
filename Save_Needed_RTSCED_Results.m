RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,1:1+ngen) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDGENSCHEDULE.val(:,1)'];
RTSCEDBINDINGLMP(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDLMP.val(:,1)'];
RTSCEDBINDINGMCC(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) MCC(:,1)'];
RTSCEDBINDINGMLC(RTSCED_binding_interval_index,1:1+nbus) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) MLC(:,1)'];
RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index,1:1+nESR) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDPUMPSCHEDULE.val(:,1)'];

for r=1:nreserve
    RTSCEDBINDINGRESERVE(RTSCED_binding_interval_index,1:1+ngen,r) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDGENRESERVESCHEDULE.val(:,1,r)'];
end;
RTSCEDBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDRCP.val(:,1)'];
RTSCEDBINDINGLOSSLOAD(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDLOSSLOAD.val(1,1)'];
RTSCEDBINDINGINSUFFICIENTRESERVE(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDINSUFFRESERVE.val(1,:)];
RTSCEDBINDINGOVERGENERATION(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) OVERGENERATION(1,1)'];
RTSCEDMARGINALLOSS(RTSCED_binding_interval_index,:) = [RTD_LOOKAHEAD_INTERVAL_VAL(1,1) marginalLoss(1,1)];

if max(rpu_time) >= time - PRTD/60 && max(rpu_time) < time
else
PUMPDISPATCH(RTSCED_binding_interval_index,:) = RTSCEDBINDINGPUMPSCHEDULE(RTSCED_binding_interval_index,:);
DISPATCH(RTSCED_binding_interval_index,:) = RTSCEDBINDINGSCHEDULE(RTSCED_binding_interval_index,:);
RESERVE(RTSCED_binding_interval_index,:,:) = RTSCEDBINDINGRESERVE(RTSCED_binding_interval_index,:,:);
RESERVEPRICE(RTSCED_binding_interval_index,:) = RTSCEDBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:);
end;

RTSCEDSTORAGELEVEL(RTSCED_binding_interval_index,1:nESR+1)=[RTD_LOOKAHEAD_INTERVAL_VAL(1,1) RTDSTORAGELEVEL.val(:,1)'];

if lossesCheck > eps
    [RTD_BUS_DELIVERY_FACTORS_VAL,RTD_GEN_DELIVERY_FACTORS_VAL,RTD_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HRTD,nbus,ngen,GEN_VAL,BRANCHBUS_CALC_VAL,PTDF_VAL,repmat(initialLineFlows,1,HRTD),SYSTEMVALUE_VAL(mva_pu,1),BRANCHDATA_VAL(:,resistance),INJECTION_FACTOR.uels,GENBUS_VAL,BUS_VAL,INJECTION_FACTOR_VAL,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    RTD_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HRTD);
    RTD_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HRTD);
    RTD_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HRTD);
end

%need to know if the vg was directed to be curtailed
binding_vg_curtailment = zeros(ngen,1); %Iniitialize here
for i=1:ngen
    if RTDVGCURTAILMENT.val(i,1) > eps && (GENVALUE_VAL(i,gen_type) == wind_gen_type_index || GENVALUE_VAL(i,gen_type) == PV_gen_type_index)
        binding_vg_curtailment(i,1) = 1;
    else
        binding_vg_curtailment(i,1) = 0;
    end;
end;

