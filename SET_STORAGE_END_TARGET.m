essidx=find(GENVALUE_VAL(:,gen_type)==6 | GENVALUE_VAL(:,gen_type)==8);
% GENVALUE_VAL(essidx,gen_type)=6;
% DEFAULT_DATA.GENVALUE.val(essidx,gen_type)=6;
if ~isempty(essidx)
    td=0:IDAC:daystosimulate*24-IDAC;
    if Solving_Initial_Models==1
        tmp_t=interpolateData(td',daystosimulate,IRTD*60,IDAC*60);
        tmp_level=zeros(size(tmp_t,1),nESR);
    end

    rang=(DASCUC_binding_interval_index-2)*1/IDAC*24*(IDAC*60/IRTD)+1:(DASCUC_binding_interval_index-1)*1/IDAC*24*(IDAC*60/IRTD);
    rang2=(DASCUC_binding_interval_index-2)*1/IDAC*24+1:(DASCUC_binding_interval_index-1)*1/IDAC*24;

    for i=1:nESR
    %     tmp=DASCUCSTORAGELEVEL(rang2,2:end);
        tmp_level(:,i)=interpolateData(DASCUCSTORAGELEVEL(:,i+1),daystosimulate,IRTD*60,IDAC*60);
    end



    % Enforce DA charge/discharge mode only, Carry over charge/discharge from DA with HRTD=12
    if rtscuc_running
        idx=find(abs(RTC_LOOKAHEAD_INTERVAL_VAL(HRTC)-tmp_t)<eps);
    else
        idx=find(abs(RTD_LOOKAHEAD_INTERVAL_VAL(HRTD)-tmp_t)<eps);
    end
    if isempty(idx)
        idx=size(tmp_t,1);
    end
    STORAGEVALUE_VAL(:,final_storage)=tmp_level(idx,:);
end