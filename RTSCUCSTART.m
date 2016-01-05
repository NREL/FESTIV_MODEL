
%Default mode
if RTSCUCSTART_MODE == 1 %RTSCUC
    RTSCUCSTART_YES = zeros(ngen,HRTC);
    RTSCUCSHUT_YES = zeros(ngen,HRTC);
    RTSCUCPUMPSTART_YES = zeros(ngen,HRTC);
    RTSCUCPUMPSHUT_YES = zeros(ngen,HRTC);
    for i2=1:ngen
        if GENVALUE.val(i2,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE.val(i2,gen_type) ~= 6 && GENVALUE.val(i2,gen_type) ~= 8 && GENVALUE.val(i2,gen_type) ~= 12))
            RTSCUCSTART_YES(i2,1:HRTC) = 1;
            RTSCUCSHUT_YES(i2,1:HRTC) = 1;
        else
            RTSCUCSTART_YES(i2,1:HRTC) = 0;
            RTSCUCSHUT_YES(i2,HRTC) = 0;
        end;
        if STORAGEVALUE.val(i2,pump_su_time) <= tRTCstart && Fix_RT_Pump == 0
            RTSCUCPUMPSTART_YES(i2,1:HRTC) = 1;
            RTSCUCPUMPSHUT_YES(i2,1:HRTC) = 1;
        else
            RTSCUCPUMPSTART_YES(i2,1:HRTC) = 0;
            RTSCUCPUMPSHUT_YES(i2,HRTC) = 0;
        end;
   end;
elseif RTSCUCSTART_MODE == 2 %RPU
    RTSCUCSTART_YES = zeros(ngen,HRPU);
    RTSCUCSHUT_YES = zeros(ngen,HRPU);
    RTSCUCPUMPSTART_YES = zeros(ngen,HRPU);
    RTSCUCPUMPSHUT_YES = zeros(ngen,HRPU);
    for i2=1:ngen
        if GENVALUE.val(i2,su_time) <= tRTCstart && (Fix_RT_Pump == 0 || (GENVALUE.val(i2,gen_type) ~= 6 && GENVALUE.val(i2,gen_type) ~= 8 && GENVALUE.val(i2,gen_type) ~= 12))
            RTSCUCSTART_YES(i2,1:HRPU) = 1;
            RTSCUCSHUT_YES(i2,1:HRPU) = 1;
        else
            if STATUS(lookahead_index-1,i2) == 1
                RTSCUCSTART_YES(i2,1:HRPU) = 1;
            else
                RTSCUCSTART_YES(i2,1:HRPU) = 0;
            end;
            RTSCUCSHUT_YES(i2,1:HRPU) = 0;
        end;
        if STORAGEVALUE.val(i2,pump_su_time) <= tRTCstart && Fix_RT_Pump == 0
            RTSCUCPUMPSTART_YES(i2,1:HRPU) = 1;
            RTSCUCPUMPSHUT_YES(i2,1:HRPU) = 1;
        else
            RTSCUCPUMPSTART_YES(i2,1:HRPU) = 0;
            RTSCUCPUMPSHUT_YES(i2,HRPU) = 0;
        end;
    end;
end;
