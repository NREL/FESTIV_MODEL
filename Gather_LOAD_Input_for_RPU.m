LOAD_VAL = zeros(HRPU,1);
t = HRTD+1; 
rpu_int = 1;
if rtd_load_data_create == 1 %if getting from a file will do a weighted average of forecast and actual
while(t <= size_RTD_LOAD_FULL )
    if t+HRTD <= size_RTD_LOAD_FULL
    if(time/24 - RTD_LOAD_FULL(t,1) >= 0 && time/24 - RTD_LOAD_FULL(t+HRTD,1) < 0)
        RPU_data_create_weighting = max(0,(RTD_LOAD_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
        LOAD_VAL(1:HRPU,1) = RPU_data_create_weighting*ACTUAL_LOAD_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2) ...
            + (1 - RPU_data_create_weighting)*RTD_LOAD_FULL(t,3);
        rpu_int = rpu_int+1;
        t=size_RTD_LOAD_FULL;
    end;
    else
    if(time/24 - RTD_LOAD_FULL(t,1) >= 0)
        RPU_data_create_weighting = max(0,(RTD_LOAD_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
        LOAD_VAL(1:HRPU,1) = RPU_data_create_weighting*ACTUAL_LOAD_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2) ...
            + (1 - RPU_data_create_weighting)*RTD_LOAD_FULL(t,3);
        rpu_int = rpu_int+1;
        t=size_RTD_LOAD_FULL;
    end;
    end;
    t = t+1;
end;
elseif rtd_load_data_create == 2 %perfect RPU forecast
    for rpu_int=1:HRPU
        LOAD_VAL(rpu_int,1) = mean(ACTUAL_LOAD_FULL(min(size_ACTUAL_LOAD_FULL,min(size(ACTUAL_LOAD_FULL,1),max(1,AGC_interval_index + ...
        rpu_int*IRPU*(60/t_AGC)-ceil(IRPU*(60/t_AGC)/2)))):min(size_ACTUAL_LOAD_FULL,min(size(ACTUAL_LOAD_FULL,1),max(1,AGC_interval_index + rpu_int*IRPU*(60/t_AGC)+ceil(IRPU*(60/t_AGC)/2)))),2));
    end;
elseif rtd_load_data_create ==3 %persistence RPU forecast
    LOAD_VAL = ones(HRPU,1).*ACTUAL_LOAD_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2);
end;
