function [forecast] = windForecast(interval_length,advisory_interval_length,interval_update,ninterval,AGC_seconds,model_time,days,error,max_data,data_type,inputfilePath,genName,PathName)
%{
    NOTE: realized VG data must be made already (i.e. the 4s vg input sheets)

    INPUTS:
        interval_length - length of optimization interval (e.g. IRTC, etc.)
        advisory_interval_length - length of advisory interval (e.g. IRTC or IRTDADV)
        interval_update - model update frequency (e.g. tRTC or tRTD)
        ninterval - optimization horizon (e.g. HRTC or HRTD)
        AGC_seconds - AGC temporal resolution (e.g. 4 sec or 6 sec)
        model_time - time for model to solve (e.g. PRTC or PRTD)
        days - number of days being considered
        error - error used for forecast create mode 4
        max_data - capacities of generators being forecasted in a 1 x N vector
        data_type - forecast create mode (e.g. 2 - perfect, 3 - persistance 4 - distribution
        inputfilePath - path of input file (to read in actual data)
        genName - names of generators being forecasted in 1 x N cell vector (e.g. {'Wind1','Solar1','CT1',etc.})

    OUTPUTS:
        forecast - forecasted outputs of generators
%}

%% Input Data
% inputfilePath='C:\Users\ikrad\Documents\FESTIV\Input\WWSIS_a_DA_Core_SC4_SMUD_Updated_BaseCase_April16-22\WWSIS_a_DA_Core_SC4_SMUD_Updated_BaseCase_April16-22LOAD2.xlsx';
[~, actual_vg_input_file] = xlsread(inputfilePath,'ACTUAL_VG_REF','A2:A10');

% HRTC = 5; 
% IRTC = 5;
% tRTC = 5;
% PRTC = 15;
% t_AGC = 4; 
% simulation_days = 7;
% max_data=[358,1380]; % max capacity of wind turbine
% vg_data_create = 3;
% genName={'SMUD_Wind_37560_SC3','SMUD_Wind_37640_SC3'};
% %Note that these are the standard deviation based on the energy level
% %for example if value is .1, then forecast is actual + randn()*.1*actual
% vg_error = [0 0.05 0.05 0.06 0.07 0.08 0.08 0.08 0.1 0.1]';
nvg=size(max_data,1);

%% Forcast Inputs

ACTUAL_VG_FULL = [];
ACTUAL_VG_FIELD = [];
VG_FULL = [];
VG_FIELD = [];

% read in complete realized vg data
for d = 1:days
    if nvg > 0
        [ACTUAL_VG_FULL_TMP, ACTUAL_VG_FIELD] = xlsread(strcat(PathName,'TIMESERIES',filesep,cell2mat(actual_vg_input_file(d,1))),'Sheet1');
        ACTUAL_VG_FULL = [ACTUAL_VG_FULL; ACTUAL_VG_FULL_TMP];
    else
        ACTUAL_VG_FIELD = [];
        ACTUAL_VG_FULL = [];
    end;
end;

% extract realized data for the wind generators from the master wind data variable
temp=ACTUAL_VG_FULL(:,1);
for i=1:size(ACTUAL_VG_FIELD,2)
    for j=1:size(genName,1)
        if strcmp(ACTUAL_VG_FIELD(1,i),genName(j,1))
            temp=[temp ACTUAL_VG_FULL(:,i)];
        end    
    end
end
ACTUAL_VG_FULL=temp;

% create the appropriate forecast
if data_type == 1

elseif data_type == 2 || data_type == 3
    if nvg > 0
        forecast = forecast_creation(ACTUAL_VG_FULL,nvg,interval_length,advisory_interval_length,interval_update,ninterval,AGC_seconds,model_time,days,error,max_data,'RT',data_type);
%         VG_FIELD_VG = [' ' ACTUAL_VG_FIELD]; 
    end;

elseif data_type == 4
    if nvg > 0
        while size(vg_error,1) < ninterval
            vg_error = [vg_error; vg_error(size(vg_error,1),1)];
        end;
        vg_error = vg_error(1:ninterval,1);
        forecast = forecast_creation(ACTUAL_VG_FULL,nvg,interval_length,advisory_interval_length,interval_update,ninterval,AGC_seconds,model_time,days,error,max_data,data_type);
%         VG_FIELD_VG = [' ' ACTUAL_VG_FIELD]; 
    end;
end;

end