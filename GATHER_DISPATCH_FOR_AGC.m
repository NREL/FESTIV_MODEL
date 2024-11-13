j=RTSCED_binding_interval_index-2;
if time > DISPATCH(RTSCED_binding_interval_index-1,1)
    while j>=1
        if DISPATCH(j,1) > time
            next_RTD = DISPATCH(j,:);
            previous_RTD = DISPATCH(max(1,j-1),:);
            next_pump_RTD = [PUMPDISPATCH(j,1) -1.*PUMPDISPATCH(j,2:end)];
            previous_pump_RTD = [PUMPDISPATCH(j-1,1) -1.*PUMPDISPATCH(j-1,2:end)];
            j=0;
        else
            j=j-1;
        end
    end
else
    next_RTD = DISPATCH(RTSCED_binding_interval_index-1,:);
    previous_RTD = DISPATCH(max(1,j),:);
    next_pump_RTD = [PUMPDISPATCH(RTSCED_binding_interval_index-1,1) -1.*PUMPDISPATCH(RTSCED_binding_interval_index-1,2:end)];
    previous_pump_RTD = [PUMPDISPATCH(max(1,j),1) -1.*PUMPDISPATCH(max(1,j),2:end)];
end
