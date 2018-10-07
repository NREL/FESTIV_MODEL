% Initialize delivery factors based on initial conditions
lossesCheck = sum(BRANCHDATA_VAL(:,resistance));
if lossesCheck > eps
    initPowerInj=zeros(nbus,1);    
    for i=1:size(GENBUS_STRING{1, 2},2)
        for c=1:size(GENBUS_VAL,1)
            if GENBUS_VAL(c,i) > 0
                for b=1:size(BUS_VAL,1)
                    if strcmp(GENBUS_STRING{1, 1}{c},BUS_VAL{b})
                        initPowerInj(b,1)=initPowerInj(b,1)+GENVALUE_VAL(strcmp(GENBUS_STRING{1, 2}{i},GEN_VAL),initial_MW)*INJECTION_FACTOR.val(c,i);
                    end
                end
            end
        end
    end
    initLoadDist=zeros(nbus,1);    
    for i=1:size(LOAD_DIST_STRING,1)
        initLoadDist(strcmp(LOAD_DIST_STRING{i},BUS_VAL))=LOAD_DIST_VAL(i)*DAC_LOAD_FULL(1,3);
    end
    initialLineFlows=PTDF_VAL*(initPowerInj-initLoadDist);
else
    initialLineFlows=zeros(nbranch,1);
end
if lossesCheck > eps
    [DAC_BUS_DELIVERY_FACTORS_VAL,DAC_GEN_DELIVERY_FACTORS_VAL,DAC_LOAD_DELIVERY_FACTORS_VAL]=calculateDeliveryFactors(HDAC,nbus,ngen,GEN_VAL,BRANCHBUS_CALC_VAL,PTDF_VAL,repmat(initialLineFlows,1,HDAC),SYSTEMVALUE_VAL(mva_pu,1),BRANCHDATA_VAL(:,resistance),INJECTION_FACTOR.uels,GENBUS_VAL,BUS_VAL,INJECTION_FACTOR.val,LOAD_DIST_VAL,LOAD_DIST_STRING);    
else
    DAC_BUS_DELIVERY_FACTORS_VAL  = ones(nbus,HDAC);
    DAC_GEN_DELIVERY_FACTORS_VAL  = ones(ngen,HDAC);
    DAC_LOAD_DELIVERY_FACTORS_VAL = ones(size(LOAD_DIST_VAL,1),HDAC);
end
