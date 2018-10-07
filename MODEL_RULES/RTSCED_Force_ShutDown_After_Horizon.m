%Start reducing dispatch to avoid an infeasibility when shutdowns are beyond the RTSCED Horizon
%
%Before RTSCED
%

time_where_shutdown_needs_considering = (GENVALUE_VAL(:,capacity) - GENVALUE_VAL(:,min_gen))./GENVALUE_VAL(:,ramp_rate)+60.*GENVALUE_VAL(:,sd_time);%in minutes
REDUCE_OUTPUT_PREPARE_SHUTDOWN_VAL=zeros(ngen,HRTD);
for i=1:ngen
    if 60*(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-RTD_LOOKAHEAD_INTERVAL_VAL(1,1))< time_where_shutdown_needs_considering(i,1) && LAST_STATUS_VAL(i,1) == 1 ...
        && (RTSCUCSTART_YES(i,1)==0 ||  time_where_shutdown_needs_considering(i,1) < HRTC*IRTC)
    look_for_time_end = min(size(STATUS,1),ceil((time + time_where_shutdown_needs_considering(i,1)/60)*rtscuc_I_perhour-eps)+1); 
    if any(STATUS(RTSCUC_binding_interval_index:look_for_time_end,1+i) == 0)
        SDForce_time_shutdown = STATUS(RTSCUC_binding_interval_index + min(find(STATUS(RTSCUC_binding_interval_index:look_for_time_end,1+i)==0)) - 1,1);
        SDForce_time_Pmin = SDForce_time_shutdown - GENVALUE_VAL(i,sd_time);
        for t=1:HRTD
            if SDForce_time_Pmin < RTD_LOOKAHEAD_INTERVAL_VAL(t,1)
                REDUCE_OUTPUT_PREPARE_SHUTDOWN_VAL(i,t)=max(0,min(GENVALUE_VAL(i,capacity),(SDForce_time_shutdown - RTD_LOOKAHEAD_INTERVAL_VAL(t,1))*GENVALUE_VAL(i,min_gen)/GENVALUE_VAL(i,sd_time)));
            else
                REDUCE_OUTPUT_PREPARE_SHUTDOWN_VAL(i,t)=max(GENVALUE_VAL(i,min_gen),min(GENVALUE_VAL(i,capacity),(SDForce_time_Pmin - RTD_LOOKAHEAD_INTERVAL_VAL(t,1))*GENVALUE_VAL(i,ramp_rate)*60 + GENVALUE_VAL(i,min_gen)));
            end
        end
    end
    end
end
REDUCE_OUTPUT_PREPARE_SHUTDOWN_indices= find(any(REDUCE_OUTPUT_PREPARE_SHUTDOWN_VAL'>0)) ;
FORCE_SHUTDOWN_GEN_VAL = GEN_VAL(REDUCE_OUTPUT_PREPARE_SHUTDOWN_indices);

if isempty(FORCE_SHUTDOWN_GEN_VAL)
    FORCE_SHUTDOWN_GEN.val = 1;
    FORCE_SHUTDOWN_GEN.uels = {'NONE'};
else
    FORCE_SHUTDOWN_GEN.val = ones(size(FORCE_SHUTDOWN_GEN_VAL));
    FORCE_SHUTDOWN_GEN.uels = FORCE_SHUTDOWN_GEN_VAL';
end
FORCE_SHUTDOWN_GEN.name = 'FORCE_SHUTDOWN_GEN';
FORCE_SHUTDOWN_GEN.form = 'full';
FORCE_SHUTDOWN_GEN.type = 'set';

REDUCE_OUTPUT_PREPARE_SHUTDOWN.val = REDUCE_OUTPUT_PREPARE_SHUTDOWN_VAL./SYSTEMVALUE_VAL(mva_pu);
REDUCE_OUTPUT_PREPARE_SHUTDOWN.name = 'REDUCE_OUTPUT_PREPARE_SHUTDOWN';
REDUCE_OUTPUT_PREPARE_SHUTDOWN.form = 'full';
REDUCE_OUTPUT_PREPARE_SHUTDOWN.type = 'parameter';
REDUCE_OUTPUT_PREPARE_SHUTDOWN.uels = {GEN_VAL' INTERVAL_VAL'};

wgdx(['TEMP', filesep, 'Force_Shutdown_File'],FORCE_SHUTDOWN_GEN,REDUCE_OUTPUT_PREPARE_SHUTDOWN);
