%Storage value for RTC. These need fixing. Copied from original code and
%need to be updated. Should esr index and not gen index.
%
%Before RTSCUC
%

%Basically, figure out the amount of money that the storage unit would
%receive in total dollars for the rest of the day including the end of the
%day. Then figure out that value in $/MWh
RTSCUC_RESERVOIR_VALUE = zeros(ngen,1);
RTSCUC_STORAGE_LEVEL = zeros(ngen,1);
if Solving_Initial_Models
for i=1:ngen
    if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index  
        RTSCUC_STORAGE_LEVEL(i,1) = SCUCSTORAGEVALUE.val(i,initial_storage);
        RTSCUC_RESERVOIR_VALUE(i,1) = ((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
            floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
            +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
            *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + STORAGEVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
            + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    elseif GENVALUE_VAL(i,gen_type) == LESR_gen_type_index || GENVALUE_VAL(i,gen_type) == CSP_gen_type_index
        RTSCUC_RESERVOIR_VALUE(i,1) = GENVALUE_VAL(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
            floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
            +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
            *SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + STORAGEVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
            + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    else
        RTSCUC_RESERVOIR_VALUE(i) = 0;
    end;
end;

%STORAGEVALUE_VAL(:,reservoir_value) = RTSCUC_RESERVOIR_VALUE;
STORAGEVALUE_VAL(:,initial_storage) = RTSCUC_STORAGE_LEVEL;
rtc_final_storage_time_index_up = ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
rtc_final_storage_time_index_lo = floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
% STORAGEVALUE_VAL(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)' ...
%     + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC),1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_up),2:ngen+1)' ...
%     - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)');

ik=1;
while ik ~= size(DASCUCSTORAGELEVEL,1)
    if RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(DASCUCSTORAGELEVEL(:,1))
        STORAGEVALUE_VAL(:,final_storage) = RTCFINALSTORAGEIN(:,end);
        ik=size(DASCUCSTORAGELEVEL,1)-1;
    elseif DASCUCSTORAGELEVEL(ik,1) > RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps
        STORAGEVALUE_VAL(:,final_storage) = DASCUCSTORAGELEVEL(ik-1,2:ngen+1)' ...
            + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(ik,2:ngen+1)' ...
            - DASCUCSTORAGELEVEL(ik-1,2:ngen+1)');
        ik=size(DASCUCSTORAGELEVEL,1)-1;
    end
    ik = ik + 1;
end
RTCFINALSTORAGEIN=[RTCFINALSTORAGEIN,STORAGEVALUE_VAL(:,final_storage)];

END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);
END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);

else
for i=1:ngen
    if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index  
        if AGC_interval_index > round(PRTC*60/t_AGC)
            RTSCUC_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRTC*60/t_AGC),i+1) - (PRTC/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                + (PRTC/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE_VAL(i,efficiency);
        else
            RTSCUC_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index,1+i);
        end;
        if ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1) > size(DASCUCLMP,1)
            RTSCUC_RESERVOIR_VALUE(i,1) = SCUCSTORAGEVALUE.val(i,reservoir_value);
        else
        RTSCUC_RESERVOIR_VALUE(i,1) = mean([SCUCSTORAGEVALUE.val(i,reservoir_value) mean(DASCUCLMP(ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1):end,GENBUS_CALCS_VAL(i,2)))]);
        %{
        RTSCUC_RESERVOIR_VALUE(i,1) = (GENVALUE_VAL(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
            floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
            +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
            *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))')) + GENVALUE_VAL(i,storage_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
            + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
        %}
        end;
    elseif GENVALUE_VAL(i,gen_type) == LESR_gen_type_index || GENVALUE_VAL(i,gen_type) == CSP_gen_type_index
        RTSCUC_RESERVOIR_VALUE(i,1) = GENVALUE_VAL(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
            floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
            +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
            *SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + GENVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
            + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    else
        RTSCUC_RESERVOIR_VALUE(i) = 0;
    end;
end;

%STORAGEVALUE_VAL(:,reservoir_value) = RTSCUC_RESERVOIR_VALUE;
STORAGEVALUE_VAL(:,initial_storage) = RTSCUC_STORAGE_LEVEL;
%         ela(RTSCUC_binding_interval_index,1) = RTSCUC_RESERVOIR_VALUE(end,1);
%         ela2(RTSCUC_binding_interval_index,1) = RTSCUC_STORAGE_LEVEL(end,1);
rtc_final_storage_time_index_up = ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
rtc_final_storage_time_index_lo = floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps) + 1; 
%         STORAGEVALUE_VAL(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)' ...
%             + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_up),2:ngen+1)' ...
%             - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtc_final_storage_time_index_lo),2:ngen+1)');

ik=1;
while ik ~= size(DASCUCSTORAGELEVEL,1)
    if RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(DASCUCSTORAGELEVEL(:,1))
        STORAGEVALUE_VAL(:,final_storage) = RTCFINALSTORAGEIN(:,end);
        ik=size(DASCUCSTORAGELEVEL,1)-1;
    elseif DASCUCSTORAGELEVEL(ik,1) > RTC_LOOKAHEAD_INTERVAL_VAL(end)+eps
        STORAGEVALUE_VAL(:,final_storage) = DASCUCSTORAGELEVEL(ik-1,2:ngen+1)' ...
            + mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(ik,2:ngen+1)' ...
            - DASCUCSTORAGELEVEL(ik-1,2:ngen+1)');
        ik=size(DASCUCSTORAGELEVEL,1)-1;
    end
    ik = ik + 1;
end        
END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);
END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtc_final_storage_time_index_up),:);

RTCFINALSTORAGEIN=[RTCFINALSTORAGEIN,STORAGEVALUE_VAL(:,final_storage)];       
end;

%This is for RPU, may be the same
%{
        %Storage value for RTC
        %Basically, figure out the amount of money that the storage unit would
        %receive in total dollars for the rest of the day including the end of the
        %day. Then figure out that value in $/MWh
        for i=1:ngen
            if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index 
                if AGC_interval_index > round(PRPU*60/t_AGC)+1
                    RPU_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRPU*60/t_AGC)-1,i+1) - (PRPU/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRPU/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE_VAL(i,efficiency);
                else
                    RPU_STORAGE_LEVEL(i,1) = STORAGEVALUE_VAL(i,initial_storage)- (PRPU/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRPU/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE_VAL(i,efficiency);
                end;
                if ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1) > size(DASCUCLMP,1)
                    RPU_RESERVOIR_VALUE(i,1) = SCUCSTORAGEVALUE.val(i,reservoir_value);
                else
                    RPU_RESERVOIR_VALUE(i,1) = mean([SCUCSTORAGEVALUE.val(i,reservoir_value) mean(DASCUCLMP(ceil(RPU_LOOKAHEAD_INTERVAL_VAL(HRPU,1)+1):end,GENBUS_CALCS_VAL(i,2)))]);
                %{
                RTSCUC_RESERVOIR_VALUE(i,1) = (GENVALUE_VAL(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))')) + GENVALUE_VAL(i,storage_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
                %}
                end;
            elseif GENVALUE_VAL(i,gen_type) == LESR_gen_type_index || GENVALUE_VAL(i,gen_type) == CSP_gen_type_index
                %TBD
                RPU_RESERVOIR_VALUE(i,1) = GENVALUE_VAL(i,efficiency)*((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
                    floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1)) ...
                    +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))...
                    *SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC))') + GENVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1))...
                    + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
            else
                RPU_RESERVOIR_VALUE(i,1) = 0;
                RPU_STORAGE_LEVEL(i,1)=0;
            end;
        end;
        
        STORAGEVALUE_VAL(:,reservoir_value) = RPU_RESERVOIR_VALUE;
        STORAGEVALUE_VAL(:,initial_storage) = RPU_STORAGE_LEVEL;
        rpu_final_storage_time_index_up = ceil(RPU_LOOKAHEAD_INTERVAL_VAL(HRPU,1)*(1/IDAC)+eps) + 1; 
        END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rpu_final_storage_time_index_up),:);
        END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rpu_final_storage_time_index_up),:);
%}