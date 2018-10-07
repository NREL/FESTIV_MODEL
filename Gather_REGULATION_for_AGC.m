if regulation_up_index == 0
    REGULATION_UP = zeros(1,ngen+1);
else
    REGULATION_UP = RESERVE(RTSCED_binding_interval_index-1,:,regulation_up_index);
end;
if regulation_down_index == 0
    REGULATION_DOWN = zeros(1,ngen+1);
else
    REGULATION_DOWN = RESERVE(RTSCED_binding_interval_index-1,:,regulation_down_index);
end;
