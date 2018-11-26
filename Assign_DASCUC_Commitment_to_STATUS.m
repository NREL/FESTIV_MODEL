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
