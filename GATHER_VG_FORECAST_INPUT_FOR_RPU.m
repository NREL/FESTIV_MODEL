t=HRTD+1;
rpu_int=1;
if nvcr > 0
    if rtd_vg_data_create == 1 %if getting from a file will do a weighted average of forecast and actual
    while(t <= size_RTD_VG_FULL )
        if t+HRTD <= size_RTD_VG_FULL
        if(time/24 - RTD_VG_FULL(t,1) >= 0 && time/24 - RTD_VG_FULL(t+HRTD,1) < 0)
            RPU_data_create_weighting = max(0,(RTD_VG_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
            vg_forecast_tmp(1:HRPU,:) = ones(HRPU,1)*(RPU_data_create_weighting.*max(0,ACTUAL_VG_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2:end)) ...
                + (1 - RPU_data_create_weighting).*RTD_VG_FULL(t,3:3+nvg-1));
            rpu_int = rpu_int+1;
            t=size_RTD_VG_FULL;
        end;
        else
        if(time/24 - RTD_VG_FULL(t,1) >= 0 )
            RPU_data_create_weighting = max(0,(RTD_VG_FULL(t,2) - (time/24+IRPU/24/60))/(tRTD/60/24));
            vg_forecast_tmp(1:HRPU,:) = ones(HRPU,1)*(RPU_data_create_weighting.*max(0,ACTUAL_VG_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2:end)) ...
                + (1 - RPU_data_create_weighting).*RTD_VG_FULL(t,3:3+nvg-1));
            rpu_int = rpu_int+1;
            t=size_RTD_VG_FULL;
        end;
        end;
        t = t+1;
    end;
    elseif rtd_vg_data_create == 2%perfect RPU forecast
        for rpu_int=1:HRPU
            vg_forecast_tmp(rpu_int,:) = mean(max(0,ACTUAL_VG_FULL(min(size_ACTUAL_VG_FULL,min(size(ACTUAL_VG_FULL,1),max(1,round(AGC_interval_index + ...
            rpu_int*IRPU*(60/t_AGC)-IRPU*(60/t_AGC)/2)))):min(size_ACTUAL_VG_FULL,min(size(ACTUAL_VG_FULL,1),max(1,AGC_interval_index + round(rpu_int*IRPU*(60/t_AGC)+IRPU*(60/t_AGC)/2)))),2:end)));
        end;
    elseif rtd_vg_data_create ==3%persistence RPU forecast
         vg_forecast_tmp = ones(HRPU,1)*max(0,ACTUAL_VG_FULL(max(1,AGC_interval_index-round(PRPU*60/t_AGC)-1),2:end));
    end;
end;

clear VG_FORECAST_VAL;
VG_FORECAST_VAL=zeros(HRPU,ngen);
i=1;
while(i<=ngen)
    w = 1;
    while(w<=nvg)
        if(strcmp(GEN_VAL(i,1),RTD_VG_FIELD(2+w))) && GENVALUE_VAL(i,gen_type) ~= outage_gen_type_index
            VG_FORECAST_VAL(1:HRPU,i) = vg_forecast_tmp(1:HRPU,w);
            w=nvg;
        elseif(w==nvg)            %gone through entire list of VG and gen is not included
            VG_FORECAST_VAL(1:HRPU,i) = zeros(HRPU,1);
        end;
        w = w+1;
    end;
    i = i+1;
end;
