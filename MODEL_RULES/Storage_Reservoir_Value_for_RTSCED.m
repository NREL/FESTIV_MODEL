%Storage value for RTD. Needs major corrections.
%
%Before RTSCED
%
%Storage value for RTD. 
%Basically, figure out the amount of money that the storage unit would
%receive in total dollars for the rest of the day including the end of the
%day. Then figure out that value in $/MWh
if Solving_Initial_Models
RTSCED_RESERVOIR_VALUE = zeros(ngen,1);
RTSCED_STORAGE_LEVEL = zeros(ngen,1);
for i=1:ngen
    if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index  
        RTSCED_STORAGE_LEVEL(i,1) = STORAGEVALUE_VAL(i,initial_storage);
        RTSCED_RESERVOIR_VALUE(i,1) = ((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
            floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))*SCUCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1)) ...
            +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))...
            *SCUCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))') + STORAGEVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))...
            + sum(SCUCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    elseif GENVALUE_VAL(i,gen_type) == LESR_gen_type_index || GENVALUE_VAL(i,gen_type) == CSP_gen_type_index
        RTSCED_RESERVOIR_VALUE(i,1) = GENVALUE_VAL(i,efficiency)*((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
            floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1)) ...
            +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))...
            *SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))') + STORAGEVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
            /((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))...
            + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
    else
        RTSCED_RESERVOIR_VALUE(i) = 0;
    end;
end;

%STORAGEVALUE_VAL(:,reservoir_value) = RTSCED_RESERVOIR_VALUE;
STORAGEVALUE_VAL(:,initial_storage) = RTSCED_STORAGE_LEVEL;
rtd_final_storage_time_index_up = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
rtd_final_storage_time_index_lo = floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
% STORAGEVALUE_VAL(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)' ...
%     + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC),1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_up),2:ngen+1)' ...
%     - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)');
% END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price
% END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price and possibly change to negative

ik=1;
while ik ~= size(RTSCUCSTORAGELEVEL2,1)
    if RTD_LOOKAHEAD_INTERVAL_VAL(end)+eps >= max(RTSCUCSTORAGELEVEL2(:,1))
        STORAGEVALUE_VAL(:,final_storage) = RTSCUCSTORAGELEVEL2(end,2:end)';
        ik=size(RTSCUCSTORAGELEVEL2,1)-1;
    elseif RTSCUCSTORAGELEVEL2(ik,1) > RTD_LOOKAHEAD_INTERVAL_VAL(end)+eps
        STORAGEVALUE_VAL(:,final_storage) = RTSCUCSTORAGELEVEL2(ik-1,2:ngen+1)' ...
            + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps,1).*(RTSCUCSTORAGELEVEL2(ik,2:ngen+1)' ...
            - RTSCUCSTORAGELEVEL2(ik-1,2:ngen+1)');
        ik=size(RTSCUCSTORAGELEVEL2,1)-1;
    end
    ik = ik + 1;
end
RTDFINALSTORAGEIN=[RTDFINALSTORAGEIN,STORAGEVALUE_VAL(:,final_storage)];
END_STORAGE_PENALTY_PLUS_PRICE.val  = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price
END_STORAGE_PENALTY_MINUS_PRICE.val = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price and possibly change to negative
else
        for i=1:ngen
            if GENVALUE_VAL(i,gen_type) == pumped_storage_gen_type_index || GENVALUE_VAL(i,gen_type) == ESR_gen_type_index  
                if AGC_interval_index > round(PRTD*60/t_AGC)
                    RTSCED_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index-round(PRTD*60/t_AGC),i+1)- (PRTD/60)*LAST_GEN_SCHEDULE_VAL(i,1) ...
                        + (PRTD/60)*LAST_PUMP_SCHEDULE_VAL(i,1)*STORAGEVALUE_VAL(i,efficiency); %only works for constant efficiency
                else
                    RTSCED_STORAGE_LEVEL(i,1) = ACTUAL_STORAGE_LEVEL(AGC_interval_index,i+1);
                end;
                if ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1) > size(DASCUCLMP,1)
                    RTSCED_RESERVOIR_VALUE(i,1) = SCUCSTORAGEVALUE.val(i,reservoir_value);
                else
                RTSCED_RESERVOIR_VALUE(i,1) = mean([SCUCSTORAGEVALUE.val(i,reservoir_value) mean(DASCUCLMP(ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1):end,GENBUS_CALCS_VAL(i,2)))]);
                end;
            elseif GENVALUE_VAL(i,gen_type) == LESR_gen_type_index || GENVALUE_VAL(i,gen_type) == CSP_gen_type_index
                RTSCED_RESERVOIR_VALUE(i,1) = GENVALUE_VAL(i,efficiency)*((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCLMP.val(GENBUS_CALCS_VAL(i,2),...
                    floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1)) ...
                    +(SCUCLMP.val(GENBUS_CALCS_VAL(i,2),ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))...
                    *SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC))') + STORAGEVALUE_VAL(i,reservoir_value)*SCUCSTORAGELEVEL.val(i,HDAC))...
                    /((1-mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)-eps,1))*SCUCNCGENSCHEDULE.val(i,floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1))...
                    + sum(SCUCNCGENSCHEDULE.val(i,ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)+1:HDAC)))+SCUCSTORAGELEVEL.val(i,HDAC));
            else
                RTSCED_RESERVOIR_VALUE(i) = 0;
            end;
        end;
        
        %STORAGEVALUE_VAL(:,reservoir_value) = RTSCED_RESERVOIR_VALUE;
        
        STORAGEVALUE_VAL(:,initial_storage) = RTSCED_STORAGE_LEVEL;
        rtd_final_storage_time_index_up = ceil(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
        rtd_final_storage_time_index_lo = floor(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps) + 1; 
        STORAGEVALUE_VAL(:,final_storage) = DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)' ...
            + mod(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD,1)*(1/IDAC)+eps,1).*(DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_up),2:ngen+1)' ...
            - DASCUCSTORAGELEVEL(min(size(DASCUCSTORAGELEVEL,1),rtd_final_storage_time_index_lo),2:ngen+1)');
        END_STORAGE_PENALTY_PLUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price
        END_STORAGE_PENALTY_MINUS_PRICE.val = PSHBIDCOST_VAL(min(size(PSHBIDCOST_VAL,1),rtd_final_storage_time_index_up),:);%turn to RTC price and possibly change to negative
        
        RTDFINALSTORAGEIN=[RTDFINALSTORAGEIN,STORAGEVALUE_VAL(:,final_storage)];
%         END_STORAGE_PENALTY_PLUS_PRICE.val  = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price
%         END_STORAGE_PENALTY_MINUS_PRICE.val = RTPSHBIDCOST_VAL(end,2:end);%turn to RTC price and possibly change to negative
end;