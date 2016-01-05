function [LOAD_FULL,VG_FULL,VG_FIELD,RESERVE_FULL,RESERVE_FIELD]=forecastInputs(model,load_data_create,simulation_days,load_input_file,ACTUAL_VG_FULL,ACTUAL_LOAD_FULL,I,t,H,t_AGC,P,load_error,nvcr,nvg,vg_data_create,vg_input_file,max_data,ACTUAL_VG_FIELD,vg_error,I2,RESERVE_FORECAST_MODE,IDAC,eps,nreserve,DAC_RESERVE_FULL,DAC_RESERVE_FIELD,reserve_input_file,RESERVETYPES)

LOAD_FULL = [];
VG_FULL = [];
VG_FIELD = [];
RESERVE_FULL = [];
useHDF5=evalin('caller','useHDF5');

% Determine model being forecasted
if strcmp(model,'DAC')
    model2='DA';
else
    model2='RT';
end

%Retrieve load from timeseries or other means.
if load_data_create == 1
    if useHDF5 == 0
        for d = 1:simulation_days
    %         if strcmp(model,'DAC')
                LOAD_FULL_TMP = xlsread(cell2mat(load_input_file(d,1)),'Sheet1');
                if strcmp(model2,'RT')
                    load_multiplier_tmp = zeros(size(LOAD_FULL_TMP));
                    load_multiplier_tmp(:,1:2) = d-1;
                    LOAD_FULL_TMP = LOAD_FULL_TMP + load_multiplier_tmp;
                end
                LOAD_FULL = [LOAD_FULL; LOAD_FULL_TMP];
    %         end
        end;
    else
        LOAD_FULL=evalin('caller',sprintf('%s_LOAD_FULL',model));
    end
elseif load_data_create == 2 || load_data_create == 3
    if strcmp(model,'DAC')
        LOAD_FULL = forecast_creation(ACTUAL_LOAD_FULL,1,I*60,I*60,t*60,H,t_AGC,P*60,simulation_days,0,inf,'DA',load_data_create);
    else
        LOAD_FULL = forecast_creation(ACTUAL_LOAD_FULL,1,I,I2,t,H,t_AGC,P,simulation_days,0,inf,'RT',load_data_create);
    end
elseif load_data_create == 4
    while size(load_error,1) < H
        load_error = [load_error; load_error(size(load_error,1),1)];
    end;
    load_error = load_error(1:H,1);
    if strcmp(model,'DAC')
        LOAD_FULL = forecast_creation(ACTUAL_LOAD_FULL,1,I*60,I*60,t*60,H,t_AGC,P*60,simulation_days,load_error,inf,'DA',load_data_create);
    else
        LOAD_FULL = forecast_creation(ACTUAL_LOAD_FULL,1,I,I,t,H,t_AGC,P,simulation_days,load_error,inf,'RT',load_data_create);
    end
end;

%Retrieve vg from timeseries or other means.
if nvcr > 0
    if vg_data_create == 1
        if useHDF5 == 0
            for d=1:simulation_days
    %             if strcmp(model,'DAC')
                    [VG_FULL_TMP, VG_FIELD] = xlsread(cell2mat(vg_input_file(d,1)),'Sheet1');
                    if strcmp(model2,'RT')
                        vg_multiplier_tmp = zeros(size(VG_FULL_TMP));
                        vg_multiplier_tmp(:,1:2) = d-1;
                        VG_FULL_TMP = VG_FULL_TMP + vg_multiplier_tmp;
                    end
                    VG_FULL = [VG_FULL; VG_FULL_TMP];
    %             end
            end
        else
            VG_FULL=evalin('caller',sprintf('%s_VG_FULL',model));
            VG_FIELD=evalin('caller',sprintf('%s_VG_FIELD',model));
        end;
    elseif vg_data_create == 2 || vg_data_create == 3
        size_of_initial_input_read= 1;
        if nvcr > nvg
            for d=1:simulation_days
                [VG_FULL_TMP, VG_FIELD] = xlsread(cell2mat(vg_input_file(d,1)),'Sheet1');
                if strcmp(model2,'RT')
                    vg_multiplier_tmp = zeros(size(VG_FULL_TMP));
                    vg_multiplier_tmp(:,1:2) = d-1;
                    VG_FULL_TMP = VG_FULL_TMP + vg_multiplier_tmp;
                end
                VG_FULL = [VG_FULL; VG_FULL_TMP];
            end;
            size_of_initial_input_read = size(VG_FULL,2)-2;
        end;
        if nvg > 0
            if strcmp(model,'DAC')
                VG_FULL_VG = forecast_creation(ACTUAL_VG_FULL,nvg,I*60,I*60,t*60,H,t_AGC,P*60,simulation_days,0,max_data,'DA',vg_data_create);
            else
                VG_FULL_VG = forecast_creation(ACTUAL_VG_FULL,nvg,I,I2,t,H,t_AGC,P,simulation_days,0,max_data,'RT',vg_data_create);
            end
            VG_FIELD_VG = [' ' ACTUAL_VG_FIELD];
            if nvcr>nvg
                for w=1:nvg
                    w2=1;
                    while w2<=size_of_initial_input_read
                        if(strcmp(VG_FIELD_VG(1,2+w),VG_FIELD(1,2+w2)))
                            VG_FULL(:,w2+2) = VG_FULL_VG(:,w+2);
                            w2=size_of_initial_input_read;
                        elseif(w2==size_of_initial_input_read)
                            VG_FULL = [VG_FULL VG_FULL_VG(:,w+2)];
                            VG_FIELD = [VG_FIELD VG_FIELD_VG(1,2+w)];
                        end;
                        w2 = w2+1;
                    end;
                end;
            else
                VG_FULL = VG_FULL_VG;
                VG_FIELD = VG_FIELD_VG;
            end;
        end;

    elseif vg_data_create == 4
        size_of_initial_input_read= 1;
        if nvcr > nvg
            for d=1:simulation_days
%                 if strcmp(model,'DAC')
                    [VG_FULL_TMP, VG_FIELD] = xlsread(cell2mat(vg_input_file(d,1)),'Sheet1');
                    if strcmp(model2,'RT')
                        vg_multiplier_tmp = zeros(size(VG_FULL_TMP));
                        vg_multiplier_tmp(:,1:2) = d-1;
                        VG_FULL_TMP = VG_FULL_TMP + vg_multiplier_tmp;
                    end
                    VG_FULL = [VG_FULL; VG_FULL_TMP];
%                 end
            end;
            size_of_initial_input_read = size(VG_FULL,2)-2;
        end;
        if nvg > 0
            while size(vg_error,1) < H
                vg_error = [vg_error; vg_error(size(vg_error,1),1)];
            end;
            vg_error = vg_error(1:H,1);
            if strcmp(model,'DAC')
                VG_FULL_VG = forecast_creation(ACTUAL_VG_FULL,nvg,I*60,I*60,t*60,H,t_AGC,P*60,simulation_days,vg_error,max_data,'DA',vg_data_create);
            else
                VG_FULL_VG = forecast_creation(ACTUAL_VG_FULL,nvg,I,I,t,H,t_AGC,P,simulation_days,vg_error,max_data,'RT',vg_data_create);
            end
            VG_FIELD_VG = [' ' ACTUAL_VG_FIELD];
            if nvcr>nvg
                for w=1:nvg
                    w2=1;
                    while w2<=size_of_initial_input_read
                        if(strcmp(VG_FIELD_VG(1,2+w),VG_FIELD(1,2+w2)))
                            VG_FULL(:,w2+2) = VG_FULL_VG(:,w+2);
                            w2=size_of_initial_input_read;
                        elseif(w2==size_of_initial_input_read)
                            VG_FULL = [VG_FULL VG_FULL_VG(:,w+2)];
                            VG_FIELD = [VG_FIELD VG_FIELD_VG(1,2+w)];
                        end;
                        w2 = w2+1;
                    end;
                end;
            else
                VG_FULL = VG_FULL_VG;
                VG_FIELD = VG_FIELD_VG;
            end;
        end;
    end;
else
    VG_FULL = [];
    VG_FIELD = '';
end;

if strcmp(model,'DAC')
try
    if RESERVE_FORECAST_MODE == 2
        if useHDF5 == 0
            for d = 1:simulation_days
                [DAC_RESERVE_FULL_TMP,RESERVE_FIELD] = xlsread(cell2mat(reserve_input_file(d,1)),'Sheet1');
                RESERVE_FULL = [RESERVE_FULL; DAC_RESERVE_FULL_TMP];
            end;
        else
            RESERVE_FULL=evalin('caller',sprintf('%s_RESERVE_FULL',model));
        end
    else
        RESERVE_FULL = zeros(24/t*H*simulation_days,nreserve+2);
        for d=1:simulation_days*round(24/t)
            RESERVE_FULL((d-1)*H+1:d*H,1) = d;
            RESERVE_FULL((d-1)*H+1:d*H,2) = (0:I:H*I-I)';
        end;
        RESERVE_FIELD = [' ' ' ' RESERVETYPES];
    end;
    RESERVE_FIELD = [' ' ' ' RESERVETYPES];
catch
    RESERVE_FULL = zeros(24/t*H*simulation_days,nreserve+2);
    for d=1:simulation_days*round(24/t)
        RESERVE_FULL((d-1)*H+1:d*H,1) = d;
        RESERVE_FULL((d-1)*H+1:d*H,2) = (0:I:H*I-I)';
    end;
    RESERVE_FIELD = [' ' ' ' RESERVETYPES];
end;
else
    if RESERVE_FORECAST_MODE == 1
        RESERVE_FULL(:,1:2) = LOAD_FULL(:,1:2);
        for t=1:size(RESERVE_FULL,1)
            lookahead_index = floor(24*RESERVE_FULL(t,2)*(1/IDAC)+eps) + 1;      %Because hour 0 is index 1
            RESERVE_FULL(t,3:nreserve+2) = DAC_RESERVE_FULL(min(size(DAC_RESERVE_FULL,1),lookahead_index),3:nreserve+2);
        end;
        RESERVE_FIELD = DAC_RESERVE_FIELD;
    elseif RESERVE_FORECAST_MODE == 2
        if useHDF5 == 0
            for d = 1:simulation_days
                [RESERVE_FULL_TMP,RESERVE_FIELD] = xlsread(cell2mat(reserve_input_file(d,1)),'Sheet1');
                load_multiplier_tmp = zeros(size(RESERVE_FULL_TMP));
                load_multiplier_tmp(:,1:2) = d-1;
                RESERVE_FULL_TMP = RESERVE_FULL_TMP + load_multiplier_tmp;
                RESERVE_FULL = [RESERVE_FULL; RESERVE_FULL_TMP];
            end;
        else
            RESERVE_FULL=evalin('caller',sprintf('%s_RESERVE_FULL',model));
            RESERVE_FIELD=evalin('caller',sprintf('DAC_RESERVE_FIELD'));
        end
    end;
end

end % end function
