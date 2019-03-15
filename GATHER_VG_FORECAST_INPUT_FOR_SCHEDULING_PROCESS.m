function [VG_FORECAST_VAL]=Gather_VG_FORECAST_Input_for_Scheduling_Process(VG_FULL,VG_FIELD,interval_index,H,GEN_VAL,GENVALUE_VAL,ngen,nvcr)

global gen_type outage_gen_type_index

Field_size = size(VG_FIELD,2)-2;

if nvcr > 0
    vg_forecast_tmp=VG_FULL(H*(interval_index-1)+1:H*(interval_index-1)+H,3:end);
else
    vg_forecast_tmp = zeros(H,1);
end;

VG_FORECAST_VAL=zeros(H,ngen);
i =1;
if nvcr>0
while(i<=ngen)
    w = 1;
    while(w<=Field_size)
        if(strcmp(GEN_VAL(i,1),VG_FIELD(2+w))) && GENVALUE_VAL(i,gen_type) ~= outage_gen_type_index
            VG_FORECAST_VAL(1:H,i) = vg_forecast_tmp(1:H,w);
            w=Field_size;
        elseif(w==Field_size)        %gone through entire list of VG and gen is not included
            VG_FORECAST_VAL(1:H,i) = zeros(H,1);
        end;
        w = w+1;
    end;
    i = i+1;
end;
end;

