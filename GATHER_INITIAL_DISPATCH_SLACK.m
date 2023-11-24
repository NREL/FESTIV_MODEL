if rtscuc_running
if RTSCUC_binding_interval_index == 1
    INITIAL_DISPATCH_SLACK_VAL = [1;1];
elseif RTSCUC_binding_interval_index == 2
    INITIAL_DISPATCH_SLACK_VAL = [1;0];
else
    INITIAL_DISPATCH_SLACK_VAL = [0;0];
end
elseif rtsced_running
if RTSCED_binding_interval_index == 1
    INITIAL_DISPATCH_SLACK_VAL = [1;1];
elseif RTSCED_binding_interval_index == 2
    INITIAL_DISPATCH_SLACK_VAL = [1;0];
else
    INITIAL_DISPATCH_SLACK_VAL = [0;0];
end
end

