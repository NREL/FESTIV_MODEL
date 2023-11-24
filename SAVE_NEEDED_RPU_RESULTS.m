RPUBINDINGCOMMITMENT(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1) ;
RPUBINDINGCOMMITMENT(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
RPUBINDINGSHUTDOWN(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1) ;
RPUBINDINGSCHEDULE(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
RPUMARGINALLOSS(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
RPUBINDINGPUMPING(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
RPUBINDINGPUMPSCHEDULE(RPU_binding_interval_index,1) = RPU_LOOKAHEAD_INTERVAL_VAL(1,1);
RPUBINDINGCOMMITMENT(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:ngen+1) = round(RPUUNITSTATUS.val(:,:)');
RPUBINDINGPUMPING(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:ngen+1) = round(RPUPUMPING.val(:,:)');
RPUBINDINGSTARTUP(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:ngen+1) = round(RPUUNITSTARTUP.val(:,:)');
for rpu_int=1:HRPU
    STATUS(ceil(RPU_LOOKAHEAD_INTERVAL_VAL(rpu_int,1)*rtscuc_I_perhour) + 1,2:end) = round(RPUUNITSTATUS.val(:,rpu_int)');
    PUMPSTATUS(ceil(RPU_LOOKAHEAD_INTERVAL_VAL(rpu_int,1)*rtscuc_I_perhour) + 1,:) = round(RPUPUMPING.val(:,rpu_int)');
end;
RPUBINDINGSHUTDOWN(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:1+ngen) = round(RPUUNITSHUTDOWN.val(:,:)');
RPUBINDINGSCHEDULE(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:1+ngen) = RPUGENSCHEDULE.val(:,:)';
RPUBINDINGPUMPSCHEDULE(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2:1+nESR) = RPUPUMPSCHEDULE.val(:,:)';
RPUMARGINALLOSS(RPU_binding_interval_index:RPU_binding_interval_index + HRPU - 1,2) = marginalLoss(1,1);

UNIT_STARTINGUP_VAL = zeros(ngen,1);
for i=1:ngen
    if PREVIOUS_UNIT_STARTUP_VAL(i,1) == 1
        UNIT_STARTINGUP_VAL(i,1) = 1;
    end;
    if RPUBINDINGSTARTUP(RPU_binding_interval_index,1+i) == 1
        RTSCUC_INITIAL_START_TIME(i,1) = time;
        UNIT_STARTINGUP_VAL(i,1) = 1;
    end;
    if RPUBINDINGSHUTDOWN(RPU_binding_interval_index,1+i) == 1
        UNIT_SHUTTINGDOWN_VAL(i,1) = 1;
    end;
    if RPUBINDINGPUMPING(RPU_binding_interval_index,1+i) - PUMPSTATUS(RTSCUC_binding_interval_index-1,i) == 1;
        RTSCUC_INITIAL_PUMPUP_TIME(i,1) = time;
    end;
end;

for r=1:nreserve
    RPUBINDINGRESERVE(RPU_binding_interval_index,1:1+ngen,r) = [RPU_LOOKAHEAD_INTERVAL_VAL(1,1) RPUGENRESERVESCHEDULE.val(:,1,r)'];
end;
RPUBINDINGRESERVEPRICE(RTSCED_binding_interval_index,:) = [RPU_LOOKAHEAD_INTERVAL_VAL(1,1) RPURCP.val(:,1)'];

%Need to save whether a wind/PV is directed to curtail so it can
%follow those directions.
for i=1:ngen
    if RPUVGCURTAILMENT.val(i,1) > eps
        rtd_binding_vg_curtailment(i,1) = 1;
    else
        rtd_binding_vg_curtailment(i,1) = 0;
    end;
end;
DISPATCH(RTSCED_binding_interval_index-1,:) = RPUBINDINGSCHEDULE(RPU_binding_interval_index,:);
PUMPDISPATCH(RTSCED_binding_interval_index-1,:) = RPUBINDINGPUMPSCHEDULE(RPU_binding_interval_index,:);
RESERVE(RTSCED_binding_interval_index-1,:,:) = RPUBINDINGRESERVE(RPU_binding_interval_index,:,:);
RESERVEPRICE(RTSCED_binding_interval_index-1,:) = RPUBINDINGRESERVEPRICE(RPU_binding_interval_index,:);
