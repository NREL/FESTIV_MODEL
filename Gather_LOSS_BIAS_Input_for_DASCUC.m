if Solving_Initial_Models == 1
    LOSS_BIAS_VAL = 0;
else
    LOSS_BIAS_VAL = storelosses(max(1,AGC_interval_index-1),1)-mean(abs(DASCUCMARGINALLOSS((DASCUC_binding_interval_index-2)*HDAC+1:HDAC+(DASCUC_binding_interval_index-2)*HDAC,2)));
end
