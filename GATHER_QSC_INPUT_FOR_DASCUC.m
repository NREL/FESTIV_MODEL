QSC_VAL=zeros(ngen,nreserve);
for rr=1:nreserve
    if RESERVEVALUE_VAL(rr,res_on)==0
        qsc_idx=60*GENVALUE_VAL(:,su_time)<=RESERVEVALUE_VAL(rr,res_time);
        QSC_VAL(qsc_idx,rr)=min(GENVALUE_VAL(qsc_idx,capacity),GENVALUE_VAL(qsc_idx,min_gen)+GENVALUE_VAL(qsc_idx,ramp_rate).*(repmat(RESERVEVALUE_VAL(rr,res_time),size(find(qsc_idx)))-60*GENVALUE_VAL(qsc_idx,su_time)));
    end
end
