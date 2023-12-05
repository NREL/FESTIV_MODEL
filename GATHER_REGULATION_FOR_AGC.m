if isempty(regulation_up_index)
    REGULATION_UP = zeros(1,ngen+1);
else
    REGULATION_UP = sum(RESERVE(RTSCED_binding_interval_index-1,:,regulation_up_index),3);
end;
if isempty(regulation_down_index)
    REGULATION_DOWN = zeros(1,ngen+1);
else
    REGULATION_DOWN = sum(RESERVE(RTSCED_binding_interval_index-1,:,regulation_down_index),3);
end;
