%% Forcast Inputs

ACTUAL_LOAD_FULL = [];
ACTUAL_VG_FULL = [];
ACTUAL_VG_FIELD = [];

%Retrieve actual load and actual vg through timeseries.
if useHDF5==0
    for d = 1:simulation_days
        ACTUAL_LOAD_FULL_TMP = xlsread(cell2mat(actual_load_input_file(d,1)),'Sheet1','A1:B30000');
        actual_load_multiplier_tmp = zeros(size(ACTUAL_LOAD_FULL_TMP));
        actual_load_multiplier_tmp(:,1) = d-1;
        ACTUAL_LOAD_FULL_TMP = ACTUAL_LOAD_FULL_TMP + actual_load_multiplier_tmp;
        ACTUAL_LOAD_FULL = [ACTUAL_LOAD_FULL; ACTUAL_LOAD_FULL_TMP];
        if nvg > 0
            [ACTUAL_VG_FULL_TMP, ACTUAL_VG_FIELD] = xlsread(cell2mat(actual_vg_input_file(d,1)),'Sheet1');
            actual_vg_multiplier_tmp = zeros(size(ACTUAL_VG_FULL_TMP));
            actual_vg_multiplier_tmp(:,1) = d-1;
            ACTUAL_VG_FULL_TMP = ACTUAL_VG_FULL_TMP + actual_vg_multiplier_tmp;
            ACTUAL_VG_FULL = [ACTUAL_VG_FULL; ACTUAL_VG_FULL_TMP];
        else
            ACTUAL_VG_FIELD = [];
            ACTUAL_VG_FULL = [];
        end;
    end;
end

if useHDF5 == 1
    CREATE_HDF5_FORECAST_DATA
end

%Declare tAGC
t_AGC=round((ACTUAL_LOAD_FULL(2,1)-ACTUAL_LOAD_FULL(1,1))*60*60*24);

ACTUAL_VG_FULL(:,3:end)=ACTUAL_VG_FULL(:,3:end);
for w=1:nvg
    i = 1;
    while(i<=ngen)
        if(strcmp(GEN_VAL(i,1),ACTUAL_VG_FIELD(1,1+w,1)))
            max_data(w,1) = GENVALUE_VAL(i,capacity); %To make sure that any forecasts are not higher than the max capacity.
            i=ngen;
        end;
        i=i+1;
    end;
end;

if nvg==0
    max_data=0;
end


% Create Interchange forecasts if necessary
DEFINE_INTERCHANGES

% Create DASCUC load,vg,and reserve forecasts
[DAC_LOAD_FULL,DAC_VG_FULL,DAC_VG_FIELD,DAC_RESERVE_FULL,DAC_RESERVE_FIELD]=forecastInputs('DAC',dac_load_data_create,simulation_days,dac_load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,IDAC,tDAC,HDAC,t_AGC,PDAC,dac_load_error,nvcr,nvg,dac_vg_data_create,dac_vg_input_file,max_data,ACTUAL_VG_FIELD,dac_vg_error,IDAC,DAC_RESERVE_FORECAST_MODE,IDAC,eps,nreserve,0,0,dac_reserve_input_file,RESERVETYPE.uels);

% Create RTSCUC load,vg,and reserve forecasts
[RTC_LOAD_FULL,RTC_VG_FULL,RTC_VG_FIELD,RTC_RESERVE_FULL,RTC_RESERVE_FIELD]=forecastInputs('RTC',rtc_load_data_create,simulation_days,rtc_load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,IRTC,tRTC,HRTC,t_AGC,PRTC,rtc_load_error,nvcr,nvg,rtc_vg_data_create,rtc_vg_input_file,max_data,ACTUAL_VG_FIELD,rtc_vg_error,IRTC,RTC_RESERVE_FORECAST_MODE,IDAC,eps,nreserve,DAC_RESERVE_FULL,DAC_RESERVE_FIELD,rtc_reserve_input_file,RESERVETYPE.uels);

% Create RTSCED load,vg,and reserve forecasts
[RTD_LOAD_FULL,RTD_VG_FULL,RTD_VG_FIELD,RTD_RESERVE_FULL,RTD_RESERVE_FIELD]=forecastInputs('RTD',rtd_load_data_create,simulation_days,rtd_load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,IRTD,tRTD,HRTD,t_AGC,PRTD,rtd_load_error,nvcr,nvg,rtd_vg_data_create,rtd_vg_input_file,max_data,ACTUAL_VG_FIELD,rtd_vg_error,IRTDADV,RTD_RESERVE_FORECAST_MODE,IDAC,eps,nreserve,DAC_RESERVE_FULL,DAC_RESERVE_FIELD,rtd_reserve_input_file,RESERVETYPE.uels);

DAC_VG_FULL(DAC_VG_FULL<eps)=0;
RTC_VG_FULL(RTC_VG_FULL<eps)=0;
RTD_VG_FULL(RTD_VG_FULL<eps)=0;
DAC_VG_FULL(:,1:2)=DAC_LOAD_FULL(:,1:2); 

