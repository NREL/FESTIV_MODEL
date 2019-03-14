clear RPU_INTERCHANGE_VAL;
INTERCHANGE_VAL=zeros(HRPU,max(1,ninterchange));
t = 1;
rpu_int = 1;
while(t <= size_RTD_RESERVE_FULL && RTD_INTERCHANGE_FULL(t,1)<= (time/24 +eps) && rpu_int <= HRPU)                
    if(abs(RTD_INTERCHANGE_FULL(t,1) - time/24) < IRTD/(60*24))
        INTERCHANGE_VAL(rpu_int,1:size(RTD_INTERCHANGE_FIELD,2)-2) = RTD_INTERCHANGE_FULL(t,3:end);
        rpu_int = rpu_int+1;
    end;
    t = t+1;
end;
