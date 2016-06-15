%{
Before DASCUC or potentially RTSCUC
%}

DROOP_EQ.name='DROOP_EQ';
DROOP_EQ.form='full';
DROOP_EQ.type='parameter';
DROOP_EQ.uels={GEN_VAL'};
DROOP_EQ.val=zeros(ngen,1);
temp_idx=GENVALUE.val(:,droop) > 0 & GENVALUE.val(:,capacity) > 0;
DROOP_EQ.val(temp_idx,1)=GENVALUE.val(temp_idx,droop).*SYSTEMVALUE.val(frequency,1)./GENVALUE.val(temp_idx,capacity);

gens_with_govs=GEN_VAL(GENVALUE.val(:,droop)>0);
PFR_MULTIPLIER.name='PFR_MULTIPLIER';
PFR_MULTIPLIER.form='full';
PFR_MULTIPLIER.type='parameter';
PFR_MULTIPLIER.uels={gens_with_govs' INTERVAL.uels RESERVETYPE_VAL'};
PFR_MULTIPLIER.val=zeros(size(gens_with_govs,1),HDAC,nreserve);
for rr=1:nreserve
    if RESERVEVALUE.val(rr,res_gov) > 1 - eps
        PFR_MULTIPLIER.val(gens_with_govs,:,rr)=1;
    end
end

DAMPING_MULTIPLIER.name='DAMPING_MULTIPLIER';
DAMPING_MULTIPLIER.form='full';
DAMPING_MULTIPLIER.type='parameter';
DAMPING_MULTIPLIER.uels={INTERVAL.uels RESERVETYPE_VAL'};
DAMPING_MULTIPLIER.val=zeros(HDAC,nreserve);
res_with_govs=RESERVEVALUE.val(:,res_gov)>1-eps;
DAMPING_MULTIPLIER.val(:,res_with_govs)=1;

wgdx(['TEMP', filesep, 'pfrinput'],PFR_MULTIPLIER,DAMPING_MULTIPLIER,DROOP_EQ);