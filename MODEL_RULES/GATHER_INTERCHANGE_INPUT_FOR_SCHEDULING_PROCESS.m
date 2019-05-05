%
%Before DASCUC, RTSCUC, or RTSCED
%

if dascuc_running
    H=HDAC;
    INTERCHANGE_FULL = DAC_INTERCHANGE_FULL;
    interval_index = DASCUC_binding_interval_index;
    INTERCHANGE_FIELD=DAC_INTERCHANGE_FIELD;
elseif rtscuc_running
    H=HRTC;
    INTERCHANGE_FULL = RTC_INTERCHANGE_FULL;
    interval_index = RTSCUC_binding_interval_index;
    INTERCHANGE_FIELD=RTC_INTERCHANGE_FIELD;
elseif rtsced_running
    H=HRTD;
    INTERCHANGE_FULL = RTD_INTERCHANGE_FULL;
    interval_index = RTSCED_binding_interval_index;
    INTERCHANGE_FIELD=RTD_INTERCHANGE_FIELD;
end

INTERCHANGE_VAL(:,:)=INTERCHANGE_FULL(H*(interval_index-1)+1:H*(interval_index-1)+H,3:end);

INTERCHANGE.val = INTERCHANGE_VAL;
INTERCHANGE.uels = {INTERVAL.uels INTERCHANGE_FIELD(1,3:end)};
INTERCHANGE.name = 'INTERCHANGE';
INTERCHANGE.form = 'full';
INTERCHANGE.type = 'parameter';

%per_unitize
INTERCHANGE.val=INTERCHANGE.val./SYSTEMVALUE_VAL(mva_pu);

wgdx(['TEMP', filesep, 'INTERCHANGE_INPUT'],INTERCHANGE);