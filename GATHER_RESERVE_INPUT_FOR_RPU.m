clear RESERVELEVEL_VAL
t = HRTD+1;
rpu_int = 1;
while(t <= size_RTD_RESERVE_FULL && RTD_RESERVE_FULL(t,1)<= (time/24 +eps) && rpu_int <= HRPU)                
    if(abs(RTD_RESERVE_FULL(t,1) - time/24) < IRTD/(60*24))
        RESERVELEVEL_VAL(rpu_int,1:size(RTD_RESERVE_FIELD,2)-2) = RTD_RESERVE_FULL(t,3:end);
        rpu_int = rpu_int+1;
    end;
    t = t+1;
end;
if rpu_int <= HRPU
    for t=rpu_int:HRPU
        RESERVELEVEL_VAL = [RESERVELEVEL_VAL; RESERVELEVEL_VAL(rpu_int-1,:)];
    end;
end;
