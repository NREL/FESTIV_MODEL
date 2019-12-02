%{
USE: AFTER RTSCUC
%}


if numberOfInfes ~= 0
    RTCUNITSTATUS.val = STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,:)';
    RTCPUMPING.val = PUMPSTATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,:)';
    RTCUNITSTARTUP.val = max(0,STATUS(RTSCUC_binding_interval_index:RTSCUC_binding_interval_index+HRTC-1,:)'- STATUS(RTSCUC_binding_interval_index-1:RTSCUC_binding_interval_index+HRTC-2,:)');
end;